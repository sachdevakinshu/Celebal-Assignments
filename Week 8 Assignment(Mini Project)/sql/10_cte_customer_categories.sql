-- Q10 (Advanced): Multi-level CTE
-- 1) monthly revenue per customer  2) categorize High/Medium/Low
-- 3) count customers per category per month
WITH monthly_revenue AS (
    SELECT
        o.customer_id,
        strftime('%Y-%m', o.order_date) AS order_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id, order_month
),
categorized AS (
    SELECT
        customer_id,
        order_month,
        revenue,
        CASE
            WHEN revenue > 10000 THEN 'High'
            WHEN revenue >= 5000 THEN 'Medium'
            ELSE 'Low'
        END AS revenue_category
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue_category,
    COUNT(*) AS customer_count
FROM categorized
GROUP BY order_month, revenue_category
ORDER BY order_month,
CASE revenue_category WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;
