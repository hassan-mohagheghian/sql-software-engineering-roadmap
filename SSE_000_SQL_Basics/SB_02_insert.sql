-- SQL Basics - INSERT
-- -----------------------------------------------------------------------------
-- The INSERT statement adds new rows to a table. SQL supports inserting
-- single rows, multiple rows, and inserting from another table.
--
-- Key concepts:
-- 1. INSERT INTO ... VALUES — single row
-- 2. INSERT INTO ... VALUES (...), (...), (...) — multiple rows
-- 3. INSERT INTO ... SELECT — insert from query
-- 4. INSERT with DEFAULT values
-- 5. OR IGNORE / ON CONFLICT — handling duplicates
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Setup
-- =============================================================================

SELECT '--- Setup: Creating products and archived_products tables ---' AS note;

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT,
    price REAL DEFAULT 0.0,
    stock INTEGER DEFAULT 0
);

CREATE TABLE archived_products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT,
    price REAL
);


-- =============================================================================
-- Single Row INSERT
-- =============================================================================

SELECT '--- Insert a single row into products ---' AS note;

INSERT INTO products (id, name, category, price, stock)
VALUES (1, 'Laptop', 'Electronics', 999.99, 50);

SELECT '--- Omitting columns (uses DEFAULT values) ---' AS note;

-- Omitting columns (uses DEFAULT values)
INSERT INTO products (id, name, category)
VALUES (2, 'Mouse', 'Electronics');


-- =============================================================================
-- Multiple Row INSERT
-- =============================================================================

SELECT '--- Insert multiple rows at once ---' AS note;

INSERT INTO products (id, name, category, price, stock) VALUES
    (3, 'Keyboard', 'Electronics', 79.99, 120),
    (4, 'Desk Chair', 'Furniture', 249.99, 30),
    (5, 'Monitor', 'Electronics', 349.99, 45),
    (6, 'Desk Lamp', 'Lighting', 49.99, 80),
    (7, 'Notebook', 'Stationery', 4.99, 500);


-- =============================================================================
-- INSERT from SELECT
-- =============================================================================

SELECT '--- Copy expensive products (price > 200) to archive ---' AS note;

-- Copy expensive products to archive
INSERT INTO archived_products (id, name, category, price)
SELECT id, name, category, price
FROM products
WHERE price > 200;

SELECT '--- Archived products ---' AS note;

SELECT * FROM archived_products;


-- =============================================================================
-- INSERT with OR IGNORE (SQLite)
-- =============================================================================

SELECT '--- OR IGNORE: skip duplicate id=1 silently ---' AS note;

-- This will silently skip if id=1 already exists
INSERT OR IGNORE INTO products (id, name, category, price, stock)
VALUES (1, 'Duplicate Laptop', 'Electronics', 999.99, 50);

SELECT '--- ON CONFLICT (upsert): update id=1 if exists ---' AS note;

-- This will update if id=1 already exists (upsert)
INSERT INTO products (id, name, category, price, stock)
VALUES (1, 'Updated Laptop', 'Electronics', 1099.99, 45)
ON CONFLICT(id) DO UPDATE SET
    name = excluded.name,
    price = excluded.price,
    stock = excluded.stock;


-- =============================================================================
-- Verify Results
-- =============================================================================

SELECT '--- Final products table ---' AS note;

SELECT * FROM products ORDER BY id;

SELECT '--- Final archived_products table ---' AS note;

SELECT * FROM archived_products ORDER BY id;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping tables ---' AS note;

DROP TABLE products;
DROP TABLE archived_products;


-- =============================================================================
-- Bonus: SQLite vs MySQL vs PostgreSQL - INSERT Differences
-- =============================================================================
--
-- INSERT syntax varies significantly, especially for handling duplicates
-- and bulk inserts.
--
-- -----------------------------------------------------------------------------
--
-- | Feature                      | SQLite                         | MySQL                         | PostgreSQL                     |
-- |------------------------------|--------------------------------|-------------------------------|--------------------------------|
-- | Basic INSERT                 | Yes                            | Yes                           | Yes                            |
-- | INSERT multiple rows         | Yes                            | Yes                           | Yes                            |
-- | INSERT with column list      | Yes                            | Yes                           | Yes                            |
-- | Insert from SELECT           | Yes                            | Yes                           | Yes                            |
-- | Ignore duplicates            | INSERT OR IGNORE               | INSERT IGNORE                 | ON CONFLICT DO NOTHING         |
-- | Upsert (insert or update)    | INSERT OR REPLACE              | INSERT ... ON DUPLICATE KEY   | ON CONFLICT ... DO UPDATE      |
-- | RETURNING clause             | No                             | No                            | Yes                            |
-- | SERIAL / auto-increment      | INTEGER PRIMARY KEY AUTOINCREMENT | AUTO_INCREMENT              | SERIAL / GENERATED AS IDENTITY |
-- | Bulk insert performance      | Slower (single transaction)    | Faster (bulk optimizations)   | Moderate                       |
-- | Quoting strings              | Single quotes                  | Single or double quotes       | Single quotes                  |
-- | Escape single quote          | '' (double it)                 | \' or ''                      | '' (double it)                 |
--
-- -----------------------------------------------------------------------------
--
-- Key takeaways:
--
-- 1. SQLite:
--    - INSERT OR IGNORE to skip duplicates silently.
--    - INSERT OR REPLACE to delete and re-insert on conflict.
--    - No RETURNING clause (use last_insert_rowid() instead).
--    - AUTOINCREMENT only with INTEGER PRIMARY KEY.
--
-- 2. MySQL:
--    - INSERT IGNORE to skip duplicates.
--    - INSERT ... ON DUPLICATE KEY UPDATE for upserts.
--    - Last insert ID via LAST_INSERT_ID().
--    - Bulk inserts are faster than individual inserts.
--
-- 3. PostgreSQL:
--    - ON CONFLICT DO NOTHING to skip duplicates.
--    - ON CONFLICT ... DO UPDATE for upserts.
--    - RETURNING clause to get inserted values back.
--    - Most flexible conflict resolution.
--
-- -----------------------------------------------------------------------------
