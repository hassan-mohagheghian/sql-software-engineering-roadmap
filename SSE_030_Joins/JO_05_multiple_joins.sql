-- Joins - Multiple JOINs
-- -----------------------------------------------------------------------------
-- Real queries often need 3+ tables joined. This covers chaining joins,
-- understanding join order, and handling complex relationships.
--
-- Key concepts:
-- 1. Chaining multiple JOINs
-- 2. Join order and parentheses
-- 3. Mixed join types (INNER + LEFT)
-- 4. Aggregation across multiple joins
-- 5. Star schema patterns
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample tables (e-commerce schema)
-- =============================================================================

SELECT '--- Setup: Creating e-commerce tables ---' AS note;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    total_amount REAL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price REAL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT
);

INSERT INTO customers VALUES
    (1, 'Alice', 'New York'),
    (2, 'Bob', 'London'),
    (3, 'Carol', 'Paris');

INSERT INTO orders VALUES
    (101, 1, '2024-01-15', 1225.00),
    (102, 1, '2024-02-20', 350.00),
    (103, 2, '2024-01-20', 525.00),
    (104, 3, '2024-03-01', 999.99);

INSERT INTO order_items VALUES
    (1, 101, 1, 1, 999.99),
    (2, 101, 2, 10, 22.50),
    (3, 102, 3, 1, 350.00),
    (4, 103, 1, 1, 999.99),
    (5, 103, 4, 5, 25.00),
    (6, 104, 1, 1, 999.99);

INSERT INTO products VALUES
    (1, 'Laptop', 'Electronics'),
    (2, 'Mouse', 'Electronics'),
    (3, 'Desk', 'Furniture'),
    (4, 'Pen', 'Stationery');


-- =============================================================================
-- Chaining Three Tables
-- =============================================================================

SELECT '--- Orders with customer info and items ---' AS note;

-- Chain: customers → orders → order_items
SELECT
    c.name AS customer,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
ORDER BY o.order_id;

SELECT '--- Full product names via four-table join ---' AS note;

-- Chain all four tables
SELECT
    c.name AS customer,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_name;


-- =============================================================================
-- Mixed Join Types (INNER + LEFT)
-- =============================================================================

SELECT '--- All customers, their orders, and products ---' AS note;

-- LEFT JOIN preserves all customers even without orders
SELECT
    c.name AS customer,
    o.order_id,
    p.product_name,
    oi.quantity
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
ORDER BY c.name, o.order_id;

SELECT '--- Customers without any orders ---' AS note;

-- LEFT JOIN + WHERE NULL = find unmatched
SELECT
    c.name AS customer,
    c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- =============================================================================
-- Aggregation Across Multiple Joins
-- =============================================================================

SELECT '--- Total spent per customer with product breakdown ---' AS note;

SELECT
    c.name AS customer,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

SELECT '--- Revenue by product category ---' AS note;

SELECT
    p.category,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category, p.product_name
ORDER BY revenue DESC;

SELECT '--- Sales by city ---' AS note;

SELECT
    c.city,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY revenue DESC;


-- =============================================================================
-- Subquery in JOIN
-- =============================================================================

SELECT '--- Customers with above-average spending ---' AS note;

-- Subquery to compute average, then join
SELECT
    c.name,
    customer_totals.total_spent
FROM customers c
INNER JOIN (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) customer_totals ON c.customer_id = customer_totals.customer_id
WHERE customer_totals.total_spent > (
    SELECT AVG(sub.total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS total
        FROM orders o2
        INNER JOIN order_items oi2 ON o2.order_id = oi2.order_id
        GROUP BY o2.customer_id
    ) sub
)
ORDER BY customer_totals.total_spent DESC;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE products;
DROP TABLE customers;