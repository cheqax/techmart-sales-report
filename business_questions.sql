-- ============================================================
-- TechMart Electronics — Business Analysis Queries
-- Author: Chethan Ramesh Reddy
-- Dataset: techmart_full_dataset.sql (150 customers, 18 products,
--          480 orders, 977 order items, full year 2023)
--
-- Each query below answers a real business question a Data Analyst
-- would be asked by a sales/ops/marketing team. Every query uses
-- only Delivered orders for revenue figures unless stated otherwise,
-- since Cancelled/Pending orders haven't actually generated revenue.
-- ============================================================

USE techmart;


-- ------------------------------------------------------------
-- Q1. What is our month-by-month revenue trend for the year?
-- Business use: spot growth, dips, and plan staffing/inventory
-- around busy months.
-- ------------------------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)          AS delivered_orders,
    ROUND(SUM(oi.unit_price * oi.quantity), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY month
ORDER BY month;


-- ------------------------------------------------------------
-- Q2. Who are our top 10 customers by total spend?
-- Business use: identify high-value customers for loyalty
-- programs or personal outreach.
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    ROUND(SUM(oi.unit_price * oi.quantity), 2) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, customer_name, c.city
ORDER BY total_spend DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q3. Which product categories drive the most revenue, and what
-- share of total revenue does each one represent?
-- Business use: category-level investment/discontinue decisions.
-- ------------------------------------------------------------
SELECT
    p.category,
    ROUND(SUM(oi.unit_price * oi.quantity), 2) AS category_revenue,
    ROUND(
        SUM(oi.unit_price * oi.quantity) * 100.0 /
        (SELECT SUM(oi2.unit_price * oi2.quantity)
         FROM order_items oi2
         JOIN orders o2 ON oi2.order_id = o2.order_id
         WHERE o2.status = 'Delivered'),
    2) AS pct_of_total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY category_revenue DESC;


-- ------------------------------------------------------------
-- Q4. How does each sales employee perform: total revenue closed,
-- number of orders, and their order cancellation rate?
-- Business use: performance review, flag reps with high cancellations.
-- Uses conditional aggregation (SUM/COUNT with IF) to get several
-- different-scope numbers about the same employee in one row.
-- ------------------------------------------------------------
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(o.order_id) AS total_orders_handled,
    SUM(IF(o.status = 'Cancelled', 1, 0)) AS cancelled_orders,
    ROUND(SUM(IF(o.status = 'Cancelled', 1, 0)) * 100.0 / COUNT(o.order_id), 1) AS cancellation_rate_pct,
    ROUND(SUM(IF(o.status = 'Delivered', oi.unit_price * oi.quantity, 0)), 2) AS delivered_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_id, employee_name
ORDER BY delivered_revenue DESC;


-- ------------------------------------------------------------
-- Q5. What are our top 10 best-selling products by revenue, and
-- how many units of each have we sold?
-- Business use: restocking priorities, what to promote.
-- ------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.unit_price * oi.quantity), 2) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q6. Which products have we never sold a single unit of?
-- Business use: catalog cleanup / dead stock identification.
-- Classic anti-join pattern: LEFT JOIN + IS NULL.
-- ------------------------------------------------------------
SELECT p.product_name, p.category, p.stock_quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- ------------------------------------------------------------
-- Q7. What percentage of orders placed are cancelled, and does
-- that rate differ by month?
-- Business use: track whether a process/quality issue is getting
-- better or worse over time.
-- ------------------------------------------------------------
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(IF(status = 'Cancelled', 1, 0)) AS cancelled_orders,
    ROUND(SUM(IF(status = 'Cancelled', 1, 0)) * 100.0 / COUNT(*), 1) AS cancellation_rate_pct
FROM orders
GROUP BY month
ORDER BY month;


-- ------------------------------------------------------------
-- Q8. Which customers spent above the average customer's total
-- spend? (Finds our "above-average" customer segment.)
-- Business use: define a segment for a targeted upsell campaign.
-- Uses a subquery to calculate the benchmark, then another to
-- compare each customer's total against it.
-- ------------------------------------------------------------
SELECT
    customer_name,
    total_spend
FROM (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(oi.unit_price * oi.quantity) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY c.customer_id, customer_name
) AS customer_totals
WHERE total_spend > (
    SELECT AVG(customer_total) FROM (
        SELECT SUM(oi.unit_price * oi.quantity) AS customer_total
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.status = 'Delivered'
        GROUP BY c.customer_id
    ) AS per_customer_totals
)
ORDER BY total_spend DESC;


-- ------------------------------------------------------------
-- Q9. Which customers have placed an order but never bought
-- anything from the Laptop category? (Cross-sell opportunity —
-- they're already buying, just not our highest-margin category.)
-- Anti-join + conditional aggregation combined.
-- ------------------------------------------------------------
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, customer_name, c.city
HAVING SUM(IF(p.category = 'Laptop', 1, 0)) = 0
ORDER BY customer_name;
