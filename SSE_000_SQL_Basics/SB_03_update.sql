-- SQL Basics - UPDATE
-- -----------------------------------------------------------------------------
-- The UPDATE statement modifies existing rows in a table. You can update
-- single columns, multiple columns, and use conditions to target specific rows.
--
-- Key concepts:
-- 1. UPDATE ... SET — basic update
-- 2. UPDATE with WHERE — conditional update
-- 3. UPDATE with expressions — compute new values
-- 4. UPDATE with subquery — update based on other tables
-- 5. Caution: updating without WHERE affects all rows
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating employees table with sample data ---' AS note;

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    department TEXT,
    salary REAL,
    bonus REAL DEFAULT 0
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Johnson', 'Engineering', 95000, 0),
    (2, 'Bob', 'Smith', 'Marketing', 72000, 0),
    (3, 'Carol', 'Williams', 'Engineering', 105000, 0),
    (4, 'David', 'Brown', 'Sales', 68000, 0),
    (5, 'Eve', 'Davis', 'Marketing', 78000, 0);


-- =============================================================================
-- Basic UPDATE
-- =============================================================================

SELECT '--- Update department for id=4 ---' AS note;

-- Update a single column
UPDATE employees SET department = 'Product' WHERE id = 4;

SELECT '--- Update salary and bonus for id=2 ---' AS note;

-- Update multiple columns
UPDATE employees
SET salary = 80000, bonus = 5000
WHERE id = 2;

SELECT '--- Verify updated rows (id 2 and 4) ---' AS note;

SELECT * FROM employees WHERE id IN (2, 4);


-- =============================================================================
-- UPDATE with Expressions
-- =============================================================================

SELECT '--- Give everyone a 10% raise ---' AS note;

-- Give everyone a 10% raise
UPDATE employees SET salary = salary * 1.10;

SELECT '--- Add bonus based on department ---' AS note;

-- Add bonus based on department
UPDATE employees
SET bonus = CASE
    WHEN department = 'Engineering' THEN 10000
    WHEN department = 'Marketing' THEN 7500
    ELSE 5000
END;

SELECT '--- Employees after raises and bonuses ---' AS note;

SELECT first_name, department, salary, bonus FROM employees;


-- =============================================================================
-- UPDATE with Subquery
-- =============================================================================

SELECT '--- Double salary of highest-paid employee in each department ---' AS note;

-- Double the salary of the highest-paid employee in each department
UPDATE employees
SET salary = salary * 2
WHERE salary = (
    SELECT MAX(salary) FROM employees AS e2
    WHERE e2.department = employees.department
);

SELECT '--- Employees after subquery update ---' AS note;

SELECT first_name, department, salary FROM employees;


-- =============================================================================
-- UPDATE with JOIN (simulated via subquery in SQLite)
-- =============================================================================

SELECT '--- Create department_budgets table and cap salaries ---' AS note;

CREATE TABLE department_budgets (
    department TEXT PRIMARY KEY,
    max_salary REAL
);

INSERT INTO department_budgets VALUES
    ('Engineering', 120000),
    ('Marketing', 90000),
    ('Sales', 85000),
    ('Product', 95000);

-- Cap salaries at department max
UPDATE employees
SET salary = (
    SELECT max_salary FROM department_budgets
    WHERE department_budgets.department = employees.department
)
WHERE salary > (
    SELECT max_salary FROM department_budgets
    WHERE department_budgets.department = employees.department
);

SELECT '--- Employees with capped salaries vs department budgets ---' AS note;

SELECT e.first_name, e.department, e.salary, db.max_salary
FROM employees e
JOIN department_budgets db ON e.department = db.department;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE employees;
DROP TABLE department_budgets;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - UPDATE Differences
-- =============================================================================
--
-- UPDATE syntax is fairly standardized, but there are important differences
-- in how JOINs and subqueries work in UPDATE statements.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Basic UPDATE                 | Yes                            | Yes                           | Yes                            |
-- | UPDATE with JOIN             | No (use subquery)              | Yes (UPDATE ... JOIN)         | No (use subquery or FROM)      |
-- | UPDATE with subquery         | Yes                            | Yes                           | Yes                            |
-- | UPDATE from another table    | Subquery in SET                | JOIN syntax                   | FROM clause                    |
-- | RETURNING clause             | No                             | No                            | Yes                            |
-- | LIMIT on UPDATE              | No                             | Yes                           | No                             |
-- | ORDER BY on UPDATE           | No                             | Yes                           | No                             |
-- | CASE in SET                  | Yes                            | Yes                           | Yes                            |
-- | NULL handling                | SET column = NULL              | SET column = NULL             | SET column = NULL              |
-- | Default value                | SET column = DEFAULT           | SET column = DEFAULT          | SET column = DEFAULT           |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - No JOIN in UPDATE — use correlated subqueries instead.
--    - No RETURNING clause.
--    - UPDATE is transactional (can be rolled back).
--
-- 2. MySQL:
--    - UPDATE ... JOIN for updating from another table.
--    - LIMIT and ORDER BY supported (unusual).
--    - In non-strict mode, updates may silently truncate data.
--
-- 3. PostgreSQL:
--    - UPDATE ... FROM for updating from another table.
--    - RETURNING clause to get updated values.
--    - Most standards-compliant behavior.
--
-- -----------------------------------------------------------------------------
