-- Aggregations - COUNT and SUM
-- -----------------------------------------------------------------------------
-- Aggregate functions collapse multiple rows into a single result. COUNT and
-- SUM are the most fundamental — COUNT tallies rows, SUM totals numeric values.
--
-- Key concepts:
-- 1. COUNT(*) vs COUNT(column) — NULL handling
-- 2. COUNT(DISTINCT ...) — unique values
-- 3. SUM with NULLs
-- 4. GROUP BY — per-group aggregation
-- 5. HAVING — filter after aggregation
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating sales table ---' AS note;

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    salesperson TEXT NOT NULL,
    region TEXT,
    product TEXT,
    quantity INTEGER,
    unit_price REAL,
    sale_date TEXT
);

INSERT INTO sales VALUES
    (1, 'Alice', 'North', 'Laptop', 2, 1200.00, '2024-01-10'),
    (2, 'Alice', 'North', 'Mouse', 10, 25.00, '2024-01-12'),
    (3, 'Bob', 'South', 'Laptop', 1, 1200.00, '2024-01-15'),
    (4, 'Bob', 'South', NULL, 5, 50.00, '2024-01-20'),
    (5, 'Carol', 'North', 'Monitor', 3, 450.00, '2024-02-01'),
    (6, 'Carol', 'North', 'Keyboard', 8, 75.00, '2024-02-05'),
    (7, 'David', 'South', 'Laptop', 1, 1200.00, '2024-02-10'),
    (8, 'David', 'South', 'Chair', 2, 280.00, '2024-02-15'),
    (9, 'Eve', 'West', NULL, 0, NULL, '2024-03-01'),
    (10, 'Eve', 'West', 'Headphones', 4, 150.00, '2024-03-05');


-- =============================================================================
-- COUNT
-- =============================================================================

SELECT '--- COUNT(*): total rows in table ---' AS note;

-- COUNT(*) counts all rows including NULLs
SELECT COUNT(*) AS total_sales FROM sales;

SELECT '--- COUNT(column): only non-NULL values ---' AS note;

-- COUNT(column) excludes NULLs
SELECT COUNT(product) AS products_sold FROM sales;
-- Returns 9 (row 9 has NULL product)

SELECT '--- COUNT(DISTINCT column): unique values ---' AS note;

SELECT
    COUNT(DISTINCT salesperson) AS unique_salespeople,
    COUNT(DISTINCT region) AS unique_regions,
    COUNT(DISTINCT product) AS unique_products
FROM sales;


-- =============================================================================
-- SUM
-- =============================================================================

SELECT '--- Total quantity sold ---' AS note;

-- SUM ignores NULLs
SELECT SUM(quantity) AS total_quantity FROM sales;

SELECT '--- Total revenue ---' AS note;

-- Compute line total then sum
SELECT SUM(quantity * unit_price) AS total_revenue FROM sales;

SELECT '--- SUM with NULLs: NULL rows are skipped ---' AS note;

-- Row 10 has unit_price = NULL, so quantity * unit_price = NULL, skipped by SUM
SELECT
    SUM(unit_price) AS total_unit_prices,
    COUNT(unit_price) AS non_null_prices
FROM sales;


-- =============================================================================
-- GROUP BY
-- =============================================================================

SELECT '--- Sales count and total per salesperson ---' AS note;

SELECT
    salesperson,
    COUNT(*) AS sale_count,
    SUM(quantity) AS total_qty,
    SUM(quantity * unit_price) AS total_revenue
FROM sales
GROUP BY salesperson
ORDER BY total_revenue DESC;

SELECT '--- Sales by region ---' AS note;

SELECT
    region,
    COUNT(*) AS sale_count,
    SUM(quantity * unit_price) AS total_revenue
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

SELECT '--- Sales per product (NULL product excluded from groups) ---' AS note;

-- NULL product groups together in most SQL engines
SELECT
    COALESCE(product, '(no product)') AS product,
    SUM(quantity) AS total_qty,
    SUM(quantity * unit_price) AS total_revenue
FROM sales
GROUP BY product
ORDER BY total_revenue DESC;


-- =============================================================================
-- HAVING (Filter After Aggregation)
-- =============================================================================

SELECT '--- Salespeople with more than 2 sales ---' AS note;

-- HAVING filters groups, WHERE filters rows
SELECT
    salesperson,
    COUNT(*) AS sale_count
FROM sales
GROUP BY salesperson
HAVING COUNT(*) > 2;

SELECT '--- Regions with total revenue over $2000 ---' AS note;

SELECT
    region,
    SUM(quantity * unit_price) AS total_revenue
FROM sales
GROUP BY region
HAVING SUM(quantity * unit_price) > 2000;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping sales table ---' AS note;

DROP TABLE sales;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - COUNT and SUM Differences
-- =============================================================================
--
-- COUNT and SUM are standard SQL and behave identically across databases.
-- Differences appear in extended features like COUNT with FILTER and
-- window function interactions.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                         | MySQL                         | PostgreSQL                     |
-- |--------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | COUNT(*)                 | Yes                            | Yes                           | Yes                            |
-- | COUNT(column)            | Ignores NULLs                  | Ignores NULLs                 | Ignores NULLs                  |
-- | COUNT(DISTINCT)          | Yes                            | Yes                           | Yes                            |
-- | COUNT with FILTER        | No                             | No                            | Yes (FILTER WHERE clause)      |
-- | SUM                      | Yes                            | Yes                           | Yes                            |
-- | SUM of all NULLs         | NULL                           | NULL                          | NULL                           |
-- | GROUP BY                 | Yes                            | Yes                           | Yes                            |
-- | GROUP BY position        | Yes (by ordinal)               | Yes (by ordinal)              | Yes (by ordinal)               |
-- | HAVING                   | Yes                            | Yes                           | Yes                            |
-- | HAVING without GROUP BY  | Allowed (single group)         | Not allowed                   | Not allowed                    |
-- | COUNT with OVER          | No (no window functions)       | Yes (MySQL 8.0+)              | Yes                            |
-- | COUNT with aggregate     | COUNT inside SUM possible      | COUNT inside SUM possible     | COUNT inside SUM possible      |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - Core COUNT/SUM work identically to other databases.
--    - No FILTER clause for conditional aggregation (use CASE instead).
--    - No window functions (COUNT() OVER()) in older versions.
--    - HAVING without GROUP BY is allowed (single-row result).
--
-- 2. MySQL:
--    - Standard behavior with one caveat: HAVING without GROUP BY is rejected.
--    - COUNT(DISTINCT) supports multiple columns: COUNT(DISTINCT col1, col2).
--    - MySQL 8.0+ supports window functions with COUNT/SUM OVER.
--
-- 3. PostgreSQL:
--    - Most feature-rich: FILTER (WHERE) clause for conditional aggregation.
--    - Example: COUNT(*) FILTER (WHERE status = 'active')
--    - Full window function support.
--    - HAVING without GROUP BY is not allowed.
--
-- Rule of thumb: COUNT(*) and SUM are portable. Use CASE inside SUM for
-- conditional counts in SQLite/MySQL. PostgreSQL's FILTER clause is cleaner
-- but not portable.
--
-- -----------------------------------------------------------------------------
