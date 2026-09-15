-- Exploracion inicial de raw_customer_support
-- Objetivo: entender calidad de datos antes de limpiar (nulos, duplicados,
-- formatos de fecha, outliers de precio) para justificar las decisiones
-- tomadas en 02_cleaning.sql.

SELECT * FROM raw_customer_support LIMIT 10;

SELECT COUNT(*) FROM raw_customer_support;

-- Nulos por columna clave
SELECT
    COUNT(*) AS total_filas,
    COUNT(*) - COUNT(customer_remarks)        AS nulos_remarks,
    COUNT(*) - COUNT(order_date_time)         AS nulos_order_date,
    COUNT(*) - COUNT(customer_city)           AS nulos_city,
    COUNT(*) - COUNT(product_category)        AS nulos_product_cat,
    COUNT(*) - COUNT(item_price)              AS nulos_item_price,
    COUNT(*) - COUNT(connected_handling_time) AS nulos_handling_time
FROM raw_customer_support;

-- Nulos de order_date_time por canal (ver si se concentra en un canal, ej. Outcall)
SELECT
    channel_name,
    COUNT(*) AS total,
    COUNT(*) - COUNT(order_date_time) AS nulos_order_date
FROM raw_customer_support
GROUP BY channel_name
ORDER BY total DESC;

-- Nulos de order_date_time por categoria
SELECT
    category,
    COUNT(*) AS total,
    COUNT(*) - COUNT(order_date_time) AS nulos_order_date
FROM raw_customer_support
GROUP BY category
ORDER BY total DESC;

-- Duplicados de unique_id (deberia ser clave primaria)
SELECT
    unique_id,
    COUNT(*) AS veces
FROM raw_customer_support
GROUP BY unique_id
HAVING COUNT(*) > 1;

-- Valores distintos de columnas categoricas
SELECT DISTINCT channel_name FROM raw_customer_support;
SELECT DISTINCT category FROM raw_customer_support;

-- Rango de precios
SELECT
    MIN(item_price) AS precio_minimo,
    MAX(item_price) AS precio_maximo,
    AVG(item_price) AS precio_promedio,
    COUNT(*) AS filas_con_precio
FROM raw_customer_support
WHERE item_price IS NOT NULL;

-- Precios en cero (posible dato faltante disfrazado)
SELECT COUNT(*) AS filas_precio_cero
FROM raw_customer_support
WHERE item_price = 0;

SELECT
    category,
    COUNT(*) AS filas_precio_cero
FROM raw_customer_support
WHERE item_price = 0
GROUP BY category
ORDER BY filas_precio_cero DESC;

-- Precios mas altos (outliers)
SELECT unique_id, category, sub_category, item_price
FROM raw_customer_support
WHERE item_price IS NOT NULL
ORDER BY item_price DESC
LIMIT 20;

-- ---------------------------------------------------------------------
-- Formatos de fecha: las columnas de fecha vienen como texto, no ISO.
-- issue_reported_at / issue_responded: "DD/MM/YYYY HH:MM" (longitud fija)
-- survey_response_date: "DD-Mon-YY" (ej. "01-Aug-23")
-- ---------------------------------------------------------------------

SELECT LENGTH(issue_reported_at) AS longitud, COUNT(*) AS cuantas
FROM raw_customer_support
GROUP BY longitud;

SELECT LENGTH(issue_responded) AS longitud, COUNT(*) AS cuantas
FROM raw_customer_support
GROUP BY longitud;

SELECT LENGTH(survey_response_date) AS longitud, COUNT(*) AS cuantas
FROM raw_customer_support
GROUP BY longitud;

-- Reconstruccion de issue_reported_at a formato ISO (YYYY-MM-DD HH:MM)
SELECT
    issue_reported_at,
    SUBSTR(issue_reported_at, 7, 4) || '-' ||
    SUBSTR(issue_reported_at, 4, 2) || '-' ||
    SUBSTR(issue_reported_at, 1, 2) || ' ' ||
    SUBSTR(issue_reported_at, 12, 5) AS fecha_reconstruida
FROM raw_customer_support
LIMIT 10;

-- Confirmar que el primer par de digitos es dia (<=31), no mes,
-- es decir que el formato es DD/MM/YYYY y no MM/DD/YYYY
SELECT COUNT(*) AS filas_confirman_formato_dia_mes
FROM raw_customer_support
WHERE CAST(SUBSTR(issue_reported_at, 1, 2) AS INTEGER) > 12;

-- Validar que la reconstruccion produce fechas parseables por SQLite
SELECT
    COUNT(*) AS total_filas,
    COUNT(datetime(
        SUBSTR(issue_reported_at, 7, 4) || '-' ||
        SUBSTR(issue_reported_at, 4, 2) || '-' ||
        SUBSTR(issue_reported_at, 1, 2) || ' ' ||
        SUBSTR(issue_reported_at, 12, 5)
    )) AS filas_fecha_valida
FROM raw_customer_support;

-- Reconstruccion de survey_response_date ("01-Aug-23" -> "2023-08-01")
SELECT
    survey_response_date,
    '20' || SUBSTR(survey_response_date, 8, 2) || '-' ||
    CASE SUBSTR(survey_response_date, 4, 3)
        WHEN 'Jan' THEN '01' WHEN 'Feb' THEN '02' WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04' WHEN 'May' THEN '05' WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07' WHEN 'Aug' THEN '08' WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10' WHEN 'Nov' THEN '11' WHEN 'Dec' THEN '12'
    END || '-' ||
    SUBSTR(survey_response_date, 1, 2) AS fecha_reconstruida
FROM raw_customer_support
LIMIT 10;

SELECT
    COUNT(*) AS total_filas,
    COUNT(datetime(
        '20' || SUBSTR(survey_response_date, 8, 2) || '-' ||
        CASE SUBSTR(survey_response_date, 4, 3)
            WHEN 'Jan' THEN '01' WHEN 'Feb' THEN '02' WHEN 'Mar' THEN '03'
            WHEN 'Apr' THEN '04' WHEN 'May' THEN '05' WHEN 'Jun' THEN '06'
            WHEN 'Jul' THEN '07' WHEN 'Aug' THEN '08' WHEN 'Sep' THEN '09'
            WHEN 'Oct' THEN '10' WHEN 'Nov' THEN '11' WHEN 'Dec' THEN '12'
        END || '-' ||
        SUBSTR(survey_response_date, 1, 2)
    )) AS filas_fecha_valida
FROM raw_customer_support;
