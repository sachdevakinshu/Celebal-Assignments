-- Q15 (Advanced): Cohort analysis by registration month.
-- month_n = customers of the cohort who ordered n months after registering.
WITH cohort AS (
    SELECT
        customer_id,
        strftime('%Y-%m',registration_date) AS cohort_month,
        CAST(strftime('%Y',registration_date) AS INTEGER) * 12
            + CAST(strftime('%m',registration_date) AS INTEGER) AS cohort_index
    FROM customers
),
activity AS (
    SELECT DISTINCT
        c.customer_id,
        c.cohort_month,
        (CAST(strftime('%Y', o.order_date) AS INTEGER) * 12
            + CAST(strftime('%m', o.order_date) AS INTEGER)) - c.cohort_index AS months_since_reg
    FROM cohort c
    JOIN orders o ON o.customer_id = c.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM cohort
    GROUP BY cohort_month
)
SELECT
    s.cohort_month,
    s.cohort_customers,
    COUNT(DISTINCT CASE WHEN a.months_since_reg = 0 THEN a.customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN a.months_since_reg = 1 THEN a.customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN a.months_since_reg = 2 THEN a.customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN a.months_since_reg = 3 THEN a.customer_id END) AS month_3,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.months_since_reg = 0 THEN a.customer_id END) / s.cohort_customers, 1) AS retention_m0_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.months_since_reg = 1 THEN a.customer_id END) / s.cohort_customers, 1) AS retention_m1_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.months_since_reg = 2 THEN a.customer_id END) / s.cohort_customers, 1) AS retention_m2_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.months_since_reg = 3 THEN a.customer_id END) / s.cohort_customers, 1) AS retention_m3_pct
FROM cohort_size s
LEFT JOIN activity a ON a.cohort_month = s.cohort_month
GROUP BY s.cohort_month,s.cohort_customers
ORDER BY s.cohort_month;
