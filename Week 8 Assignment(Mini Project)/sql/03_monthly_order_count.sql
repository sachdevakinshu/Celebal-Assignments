-- Q3 (Basic): Month-wise order count for the last 12 months
-- "Last 12 months" is measured relative to the most recent order in the data,
-- so the query keeps working no matter when it is run.
WITH latest AS (
    SELECT MAX(order_date) AS max_date FROM orders
)
SELECT
    strftime('%Y-%m', o.order_date) AS order_month,
    COUNT(*) AS order_count
FROM orders o, latest l
WHERE o.order_date >= datetime(l.max_date, '-12 months')
GROUP BY order_month
ORDER BY order_month;
