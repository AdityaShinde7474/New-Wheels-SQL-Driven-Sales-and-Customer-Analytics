-- ============================================================
-- New Wheels: Quarterly Business Report - SQL Analysis
-- Author: Aditya Shinde
-- Description: SQL queries analyzing customer, sales, revenue,
-- and shipping trends for New-Wheels vehicle resale platform
-- ============================================================


-- ============================================================
-- Q1: Total number of customers who placed orders,
--     and their distribution across states
-- ============================================================

-- Total number of customers who placed orders
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM order_t;

-- Distribution of customers across states
SELECT 
    customer_t.state, 
    COUNT(DISTINCT order_t.customer_id) AS customer_count
FROM order_t
JOIN customer_t 
    ON order_t.customer_id = customer_t.customer_id
GROUP BY customer_t.state
ORDER BY customer_count DESC;


-- ============================================================
-- Q2: Top 5 vehicle makers preferred by customers
-- ============================================================

SELECT 
    product_t.vehicle_maker, 
    COUNT(DISTINCT order_t.customer_id) AS customer_count
FROM order_t
JOIN product_t 
    ON order_t.product_id = product_t.product_id
GROUP BY product_t.vehicle_maker
ORDER BY customer_count DESC
LIMIT 5;


-- ============================================================
-- Q3: Most preferred vehicle maker in each state
-- ============================================================

SELECT 
    customer_t.state, 
    product_t.vehicle_maker, 
    COUNT(DISTINCT order_t.customer_id) AS customer_count
FROM order_t
JOIN customer_t 
    ON order_t.customer_id = customer_t.customer_id
JOIN product_t 
    ON order_t.product_id = product_t.product_id
GROUP BY customer_t.state, product_t.vehicle_maker;


-- ============================================================
-- Q4: Overall average customer rating, 
--     and average rating by quarter
-- ============================================================

-- Overall average rating
SELECT 
    AVG(
        CASE customer_feedback
            WHEN 'Very Bad' THEN 1
            WHEN 'Bad' THEN 2
            WHEN 'Okay' THEN 3
            WHEN 'Good' THEN 4
            WHEN 'Very Good' THEN 5
        END
    ) AS overall_avg_rating
FROM order_t;

-- Average rating by quarter
SELECT 
    quarter_number,
    AVG(rating_value) AS avg_rating
FROM (
    SELECT 
        quarter_number,
        CASE customer_feedback
            WHEN 'Very Bad' THEN 1
            WHEN 'Bad' THEN 2
            WHEN 'Okay' THEN 3
            WHEN 'Good' THEN 4
            WHEN 'Very Good' THEN 5
        END AS rating_value
    FROM order_t
) AS feedback_table
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Q5: Percentage distribution of customer feedback by quarter
--     (Are customers getting more dissatisfied over time?)
-- ============================================================

SELECT 
    quarter_number, 
    ROUND(SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS very_good_percent, 
    ROUND(SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS good_percent, 
    ROUND(SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS okay_percent,
    ROUND(SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bad_percent, 
    ROUND(SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS very_bad_percent
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Q6: Trend of number of orders by quarter
-- ============================================================

SELECT 
    quarter_number, 
    COUNT(order_id) AS total_orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Q7: Net revenue and quarter-over-quarter (QoQ) % change
--     using LAG() window function
-- ============================================================

SELECT 
    quarter_number,
    SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100)) AS net_revenue,
    LAG(SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100))) 
        OVER (ORDER BY quarter_number) AS previous_quarter_revenue,
    ROUND(
        (
            SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100))
            - LAG(SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100))) 
                OVER (ORDER BY quarter_number)
        )
        / LAG(SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100))) 
            OVER (ORDER BY quarter_number)
        * 100, 2
    ) AS qoq_percent_change
FROM order_t
JOIN product_t 
    ON order_t.product_id = product_t.product_id
GROUP BY quarter_number
ORDER BY quarter_number;


-- ============================================================
-- Q8: Trend of net revenue and total orders by quarter
-- ============================================================

SELECT 
    order_t.quarter_number, 
    COUNT(order_t.order_id) AS total_orders,
    SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100)) AS net_revenue
FROM order_t
JOIN product_t 
    ON order_t.product_id = product_t.product_id
GROUP BY order_t.quarter_number
ORDER BY order_t.quarter_number;


-- ============================================================
-- Q9: Average discount offered by credit card type
-- ============================================================

SELECT 
    customer_t.credit_card_type,
    AVG(order_t.discount) AS avg_discount
FROM order_t
JOIN customer_t 
    ON order_t.customer_id = customer_t.customer_id
GROUP BY customer_t.credit_card_type
ORDER BY avg_discount DESC;


-- ============================================================
-- Q10: Average shipping time (in days) by quarter
-- ============================================================

SELECT 
    quarter_number, 
    AVG(DATEDIFF(ship_date, order_date)) AS avg_shipping_days
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;