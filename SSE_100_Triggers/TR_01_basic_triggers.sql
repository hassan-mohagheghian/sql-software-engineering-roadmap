-- Triggers - Basics
-- -----------------------------------------------------------------------------
-- Triggers automatically execute SQL code when specific events occur on a table
-- (INSERT, UPDATE, DELETE). They're useful for auditing, validation, and
-- maintaining derived data.
--
-- Key concepts:
-- 1. CREATE TRIGGER / DROP TRIGGER
-- 2. BEFORE vs AFTER triggers
-- 3. INSERT, UPDATE, DELETE triggers
-- 4. OLD and NEW row references
-- 5. Trigger timing and ordering
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample tables
-- =============================================================================

SELECT '--- Setup: Creating employees and audit_log tables ---' AS note;

CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department TEXT,
    salary REAL
);

CREATE TABLE audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT,
    action TEXT,
    old_values TEXT,
    new_values TEXT,
    changed_at TEXT DEFAULT (datetime('now'))
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Engineering', 95000),
    (2, 'Bob', 'Marketing', 72000),
    (3, 'Carol', 'Engineering', 105000);


-- =============================================================================
-- AFTER INSERT Trigger
-- =============================================================================

SELECT '--- Create trigger to log inserts ---' AS note;

-- SQLite syntax:
CREATE TRIGGER trg_employee_insert
AFTER INSERT ON employees
BEGIN
    INSERT INTO audit_log (table_name, action, new_values)
    VALUES ('employees', 'INSERT', NEW.name || ' - ' || NEW.department);
END;

-- Test: insert a new employee
INSERT INTO employees VALUES (4, 'David', 'Sales', 68000);

SELECT * FROM audit_log;


-- =============================================================================
-- AFTER UPDATE Trigger
-- =============================================================================

SELECT '--- Create trigger to log updates ---' AS note;

CREATE TRIGGER trg_employee_update
AFTER UPDATE ON employees
BEGIN
    INSERT INTO audit_log (table_name, action, old_values, new_values)
    VALUES ('employees', 'UPDATE',
            OLD.name || ' salary=' || OLD.salary,
            NEW.name || ' salary=' || NEW.salary);
END;

-- Test: update salary
UPDATE employees SET salary = 98000 WHERE emp_id = 1;

SELECT * FROM audit_log;


-- =============================================================================
-- AFTER DELETE Trigger
-- =============================================================================

SELECT '--- Create trigger to log deletes ---' AS note;

CREATE TRIGGER trg_employee_delete
AFTER DELETE ON employees
BEGIN
    INSERT INTO audit_log (table_name, action, old_values)
    VALUES ('employees', 'DELETE', OLD.name || ' - ' || OLD.department);
END;

-- Test: delete an employee
DELETE FROM employees WHERE emp_id = 4;

SELECT * FROM audit_log;


-- =============================================================================
-- BEFORE Triggers
-- =============================================================================


SELECT '--- BEFORE trigger: validate data before insert ---' AS note;

-- BEFORE triggers are useful for validation.
-- SQLite cannot directly modify NEW values.
-- Use RAISE() to reject invalid data.

CREATE TRIGGER trg_employee_before_insert
BEFORE INSERT ON employees
WHEN NEW.salary < 0
BEGIN
    SELECT RAISE(ABORT, 'Salary cannot be negative');
END;


-- Test: this insert will fail
INSERT INTO employees VALUES
    (5, 'Eve', 'Engineering', -1000);

-- Note: SQLite BEFORE triggers have limited ability to modify NEW values
-- MySQL and PostgreSQL allow: SET NEW.column = value


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping triggers and tables ---' AS note;

DROP TRIGGER IF EXISTS trg_employee_insert;
DROP TRIGGER IF EXISTS trg_employee_update;
DROP TRIGGER IF EXISTS trg_employee_delete;
DROP TRIGGER IF EXISTS trg_employee_before_insert;
DROP TABLE audit_log;
DROP TABLE employees;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - Basic Trigger Differences
-- =============================================================================
--
-- All three databases support triggers, but syntax and capabilities differ.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                         | MySQL                         | PostgreSQL                     |
-- |--------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | CREATE TRIGGER           | Yes                            | Yes                           | Yes                            |
-- | DROP TRIGGER             | Yes (IF EXISTS)                | Yes (IF EXISTS)               | Yes (IF EXISTS)                |
-- | BEFORE triggers          | Yes                            | Yes                           | Yes                            |
-- | AFTER triggers           | Yes                            | Yes                           | Yes                            |
-- | INSTEAD OF triggers      | No                             | No                            | Yes (on views)                 |
-- | INSERT trigger           | Yes                            | Yes                           | Yes                            |
-- | UPDATE trigger           | Yes                            | Yes                           | Yes                            |
-- | DELETE trigger           | Yes                            | Yes                           | Yes                            |
-- | NEW reference            | Yes (read-only in BEFORE)      | Yes (read/write in BEFORE)    | Yes (read/write in BEFORE)     |
-- | OLD reference            | Yes (read-only)                | Yes (read-only)               | Yes (read-only)                |
-- | Modify NEW in BEFORE     | Limited (SQLite 3.30+)         | Yes (SET NEW.col = val)       | Yes (NEW.col := val)           |
-- | Conditional trigger      | No                             | No                            | Yes (WHEN clause)              |
-- | Trigger on view          | No                             | No                            | Yes (INSTEAD OF)               |
-- | Multiple triggers        | Yes (execution order varies)   | Yes (FOLLOWS/PRECEDES)        | Yes (creation order)           |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - BEFORE triggers: NEW values are read-only (cannot modify in most cases).
--    - AFTER triggers: use for auditing and logging.
--    - No conditional WHEN clause on triggers.
--    - No INSTEAD OF triggers on views.
--    - Trigger execution order: creation order within same timing.
--
-- 2. MySQL:
--    - BEFORE triggers can modify NEW values: SET NEW.column = value.
--    - FOLLOWS/PRECEDES for explicit trigger ordering (MySQL 5.7+).
--    - No conditional WHEN clause (use IF inside trigger body).
--    - No INSTEAD OF triggers on views.
--
-- 3. PostgreSQL:
--    - Most complete trigger support.
--    - BEFORE triggers can modify NEW values freely.
--    - WHEN clause for conditional trigger execution.
--    - INSTEAD OF triggers on views.
--    - Execution order: creation order within same event/timing.
--
-- Rule of thumb: Use AFTER triggers for auditing (don't block the original
-- operation). Use BEFORE triggers for validation or data transformation.
-- Always be aware that triggers add overhead to every INSERT/UPDATE/DELETE.
--
-- -----------------------------------------------------------------------------
