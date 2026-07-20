-- Aggregations - AVG, MIN, MAX
-- -----------------------------------------------------------------------------
-- These aggregate functions find the average, minimum, and maximum values.
-- Combined with GROUP BY, they reveal distribution patterns in your data.
--
-- Key concepts:
-- 1. AVG — arithmetic mean (NULLs excluded)
-- 2. MIN / MAX — smallest and largest values
-- 3. AVG of expressions
-- 4. MIN/MAX with GROUP BY
-- 5. Statistical aggregates (SQLite doesn't have built-in STDDEV/VARIANCE)
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating employees table ---' AS note;

CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department TEXT,
    salary REAL,
    hire_date TEXT,
    performance_score INTEGER
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Engineering', 95000, '2020-01-15', 92),
    (2, 'Bob', 'Marketing', 72000, '2019-06-01', 78),
    (3, 'Carol', 'Engineering', 105000, '2018-03-20', 95),
    (4, 'David', 'Sales', 68000, '2021-09-10', 71),
    (5, 'Eve', 'Marketing', 78000, '2020-07-22', 85),
    (6, 'Frank', 'Engineering', 110000, '2017-11-05', 88),
    (7, 'Grace', 'Sales', 71000, '2022-01-30', 74),
    (8, 'Hank', 'Engineering', 98000, '2019-04-18', 90),
    (9, 'Ivy', 'Sales', 65000, '2023-02-14', NULL);


-- =============================================================================
-- AVG
-- =============================================================================

SELECT '--- Average salary across all employees ---' AS note;

-- AVG excludes NULLs by default
SELECT AVG(salary) AS avg_salary
FROM employees;

SELECT '--- Average salary per department ---' AS note;

SELECT
    department,
    COUNT(*) AS headcount,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

SELECT '--- Average performance score (NULLs excluded) ---' AS note;

-- Row 9 has NULL performance_score — excluded from average
SELECT
    COUNT(*) AS total_employees,
    COUNT(performance_score) AS scored_employees,
    AVG(performance_score) AS avg_score
FROM employees;

SELECT '--- Average of computed expression ---' AS note;

-- AVG can operate on expressions
SELECT
    department,
    AVG(salary / 1000) AS avg_salary_k
FROM employees
GROUP BY department;


-- =============================================================================
-- MIN and MAX
-- =============================================================================

SELECT '--- Highest and lowest salaries ---' AS note;

SELECT
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;

SELECT '--- Min/max salary per department ---' AS note;

SELECT
    department,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    MAX(salary) - MIN(salary) AS salary_range
FROM employees
GROUP BY department;

SELECT '--- Earliest and latest hire dates ---' AS note;

-- MIN/MAX work on dates (stored as text in ISO format)
SELECT
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire
FROM employees;

SELECT '--- Min/max performance score ---' AS note;

-- NULLs are excluded from MIN/MAX
SELECT
    MIN(performance_score) AS lowest_score,
    MAX(performance_score) AS highest_score
FROM employees;


-- =============================================================================
-- Combined Statistics
-- =============================================================================

SELECT '--- Salary statistics per department ---' AS note;

-- Combine multiple aggregates in one query
SELECT
    department,
    COUNT(*) AS headcount,
    MIN(salary) AS min_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    MAX(salary) AS max_salary,
    MAX(salary) - MIN(salary) AS spread
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

SELECT '--- Overall company statistics ---' AS note;

-- Single-row summary
SELECT
    COUNT(*) AS total_employees,
    MIN(salary) AS min_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_payroll
FROM employees;


-- =============================================================================
-- AVG with Conditional Logic
-- =============================================================================

SELECT '--- Average salary: senior vs junior ---' AS note;

-- Use CASE inside AVG for conditional averaging
SELECT
    ROUND(AVG(CASE
        WHEN hire_date < '2020-01-01' THEN salary
    END), 2) AS avg_senior_salary,
    ROUND(AVG(CASE
        WHEN hire_date >= '2020-01-01' THEN salary
    END), 2) AS avg_junior_salary
FROM employees;

SELECT '--- Average performance for high vs low salary ---' AS note;

SELECT
    CASE
        WHEN salary >= 90000 THEN 'High Salary'
        ELSE 'Low Salary'
    END AS salary_band,
    ROUND(AVG(performance_score), 1) AS avg_performance,
    COUNT(*) AS count
FROM employees
GROUP BY salary_band;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping employees table ---' AS note;

DROP TABLE employees;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - AVG, MIN, MAX Differences
-- =============================================================================
--
-- AVG, MIN, and MAX are standard SQL and behave almost identically across
-- databases. The main differences are statistical aggregates and FILTER support.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                         | MySQL                         | PostgreSQL                     |
-- |--------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | AVG                      | Yes                            | Yes                           | Yes                            |
-- | AVG with NULLs           | Excludes NULLs                 | Excludes NULLs                | Excludes NULLs                 |
-- | MIN                      | Yes                            | Yes                           | Yes                            |
-- | MAX                      | Yes                            | Yes                           | Yes                            |
-- | MIN/MAX on TEXT          | Lexicographic                  | Lexicographic                 | Lexicographic                  |
-- | MIN/MAX on dates         | Works on ISO text              | Works on DATE type            | Works on DATE type             |
-- | COUNT with FILTER        | No                             | No                            | Yes (FILTER WHERE clause)      |
-- | AVG with FILTER          | No                             | No                            | Yes (FILTER WHERE clause)      |
-- | STDDEV                   | No built-in                    | STDDEV() / STDDEV_POP()      | STDDEV() / STDDEV_POP()       |
-- | VARIANCE                 | No built-in                    | VARIANCE() / VAR_POP()       | VARIANCE() / VAR_POP()        |
-- | PERCENTILE_CONT          | No                             | No                            | Yes (ordered-set aggregate)    |
-- | Conditional AVG          | Use CASE inside AVG            | Use CASE inside AVG           | FILTER or CASE inside AVG      |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - Core AVG, MIN, MAX work identically to other databases.
--    - No built-in statistical aggregates (STDDEV, VARIANCE).
--    - Use CASE inside AVG for conditional averaging.
--    - No FILTER clause for conditional aggregation.
--
-- 2. MySQL:
--    - Standard AVG, MIN, MAX with full support.
--    - MySQL 8.0+ provides STDDEV(), VARIANCE() and population/sample variants.
--    - No FILTER clause — use CASE inside aggregate functions.
--    - MIN/MAX work on DATE/DATETIME types natively.
--
-- 3. PostgreSQL:
--    - Most feature-rich: FILTER (WHERE) clause for conditional aggregation.
--    - Example: AVG(salary) FILTER (WHERE department = 'Engineering')
--    - Full statistical aggregate library: STDDEV, VARIANCE, PERCENTILE_CONT.
--    - Ordered-set aggregates for advanced analytics.
--
-- Rule of thumb: AVG, MIN, MAX are portable. For statistical analysis, use
-- MySQL or PostgreSQL. For conditional aggregation, PostgreSQL's FILTER is
-- cleaner but CASE inside AVG works everywhere.
--
-- -----------------------------------------------------------------------------
