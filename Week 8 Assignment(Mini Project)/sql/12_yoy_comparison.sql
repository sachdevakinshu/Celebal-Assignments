-- Q12 (Advanced): Year-over-Year monthly revenue comparison.
-- LEFT JOIN so months with no previous-year data still appear (growth = NULL).
WITH monthly AS (
    SELECT
        CAST(strftime('%Y', o.order_date) AS INTEGER) AS year,
        CAST(strftime('%m', o.order_date) AS INTEGER) AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY year, month
)
SELECT
    cur.year,
    cur.month,
    ROUND(cur.revenue, 2) AS revenue,
    ROUND(prev.revenue, 2) AS prev_year_revenue,
    ROUND(100.0 * (cur.revenue - prev.revenue) / NULLIF(prev.revenue, 0), 2) AS yoy_growth_percent
FROM monthly cur
LEFT JOIN monthly prev
    ON prev.year = cur.year - 1
   AND prev.month = cur.month
ORDER BY cur.year, cur.month;
