-- Data Types - Date and Time Types
-- -----------------------------------------------------------------------------
-- Date and time types are critical for time-series data, scheduling, aging
-- calculations, and filtering by time ranges.
--
-- SQLite does not have a dedicated DATE/DATETIME type. Dates are commonly
-- stored as TEXT (ISO-8601), INTEGER (Unix timestamp), or REAL (Julian day),
-- while built-in date/time functions provide manipulation and comparison.
--
-- Key concepts:
-- 1. Date formats: TEXT (ISO 8601), REAL (Julian), INTEGER (Unix)
-- 2. date(), time(), datetime() functions
-- 3. strftime() for custom formatting
-- 4. Date arithmetic: adding/subtracting intervals
-- 5. Difference between two dates
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating events table ---' AS note;

CREATE TABLE events (
    event_id INTEGER PRIMARY KEY,
    event_name TEXT NOT NULL,
    event_date TEXT NOT NULL,
    event_time TEXT,
    venue TEXT
);

INSERT INTO events VALUES
    (1, 'Conference', '2024-03-15', '09:00:00', 'Main Hall'),
    (2, 'Workshop', '2024-03-15', '14:00:00', 'Room B'),
    (3, 'Meetup', '2024-04-01', '18:30:00', 'Cafe'),
    (4, 'Hackathon', '2024-04-10', '10:00:00', 'Lab'),
    (5, 'Webinar', '2024-05-20', '15:00:00', 'Online'),
    (6, 'Retreat', '2024-06-01', NULL, 'Mountain Resort');


-- =============================================================================
-- Current Date and Time
-- =============================================================================

SELECT '--- Get current date, time, and datetime ---' AS note;

SELECT
    date('now') AS today,
    time('now') AS current_time,
    datetime('now') AS current_datetime;

SELECT '--- Current Unix timestamp ---' AS note;

SELECT CAST(strftime('%s', 'now') AS INTEGER) AS unix_timestamp;


-- =============================================================================
-- Date Parts with strftime
-- =============================================================================

SELECT '--- Extract year, month, day from event_date ---' AS note;

SELECT
    event_name,
    event_date,
    strftime('%Y', event_date) AS year,
    strftime('%m', event_date) AS month,
    strftime('%d', event_date) AS day
FROM events;

SELECT '--- Extract day of week and week number ---' AS note;

-- %w: 0=Sunday, 1=Monday, ..., 6=Saturday
-- %W: week number (00-53)
SELECT
    event_name,
    event_date,
    strftime('%w', event_date) AS day_of_week,
    strftime('%W', event_date) AS week_number,
    strftime('%j', event_date) AS day_of_year
FROM events;


-- =============================================================================
-- Formatting Dates
-- =============================================================================

SELECT '--- Custom date formats ---' AS note;

SELECT
    event_name,
    event_date,
    strftime('%Y-%m-%d', event_date) AS iso_format,
    strftime('%d/%m/%Y', event_date) AS eu_format,
    strftime('%B %d, %Y', event_date) AS long_format
FROM events;

SELECT '--- Combine date and time ---' AS note;

SELECT
    event_name,
    event_date || ' ' || event_time AS full_datetime
FROM events
WHERE event_time IS NOT NULL;


-- =============================================================================
-- Date Arithmetic
-- =============================================================================

SELECT '--- Add days to a date ---' AS note;

SELECT
    event_name,
    event_date,
    date(event_date, '+7 days') AS plus_one_week,
    date(event_date, '+1 month') AS plus_one_month,
    date(event_date, '+3 months', '+10 days') AS combined
FROM events;

SELECT '--- Subtract days ---' AS note;

SELECT
    event_name,
    event_date,
    date(event_date, '-1 day') AS yesterday
FROM events;

SELECT '--- Start and end of month ---' AS note;

SELECT
    event_name,
    event_date,
    date(event_date, 'start of month') AS month_start,
    date(event_date, 'start of month', '+1 month', '-1 day') AS month_end
FROM events;


-- =============================================================================
-- Date Difference
-- =============================================================================

SELECT '--- Days between two dates ---' AS note;

SELECT
    event_name,
    event_date,
    julianday(event_date) - julianday('2024-01-01') AS days_since_jan1
FROM events;

SELECT '--- Difference between events ---' AS note;

SELECT
    e1.event_name AS event_a,
    e2.event_name AS event_b,
    julianday(e2.event_date) - julianday(e1.event_date) AS days_between
FROM events e1
CROSS JOIN events e2
WHERE e1.event_id < e2.event_id
ORDER BY days_between
LIMIT 5;


-- =============================================================================
-- Filtering by Date Ranges
-- =============================================================================

SELECT '--- Events in March 2024 ---' AS note;

SELECT event_name, event_date
FROM events
WHERE event_date BETWEEN '2024-03-01' AND '2024-03-31';

SELECT '--- Events in the next 30 days from a reference date ---' AS note;

SELECT event_name, event_date
FROM events
WHERE event_date BETWEEN date('2024-03-01') AND date('2024-03-01', '+30 days');

SELECT '--- Events by year and month ---' AS note;

SELECT event_name, event_date
FROM events
WHERE strftime('%Y-%m', event_date) = '2024-04';


-- =============================================================================
-- Time Extraction
-- =============================================================================

SELECT '--- Extract hour and minute from event_time ---' AS note;

SELECT
    event_name,
    event_time,
    SUBSTR(event_time, 1, 2) AS hour,
    SUBSTR(event_time, 4, 2) AS minute
FROM events
WHERE event_time IS NOT NULL;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping events table ---' AS note;

DROP TABLE events;




-- =============================================================================
-- Bous: SQLite vs MySQL vs PostgreSQL - Date and Time Differences
-- =============================================================================
--
-- All databases support similar date/time concepts:
-- - current date/time
-- - extracting date parts
-- - date arithmetic
-- - filtering by ranges
-- - comparing dates
--
-- The main differences are:
-- - native date/time types
-- - function names
-- - interval syntax
-- - timezone support
--
-- -----------------------------------------------------------------------------
--
-- | Feature                  | SQLite                         | MySQL                         | PostgreSQL                     |
-- |--------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Native DATE type         | No                             | Yes                           | Yes                            |
-- | Native DATETIME type     | No                             | Yes                           | Yes                            |
-- | Common storage           | TEXT / INTEGER / REAL          | DATE / DATETIME / TIMESTAMP   | DATE / TIMESTAMP / TIMESTAMPTZ |
-- | ISO date format          | TEXT: 'YYYY-MM-DD'             | DATE type                     | DATE type                      |
-- | Current datetime          | datetime('now')                | NOW()                         | NOW()                          |
-- | Current date              | date('now')                    | CURDATE()                     | CURRENT_DATE                   |
-- | Extract year              | strftime('%Y', date)           | YEAR(date)                    | EXTRACT(YEAR FROM date)        |
-- | Extract month             | strftime('%m', date)           | MONTH(date)                   | EXTRACT(MONTH FROM date)       |
-- | Format date               | strftime()                     | DATE_FORMAT()                 | TO_CHAR()                     |
-- | Add interval               | date(x, '+7 days')             | DATE_ADD(x, INTERVAL 7 DAY)   | x + INTERVAL '7 days'          |
-- | Subtract interval          | date(x, '-7 days')             | DATE_SUB(x, INTERVAL 7 DAY)   | x - INTERVAL '7 days'          |
-- | Date difference            | julianday(a)-julianday(b)      | DATEDIFF(a,b)                 | date subtraction / AGE()       |
-- | Unix timestamp             | strftime('%s','now')           | UNIX_TIMESTAMP()              | EXTRACT(EPOCH FROM ...)        |
-- | Timezone support           | Limited                        | Good                          | Advanced                       |
--
-- -----------------------------------------------------------------------------
--
-- Key differences:
--
-- 1. SQLite:
--    - Lightweight and flexible.
--    - No strict date type.
--    - Developer controls the storage format.
--    - Date functions operate on stored values.
--
-- 2. MySQL:
--    - Provides dedicated DATE, DATETIME, TIMESTAMP types.
--    - Simple and widely used date functions.
--    - Good timezone support.
--
-- 3. PostgreSQL:
--    - Most powerful date/time support.
--    - Supports timezone-aware timestamps.
--    - Rich interval and date calculation features.
--
-- -----------------------------------------------------------------------------
