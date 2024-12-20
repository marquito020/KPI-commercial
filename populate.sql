-- Habilitar extensión para generar valores aleatorios en textos y números
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Crear tabla para registrar migraciones (si no existe)
CREATE TABLE IF NOT EXISTS migration_logs (
    migration_name VARCHAR(255) PRIMARY KEY,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verificar si los datos iniciales ya fueron poblados
DO $$
DECLARE
    first_names TEXT[] := ARRAY['Juan', 'María', 'Carlos', 'Ana', 'Luis', 'Sofía', 'Jorge', 'Isabel', 'Pedro', 'Elena'];
    last_names TEXT[] := ARRAY['Gómez', 'Pérez', 'Rodríguez', 'López', 'Martínez', 'García', 'Hernández', 'Sánchez', 'Ramírez', 'Flores'];
    first_name TEXT;
    last_name TEXT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM migration_logs WHERE migration_name = 'populate_initial_data') THEN
        -- Poblar la tabla `users` con nombres aleatorios
        FOR i IN 1..500 LOOP
            first_name := first_names[FLOOR(random() * array_length(first_names, 1) + 1)];
            last_name := last_names[FLOOR(random() * array_length(last_names, 1) + 1)];
            INSERT INTO users (name, email, password_hash, role, created_at, updated_at)
            VALUES (
                first_name || ' ' || last_name, -- Nombre generado aleatoriamente
                LOWER(first_name || '.' || last_name || i || '@example.com'), -- Email basado en el nombre
                gen_random_uuid()::TEXT, -- Simula un hash aleatorio para la contraseña
                CAST(CASE WHEN i % 3 = 0 THEN 'admin' 
                          WHEN i % 3 = 1 THEN 'manager' 
                          ELSE 'analyst' END AS role_type),
                NOW() - (i * INTERVAL '1 day'), 
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `stores`
        FOR i IN 1..100 LOOP
            INSERT INTO stores (name, category, floor, owner_name, contact_email, created_at, updated_at)
            VALUES (
                'Store ' || i, 
                CAST(CASE WHEN i % 3 = 0 THEN 'retail' 
                          WHEN i % 3 = 1 THEN 'food' 
                          ELSE 'service' END AS category_type),
                (i % 5) + 1, 
                'Owner ' || i, 
                'store' || i || '@example.com', 
                NOW() - (i * INTERVAL '2 days'), 
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `kpis`
        FOR i IN 1..50 LOOP
            INSERT INTO kpis (name, description, target_value, actual_value, unit, status, created_at, updated_at)
            VALUES (
                'KPI ' || i, 
                'Description for KPI ' || i, 
                TRUNC(random() * 1000 * 100) / 100, -- Redondeo a dos decimales
                TRUNC(random() * 1000 * 100) / 100, -- Redondeo a dos decimales
                CASE WHEN i % 2 = 0 THEN '%' ELSE '$' END,
                CAST(CASE WHEN i % 3 = 0 THEN 'on_track' 
                          WHEN i % 3 = 1 THEN 'at_risk' 
                          ELSE 'off_track' END AS status_type),
                NOW() - (i * INTERVAL '1 day'), 
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `purchases`
        FOR i IN 1..1000 LOOP
            INSERT INTO purchases (user_id, product_id, price, quantity, rating, purchase_date)
            VALUES (
                (i % 500) + 1, -- IDs de usuarios entre 1 y 500
                (i % 100) + 1, -- IDs de productos entre 1 y 100
                TRUNC(random() * 500 * 100) / 100, -- Precios entre 0 y 500
                (random() * 5)::INT + 1, -- Cantidades entre 1 y 5
                TRUNC(random() * 5 * 100) / 100, -- Calificación entre 0 y 5
                NOW() - (i * INTERVAL '1 hour')
            );
        END LOOP;

        -- Poblar la tabla `user_interactions`
        FOR i IN 1..2000 LOOP
            INSERT INTO user_interactions (user_id, interaction_type, interaction_date)
            VALUES (
                (i % 500) + 1, -- IDs de usuarios entre 1 y 500
                CASE WHEN i % 3 = 0 THEN 'click' 
                     WHEN i % 3 = 1 THEN 'view' 
                     ELSE 'purchase' END, -- Tipos de interacción
                NOW() - (i * INTERVAL '30 minutes')
            );
        END LOOP;

        -- Poblar la tabla `sales`
        FOR i IN 1..1000 LOOP
            INSERT INTO sales (store_id, sale_date, total_sales, total_customers, created_at)
            VALUES (
                (i % 100) + 1, -- IDs de tiendas entre 1 y 100
                NOW() - (i * INTERVAL '1 hour'),
                TRUNC(random() * 10000 * 100) / 100, -- Redondeo a dos decimales
                (random() * 100)::INT, -- Clientes entre 0 y 100
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `visits`
        FOR i IN 1..1000 LOOP
            INSERT INTO visits (visit_date, total_visits, unique_visits, peak_hour, created_at)
            VALUES (
                NOW()::DATE - (i % 30), -- Últimos 30 días
                (random() * 5000)::INT, -- Visitas totales entre 0 y 5000
                (random() * 4000)::INT, -- Visitas únicas entre 0 y 4000
                TIME '08:00:00' + (i % 12) * INTERVAL '1 hour', -- Hora pico
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `alerts`
        FOR i IN 1..200 LOOP
            INSERT INTO alerts (kpi_id, message, alert_level, resolved, created_at)
            VALUES (
                (i % 50) + 1, -- IDs de KPIs entre 1 y 50
                'Alert message for KPI ' || (i % 50) + 1,
                CAST(CASE WHEN i % 3 = 0 THEN 'low' 
                          WHEN i % 3 = 1 THEN 'medium' 
                          ELSE 'high' END AS alert_level_type),
                i % 2 = 0, -- Resuelta o no
                NOW() - (i * INTERVAL '3 hours')
            );
        END LOOP;

        -- Poblar la tabla `dashboards`
        FOR i IN 1..100 LOOP
            INSERT INTO dashboards (user_id, name, created_at, updated_at)
            VALUES (
                (i % 500) + 1, -- IDs de usuarios entre 1 y 500
                'Dashboard ' || i,
                NOW() - (i * INTERVAL '2 days'),
                NOW()
            );
        END LOOP;

        -- Poblar la tabla `kpi_logs`
        FOR i IN 1..1000 LOOP
            INSERT INTO kpi_logs (kpi_id, value, logged_at)
            VALUES (
                (i % 50) + 1, -- IDs de KPIs entre 1 y 50
                TRUNC(random() * 1000 * 100) / 100, -- Redondeo a dos decimales
                NOW() - (i * INTERVAL '1 hour')
            );
        END LOOP;

        -- Registrar que los datos iniciales fueron poblados
        INSERT INTO migration_logs (migration_name) VALUES ('populate_initial_data');
    END IF;
END $$;
