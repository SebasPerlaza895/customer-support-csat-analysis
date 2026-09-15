-- Limpieza de raw_customer_support -> clean_customer_support
-- Unico cambio real de contenido: reconstruir las 4 columnas de fecha a
-- formato ISO (YYYY-MM-DD[ HH:MM]) para que sean utilizables con las
-- funciones de fecha de SQLite. Todo lo demas se deja igual; los nombres
-- de columna ya vienen normalizados desde python/load_to_sqlite.py.
--
-- order_date_time queda NULL cuando el original era NULL (llamadas sin
-- pedido asociado, ver 01_exploration.sql).

DROP TABLE IF EXISTS clean_customer_support;

CREATE TABLE clean_customer_support AS
SELECT
    unique_id,
    channel_name,
    category,
    sub_category,
    customer_remarks,
    order_id,
    CASE WHEN order_date_time IS NOT NULL THEN
        SUBSTR(order_date_time, 7, 4) || '-' || SUBSTR(order_date_time, 4, 2) || '-' ||
        SUBSTR(order_date_time, 1, 2) || ' ' || SUBSTR(order_date_time, 12, 5)
    ELSE NULL END AS order_date_time,
    SUBSTR(issue_reported_at, 7, 4) || '-' || SUBSTR(issue_reported_at, 4, 2) || '-' ||
        SUBSTR(issue_reported_at, 1, 2) || ' ' || SUBSTR(issue_reported_at, 12, 5) AS issue_reported_at,
    SUBSTR(issue_responded, 7, 4) || '-' || SUBSTR(issue_responded, 4, 2) || '-' ||
        SUBSTR(issue_responded, 1, 2) || ' ' || SUBSTR(issue_responded, 12, 5) AS issue_responded,
    '20' || SUBSTR(survey_response_date, 8, 2) || '-' ||
        CASE SUBSTR(survey_response_date, 4, 3)
            WHEN 'Jan' THEN '01' WHEN 'Feb' THEN '02' WHEN 'Mar' THEN '03'
            WHEN 'Apr' THEN '04' WHEN 'May' THEN '05' WHEN 'Jun' THEN '06'
            WHEN 'Jul' THEN '07' WHEN 'Aug' THEN '08' WHEN 'Sep' THEN '09'
            WHEN 'Oct' THEN '10' WHEN 'Nov' THEN '11' WHEN 'Dec' THEN '12'
        END || '-' || SUBSTR(survey_response_date, 1, 2) AS survey_response_date,
    customer_city,
    product_category,
    item_price,
    connected_handling_time,
    agent_name,
    supervisor,
    manager,
    tenure_bucket,
    agent_shift,
    csat_score
FROM raw_customer_support;

-- Verificacion: mismo numero de filas que raw, y las 3 columnas de fecha
-- que siempre existen (issue_reported_at, issue_responded,
-- survey_response_date) deben ser 100% parseables por datetime().
SELECT COUNT(*) FROM clean_customer_support;

SELECT
    COUNT(*) AS total,
    COUNT(datetime(issue_reported_at))     AS validas_reported,
    COUNT(datetime(issue_responded))       AS validas_responded,
    COUNT(datetime(survey_response_date))  AS validas_survey
FROM clean_customer_support;
