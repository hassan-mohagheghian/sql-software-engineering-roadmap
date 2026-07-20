-- Data Types - String Types
-- -----------------------------------------------------------------------------
-- String types store text data. SQL offers CHAR (fixed-length), VARCHAR
-- (variable-length), and TEXT (unlimited). Understanding when to use each
-- and how string functions work is essential for data manipulation.
--
-- Key concepts:
-- 1. CHAR vs VARCHAR vs TEXT — storage and performance tradeoffs
-- 2. String length and padding behavior
-- 3. Common string functions: LENGTH, SUBSTR, UPPER, LOWER, TRIM
-- 4. String concatenation and REPLACE
-- 5. Pattern extraction with INSTR
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating string_demo table ---' AS note;

CREATE TABLE string_demo (
    id INTEGER PRIMARY KEY,
    fixed_char CHAR(10),
    var_char VARCHAR(50),
    full_text TEXT,
    code CHAR(3)
);

INSERT INTO string_demo VALUES
    (1, 'hello', 'hello world', 'The quick brown fox jumps over the lazy dog', 'A'),
    (2, 'hi', 'a very long string that exceeds typical varchar limits', 'short', 'BB'),
    (3, 'test', NULL, '', 'C'),
    (4, 'abc', '  spaces  ', 'Line one. Line two. Line three.', NULL);


-- =============================================================================
-- CHAR vs VARCHAR vs TEXT
-- =============================================================================

SELECT '--- CHAR: fixed-length, right-padded with spaces ---' AS note;

-- CHAR(n) always stores exactly n characters, padding with spaces
SELECT
    id,
    fixed_char,
    LENGTH(fixed_char) AS stored_length
FROM string_demo;

SELECT '--- VARCHAR: variable-length, stores only what you give it ---' AS note;

-- VARCHAR(n) stores up to n characters, no padding
SELECT
    id,
    var_char,
    LENGTH(var_char) AS stored_length
FROM string_demo;

SELECT '--- TEXT: no practical length limit ---' AS note;

-- TEXT has no declared max length — stores whatever fits in storage
SELECT
    id,
    full_text,
    LENGTH(full_text) AS char_count
FROM string_demo;


-- =============================================================================
-- LENGTH / LEN
-- =============================================================================

SELECT '--- Character count of each text field ---' AS note;

SELECT
    id,
    full_text,
    LENGTH(full_text) AS char_count
FROM string_demo;

SELECT '--- Length of NULL is NULL ---' AS note;

SELECT
    id,
    var_char,
    LENGTH(var_char) AS len
FROM string_demo;


-- =============================================================================
-- UPPER, LOWER, INITCAP
-- =============================================================================

SELECT '--- Case conversion ---' AS note;

SELECT
    id,
    var_char,
    UPPER(var_char) AS uppercased,
    LOWER(var_char) AS lowercased
FROM string_demo;

SELECT '--- SQLite has no built-in INITCAP — manual approach ---' AS note;

-- Manual title case (SQLite)
SELECT
    'hello world' AS input,
    UPPER(SUBSTR('hello world', 1, 1)) || SUBSTR('hello world', 2) AS first_cap;


-- =============================================================================
-- TRIM, LTRIM, RTRIM
-- =============================================================================

SELECT '--- Trim whitespace from both sides ---' AS note;

SELECT
    id,
    var_char,
    TRIM(var_char) AS trimmed,
    LENGTH(var_char) AS original_len,
    LENGTH(TRIM(var_char)) AS trimmed_len
FROM string_demo;

SELECT '--- LTRIM and RTRIM (SQLite uses ltrim/rtrim) ---' AS note;

SELECT
    '  hello  ' AS original,
    LTRIM('  hello  ') AS left_trimmed,
    RTRIM('  hello  ') AS right_trimmed;


-- =============================================================================
-- SUBSTR (Substring)
-- =============================================================================

SELECT '--- Extract substring ---' AS note;

-- SUBSTR(string, start_pos, length) — 1-indexed
SELECT
    full_text,
    SUBSTR(full_text, 1, 3) AS first_three,
    SUBSTR(full_text, 5, 5) AS chars_5_to_9,
    SUBSTR(full_text, -3) AS last_three
FROM string_demo
WHERE id = 1;

SELECT '--- Extract middle portion ---' AS note;

SELECT
    'abcdefghij' AS full,
    SUBSTR('abcdefghij', 4, 3) AS middle;


-- =============================================================================
-- INSTR (Find Position)
-- =============================================================================

SELECT '--- Find substring position ---' AS note;

-- INSTR returns position of first occurrence (0 if not found)
SELECT
    full_text,
    INSTR(full_text, 'fox') AS fox_pos,
    INSTR(full_text, 'zebra') AS zebra_pos
FROM string_demo
WHERE id = 1;

SELECT '--- Use INSTR for conditional extraction ---' AS note;

-- Extract text before first space
SELECT
    'John Smith' AS full_name,
    SUBSTR('John Smith', 1, INSTR('John Smith', ' ') - 1) AS first_name;


-- =============================================================================
-- REPLACE
-- =============================================================================

SELECT '--- Replace characters in a string ---' AS note;

SELECT
    full_text,
    REPLACE(full_text, 'fox', 'cat') AS replaced,
    REPLACE(full_text, ' ', '-') AS dash_separated
FROM string_demo
WHERE id = 1;

SELECT '--- Multiple replaces ---' AS note;

SELECT
    REPLACE(REPLACE('Hello World', 'H', 'J'), 'o', '0') AS chained;


-- =============================================================================
-- CONCATENATION
-- =============================================================================

SELECT '--- String concatenation with || ---' AS note;

-- SQLite uses || for concatenation
SELECT
    'Hello' || ' ' || 'World' AS greeting;

SELECT '--- CONCAT is not in SQLite, but || works ---' AS note;

SELECT
    fixed_code || ': ' || full_text AS labeled
FROM (SELECT 'ABC' AS fixed_code, 'Some text' AS full_text);


-- =============================================================================
-- Manual Padding (SQLite has no LPAD/RPAD — other databases do)
-- =============================================================================

-- LPAD/RPAD exist in MySQL and PostgreSQL but not SQLite.
-- Below shows manual padding and notes the cross-db difference.

SELECT '--- Manual zero-padding using SUBSTR and REPLACE ---' AS note;

-- Left-pad '42' to 6 digits: '000042'
SELECT
    REPLACE('000000' || '42', SUBSTR('000000' || '42', 1, LENGTH('42')), '') || '42' AS broken,
    '0000' || '42' AS simple_pad;

-- Simpler: just concatenate zeros (when you know the target width)
SELECT
    '0000' || '42' AS padded_number,
    'hi' || '........' AS right_padded_manual;

SELECT '--- MySQL/PostgreSQL syntax (for reference, not run here) ---' AS note;

-- MySQL/PostgreSQL:
--   SELECT LPAD('42', 6, '0');   -- '000042'
--   SELECT RPAD('hi', 10, '.');  -- 'hi........'


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping string_demo table ---' AS note;

DROP TABLE string_demo;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - String Type Differences
-- =============================================================================
--
-- All databases support strings, but storage rules, length limits, and
-- built-in functions vary significantly.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                         | MySQL                         | PostgreSQL                     |
-- |--------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | CHAR(n)                  | Yes (padded)                   | Yes (padded)                  | Yes (padded)                   |
-- | VARCHAR(n)               | Yes (logical only)             | Yes (enforced)                | Yes (enforced)                 |
-- | TEXT                     | Yes (no limit)                 | Yes (up to 65KB)              | TEXT (no limit)                |
-- | VARCHAR limit            | Enforced at application level  | Enforced by database          | Enforced by database           |
-- | Trailing space handling  | Truncated on comparison        | Kept but trimmed on compare   | Kept but trimmed on compare    |
-- | Concatenation            | \|\| operator                  | CONCAT() function             | \|\| operator                 |
-- | String length            | LENGTH()                       | LENGTH() or CHAR_LENGTH()     | LENGTH() or CHAR_LENGTH()      |
-- | Substring                | SUBSTR()                       | SUBSTRING() or SUBSTR()       | SUBSTRING()                    |
-- | Find position            | INSTR()                        | LOCATE() or INSTR()           | POSITION() or STRPOS()         |
-- | Regex support            | No (GLOB only)                 | REGEXP                         | ~ operator (POSIX regex)       |
-- | Case conversion          | UPPER(), LOWER()               | UPPER(), LOWER()              | UPPER(), LOWER()               |
-- | Trim                     | TRIM(), LTRIM(), RTRIM()       | TRIM() with syntax options     | TRIM() with syntax options     |
-- | Pattern matching         | LIKE, GLOB                     | LIKE, REGEXP                   | LIKE, SIMILAR TO, ~            |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - VARCHAR(n) is treated as TEXT — no length enforcement.
--    - No REGEXP by default (use GLOB for simple patterns).
--    - CONCAT() not available — use || operator.
--    - LPAD/RPAD not available — use manual padding.
--
-- 2. MySQL:
--    - VARCHAR(n) enforces length limit.
--    - CONCAT() for concatenation; || may not work depending on mode.
--    - REGEXP for pattern matching.
--    - CHAR_LENGTH() returns character count (vs LENGTH() for bytes).
--
-- 3. PostgreSQL:
--    - Most strict: VARCHAR(n) enforces limit.
--    - TEXT type has no practical limit.
--    - ~ operator for POSIX regex; SIMILAR TO for SQL regex.
--    - Most complete string function library.
--
-- Rule of thumb: Use TEXT in SQLite (VARCHAR is just syntax sugar).
-- In MySQL/PostgreSQL, use VARCHAR when you need enforced length limits.
--
-- -----------------------------------------------------------------------------
