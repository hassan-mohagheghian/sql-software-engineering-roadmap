-- Joins - Self JOIN
-- -----------------------------------------------------------------------------
-- A self JOIN joins a table to itself — essential for hierarchical data,
-- comparing rows, and finding relationships within the same dataset.
--
-- Key concepts:
-- 1. Employee-manager hierarchy
-- 2. Comparing rows (pairs, duplicates)
-- 3. Finding gaps in sequences
-- 4. Adjacent row comparison
-- 5. Recursive patterns
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating employees table ---' AS note;

CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    manager_id INTEGER,
    hire_date TEXT,
    salary REAL
);

INSERT INTO employees VALUES
    (1, 'Alice', NULL, '2018-01-15', 120000),
    (2, 'Bob', 1, '2019-03-20', 95000),
    (3, 'Carol', 1, '2019-06-01', 98000),
    (4, 'David', 2, '2020-09-10', 75000),
    (5, 'Eve', 2, '2020-11-15', 78000),
    (6, 'Frank', 3, '2021-02-28', 72000),
    (7, 'Grace', 3, '2021-04-10', 80000),
    (8, 'Hank', 4, '2022-06-01', 65000);


-- =============================================================================
-- Employee-Manager Hierarchy
-- =============================================================================

SELECT '--- Each employee with their manager ---' AS note;

-- Join employees to themselves to find managers
SELECT
    e.name AS employee,
    e.emp_id,
    m.name AS manager,
    m.emp_id AS manager_id
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;

SELECT '--- Employees who earn more than their manager ---' AS note;

-- Compare salary between employee and manager
SELECT
    e.name AS employee,
    e.salary AS emp_salary,
    m.name AS manager,
    m.salary AS mgr_salary,
    e.salary - m.salary AS difference
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;

SELECT '--- Manager and their direct reports ---' AS note;

-- Aggregate: count direct reports per manager
SELECT
    m.name AS manager,
    COUNT(e.emp_id) AS direct_reports,
    AVG(e.salary) AS avg_team_salary
FROM employees m
LEFT JOIN employees e ON m.emp_id = e.manager_id
GROUP BY m.emp_id, m.name
HAVING COUNT(e.emp_id) > 0
ORDER BY direct_reports DESC;


-- =============================================================================
-- Comparing Rows (Finding Duplicates/Pairs)
-- =============================================================================

-- Create an orders table for comparison example
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product TEXT,
    amount REAL,
    order_date TEXT
);

INSERT INTO orders VALUES
    (1, 101, 'Laptop', 999.99, '2024-01-15'),
    (2, 101, 'Mouse', 24.99, '2024-01-16'),
    (3, 102, 'Laptop', 999.99, '2024-01-15'),
    (4, 103, 'Keyboard', 79.99, '2024-02-01'),
    (5, 103, 'Mouse', 24.99, '2024-02-02');

SELECT '--- Find customers who ordered the same product ---' AS note;

-- Self join to find pairs of orders with same product
SELECT DISTINCT
    o1.customer_id AS customer_1,
    o2.customer_id AS customer_2,
    o1.product
FROM orders o1
INNER JOIN orders o2
    ON o1.product = o2.product
    AND o1.customer_id < o2.customer_id
ORDER BY o1.product, customer_1;

SELECT '--- Find duplicate orders (same product, same date) ---' AS note;

-- Self join to find exact duplicates
SELECT
    o1.order_id AS order_1,
    o2.order_id AS order_2,
    o1.product,
    o1.order_date
FROM orders o1
INNER JOIN orders o2
    ON o1.product = o2.product
    AND o1.order_date = o2.order_date
    AND o1.order_id < o2.order_id;


-- =============================================================================
-- Adjacent Row Comparison
-- =============================================================================

SELECT '--- Compare each order with the next order ---' AS note;

-- Self join with row number comparison
SELECT
    o1.order_id,
    o1.amount AS current_amount,
    o2.order_id AS next_order,
    o2.amount AS next_amount,
    o2.amount - o1.amount AS difference
FROM orders o1
LEFT JOIN orders o2 ON o2.order_id = o1.order_id + 1
ORDER BY o1.order_id;

-- Clean up demo table
DROP TABLE orders;


-- =============================================================================
-- Finding Gaps in Sequences
-- =============================================================================

-- Create a table with missing IDs
CREATE TABLE task_log (
    log_id INTEGER PRIMARY KEY,
    task_name TEXT
);

INSERT INTO task_log VALUES (1, 'Task A'), (2, 'Task B'), (4, 'Task D'), (5, 'Task E'), (7, 'Task G');

SELECT '--- Find gaps in log_id sequence ---' AS note;

-- Self join to find missing IDs
SELECT
    a.log_id + 1 AS gap_start,
    b.log_id - 1 AS gap_end
FROM task_log a
INNER JOIN task_log b ON a.log_id < b.log_id
WHERE NOT EXISTS (
    SELECT 1 FROM task_log c WHERE c.log_id = a.log_id + 1
)
AND b.log_id = (
    SELECT MIN(c.log_id) FROM task_log c WHERE c.log_id > a.log_id
)
ORDER BY gap_start;

DROP TABLE task_log;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping employees table ---' AS note;

DROP TABLE employees;
