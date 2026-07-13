-- Q2 (Basic): Top 10 customers by total order value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY total_order_value DESC
LIMIT 10;
