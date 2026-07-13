-- Q14 (Advanced): Cumulative revenue distribution - what share of total
-- revenue comes from the top N% of customers (Pareto analysis).
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER (
        ORDER BY revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS cumulative_revenue,
    ROUND(100.0 * SUM(revenue) OVER (
        ORDER BY revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(revenue) OVER (), 2) AS cumulative_percent,
    ROUND(100.0 * ROW_NUMBER() OVER (ORDER BY revenue DESC)
          / COUNT(*) OVER (), 2) AS customer_percentile
FROM customer_revenue
ORDER BY revenue DESC;
