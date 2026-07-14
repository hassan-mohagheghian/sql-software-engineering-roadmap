-- Joins - CROSS JOIN
-- -----------------------------------------------------------------------------
-- CROSS JOIN produces the Cartesian product — every row from the left table
-- paired with every row from the right table. Useful for generating combinations
-- and test data, but dangerous on large tables.
--
-- Key concepts:
-- 1. Basic CROSS JOIN (Cartesian product)
-- 2. CROSS JOIN with WHERE (filtering combinations)
-- 3. Generating test data
-- 4. Calendar/date series generation
-- 5. Performance considerations
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample tables
-- =============================================================================

SELECT '--- Setup: Creating sizes and colors tables ---' AS note;

CREATE TABLE sizes (
    size_id INTEGER PRIMARY KEY,
    size_name TEXT NOT NULL
);

CREATE TABLE colors (
    color_id INTEGER PRIMARY KEY,
    color_name TEXT NOT NULL
);

INSERT INTO sizes VALUES (1, 'Small'), (2, 'Medium'), (3, 'Large');
INSERT INTO colors VALUES (1, 'Red'), (2, 'Blue'), (3, 'Green');


-- =============================================================================
-- Basic CROSS JOIN
-- =============================================================================

SELECT '--- All size-color combinations ---' AS note;

-- CROSS JOIN: 3 sizes × 3 colors = 9 rows
SELECT
    s.size_name,
    c.color_name
FROM sizes s
CROSS JOIN colors c;

SELECT '--- Equivalent using comma syntax ---' AS note;

-- Comma syntax is equivalent to CROSS JOIN
SELECT
    s.size_name,
    c.color_name
FROM sizes s, colors c;

SELECT '--- CROSS JOIN with aliases ---' AS note;

-- Using table aliases for readability
SELECT
    s.size_name AS size,
    c.color_name AS color
FROM sizes s
CROSS JOIN colors c
ORDER BY s.size_name, c.color_name;


-- =============================================================================
-- CROSS JOIN with WHERE
-- =============================================================================

SELECT '--- Filter: only certain combinations ---' AS note;

-- CROSS JOIN + WHERE = filtered Cartesian product
SELECT
    s.size_name,
    c.color_name
FROM sizes s
CROSS JOIN colors c
WHERE s.size_name != 'Small' OR c.color_name != 'Green';

SELECT '--- Valid product variants only ---' AS note;

-- Simulate: not all combinations are valid
SELECT
    s.size_name,
    c.color_name
FROM sizes s
CROSS JOIN colors c
WHERE
    (s.size_name = 'Large' AND c.color_name IN ('Red', 'Blue'))
    OR s.size_name != 'Large'
ORDER BY s.size_name, c.color_name;


-- =============================================================================
-- Generating Test Data
-- =============================================================================

SELECT '--- Generate number sequence 1-10 ---' AS note;

-- Cross join with a single-row table to generate sequences
CREATE TABLE nums (n INTEGER);
INSERT INTO nums VALUES (1), (2), (3), (4), (5);

-- Generate 25 rows (5 × 5)
SELECT
    a.n * 5 + b.n AS sequence_num
FROM nums a
CROSS JOIN nums b
ORDER BY sequence_num;

SELECT '--- Generate date pairs ---' AS note;

-- Create a dates table
CREATE TABLE dates (
    date_val TEXT
);

INSERT INTO dates VALUES ('2024-01-01'), ('2024-01-02'), ('2024-01-03');

-- All date pairs
SELECT
    d1.date_val AS start_date,
    d2.date_val AS end_date
FROM dates d1
CROSS JOIN dates d2
WHERE d1.date_val <= d2.date_val
ORDER BY d1.date_val, d2.date_val;

-- Clean up demo tables
DROP TABLE nums;
DROP TABLE dates;


-- =============================================================================
-- CROSS JOIN with Aggregation
-- =============================================================================

SELECT '--- Pivot: products × regions ---' AS note;

-- Create sales data
CREATE TABLE sales (
    product TEXT,
    region TEXT,
    amount INTEGER
);

INSERT INTO sales VALUES
    ('Laptop', 'North', 10),
    ('Laptop', 'South', 8),
    ('Mouse', 'North', 25),
    ('Mouse', 'East', 15);

-- Get all products and regions
SELECT DISTINCT product FROM sales
UNION
SELECT DISTINCT region FROM sales;

-- Cross join to ensure all combinations exist
SELECT
    p.product,
    r.region,
    COALESCE(s.amount, 0) AS sales
FROM (SELECT DISTINCT product FROM sales) p
CROSS JOIN (SELECT DISTINCT region FROM sales) r
LEFT JOIN sales s ON p.product = s.product AND r.region = s.region
ORDER BY p.product, r.region;

DROP TABLE sales;


-- =============================================================================
-- Performance Warning
-- =============================================================================

-- CROSS JOIN produces M × N rows!
-- 1000 rows × 1000 rows = 1,000,000 rows
-- Always filter or use only small tables


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE colors;
DROP TABLE sizes;