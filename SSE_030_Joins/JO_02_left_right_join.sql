-- Joins - LEFT and RIGHT JOIN
-- -----------------------------------------------------------------------------
-- LEFT JOIN returns all rows from the left table and matched rows from the
-- right. RIGHT JOIN is the mirror — all rows from the right, matched from left.
-- Essential for finding missing data and ensuring complete results.
--
-- Key concepts:
-- 1. LEFT JOIN — all left rows, matched right (NULLs where no match)
-- 2. RIGHT JOIN — all right rows, matched left (NULLs where no match)
-- 3. LEFT JOIN to find unmatched rows
-- 4. FULL OUTER JOIN via UNION
-- 5. NULL comparison after join
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample tables
-- =============================================================================

SELECT '--- Setup: Creating customers and orders tables ---' AS note;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    city TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product TEXT NOT NULL,
    amount REAL,
    order_date TEXT
);

INSERT INTO customers VALUES
    (1, 'Alice', 'alice@example.com', 'New York'),
    (2, 'Bob', 'bob@example.com', 'London'),
    (3, 'Carol', 'carol@example.com', 'New York'),
    (4, 'David', 'david@example.com', 'Paris'),
    (5, 'Eve', 'eve@example.com', 'London');

INSERT INTO orders VALUES
    (101, 1, 'Laptop', 1200.00, '2024-01-15'),
    (102, 1, 'Mouse', 25.00, '2024-01-16'),
    (103, 2, 'Keyboard', 75.00, '2024-02-01'),
    (104, 3, 'Monitor', 450.00, '2024-02-03'),
    (105, NULL, 'Desk', 350.00, '2024-02-10');

-- Note: customer 4 (David) has no orders
-- Note: order 105 has no matching customer (orphan)


-- =============================================================================
-- LEFT JOIN
-- =============================================================================

SELECT '--- All customers, including those without orders ---' AS note;

-- LEFT JOIN: all left rows, matched right (NULLs for no match)
SELECT
    c.name,
    c.city,
    o.order_id,
    o.product,
    o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

SELECT '--- LEFT JOIN with NULL check: customers without orders ---' AS note;

-- Find customers who have never ordered
SELECT
    c.name,
    c.city,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT '--- LEFT JOIN with WHERE: only customers with orders ---' AS note;

-- Adding WHERE on right table negates the LEFT JOIN effect
-- This is equivalent to INNER JOIN
SELECT
    c.name,
    o.product,
    o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NOT NULL;


-- =============================================================================
-- RIGHT JOIN
-- =============================================================================

SELECT '--- All orders, including those without matching customers ---' AS note;

-- RIGHT JOIN: all right rows, matched left (NULLs for no match)
-- Note: SQLite doesn't support RIGHT JOIN directly (use LEFT JOIN with tables swapped)
-- This syntax works in PostgreSQL and MySQL:
-- SELECT c.name, o.order_id, o.product
-- FROM customers c
-- RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- SQLite workaround: swap table order and use LEFT JOIN
SELECT
    c.name,
    c.city,
    o.order_id,
    o.product,
    o.amount
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;

SELECT '--- Find orphan orders (no matching customer) ---' AS note;

-- RIGHT JOIN equivalent: orders without customers
SELECT
    o.order_id,
    o.product,
    o.amount,
    c.name AS customer_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- =============================================================================
-- LEFT JOIN with Aggregation
-- =============================================================================

SELECT '--- Order count per customer (including zero orders) ---' AS note;

-- LEFT JOIN + COUNT includes customers with zero orders
SELECT
    c.name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- =============================================================================
-- Simulating FULL OUTER JOIN
-- =============================================================================

SELECT '--- FULL OUTER JOIN equivalent using UNION ---' AS note;

-- SQLite doesn't support FULL OUTER JOIN directly
-- Simulate with LEFT JOIN + RIGHT JOIN + UNION

-- All customers and all orders
SELECT
    c.name,
    c.city,
    o.order_id,
    o.product
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT
    c.name,
    c.city,
    o.order_id,
    o.product
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Note: UNION removes duplicates; UNION ALL keeps them


-- =============================================================================
-- Multiple LEFT JOINs
-- =============================================================================

-- Add a payments table for multi-join example
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    payment_method TEXT,
    paid_amount REAL
);

INSERT INTO payments VALUES
    (1, 101, 'Credit Card', 1200.00),
    (2, 103, 'PayPal', 75.00),
    (3, 104, 'Credit Card', 450.00);

SELECT '--- Customers with orders and payments ---' AS note;

-- Chain multiple LEFT JOINs
SELECT
    c.name,
    o.product,
    o.amount AS order_amount,
    p.payment_method,
    p.paid_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
ORDER BY c.name;

SELECT '--- Find unpaid orders ---' AS note;

SELECT
    c.name,
    o.order_id,
    o.product,
    o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL AND o.order_id IS NOT NULL;

-- Clean up demo table
DROP TABLE payments;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE orders;
DROP TABLE customers;