-- Filtering & Sorting - LIMIT and OFFSET
-- -----------------------------------------------------------------------------
-- LIMIT and OFFSET control how many rows are returned and where to start.
-- Essential for pagination and top-N queries.
--
-- Key concepts:
-- 1. LIMIT — restrict number of rows returned
-- 2. OFFSET — skip rows before returning results
-- 3. Pagination pattern (LIMIT + OFFSET)
-- 4. Top-N queries (ORDER BY + LIMIT)
-- 5. FETCH FIRST (SQL standard alternative)
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create sample data
-- =============================================================================

SELECT '--- Setup: Creating scores table ---' AS note;

CREATE TABLE scores (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    score INTEGER,
    exam_date TEXT
);

INSERT INTO scores VALUES
    (1, 'Alice', 95, '2024-01-15'),
    (2, 'Bob', 87, '2024-01-15'),
    (3, 'Carol', 92, '2024-01-15'),
    (4, 'David', 78, '2024-01-15'),
    (5, 'Eve', 88, '2024-01-15'),
    (6, 'Frank', 91, '2024-01-15'),
    (7, 'Grace', 85, '2024-01-15'),
    (8, 'Hank', 93, '2024-01-15'),
    (9, 'Ivy', 79, '2024-01-15'),
    (10, 'Jack', 96, '2024-01-15');


-- =============================================================================
-- LIMIT
-- =============================================================================

SELECT '--- Top 3 students by score ---' AS note;

-- LIMIT restricts output to N rows
SELECT name, score
FROM scores
ORDER BY score DESC
LIMIT 3;

SELECT '--- First 5 students (by insertion order) ---' AS note;

-- Without ORDER BY, LIMIT just picks arbitrary rows
SELECT name, score
FROM scores
LIMIT 5;


-- =============================================================================
-- OFFSET
-- =============================================================================

SELECT '--- Skip first 3, return next 4 ---' AS note;

-- OFFSET skips N rows before returning results
SELECT name, score
FROM scores
ORDER BY student_id
OFFSET 3 ROWS
LIMIT 4;

SELECT '--- Skip first 5 ---' AS note;

-- OFFSET without LIMIT returns all remaining rows
SELECT name, score
FROM scores
ORDER BY student_id
OFFSET 5 ROWS;


-- =============================================================================
-- Pagination Pattern
-- =============================================================================

SELECT '--- Page 1 (rows 1-3) ---' AS note;

-- Page 1: OFFSET 0
SELECT name, score
FROM scores
ORDER BY student_id
LIMIT 3
OFFSET 0;

SELECT '--- Page 2 (rows 4-6) ---' AS note;

-- Page 2: OFFSET 3
SELECT name, score
FROM scores
ORDER BY student_id
LIMIT 3
OFFSET 3;

SELECT '--- Page 3 (rows 7-9) ---' AS note;

-- Page 3: OFFSET 6
SELECT name, score
FROM scores
ORDER BY student_id
LIMIT 3
OFFSET 6;


-- =============================================================================
-- Top-N Queries
-- =============================================================================

SELECT '--- Bottom 2 students ---' AS note;

-- Combine ORDER BY with LIMIT for top/bottom N
SELECT name, score
FROM scores
ORDER BY score ASC
LIMIT 2;

SELECT '--- Top 25% (approximately) ---' AS note;

-- SQLite doesn't have PERCENT, so use LIMIT with calculation
SELECT name, score
FROM scores
ORDER BY score DESC
LIMIT (SELECT COUNT(*) / 4 FROM scores);


-- =============================================================================
-- FETCH FIRST (SQL Standard)
-- =============================================================================

SELECT '--- FETCH FIRST 3 rows ---' AS note;

-- SQL:2008 standard syntax (supported by PostgreSQL, MySQL 8+, SQLite 3.33+)
SELECT name, score
FROM scores
ORDER BY score DESC
FETCH FIRST 3 ROWS ONLY;

SELECT '--- OFFSET 2, FETCH NEXT 3 ---' AS note;

SELECT name, score
FROM scores
ORDER BY score DESC
OFFSET 2 ROWS
FETCH NEXT 3 ROWS ONLY;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping scores table ---' AS note;

DROP TABLE scores;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - LIMIT/OFFSET Differences
-- =============================================================================
--
-- Pagination syntax varies significantly across databases. LIMIT/OFFSET is
-- most common, but FETCH FIRST is the SQL standard.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | LIMIT                        | Yes                            | Yes                           | Yes                            |
-- | OFFSET                       | Yes (with LIMIT)               | Yes (with LIMIT)              | Yes (with LIMIT)               |
-- | LIMIT m, n syntax            | No                             | Yes (m=offset, n=count)       | No                             |
-- | FETCH FIRST                  | Yes (3.33+)                    | Yes (8.0+)                    | Yes                            |
-- | TOP (SQL Server)             | No                             | No                            | No                             |
-- | LIMIT without ORDER BY       | Non-deterministic              | Non-deterministic             | Non-deterministic              |
-- | OFFSET without LIMIT         | Yes                            | Yes                           | Yes                            |
-- | Performance for large offset | Slow (scans skipped rows)      | Slow (scans skipped rows)     | Slow (scans skipped rows)      |
-- | Keyset pagination            | Recommended for large datasets | Recommended                   | Recommended                    |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - LIMIT/OFFSET is the primary pagination method.
--    - FETCH FIRST supported since 3.33.0.
--    - Large offsets are slow — use keyset pagination for big tables.
--
-- 2. MySQL:
--    - LIMIT m, n is alternative syntax (m=offset, n=count).
--    - LIMIT n OFFSET m is also supported.
--    - FETCH FIRST supported since 8.0.
--
-- 3. PostgreSQL:
--    - LIMIT/OFFSET and FETCH FIRST both supported.
--    - Most standards-compliant behavior.
--    - Consider cursor-based pagination for large datasets.
--
-- -----------------------------------------------------------------------------