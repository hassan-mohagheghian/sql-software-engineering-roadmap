-- Data Types - Boolean and NULL
-- -----------------------------------------------------------------------------
-- Boolean values represent TRUE/FALSE logic. NULL represents missing or unknown
-- data — a third logical state that behaves differently from TRUE or FALSE.
-- Understanding NULL semantics is one of the most important SQL concepts.
--
-- Key concepts:
-- 1. BOOLEAN in SQLite (stored as 0/1)
-- 2. NULL is not a value — it's the absence of a value
-- 3. NULL in comparisons always yields NULL (unknown)
-- 4. IS NULL / IS NOT NULL — the only correct way to check
-- 5. NULL propagation in expressions and aggregates
-- 6. COALESCE and NULLIF for NULL handling
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating tasks table ---' AS note;

CREATE TABLE tasks (
    task_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    is_completed INTEGER,  -- SQLite uses 0/1 for boolean
    priority TEXT,
    assigned_to TEXT,
    due_date TEXT
);

INSERT INTO tasks VALUES
    (1, 'Design database schema', 1, 'high', 'Alice', '2024-03-01'),
    (2, 'Write unit tests', 0, 'high', 'Bob', '2024-03-05'),
    (3, 'Update README', 1, 'low', NULL, NULL),
    (4, 'Fix login bug', 0, 'medium', 'Carol', '2024-03-10'),
    (5, 'Deploy to staging', 0, NULL, NULL, '2024-03-15'),
    (6, 'Code review', 1, 'low', 'Alice', NULL);


-- =============================================================================
-- Boolean Basics
-- =============================================================================

SELECT '--- SQLite stores booleans as INTEGER (0 = false, 1 = true) ---' AS note;

SELECT
    task_id,
    title,
    is_completed,
    CASE WHEN is_completed THEN 'Yes' ELSE 'No' END AS status_text
FROM tasks;

SELECT '--- Filter completed vs incomplete tasks ---' AS note;

SELECT title
FROM tasks
WHERE is_completed = 1;

SELECT title
FROM tasks
WHERE is_completed = 0;

SELECT '--- Boolean expressions with AND/OR ---' AS note;

-- High priority AND not completed
SELECT title, priority
FROM tasks
WHERE priority = 'high' AND is_completed = 0;


-- =============================================================================
-- NULL: The Absence of Value
-- =============================================================================

SELECT '--- NULL is NOT equal to anything, including itself ---' AS note;

-- These all return 0 rows:
SELECT * FROM tasks WHERE assigned_to = NULL;       -- WRONG: 0 results
SELECT * FROM tasks WHERE assigned_to != NULL;      -- WRONG: 0 results
SELECT * FROM tasks WHERE assigned_to = assigned_to; -- WRONG: excludes NULLs

SELECT '--- Correct: use IS NULL / IS NOT NULL ---' AS note;

SELECT title, assigned_to
FROM tasks
WHERE assigned_to IS NULL;

SELECT title, assigned_to
FROM tasks
WHERE assigned_to IS NOT NULL;


-- =============================================================================
-- NULL in Expressions
-- =============================================================================

SELECT '--- NULL propagates through arithmetic ---' AS note;

-- Any arithmetic with NULL yields NULL
SELECT
    NULL + 1 AS result,
    10 * NULL AS result2,
    NULL || 'text' AS result3;

SELECT '--- NULL in comparisons returns NULL (unknown) ---' AS note;

SELECT
    NULL = 1 AS eq,
    NULL <> 1 AS neq,
    NULL > 1 AS gt,
    NULL < 1 AS lt;

SELECT '--- NULL in CASE expressions ---' AS note;

-- CASE handles NULL through IS NULL / IS NOT NULL
SELECT
    title,
    assigned_to,
    CASE
        WHEN assigned_to IS NULL THEN 'Unassigned'
        ELSE assigned_to
    END AS assignee_display
FROM tasks;


-- =============================================================================
-- NULL in Aggregates
-- =============================================================================

SELECT '--- COUNT(*) counts all rows, COUNT(column) ignores NULLs ---' AS note;

SELECT
    COUNT(*) AS total_tasks,
    COUNT(assigned_to) AS assigned_count,
    COUNT(priority) AS prioritized_count
FROM tasks;

SELECT '--- SUM ignores NULLs (does NOT treat as 0) ---' AS note;

-- NULLs are simply skipped
SELECT
    SUM(CASE WHEN is_completed THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN is_completed = 0 THEN 1 ELSE 0 END) AS incomplete
FROM tasks;


-- =============================================================================
-- COALESCE: Replace NULL with a Default
-- =============================================================================

SELECT '--- COALESCE returns first non-NULL value ---' AS note;

SELECT
    task_id,
    title,
    COALESCE(assigned_to, 'Unassigned') AS assignee,
    COALESCE(priority, 'No priority') AS prio,
    COALESCE(due_date, 'No deadline') AS deadline
FROM tasks;

SELECT '--- COALESCE with multiple fallbacks ---' AS note;

SELECT
    COALESCE(NULL, NULL, 'fallback') AS result,
    COALESCE(NULL, 'first', 'second') AS result2;


-- =============================================================================
-- NULLIF: Return NULL When Values Match
-- =============================================================================

SELECT '--- NULLIF(a, b) returns NULL if a = b, else returns a ---' AS note;

-- Useful for preventing division by zero
SELECT
    10 / NULLIF(0, 0) AS safe_division;  -- Returns NULL instead of error

SELECT '--- NULLIF in practice: avoid divide-by-zero ---' AS note;

CREATE TABLE scores (
    student TEXT,
    total_points INTEGER,
    attempts INTEGER
);

INSERT INTO scores VALUES
    ('Alice', 95, 3),
    ('Bob', 0, 0),
    ('Carol', 80, 2);

-- Safe average: NULLIF prevents division by zero
SELECT
    student,
    total_points,
    attempts,
    total_points / NULLIF(attempts, 0) AS avg_score
FROM scores;

DROP TABLE scores;


-- =============================================================================
-- Three-Valued Logic in WHERE
-- =============================================================================

SELECT '--- NOT NULL returns NULL, not TRUE ---' AS note;

-- NOT NULL is NULL
SELECT NOT NULL AS result;

-- NULL AND TRUE is NULL
SELECT NULL AND 1 AS result;

-- NULL OR TRUE is TRUE
SELECT NULL OR 1 AS result;

SELECT '--- Filtering NULLs in complex conditions ---' AS note;

-- Tasks that are either completed or have no priority
SELECT title, is_completed, priority
FROM tasks
WHERE is_completed = 1 OR priority IS NULL;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tasks table ---' AS note;

DROP TABLE tasks;


-- =============================================================================
-- Bonus: NULL vs BOOLEAN - SQLite vs MySQL vs PostgreSQL
-- =============================================================================
--
-- NULL and BOOLEAN concepts are common across databases, but implementation
-- details are different.
--
-- -----------------------------------------------------------------------------
--
-- | Feature              | SQLite                     | MySQL                      | PostgreSQL                  |
-- |----------------------|----------------------------|----------------------------|-----------------------------|
-- | NULL support         | Yes                        | Yes                        | Yes                         |
-- | NULL meaning         | Unknown / missing value    | Unknown / missing value    | Unknown / missing value     |
-- | Check NULL           | IS NULL                    | IS NULL                    | IS NULL                     |
-- | Compare NULL         | Cannot use = NULL          | Cannot use = NULL          | Cannot use = NULL           |
-- | Empty string != NULL | Yes                        | Yes                        | Yes                         |
-- | Aggregate behavior   | Usually ignores NULL       | Usually ignores NULL       | Usually ignores NULL        |
-- |----------------------|----------------------------|----------------------------|-----------------------------|
-- | Boolean type         | No native BOOLEAN type     | BOOLEAN alias of TINYINT   | Native BOOLEAN type         |
-- | Boolean storage      | INTEGER (0 / 1)            | TINYINT (0 / 1)            | TRUE / FALSE values         |
-- | True value           | 1                          | TRUE or 1                  | TRUE                        |
-- | False value          | 0                          | FALSE or 0                 | FALSE                       |
-- | Boolean check        | column = 1                 | column = TRUE              | column = TRUE               |
--
-- -----------------------------------------------------------------------------
--
-- Key concepts:
--
-- NULL:
-- - Represents missing, unknown, or unavailable data.
-- - It is not zero, false, or an empty string.
-- - Always use IS NULL / IS NOT NULL.
--
-- BOOLEAN:
-- - Represents a logical state: true or false.
-- - Commonly used for flags:
--      is_active
--      is_deleted
--      has_permission
--
-- -----------------------------------------------------------------------------
