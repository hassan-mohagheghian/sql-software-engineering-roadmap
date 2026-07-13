-- Filtering & Sorting - CASE Expression
-- -----------------------------------------------------------------------------
-- CASE is SQL's conditional expression — it lets you create if/else logic
-- directly in queries. Essential for data transformation and categorization.
--
-- Key concepts:
-- 1. Simple CASE — compare a value against alternatives
-- 2. Searched CASE — test conditions in order
-- 3. CASE in SELECT — transform output
-- 4. CASE in WHERE — conditional filtering
-- 5. CASE in ORDER BY — custom sort order
-- 6. CASE with aggregation — conditional counts/sums
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating orders table ---' AS note;

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer TEXT NOT NULL,
    product TEXT,
    quantity INTEGER,
    unit_price REAL,
    status TEXT,
    region TEXT
);

INSERT INTO orders VALUES
    (1, 'Alice', 'Laptop', 1, 999.99, 'completed', 'North'),
    (2, 'Bob', 'Mouse', 5, 24.99, 'completed', 'South'),
    (3, 'Carol', 'Keyboard', 2, 79.99, 'pending', 'North'),
    (4, 'David', 'Monitor', 1, 449.99, 'shipped', 'West'),
    (5, 'Eve', 'Headphones', 3, 149.99, 'completed', 'South'),
    (6, 'Frank', 'Desk', 1, 349.99, 'cancelled', 'North'),
    (7, 'Grace', 'Chair', 2, 249.99, 'pending', 'West'),
    (8, 'Hank', 'Lamp', 4, 59.99, 'completed', 'North');


-- =============================================================================
-- Simple CASE
-- =============================================================================

SELECT '--- Map status codes to labels ---' AS note;

-- Simple CASE compares a single value
SELECT
    order_id,
    status,
    CASE status
        WHEN 'completed' THEN 'Done'
        WHEN 'pending' THEN 'Awaiting'
        WHEN 'shipped' THEN 'In Transit'
        WHEN 'cancelled' THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_label
FROM orders;

SELECT '--- Compare region against values ---' AS note;

SELECT
    order_id,
    region,
    CASE region
        WHEN 'North' THEN 'N'
        WHEN 'South' THEN 'S'
        WHEN 'East' THEN 'E'
        WHEN 'West' THEN 'W'
        ELSE '-'
    END AS region_code
FROM orders;


-- =============================================================================
-- Searched CASE
-- =============================================================================

SELECT '--- Categorize orders by total value ---' AS note;

-- Searched CASE tests multiple independent conditions
SELECT
    order_id,
    customer,
    quantity * unit_price AS total,
    CASE
        WHEN quantity * unit_price >= 500 THEN 'High Value'
        WHEN quantity * unit_price >= 100 THEN 'Medium Value'
        WHEN quantity * unit_price >= 0 THEN 'Low Value'
        ELSE 'Invalid'
    END AS value_category
FROM orders;

SELECT '--- Classify quantity levels ---' AS note;

SELECT
    order_id,
    product,
    quantity,
    CASE
        WHEN quantity >= 5 THEN 'Bulk'
        WHEN quantity >= 2 THEN 'Multiple'
        ELSE 'Single'
    END AS quantity_level
FROM orders;


-- =============================================================================
-- CASE in SELECT (Data Transformation)
-- =============================================================================

SELECT '--- Pivot-like display with CASE ---' AS note;

-- Create columns from row values
SELECT
    customer,
    SUM(CASE WHEN region = 'North' THEN 1 ELSE 0 END) AS north_orders,
    SUM(CASE WHEN region = 'South' THEN 1 ELSE 0 END) AS south_orders,
    SUM(CASE WHEN region = 'West' THEN 1 ELSE 0 END) AS west_orders
FROM orders
GROUP BY customer;

SELECT '--- Show completed vs pending totals ---' AS note;

SELECT
    customer,
    SUM(CASE WHEN status = 'completed' THEN quantity * unit_price ELSE 0 END) AS completed_total,
    SUM(CASE WHEN status = 'pending' THEN quantity * unit_price ELSE 0 END) AS pending_total
FROM orders
GROUP BY customer;


-- =============================================================================
-- CASE in WHERE (Conditional Filtering)
-- =============================================================================

SELECT '--- Filter: high-value OR pending orders ---' AS note;

-- Use CASE in WHERE for complex conditions
SELECT order_id, customer, quantity * unit_price AS total, status
FROM orders
WHERE
    CASE
        WHEN status = 'pending' THEN 1
        WHEN quantity * unit_price > 200 THEN 1
        ELSE 0
    END = 1;


-- =============================================================================
-- CASE in ORDER BY (Custom Sort)
-- =============================================================================

SELECT '--- Custom sort: pending first, then by value ---' AS note;

-- Sort by custom priority
SELECT order_id, status, quantity * unit_price AS total
FROM orders
ORDER BY
    CASE status
        WHEN 'pending' THEN 1
        WHEN 'shipped' THEN 2
        WHEN 'completed' THEN 3
        WHEN 'cancelled' THEN 4
        ELSE 5
    END,
    total DESC;


-- =============================================================================
-- CASE with Aggregation
-- =============================================================================

SELECT '--- Count by status category ---' AS note;

-- Conditional aggregation
SELECT
    SUM(CASE WHEN status IN ('completed', 'shipped') THEN 1 ELSE 0 END) AS fulfilled,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS awaiting,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders;

SELECT '--- Average order value by region ---' AS note;

-- Use CASE to split aggregates
SELECT
    region,
    AVG(CASE WHEN status = 'completed' THEN quantity * unit_price END) AS avg_completed,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending_count
FROM orders
GROUP BY region;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping orders table ---' AS note;

DROP TABLE orders;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - CASE Expression Differences
-- =============================================================================
--
-- CASE is part of the SQL standard and works identically across databases.
-- The differences are in related conditional functions.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Simple CASE                  | Yes                            | Yes                           | Yes                            |
-- | Searched CASE                | Yes                            | Yes                           | Yes                            |
-- | NULL handling in CASE        | Use IS NULL                    | Use IS NULL                   | Use IS NULL                    |
-- | NULLIF(a, b)                 | Yes                            | Yes                           | Yes                            |
-- | COALESCE(a, b, ...)          | Yes                            | Yes                           | Yes                            |
-- | IF(condition, true, false)   | No (use CASE)                  | Yes                           | No (use CASE)                  |
-- | IFNULL(a, b)                 | No (use COALESCE)              | Yes                           | No (use COALESCE)              |
-- | NULLIFNULL(a, b)             | No                             | No                            | No                             |
-- | GREATEST / LEAST             | Yes (3.33+)                    | Yes                           | Yes                            |
-- | DECODE (Oracle-style)        | No                             | Yes                           | No                             |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - CASE is the only conditional expression.
--    - No IF() or IFNULL() — use COALESCE() instead.
--    - GREATEST/LEAST supported since 3.33.0.
--
-- 2. MySQL:
--    - IF(condition, true, false) shorthand.
--    - IFNULL(a, b) shorthand for COALESCE(a, b).
--    - DECODE() for Oracle compatibility.
--
-- 3. PostgreSQL:
--    - CASE is the standard conditional expression.
--    - No IF() or IFNULL() — use COALESCE() instead.
--    - GREATEST/LEAST for finding min/max of arguments.
--
-- Rule of thumb: Use CASE for portability across all databases.
--
-- -----------------------------------------------------------------------------