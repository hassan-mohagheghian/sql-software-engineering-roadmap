-- Data Types - Type Casting and Conversion
-- -----------------------------------------------------------------------------
-- Type casting converts data from one type to another. SQL provides CAST for
-- explicit conversion and implicit coercion happens automatically in many
-- expressions. Knowing when and how to cast prevents subtle bugs.
--
-- Key concepts:
-- 1. CAST() — explicit type conversion
-- 2. typeof() — inspect the current type
-- 3. Implicit vs explicit casting
-- 4. Numeric ↔ String conversions
-- 5. Handling malformed data during conversion
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating mixed_types table ---' AS note;

CREATE TABLE mixed_types (
    id INTEGER PRIMARY KEY,
    text_number TEXT,
    real_number REAL,
    integer_val INTEGER,
    date_text TEXT,
    messy_data TEXT
);

INSERT INTO mixed_types VALUES
    (1, '42', 3.14, 100, '2024-03-15', '123abc'),
    (2, '-7', -2.5, -50, '2024/01/20', '456'),
    (3, '0', 0.0, 0, 'not-a-date', 'hello'),
    (4, '99999', 100000.5, 999, '2024-12-31', ''),
    (5, NULL, NULL, NULL, NULL, NULL);


-- =============================================================================
-- typeof(): Inspect Current Type
-- =============================================================================

SELECT '--- Check data types of columns ---' AS note;

SELECT
    id,
    text_number,
    typeof(text_number) AS type,
    real_number,
    typeof(real_number) AS real_type,
    integer_val,
    typeof(integer_val) AS int_type
FROM mixed_types;


-- =============================================================================
-- CAST(): Explicit Conversion
-- =============================================================================

SELECT '--- TEXT to INTEGER ---' AS note;

SELECT
    id,
    text_number,
    CAST(text_number AS INTEGER) AS as_integer
FROM mixed_types
WHERE text_number IS NOT NULL;

SELECT '--- TEXT to REAL ---' AS note;

SELECT
    id,
    text_number,
    CAST(text_number AS REAL) AS as_real
FROM mixed_types
WHERE text_number IS NOT NULL;

SELECT '--- INTEGER to TEXT ---' AS note;

SELECT
    id,
    integer_val,
    CAST(integer_val AS TEXT) AS as_text,
    typeof(CAST(integer_val AS TEXT)) AS type
FROM mixed_types
WHERE integer_val IS NOT NULL;

SELECT '--- REAL to INTEGER (truncation, not rounding) ---' AS note;

SELECT
    3.7 AS original,
    CAST(3.7 AS INTEGER) AS truncated,
    -3.7 AS negative,
    CAST(-3.7 AS INTEGER) AS neg_truncated;


-- =============================================================================
-- Implicit Casting
-- =============================================================================

SELECT '--- SQLite automatically coerces types in expressions ---' AS note;

-- String + number: string is coerced to number
SELECT '5' + 3 AS implicit_number;

-- String concatenation: number is coerced to string
SELECT 'Value: ' || 42 AS implicit_string;

SELECT '--- Implicit casting can be dangerous ---' AS note;

-- 'abc' becomes 0 when used in arithmetic
SELECT 'abc' + 1 AS sneaky_zero;

-- This is why explicit CAST is safer for data you don't control
SELECT
    CAST('abc' AS INTEGER) AS explicit_result;  -- Returns 0 in SQLite


-- =============================================================================
-- Numeric ↔ String Conversions
-- =============================================================================

SELECT '--- Format numbers as fixed-width strings ---' AS note;

-- Useful for display, sorting by numeric text, generating codes
-- SQLite has no LPAD — use manual zero-padding
SELECT
    id,
    '00000' || CAST(integer_val AS TEXT) AS raw_padded,
    SUBSTR('00000' || CAST(integer_val AS TEXT), -5) AS padded_code
FROM mixed_types
WHERE integer_val IS NOT NULL;

SELECT '--- Extract numeric parts from messy strings ---' AS note;

-- SQLite has no REGEXP by default, but we can use CAST to pull numbers
SELECT
    id,
    messy_data,
    CAST(messy_data AS INTEGER) AS extracted_number
FROM mixed_types
WHERE messy_data IS NOT NULL AND messy_data != '';


-- =============================================================================
-- Date String Conversions
-- =============================================================================

SELECT '--- Normalize date formats ---' AS note;

-- SQLite date functions work on ISO 8601 strings (YYYY-MM-DD)
SELECT
    id,
    date_text,
    date(date_text) AS normalized
FROM mixed_types
WHERE date(date_text) IS NOT NULL;

SELECT '--- Extract date parts from text dates ---' AS note;

SELECT
    '2024-03-15' AS date_str,
    CAST(SUBSTR('2024-03-15', 1, 4) AS INTEGER) AS year,
    CAST(SUBSTR('2024-03-15', 6, 2) AS INTEGER) AS month,
    CAST(SUBSTR('2024-03-15', 9, 2) AS INTEGER) AS day;


-- =============================================================================
-- CASE for Conditional Casting
-- =============================================================================

SELECT '--- Safe conversion with CASE guards ---' AS note;

-- Only cast if the data looks numeric
SELECT
    id,
    messy_data,
    CASE
        WHEN messy_data GLOB '*[0-9]*' THEN CAST(messy_data AS INTEGER)
        ELSE NULL
    END AS safe_number
FROM mixed_types
WHERE messy_data IS NOT NULL;

SELECT '--- Display-friendly type conversion ---' AS note;

SELECT
    id,
    CASE
        WHEN real_number > 0 THEN '+' || CAST(real_number AS TEXT)
        WHEN real_number < 0 THEN CAST(real_number AS TEXT)
        ELSE '0.0'
    END AS formatted_number
FROM mixed_types
WHERE real_number IS NOT NULL;


-- =============================================================================
-- Practical: Aggregation with Mixed Types
-- =============================================================================

SELECT '--- Average of text-stored numbers ---' AS note;

-- CAST needed when numeric data is stored as TEXT
SELECT
    AVG(CAST(text_number AS REAL)) AS avg_value,
    SUM(CAST(text_number AS INTEGER)) AS total
FROM mixed_types
WHERE text_number IS NOT NULL AND text_number != '';

SELECT '--- Compare: with and without casting ---' AS note;

-- Without CAST: string comparison (lexicographic)
SELECT MIN(text_number) AS string_min FROM mixed_types WHERE text_number IS NOT NULL;

-- With CAST: numeric comparison
SELECT MIN(CAST(text_number AS INTEGER)) AS numeric_min FROM mixed_types WHERE text_number IS NOT NULL;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping mixed_types table ---' AS note;

DROP TABLE mixed_types;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - Type Casting Differences
-- =============================================================================
--
-- All databases support CAST(), but implicit casting rules and safe
-- conversion behavior vary significantly.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                       | MySQL                          | PostgreSQL                      |
-- |--------------------------|------------------------------|--------------------------------|---------------------------------|
-- | CAST() support           | Yes                          | Yes                            | Yes                             |
-- | :: syntax                | No                           | No                             | Yes (e.g. col::integer)         |
-- | CONVERT()                | No                           | Yes (CONVERT(x, TYPE))         | No                              |
-- | typeof()                 | Yes                          | No                             | No                              |
-- | Implicit casting         | Aggressive coercion          | Context-dependent              | Strict (no implicit casts)      |
-- | String to number         | '5' + 3 = 8                  | '5' + 3 = 8                    | Error (must cast explicitly)    |
-- | Malformed string         | Returns 0 (silent)           | Returns 0 (silent)             | Throws error                    |
-- | REAL to INTEGER          | Truncation                   | Truncation                     | Truncation                      |
-- | BOOLEAN casting          | INTEGER 0/1                  | TINYINT 0/1                    | Native TRUE/FALSE               |
-- | Date string casting      | date('string') function      | STR_TO_DATE() / CAST           | CAST / to_date() function       |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - Most permissive with implicit casts.
--    - Malformed strings silently become 0.
--    - typeof() is unique to SQLite — useful for debugging.
--
-- 2. MySQL:
--    - Similar implicit coercion to SQLite in many contexts.
--    - CONVERT() provides explicit control over collation and type.
--    - Strict mode changes error behavior.
--
-- 3. PostgreSQL:
--    - Most strict — no implicit type coercion in most cases.
--    - Must use CAST() or :: syntax explicitly.
--    - Malformed data throws errors instead of silent defaults.
--
-- Rule of thumb: Always use explicit CAST() for data you don't control.
-- Implicit casting is a source of subtle bugs across all databases.
--
-- -----------------------------------------------------------------------------
