-- Filtering & Sorting - WHERE Clause
-- -----------------------------------------------------------------------------
-- The WHERE clause filters rows before aggregation or further processing.
-- It supports comparison operators, logical operators, and special predicates.
--
-- Key concepts:
-- 1. Comparison operators: =, !=, <>, <, >, <=, >=
-- 2. Logical operators: AND, OR, NOT
-- 3. Range predicates: BETWEEN
-- 4. Membership: IN, NOT IN
-- 5. Pattern matching: LIKE
-- 6. Null checking: IS NULL, IS NOT NULL
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating orders table ---' AS note;

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    product TEXT NOT NULL,
    category TEXT,
    amount REAL,
    order_date TEXT,
    status TEXT
);

INSERT INTO orders VALUES
    (101, 'Alice', 'Laptop', 'Electronics', 1200.00, '2024-01-15', 'completed'),
    (102, 'Bob', 'Mouse', 'Electronics', 25.00, '2024-01-16', 'completed'),
    (103, 'Carol', 'Desk', 'Furniture', 350.00, '2024-02-01', 'shipped'),
    (104, 'David', 'Keyboard', 'Electronics', 75.00, '2024-02-03', 'pending'),
    (105, 'Eve', 'Chair', 'Furniture', 280.00, '2024-02-10', 'completed'),
    (106, 'Frank', 'Monitor', 'Electronics', 450.00, '2024-03-01', 'shipped'),
    (107, 'Grace', 'Lamp', 'Furniture', 60.00, '2024-03-05', NULL),
    (108, 'Hank', 'Headphones', 'Electronics', 150.00, '2024-03-10', 'completed');


-- =============================================================================
-- Comparison Operators
-- =============================================================================

SELECT '--- Orders over $200 ---' AS note;

-- Greater than
SELECT order_id, customer_name, amount
FROM orders
WHERE amount > 200;

SELECT '--- Orders with amount exactly 25 ---' AS note;

-- Equality
SELECT order_id, customer_name, product
FROM orders
WHERE amount = 25;

SELECT '--- Electronics under $100 ---' AS note;

-- Combined conditions
SELECT order_id, product, amount
FROM orders
WHERE category = 'Electronics' AND amount < 100;


-- =============================================================================
-- Logical Operators (AND, OR, NOT)
-- =============================================================================

SELECT '--- Electronics OR amount > 300 ---' AS note;

-- OR: either condition
SELECT order_id, product, category, amount
FROM orders
WHERE category = 'Electronics' OR amount > 300;

SELECT '--- NOT pending orders ---' AS note;

-- NOT: exclude matching rows
SELECT order_id, customer_name, status
FROM orders
WHERE status != 'pending';


-- =============================================================================
-- BETWEEN (Range Predicate)
-- =============================================================================

SELECT '--- Orders between $100 and $500 (inclusive) ---' AS note;

-- BETWEEN includes both endpoints
SELECT order_id, product, amount
FROM orders
WHERE amount BETWEEN 100 AND 500;

SELECT '--- Orders in February 2024 ---' AS note;

-- BETWEEN works for dates too
SELECT order_id, customer_name, order_date
FROM orders
WHERE order_date BETWEEN '2024-02-01' AND '2024-02-29';


-- =============================================================================
-- IN and NOT IN
-- =============================================================================

SELECT '--- Orders in Electronics or Furniture ---' AS note;

-- IN: match any value in the list
SELECT order_id, product, category
FROM orders
WHERE category IN ('Electronics', 'Furniture');

SELECT '--- Exclude completed and shipped orders ---' AS note;

-- NOT IN: exclude matching values
SELECT order_id, customer_name, status
FROM orders
WHERE status NOT IN ('completed', 'shipped');


-- =============================================================================
-- LIKE (Pattern Matching)
-- =============================================================================

SELECT '--- Customers whose name starts with "A" ---' AS note;

-- % matches any sequence of characters
SELECT order_id, customer_name
FROM orders
WHERE customer_name LIKE 'A%';

SELECT '--- Products with "o" in the name ---' AS note;

-- _ matches a single character
SELECT order_id, product
FROM orders
WHERE product LIKE '%o%';

SELECT '--- Products with exactly 5 characters ---' AS note;

-- Each _ matches exactly one character
SELECT order_id, product
FROM orders
WHERE product LIKE '_____';


-- =============================================================================
-- IS NULL / IS NOT NULL
-- =============================================================================

SELECT '--- Orders with no status (NULL) ---' AS note;

-- NULL requires special syntax — = NULL does not work
SELECT order_id, customer_name, status
FROM orders
WHERE status IS NULL;

SELECT '--- Orders with a known status ---' AS note;

SELECT order_id, customer_name, status
FROM orders
WHERE status IS NOT NULL;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping orders table ---' AS note;

DROP TABLE orders;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - WHERE Clause Differences
-- =============================================================================
--
-- WHERE clause syntax is highly standardized, but there are subtle differences
-- in operator behavior and NULL handling.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Comparison operators         | =, !=, <>, <, >, <=, >=        | Same                          | Same                           |
-- | Logical operators            | AND, OR, NOT                   | Same                          | Same                           |
-- | BETWEEN                      | Yes (inclusive)                | Yes (inclusive)               | Yes (inclusive)                |
-- | IN / NOT IN                  | Yes                            | Yes                           | Yes                            |
-- | LIKE (case-insensitive)      | Depends on collation           | Depends on collation          | Depends on collation           |
-- | ILIKE (case-insensitive)     | No                             | No                            | Yes                            |
-- | GLOB (case-sensitive)        | Yes                            | No                            | No                             |
-- | REGEXP                       | No (not built-in)              | Yes                           | Yes (via ~ operator)           |
-- | IS NULL / IS NOT NULL        | Yes                            | Yes                           | Yes                            |
-- | NULL = NULL                  | NULL (not TRUE)                | NULL (not TRUE)               | NULL (not TRUE)                |
-- | EXISTS / NOT EXISTS          | Yes                            | Yes                           | Yes                            |
-- | ANY / ALL                    | Yes                            | Yes                           | Yes                            |
-- | COLLATE                      | Yes                            | Yes                           | Yes                            |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - GLOB for case-sensitive pattern matching (* and ? wildcards).
--    - No built-in REGEXP (use custom function or extension).
--    - LIKE is case-insensitive for ASCII by default.
--
-- 2. MySQL:
--    - REGEXP for regular expression matching.
--    - LIKE is case-insensitive by default (depends on collation).
--    - Backticks for identifiers: `column name`.
--
-- 3. PostgreSQL:
--    - ILIKE for case-insensitive LIKE.
--    - ~ operator for POSIX regular expressions.
--    - SIMILAR TO for SQL-style regex.
--    - Double quotes for identifiers: "column name".
--
-- -----------------------------------------------------------------------------
