-- Q16 (Advanced): Products frequently bought together (same order).
WITH order_products AS (
    SELECT DISTINCT order_id, product_id
    FROM order_items
    WHERE quantity > 0
)
SELECT
    pa.product_name AS product_a,
    pb.product_name AS product_b,
    COUNT(*) AS times_bought_together
FROM order_products a
JOIN order_products b
    ON a.order_id = b.order_id
    AND a.product_id < b.product_id
JOIN products pa ON pa.product_id = a.product_id
JOIN products pb ON pb.product_id = b.product_id
GROUP BY a.product_id, b.product_id, pa.product_name, pb.product_name
ORDER BY times_bought_together DESC, product_a, product_b;