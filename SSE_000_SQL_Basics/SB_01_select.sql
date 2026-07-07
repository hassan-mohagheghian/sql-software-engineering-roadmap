-- SQL Basics - SELECT Statement
-- -----------------------------------------------------------------------------
-- The SELECT statement is the foundation of SQL. It retrieves data from one
-- or more tables and is the most commonly used command in SQL.
--
-- Key concepts:
-- 1. SELECT ... FROM — basic retrieval
-- 2. SELECT * — retrieve all columns
-- 3. SELECT with aliases — rename columns in output
-- 4. SELECT DISTINCT — eliminate duplicate rows
-- 5. SELECT with expressions — computed columns
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create a sample table
-- =============================================================================

SELECT '--- Setup: Creating employees table and inserting sample data ---' AS note;

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    department TEXT,
    salary REAL,
    hire_date TEXT
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Johnson', 'Engineering', 95000, '2020-01-15'),
    (2, 'Bob', 'Smith', 'Marketing', 72000, '2019-06-01'),
    (3, 'Carol', 'Williams', 'Engineering', 105000, '2018-03-20'),
    (4, 'David', 'Brown', 'Sales', 68000, '2021-09-10'),
    (5, 'Eve', 'Davis', 'Marketing', 78000, '2020-07-22'),
    (6, 'Frank', 'Miller', 'Engineering', 110000, '2017-11-05'),
    (7, 'Grace', 'Wilson', 'Sales', 71000, '2022-01-30'),
    (8, 'Hank', 'Moore', 'Engineering', 98000, '2019-04-18');


-- =============================================================================
-- Basic SELECT
-- =============================================================================

SELECT '--- Retrieve all columns from employees ---' AS note;

-- Retrieve all columns
SELECT * FROM employees;

SELECT '--- Retrieve specific columns (first_name, last_name) ---' AS note;

-- Retrieve specific columns
SELECT first_name, last_name FROM employees;

SELECT '--- Retrieve with column aliases ---' AS note;

-- Retrieve with column aliases
SELECT
    first_name AS "First Name",
    last_name AS "Last Name",
    salary AS "Annual Salary"
FROM employees;


-- =============================================================================
-- SELECT DISTINCT
-- =============================================================================

SELECT '--- Get unique departments ---' AS note;

-- Get unique departments
SELECT DISTINCT department FROM employees;

SELECT '--- Count unique departments ---' AS note;

-- Count unique departments
SELECT COUNT(DISTINCT department) AS department_count FROM employees;


-- =============================================================================
-- SELECT with Expressions
-- =============================================================================

SELECT '--- Computed columns: annual salary and bonus ---' AS note;

-- Computed columns
SELECT
    first_name,
    last_name,
    salary,
    salary * 12 AS annual_salary,
    salary * 0.1 AS bonus
FROM employees;

SELECT '--- String concatenation: full_name ---' AS note;

-- String concatenation
SELECT
    first_name || ' ' || last_name AS full_name,
    department
FROM employees;

SELECT '--- Conditional expressions with CASE ---' AS note;

-- Conditional expressions with CASE
SELECT
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'Senior'
        WHEN salary >= 80000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS level
FROM employees;


-- =============================================================================
-- LIMIT and OFFSET
-- =============================================================================

SELECT '--- Top 3 highest salaries ---' AS note;

-- Top 3 highest salaries
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

SELECT '--- Pagination: page 2 (offset 3, limit 3) ---' AS note;

-- Pagination: page 2 (offset 3, limit 3)
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping employees table ---' AS note;

DROP TABLE employees;
