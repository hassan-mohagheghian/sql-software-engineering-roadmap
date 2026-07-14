-- Joins - INNER JOIN
-- -----------------------------------------------------------------------------
-- INNER JOIN returns only rows where there is a match in both tables. It's the
-- most common join type and forms the basis for combining data across tables.
--
-- Key concepts:
-- 1. Basic INNER JOIN with ON clause
-- 2. Joining on multiple columns
-- 3. Table aliases for readability
-- 4. Self-joins
-- 5. Join with WHERE filtering
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
    customer_id INTEGER NOT NULL,
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
    (105, 3, 'Desk', 350.00, '2024-02-10'),
    (106, 3, 'Chair', 280.00, '2024-03-01'),
    (107, 5, 'Headphones', 150.00, '2024-03-05');

-- Note: customer 4 (David) has no orders — will be excluded from INNER JOIN


-- =============================================================================
-- Basic INNER JOIN
-- =============================================================================

SELECT '--- Match customers with their orders ---' AS note;

-- INNER JOIN: only customers who have orders
SELECT
    c.name,
    c.city,
    o.product,
    o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

SELECT '--- Using explicit INNER keyword (optional) ---' AS note;

-- INNER is optional — JOIN alone means INNER JOIN
SELECT
    c.name,
    o.product,
    o.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


-- =============================================================================
-- Multiple Column Join
-- =============================================================================

-- For demonstration, add a composite key scenario
SELECT '--- Join on multiple columns ---' AS note;

CREATE TABLE order_items (
    order_id INTEGER,
    item_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, item_id)
);

INSERT INTO order_items VALUES
    (101, 1, 1),
    (101, 2, 2),
    (102, 1, 1);

-- Join on two columns
SELECT
    o.order_id,
    o.product,
    oi.quantity,
    o.amount
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id AND o.product = 'Laptop';

-- Clean up demo table
DROP TABLE order_items;


-- =============================================================================
-- Self-Join
-- =============================================================================

-- Create a table with a self-referential relationship
CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    manager_id INTEGER
);

INSERT INTO employees VALUES
    (1, 'Alice', NULL),
    (2, 'Bob', 1),
    (3, 'Carol', 1),
    (4, 'David', 2),
    (5, 'Eve', 2),
    (6, 'Frank', 3);

SELECT '--- Self-join: employees and their managers ---' AS note;

-- Join employees to themselves to find managers
SELECT
    e.name AS employee,
    m.name AS manager
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id;

SELECT '--- Self-join: all employees with manager names (NULL for top-level) ---' AS note;

-- This inner join excludes Alice (no manager). Use LEFT JOIN to include her.
-- Shown here for contrast — see JO_02 for LEFT JOIN.
SELECT
    e.name AS employee,
    m.name AS manager
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id
ORDER BY m.name;


-- =============================================================================
-- Join with WHERE Filtering
-- =============================================================================

SELECT '--- Orders from New York customers only ---' AS note;

-- Join + filter: combine data, then narrow results
SELECT
    c.name,
    c.city,
    o.product,
    o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'New York';

SELECT '--- High-value orders from London customers ---' AS note;

SELECT
    c.name,
    o.product,
    o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'London' AND o.amount > 100;


-- =============================================================================
-- Aggregate with Join
-- =============================================================================

SELECT '--- Total spent per customer ---' AS note;

-- Join + group: aggregate joined data
SELECT
    c.name,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS total_spent
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE employees;
DROP TABLE orders;
DROP TABLE customers;
