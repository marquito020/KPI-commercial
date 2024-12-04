const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = 4000;

// Configuración de conexión a PostgreSQL
const pool = new Pool({
    user: 'admin',
    host: 'postgres',
    database: 'kpi_db',
    password: 'adminpassword',
    port: 5432
});

// Servir el archivo HTML desde la raíz
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Endpoint para KPI Status Distribution
app.get('/api/kpi-status', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT status, COUNT(*) AS count
            FROM kpis
            GROUP BY status
        `);

        const labels = [];
        const values = [];

        result.rows.forEach(row => {
            labels.push(row.status);
            values.push(parseInt(row.count, 10));
        });

        res.json({ labels, values });
    } catch (error) {
        console.error('Error fetching KPI data:', error);
        res.status(500).send('Error fetching KPI data');
    }
});

// Endpoint para ventas por categoría
app.get('/api/sales-by-category', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT s.category, SUM(sa.total_sales) AS total_sales
            FROM sales sa
            JOIN stores s ON sa.store_id = s.store_id
            GROUP BY s.category
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching sales by category:', error);
        res.status(500).send('Error fetching sales by category');
    }
});

// Endpoint para visitas por día
app.get('/api/visits-by-date', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT visit_date, SUM(total_visits) AS total_visits, SUM(unique_visits) AS unique_visits
            FROM visits
            GROUP BY visit_date
            ORDER BY visit_date
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching visits by date:', error);
        res.status(500).send('Error fetching visits by date');
    }
});

// Endpoint para alertas por nivel
app.get('/api/alerts-by-level', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT alert_level, COUNT(*) AS count
            FROM alerts
            WHERE resolved = FALSE
            GROUP BY alert_level
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching alerts by level:', error);
        res.status(500).send('Error fetching alerts by level');
    }
});

// Endpoint para rendimiento de KPIs
app.get('/api/kpi-performance', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT name, target_value, actual_value
            FROM kpis
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching KPI performance:', error);
        res.status(500).send('Error fetching KPI performance');
    }
});

app.get('/api/alerts-by-level', async (req, res) => {
    const result = await pool.query(`
        SELECT alert_level, COUNT(*) AS count
        FROM alerts
        WHERE resolved = FALSE
        GROUP BY alert_level
    `);
    res.json(result.rows);
});

// Endpoint para calcular la tasa de conversión
app.get('/api/conversion-rate', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                v.visit_date, 
                COALESCE(SUM(s.total_sales), 0) AS total_sales,
                SUM(v.total_visits) AS total_visits,
                CASE 
                    WHEN SUM(v.total_visits) = 0 THEN 0
                    ELSE (COALESCE(SUM(s.total_sales), 0) / SUM(v.total_visits)) * 100
                END AS conversion_rate
            FROM visits v
            LEFT JOIN sales s ON v.visit_date = s.sale_date
            GROUP BY v.visit_date
            ORDER BY v.visit_date
        `);

        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching conversion rate:', error);
        res.status(500).send('Error fetching conversion rate');
    }
});

app.get('/api/ipc', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                u.name AS user_name, -- Agregar el nombre del usuario
                p.user_id,
                (AVG(p.price) / COALESCE((SELECT AVG(price) 
                                          FROM purchases 
                                          WHERE purchases.product_id = ANY(ARRAY_AGG(p.product_id))), 1)) AS Pc,
                COUNT(i.interaction_id) AS Fc,
                (AVG(p.rating) / COALESCE((SELECT AVG(rating) 
                                           FROM purchases 
                                           WHERE purchases.product_id = ANY(ARRAY_AGG(p.product_id))), 1)) AS Qc,
                COUNT(p.purchase_id) AS Tc,
                ((AVG(p.price) / COALESCE((SELECT AVG(price) 
                                           FROM purchases 
                                           WHERE purchases.product_id = ANY(ARRAY_AGG(p.product_id))), 1)) *
                 COUNT(i.interaction_id) *
                 (AVG(p.rating) / COALESCE((SELECT AVG(rating) 
                                            FROM purchases 
                                            WHERE purchases.product_id = ANY(ARRAY_AGG(p.product_id))), 1))) /
                COUNT(p.purchase_id) AS IPC
            FROM purchases p
            LEFT JOIN user_interactions i ON p.user_id = i.user_id
            INNER JOIN users u ON p.user_id = u.user_id -- Relacionar con la tabla users
            GROUP BY p.user_id, u.name -- Agrupar por user_id y nombre
            ORDER BY IPC DESC;
        `);

        res.json(result.rows);
    } catch (error) {
        console.error('Error calculating IPC:', error);
        res.status(500).send('Error calculating IPC');
    }
});


// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
