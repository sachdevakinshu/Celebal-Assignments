-- Q5 (Intermediate): Products that were ordered but had more returned units
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(CASE WHEN oi.quantity > 0 THEN oi.quantity ELSE 0 END)  AS units_purchased,
    SUM(CASE WHEN oi.quantity < 0 THEN -oi.quantity ELSE 0 END) AS units_returned
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING units_returned > units_purchased
ORDER BY units_returned - units_purchased DESC;
