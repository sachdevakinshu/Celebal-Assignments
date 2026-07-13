-- Q4 (Intermediate): Customers who placed orders but never had any order delivered
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    GROUP_CONCAT(DISTINCT o.status) AS statuses_seen
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM orders d
    WHERE d.customer_id = c.customer_id
      AND d.status = 'DELIVERED'
)
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;
