-- Filtering & Sorting - DISTINCT
-- -----------------------------------------------------------------------------
-- DISTINCT eliminates duplicate rows from query results. It's applied to the
-- entire SELECT list, not individual columns.
--
-- Key concepts:
-- 1. DISTINCT — remove duplicate rows
-- 2. DISTINCT ON — keep first row per group (PostgreSQL)
-- 3. COUNT(DISTINCT ...) — count unique values
-- 4. Performance implications
-- 5. NULL handling with DISTINCT
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating employees table ---' AS note;

CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department TEXT,
    city TEXT,
    salary REAL
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Engineering', 'New York', 95000),
    (2, 'Bob', 'Marketing', 'London', 72000),
    (3, 'Carol', 'Engineering', 'New York', 105000),
    (4, 'David', 'Sales', 'Paris', 68000),
    (5, 'Eve', 'Marketing', 'London', 78000),
    (6, 'Frank', 'Engineering', 'New York', 110000),
    (7, 'Grace', 'Sales', 'Paris', 71000),
    (8, 'Hank', 'Engineering', 'New York', 98000),
    (9, 'James', 'Sales', 'New York', 98000);


-- =============================================================================
-- DISTINCT Basics
-- =============================================================================

SELECT '--- All departments (with duplicates) ---' AS note;

-- Without DISTINCT: shows duplicate departments
SELECT department
FROM employees;

SELECT '--- Unique departments only ---' AS note;

-- DISTINCT removes duplicate rows from the result
SELECT DISTINCT department
FROM employees;

SELECT '--- Unique cities ---' AS note;

SELECT DISTINCT city
FROM employees;

SELECT '--- Unique department-city combinations ---' AS note;

-- DISTINCT applies to the entire row, not individual columns
SELECT DISTINCT department, city
FROM employees
ORDER BY department;


-- =============================================================================
-- DISTINCT with NULLs
-- =============================================================================

-- Add some NULL values for demonstration
INSERT INTO employees VALUES (10, 'Ivy', NULL, 'New York', 65000);
INSERT INTO employees VALUES (11, 'Jack', NULL, NULL, 80000);

SELECT '--- DISTINCT treats NULLs as equal ---' AS note;

-- All NULLs collapse into one group
SELECT DISTINCT department
FROM employees
ORDER BY department;

SELECT '--- Unique (department, city) with NULLs ---' AS note;

SELECT DISTINCT department, city
FROM employees
ORDER BY department;


-- =============================================================================
-- COUNT(DISTINCT ...)
-- =============================================================================

SELECT '--- Count unique departments ---' AS note;

-- COUNT(DISTINCT col) counts unique non-NULL values
SELECT COUNT(DISTINCT department) AS unique_departments
FROM employees;

SELECT '--- Count unique cities per department ---' AS note;

SELECT
    department,
    COUNT(DISTINCT city) AS unique_cities,
    COUNT(DISTINCT name) AS employee_count
FROM employees
WHERE department IS NOT NULL
GROUP BY department;

SELECT '--- Distinct salaries ---' AS note;

-- Check if any employees share the same salary
SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT salary) AS unique_salaries
FROM employees;


-- =============================================================================
-- DISTINCT ON (PostgreSQL)
-- =============================================================================

-- NOTE: DISTINCT ON is PostgreSQL-specific, not supported in SQLite or MySQL

SELECT '--- DISTINCT ON: first employee per department ---' AS note;

-- PostgreSQL syntax:
-- SELECT DISTINCT ON (department) department, name, salary
-- FROM employees
-- WHERE department IS NOT NULL
-- ORDER BY department, salary DESC;

-- SQLite alternative: use window functions or subquery
SELECT department, name, salary
FROM employees e1
WHERE department IS NOT NULL
AND emp_id = (
    SELECT emp_id
    FROM employees e2
    WHERE e2.department = e1.department
    ORDER BY salary DESC
    LIMIT 1
)
ORDER BY department;


-- =============================================================================
-- DISTINCT with ORDER BY and LIMIT
-- =============================================================================

SELECT '--- Top unique salary per department ---' AS note;

-- Combine DISTINCT with other clauses
SELECT DISTINCT department, salary
FROM employees
WHERE department IS NOT NULL
ORDER BY salary DESC
LIMIT 5;


-- =============================================================================
-- Performance Note
-- =============================================================================

SELECT '--- DISTINCT is expensive on large datasets ---' AS note;

-- DISTINCT requires sorting/hashing the entire result set
-- Alternatives for better performance:
-- 1. Use GROUP BY instead (often optimized better)
-- 2. Use EXISTS/NOT EXISTS for existence checks
-- 3. Use UNION (which inherently removes duplicates)

-- Example: same result, different approaches
-- Slow: SELECT DISTINCT department FROM employees;
-- Faster: SELECT department FROM employees GROUP BY department;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping employees table ---' AS note;

DROP TABLE employees;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - DISTINCT Differences
-- =============================================================================
--
-- DISTINCT behavior is standardized, but there are syntax differences and
-- database-specific extensions.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | SELECT DISTINCT              | Yes                            | Yes                           | Yes                            |
-- | DISTINCT ON (col)            | No                             | No                            | Yes                            |
-- | COUNT(DISTINCT col)          | Yes                            | Yes                           | Yes                            |
-- | DISTINCT in subquery         | Yes                            | Yes                           | Yes                            |
-- | DISTINCT with ORDER BY       | Yes                            | Yes                           | Yes                            |
-- | DISTINCT with aggregate      | Yes                            | Yes                           | Yes                            |
-- | NULL handling                | All NULLs collapse to one group | All NULLs collapse to one group | All NULLs collapse to one group |
-- | Performance optimization     | GROUP BY alternative           | GROUP BY alternative          | GROUP BY alternative           |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - DISTINCT works as expected.
--    - No DISTINCT ON — use window functions instead.
--    - GROUP BY is often faster than DISTINCT for large datasets.
--
-- 2. MySQL:
--    - DISTINCT works as expected.
--    - No DISTINCT ON — use window functions instead.
--    - DISTINCTROW is a MySQL-specific alias for DISTINCT.
--
-- 3. PostgreSQL:
--    - DISTINCT ON (col1, col2) for keeping first row per group.
--    - Most powerful DISTINCT implementation.
--    - Can combine DISTINCT ON with ORDER BY for deterministic results.
--
-- -----------------------------------------------------------------------------
