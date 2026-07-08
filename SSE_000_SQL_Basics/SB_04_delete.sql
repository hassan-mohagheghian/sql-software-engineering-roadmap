-- SQL Basics - DELETE
-- -----------------------------------------------------------------------------
-- The DELETE statement removes rows from a table. Always use a WHERE clause
-- unless you intend to delete all rows.
--
-- Key concepts:
-- 1. DELETE FROM ... WHERE — conditional delete
-- 2. DELETE without WHERE — deletes ALL rows (dangerous!)
-- 3. DELETE with subquery — delete based on other tables
-- 4. TRUNCATE — faster bulk delete (resets auto-increment)
-- 5. OR IGNORE — skip if row doesn't exist
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating orders table with sample data ---' AS note;

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer TEXT NOT NULL,
    product TEXT NOT NULL,
    amount REAL,
    status TEXT DEFAULT 'pending',
    created_at TEXT DEFAULT (datetime('now'))
);

INSERT INTO orders (id, customer, product, amount, status) VALUES
    (1, 'Alice', 'Laptop', 999.99, 'completed'),
    (2, 'Bob', 'Mouse', 29.99, 'pending'),
    (3, 'Carol', 'Keyboard', 79.99, 'completed'),
    (4, 'David', 'Monitor', 349.99, 'cancelled'),
    (5, 'Eve', 'Desk Chair', 249.99, 'pending'),
    (6, 'Frank', 'Laptop', 999.99, 'completed'),
    (7, 'Grace', 'Notebook', 4.99, 'completed'),
    (8, 'Hank', 'Desk Lamp', 49.99, 'cancelled');


-- =============================================================================
-- DELETE with WHERE
-- =============================================================================

SELECT '--- Delete cancelled orders ---' AS note;

-- Delete cancelled orders
DELETE FROM orders WHERE status = 'cancelled';

SELECT '--- Remaining orders after deleting cancelled ---' AS note;

SELECT * FROM orders;

SELECT '--- Delete orders below $50 ---' AS note;

-- Delete orders below a threshold
DELETE FROM orders WHERE amount < 50;

SELECT '--- Remaining orders after deleting low-value orders ---' AS note;

SELECT * FROM orders;


-- =============================================================================
-- DELETE with Subquery
-- =============================================================================

SELECT '--- Delete all orders from customers with no pending orders ---' AS note;

-- Delete all orders from customers who have no pending orders
DELETE FROM orders
WHERE customer IN (
    SELECT customer FROM orders
    GROUP BY customer
    HAVING SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) = 0
);

SELECT '--- Orders after subquery delete ---' AS note;

SELECT * FROM orders;


-- =============================================================================
-- DELETE and Re-insert for TRUNCATE demo
-- =============================================================================

SELECT '--- Insert test data for TRUNCATE demo ---' AS note;

INSERT INTO orders (id, customer, product, amount, status) VALUES
    (10, 'Test1', 'Item1', 10, 'completed'),
    (11, 'Test2', 'Item2', 20, 'completed'),
    (12, 'Test3', 'Item3', 30, 'completed');

SELECT '--- Row count before TRUNCATE ---' AS note;

SELECT COUNT(*) AS before_truncate FROM orders;


-- =============================================================================
-- TRUNCATE (SQLite equivalent using DELETE)
-- =============================================================================

SELECT '--- TRUNCATE: deleting ALL rows (SQLite: DELETE without WHERE) ---' AS note;

-- In SQLite, DELETE without WHERE removes all rows
-- In other databases: TRUNCATE TABLE orders;
DELETE FROM orders;

SELECT '--- Row count after TRUNCATE ---' AS note;

SELECT COUNT(*) AS after_truncate FROM orders;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping orders table ---' AS note;

DROP TABLE orders;
