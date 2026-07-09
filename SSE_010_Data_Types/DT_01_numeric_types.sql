-- Data Types - Numeric Types
-- -----------------------------------------------------------------------------
-- SQL numeric types come in several flavors: exact (integer) and approximate
-- (floating point). Choosing the right type affects storage, precision, and
-- performance.
--
-- Key concepts:
-- 1. INTEGER types — SMALLINT, INTEGER, BIGINT
-- 2. DECIMAL/NUMERIC — exact-precision decimal numbers
-- 3. FLOAT/REAL — approximate floating-point
-- 4. Type boundaries and overflow behavior
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup: Create a table demonstrating numeric types
-- =============================================================================

SELECT '--- Setup: Creating numeric_types_demo table ---' AS note;

CREATE TABLE numeric_types_demo (
    id INTEGER PRIMARY KEY,
    small_val SMALLINT,
    int_val INTEGER,
    big_val BIGINT,
    decimal_val DECIMAL(10, 2),
    real_val REAL,
    float_val FLOAT
);

INSERT INTO numeric_types_demo VALUES
    (1, 100, 100000, 99999999999, 123456.78, 3.14159, 2.71828),
    (2, -50, -100000, -99999999999, -999.99, -1.5, -2.5),
    (3, 0, 0, 0, 0.00, 0.0, 0.0),
    (4, 32767, 2147483647, 9223372036854775807, 99999999.99, 999999.9, 999999.9),
    (5, -32768, -2147483648, -9223372036854775808, -99999999.99, -999999.9, -999999.9);


-- =============================================================================
-- INTEGER Types
-- =============================================================================

SELECT '--- SMALLINT range (stores -32768 to 32767) ---' AS note;

-- SMALLINT: 2 bytes, range -32768 to 32767
SELECT
    id,
    small_val,
    typeof(small_val) AS type
FROM numeric_types_demo;

SELECT '--- INTEGER range (stores ~2.1 billion) ---' AS note;

-- INTEGER: 4 bytes, range -2147483648 to 2147483647
SELECT
    id,
    int_val,
    typeof(int_val) AS type
FROM numeric_types_demo;

SELECT '--- BIGINT range (stores very large numbers) ---' AS note;

-- BIGINT: 8 bytes, range -9223372036854775808 to 9223372036854775807
SELECT
    id,
    big_val,
    typeof(big_val) AS type
FROM numeric_types_demo;


-- =============================================================================
-- DECIMAL / NUMERIC (Exact Precision)
-- =============================================================================

SELECT '--- DECIMAL(10,2): 10 total digits, 2 after decimal ---' AS note;

-- DECIMAL(precision, scale): exact storage, no rounding errors
SELECT
    id,
    decimal_val,
    decimal_val * 2 AS doubled,
    typeof(decimal_val) AS type
FROM numeric_types_demo;


-- =============================================================================
-- FLOAT / REAL (Approximate)
-- =============================================================================

SELECT '--- REAL and FLOAT: floating-point (may have precision issues) ---' AS note;

-- REAL/REAL: 4 bytes, ~7 significant digits
-- FLOAT: 8 bytes, ~15 significant digits
SELECT
    id,
    real_val,
    float_val,
    typeof(real_val) AS real_type,
    typeof(float_val) AS float_type
FROM numeric_types_demo;


-- =============================================================================
-- Practical: Precision vs Performance
-- =============================================================================

SELECT '--- DECIMAL arithmetic: exact in databases with true DECIMAL support ---' AS note;
SELECT
    CAST(0.1 AS DECIMAL(10,2)) + CAST(0.2 AS DECIMAL(10,2)) AS result,
    'This calculation is exact (in databases with true DECIMAL support)' AS explanation;


SELECT '--- REAL arithmetic: floating-point approximation ---' AS note;
SELECT
    CAST(0.1 AS REAL) + CAST(0.2 AS REAL) AS result,
    'This calculation may have tiny floating-point rounding errors' AS explanation;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping numeric_types_demo table ---' AS note;

DROP TABLE numeric_types_demo;
