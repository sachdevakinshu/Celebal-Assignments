-- Q9 (Advanced): LAG analysis - days between consecutive orders per customer.
WITH gaps AS (
    SELECT
        o.customer_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date
    FROM orders o
    WHERE o.customer_id IS NOT NULL
),
with_gap AS (
    SELECT
        customer_id,
        order_date,
        previous_order_date,
        ROUND(julianday(order_date)-julianday(previous_order_date), 1) AS days_gap
    FROM gaps
),
avg_gap AS (
    SELECT
        customer_id,
        ROUND(AVG(days_gap), 1) AS avg_days_gap
    FROM with_gap
    WHERE days_gap IS NOT NULL
    GROUP BY customer_id
)
SELECT
    w.customer_id,
    w.order_date,
    w.previous_order_date,
    w.days_gap,
    a.avg_days_gap,
    CASE WHEN a.avg_days_gap > 30 THEN 'At Risk' ELSE 'Active' END AS risk_flag
FROM with_gap w
LEFT JOIN avg_gap a ON a.customer_id = w.customer_id
ORDER BY w.customer_id, w.order_date;
