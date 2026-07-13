-- Filtering & Sorting - ORDER BY
-- -----------------------------------------------------------------------------
-- ORDER BY sorts the result set by one or more columns. It's essential for
-- presenting data in a meaningful order.
--
-- Key concepts:
-- 1. Default ordering (without ORDER BY)
-- 2. Single column sorting (ASC, DESC)
-- 3. Multi-column sorting
-- 4. Sorting by column position
-- 5. Sorting by expression
-- 6. NULLS FIRST / NULLS LAST
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating products table ---' AS note;

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT,
    price REAL,
    stock INTEGER,
    rating REAL
);

INSERT INTO products VALUES
    (1, 'Laptop', 'Electronics', 999.99, 50, 4.5),
    (2, 'Mouse', 'Electronics', 24.99, 200, 4.2),
    (3, 'Desk', 'Furniture', 349.99, 30, 4.8),
    (4, 'Chair', 'Furniture', 249.99, 45, 4.3),
    (5, 'Monitor', 'Electronics', 449.99, 75, 4.6),
    (6, 'Keyboard', 'Electronics', 79.99, 150, 4.1),
    (7, 'Lamp', 'Furniture', 59.99, NULL, 4.0),
    (8, 'Headphones', 'Electronics', 149.99, 100, NULL);


-- =============================================================================
-- Default Ordering (Without ORDER BY)
-- =============================================================================

SELECT '--- Products without ORDER BY (insertion order) ---' AS note;

-- Without ORDER BY, rows are returned in insertion order (rowid order in SQLite)
-- This is implementation-dependent — never rely on it in production
SELECT name, price
FROM products;

SELECT '--- Same query with explicit ORDER BY for predictable results ---' AS note;

-- Always use ORDER BY when order matters
SELECT name, price
FROM products
ORDER BY product_id;


-- =============================================================================
-- Single Column Sorting
-- =============================================================================

SELECT '--- Products sorted by price (ascending) ---' AS note;

-- ASC is the default (optional)
SELECT name, price
FROM products
ORDER BY price ASC;

SELECT '--- Products sorted by price (descending) ---' AS note;

-- DESC for highest first
SELECT name, price
FROM products
ORDER BY price DESC;

SELECT '--- Products sorted alphabetically ---' AS note;

-- Text sorting is alphabetical
SELECT name, category
FROM products
ORDER BY name;


-- =============================================================================
-- Multi-Column Sorting
-- =============================================================================

SELECT '--- Sort by category, then by price within each category ---' AS note;

-- First sort by category (ASC), then by price (DESC) within each group
SELECT name, category, price
FROM products
ORDER BY category ASC, price DESC;

SELECT '--- Sort by stock, then by name ---' AS note;

-- NULLs appear first by default in ascending order
SELECT name, stock, price
FROM products
ORDER BY stock, name;


-- =============================================================================
-- Sorting by Column Position
-- =============================================================================

SELECT '--- Sort by 3rd column (price) ---' AS note;

-- You can reference columns by position (1-indexed)
SELECT name, category, price
FROM products
ORDER BY 3;

SELECT '--- Sort by multiple positions ---' AS note;

SELECT name, category, price
FROM products
ORDER BY 2, 3 DESC;


-- =============================================================================
-- Sorting by Expression
-- =============================================================================

SELECT '--- Sort by discounted price (20% off) ---' AS note;

-- ORDER BY can use expressions
SELECT name, price, price * 0.8 AS discounted
FROM products
ORDER BY price * 0.8;

SELECT '--- Sort by name length ---' AS note;

-- Sort by computed value
SELECT name, LENGTH(name) AS name_length
FROM products
ORDER BY LENGTH(name) DESC;


-- =============================================================================
-- NULLS FIRST / NULLS LAST
-- =============================================================================

SELECT '--- NULLs last for stock ---' AS note;

-- Explicitly control NULL placement
SELECT name, stock
FROM products
ORDER BY stock NULLS LAST;

SELECT '--- NULLs first for rating ---' AS note;

SELECT name, rating
FROM products
ORDER BY rating DESC NULLS FIRST;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping products table ---' AS note;

DROP TABLE products;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - ORDER BY Differences
-- =============================================================================
--
-- ORDER BY is mostly standardized, but NULL handling and expression sorting
-- vary across databases.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Basic ORDER BY               | Yes                            | Yes                           | Yes                            |
-- | ASC / DESC                   | Yes                            | Yes                           | Yes                            |
-- | Multi-column sort            | Yes                            | Yes                           | Yes                            |
-- | Sort by column position      | Yes (1-indexed)                | Yes (1-indexed)               | Yes (1-indexed)                |
-- | Sort by expression           | Yes                            | Yes                           | Yes                            |
-- | NULLS FIRST / NULLS LAST     | Yes (3.30+)                    | No                            | Yes                            |
-- | NULL default position        | NULLs first (ASC)              | NULLs first (ASC)             | NULLs last (ASC)               |
-- | Sort by alias                | Yes                            | Yes                           | Yes                            |
-- | Sort by function result      | Yes                            | Yes                           | Yes                            |
-- | CASE in ORDER BY             | Yes                            | Yes                           | Yes                            |
-- | Random sort                  | RANDOM()                       | RAND()                        | RANDOM()                       |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - NULLS FIRST / NULLS LAST supported since 3.30.0.
--    - RANDOM() for random ordering.
--    - Can sort by column position (1-indexed).
--
-- 2. MySQL:
--    - No NULLS FIRST / NULLS LAST syntax.
--    - RAND() for random ordering.
--    - NULLs sort first in ASC, last in DESC by default.
--
-- 3. PostgreSQL:
--    - NULLS FIRST / NULLS LAST supported.
--    - RANDOM() for random ordering.
--    - NULLs sort last in ASC, first in DESC by default.
--    - Can sort by complex expressions and subqueries.
--
-- -----------------------------------------------------------------------------
