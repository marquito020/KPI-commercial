-- Definir tipos ENUM
CREATE TYPE role_type AS ENUM ('admin', 'manager', 'analyst');
CREATE TYPE status_type AS ENUM ('on_track', 'at_risk', 'off_track');
CREATE TYPE category_type AS ENUM ('retail', 'food', 'service');
CREATE TYPE alert_level_type AS ENUM ('low', 'medium', 'high');

-- Crear tablas
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role role_type DEFAULT 'analyst',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INT NOT NULL, -- Relacionado con una tabla de productos
    price DECIMAL(15, 2) NOT NULL,
    quantity INT NOT NULL,
    rating DECIMAL(3, 2) DEFAULT NULL, -- Calificación del producto
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_interactions (
    interaction_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    interaction_type VARCHAR(50) NOT NULL, -- Ejemplo: 'click', 'view', 'purchase'
    interaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE kpis (
    kpi_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    target_value DECIMAL(15, 2) NOT NULL,
    actual_value DECIMAL(15, 2) DEFAULT 0,
    unit VARCHAR(20) NOT NULL,
    status status_type DEFAULT 'on_track',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category category_type NOT NULL,
    floor SMALLINT NOT NULL,
    owner_name VARCHAR(100),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    store_id INT NOT NULL REFERENCES stores(store_id) ON DELETE CASCADE,
    sale_date DATE NOT NULL,
    total_sales DECIMAL(15, 2) NOT NULL,
    total_customers INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE visits (
    visit_id SERIAL PRIMARY KEY,
    visit_date DATE NOT NULL,
    total_visits INT NOT NULL,
    unique_visits INT NOT NULL,
    peak_hour TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alerts (
    alert_id SERIAL PRIMARY KEY,
    kpi_id INT NOT NULL REFERENCES kpis(kpi_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    alert_level alert_level_type DEFAULT 'medium',
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dashboards (
    dashboard_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kpi_logs (
    log_id SERIAL PRIMARY KEY,
    kpi_id INT NOT NULL REFERENCES kpis(kpi_id) ON DELETE CASCADE,
    value DECIMAL(15, 2) NOT NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
