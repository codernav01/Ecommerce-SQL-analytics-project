-- ============================================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS ECommerce_Project;
USE ECommerce_Project;

-- ============================================================
-- 1. TABLES
-- ============================================================

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_each DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50),
    payment_date DATE,
    payment_amount DECIMAL(10,2),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE,
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- 2. SAMPLE DATA
-- ============================================================

INSERT INTO customers VALUES
(1, 'Amit Roy', 'amit@example.com', 'Delhi', 'Delhi', '2022-03-10'),
(2, 'Sonal Jain', 'sonal@example.com', 'Mumbai', 'Maharashtra', '2023-01-22'),
(3, 'Rakesh Singh', 'rakesh@example.com', 'Lucknow', 'UP', '2021-11-05');

INSERT INTO products VALUES
(101, 'Wireless Mouse', 'Electronics', 599.00, 100),
(102, 'Bluetooth Speaker', 'Electronics', 1299.00, 50),
(103, 'Cotton Shirt', 'Fashion', 899.00, 200),
(104, 'Cooking Oil 1L', 'Grocery', 175.00, 300);

INSERT INTO orders VALUES
(1001, 1, '2024-06-01', 'Delivered'),
(1002, 2, '2024-06-05', 'Delivered'),
(1003, 1, '2024-06-10', 'Returned'),
(1004, 3, '2024-06-11', 'Cancelled');

INSERT INTO order_items VALUES
(1, 1001, 101, 2, 599.00),
(2, 1002, 103, 1, 899.00),
(3, 1003, 102, 1, 1299.00),
(4, 1004, 104, 5, 175.00);

INSERT INTO payments VALUES
(501, 1001, 'Credit Card', '2024-06-01', 1198.00),
(502, 1002, 'UPI', '2024-06-05', 899.00),
(503, 1003, 'Net Banking', '2024-06-10', 1299.00);

INSERT INTO reviews VALUES
(901, 1001, 5, 'Great product', '2024-06-03'),
(902, 1002, 4, 'Good fit and quality', '2024-06-06'),
(903, 1003, 2, 'Stopped working in 2 days', '2024-06-12');

-- ============================================================
-- 3. BASIC BUSINESS ANALYSIS
-- ============================================================

-- Customers per state
SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC, state;

-- Total orders in June 2024
SELECT
    COUNT(*) AS total_orders
FROM orders
WHERE order_date >= '2024-06-01'
  AND order_date < '2024-07-01';

-- Most sold products by units
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p
  ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC, p.product_name
LIMIT 1;

-- Customers who signed up before 2023
SELECT
    customer_id,
    name,
    signup_date
FROM customers
WHERE signup_date < '2023-01-01'
ORDER BY signup_date;

-- Products priced above the average product price
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Buyer details per order
SELECT
    c.customer_id,
    c.name,
    c.city,
    c.state,
    c.signup_date,
    o.order_id,
    o.order_date,
    o.status
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
ORDER BY o.order_date, o.order_id;

-- Product details per order
SELECT
    oi.order_id,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.price_each,
    oi.quantity * oi.price_each AS line_value
FROM order_items oi
JOIN products p
  ON p.product_id = oi.product_id
ORDER BY oi.order_id;

-- Feedback with customer geography
SELECT
    c.customer_id,
    c.name,
    c.city,
    c.state,
    o.order_id,
    o.order_date,
    o.status,
    r.rating,
    r.review_text,
    r.review_date
FROM reviews r
JOIN orders o
  ON o.order_id = r.order_id
JOIN customers c
  ON c.customer_id = o.customer_id
ORDER BY r.review_date;

-- Products bought by a selected customer
SET @customer_id = 1;

SELECT
    c.customer_id,
    c.name,
    o.order_id,
    p.product_id,
    p.product_name,
    oi.quantity,
    oi.price_each
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN order_items oi
  ON oi.order_id = o.order_id
JOIN products p
  ON p.product_id = oi.product_id
WHERE c.customer_id = @customer_id
ORDER BY o.order_date;

-- Returned orders that still have payment records
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    p.payment_id,
    p.payment_method,
    p.payment_date,
    p.payment_amount
FROM orders o
JOIN payments p
  ON p.order_id = o.order_id
WHERE o.status = 'Returned';

-- Delivered revenue by category
SELECT
    p.category,
    SUM(oi.quantity * oi.price_each) AS delivered_revenue
FROM orders o
JOIN order_items oi
  ON oi.order_id = o.order_id
JOIN products p
  ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY delivered_revenue DESC;

-- Average rating per product
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM products p
LEFT JOIN order_items oi
  ON oi.product_id = p.product_id
LEFT JOIN reviews r
  ON r.order_id = oi.order_id
GROUP BY p.product_id, p.product_name
ORDER BY avg_rating DESC, review_count DESC;

-- Review distribution
SELECT
    rating,
    COUNT(*) AS review_count
FROM reviews
GROUP BY rating
ORDER BY rating DESC;

-- Monthly order trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

-- Total transaction value per customer
SELECT
    c.customer_id,
    c.name,
    COALESCE(SUM(oi.quantity * oi.price_each), 0) AS total_transaction_value
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id
LEFT JOIN order_items oi
  ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_transaction_value DESC;

-- ============================================================
-- 4. ADVANCED SQL
-- ============================================================

-- Rank customers by total transaction value
WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.name,
        SUM(oi.quantity * oi.price_each) AS total_sales
    FROM customers c
    JOIN orders o
      ON o.customer_id = c.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.name
)
SELECT
    customer_id,
    name,
    total_sales,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
ORDER BY sales_rank, customer_id;

-- Compare each customer's spending with their previous order
WITH order_values AS (
    SELECT
        c.customer_id,
        c.name,
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.price_each) AS order_value
    FROM customers c
    JOIN orders o
      ON o.customer_id = c.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    GROUP BY
        c.customer_id,
        c.name,
        o.order_id,
        o.order_date
),
with_previous AS (
    SELECT
        customer_id,
        name,
        order_id,
        order_date,
        order_value,
        LAG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_value
    FROM order_values
)
SELECT
    customer_id,
    name,
    order_id,
    order_date,
    order_value,
    previous_order_value,
    order_value - previous_order_value AS change_vs_previous_order
FROM with_previous
ORDER BY customer_id, order_date, order_id;

-- High-value customers based on total transaction value
WITH customer_value AS (
    SELECT
        c.customer_id,
        c.name,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity * oi.price_each) AS total_spend
    FROM customers c
    JOIN orders o
      ON o.customer_id = c.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.name
)
SELECT *
FROM customer_value
WHERE total_spend > 2000
ORDER BY total_spend DESC;

-- Delivered category sales performance
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.price_each) AS delivered_revenue
FROM orders o
JOIN order_items oi
  ON oi.order_id = o.order_id
JOIN products p
  ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY delivered_revenue DESC;

-- Orders with low ratings
SELECT
    c.customer_id,
    c.name,
    o.order_id,
    o.order_date,
    r.rating,
    r.review_text,
    r.review_date
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN reviews r
  ON r.order_id = o.order_id
WHERE r.rating < 3
ORDER BY r.rating, r.review_date;

-- ============================================================
-- 5. STORED PROCEDURES
-- ============================================================

DROP PROCEDURE IF EXISTS get_customer_orders;
DELIMITER //
CREATE PROCEDURE get_customer_orders(IN p_customer_id INT)
BEGIN
    SELECT
        c.customer_id,
        c.name,
        o.order_id,
        o.order_date,
        o.status,
        p.product_id,
        p.product_name,
        p.category,
        oi.quantity,
        oi.price_each,
        oi.quantity * oi.price_each AS line_value
    FROM customers c
    JOIN orders o
      ON o.customer_id = c.customer_id
    JOIN order_items oi
      ON oi.order_id = o.order_id
    JOIN products p
      ON p.product_id = oi.product_id
    WHERE c.customer_id = p_customer_id
    ORDER BY o.order_date, o.order_id;
END //
DELIMITER ;

CALL get_customer_orders(3);

DROP PROCEDURE IF EXISTS payment_revenue_between_dates;
DELIMITER //
CREATE PROCEDURE payment_revenue_between_dates(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        COALESCE(SUM(payment_amount), 0) AS payment_revenue
    FROM payments
    WHERE payment_date BETWEEN p_start_date AND p_end_date;
END //
DELIMITER ;

CALL payment_revenue_between_dates('2024-06-01', '2024-06-10');

DROP PROCEDURE IF EXISTS top_rated_product_by_category;
DELIMITER //
CREATE PROCEDURE top_rated_product_by_category(IN p_category VARCHAR(100))
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(AVG(r.rating), 2) AS avg_rating,
        COUNT(r.review_id) AS review_count
    FROM products p
    JOIN order_items oi
      ON oi.product_id = p.product_id
    JOIN reviews r
      ON r.order_id = oi.order_id
    WHERE p.category = p_category
    GROUP BY p.product_id, p.product_name, p.category
    ORDER BY avg_rating DESC, review_count DESC, p.product_name
    LIMIT 1;
END //
DELIMITER ;

CALL top_rated_product_by_category('Electronics');

-- ============================================================
-- 6. USER-DEFINED FUNCTIONS
-- ============================================================

DROP FUNCTION IF EXISTS average_rating_for_product;
DELIMITER //
CREATE FUNCTION average_rating_for_product(p_product_id INT)
RETURNS DECIMAL(4,2)
READS SQL DATA
BEGIN
    DECLARE v_avg_rating DECIMAL(4,2);

    SELECT AVG(r.rating)
    INTO v_avg_rating
    FROM reviews r
    JOIN order_items oi
      ON oi.order_id = r.order_id
    WHERE oi.product_id = p_product_id;

    RETURN v_avg_rating;
END //
DELIMITER ;

SELECT average_rating_for_product(102) AS average_rating;

-- Note: the dataset does not include a true delivery timestamp.
-- Therefore review lateness is measured from order_date only and should
-- not be interpreted as days after delivery.

DROP FUNCTION IF EXISTS review_timing_flag;
DELIMITER //
CREATE FUNCTION review_timing_flag(p_order_id INT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_order_date DATE;
    DECLARE v_review_date DATE;

    SELECT o.order_date, r.review_date
    INTO v_order_date, v_review_date
    FROM orders o
    JOIN reviews r
      ON r.order_id = o.order_id
    WHERE o.order_id = p_order_id
    LIMIT 1;

    IF v_review_date IS NULL OR v_order_date IS NULL THEN
        RETURN 'No review';
    ELSEIF DATEDIFF(v_review_date, v_order_date) > 5 THEN
        RETURN 'After 5 days';
    ELSE
        RETURN 'Within 5 days';
    END IF;
END //
DELIMITER ;

SELECT review_timing_flag(1001) AS review_timing;

DROP FUNCTION IF EXISTS status_score;
DELIMITER //
CREATE FUNCTION status_score(p_status VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_status = 'Delivered' THEN 5
        WHEN p_status = 'Returned' THEN 2
        WHEN p_status = 'Cancelled' THEN 0
        ELSE NULL
    END;
END //
DELIMITER ;

SELECT
    order_id,
    status,
    status_score(status) AS status_score
FROM orders
ORDER BY order_id;
