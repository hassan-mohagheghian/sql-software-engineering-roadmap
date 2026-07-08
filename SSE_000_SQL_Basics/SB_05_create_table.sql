-- SQL Basics - CREATE TABLE
-- -----------------------------------------------------------------------------
-- CREATE TABLE defines a new table with columns, data types, and constraints.
-- A well-designed table enforces data integrity at the database level.
--
-- Key concepts:
-- 1. Column data types (TEXT, INTEGER, REAL, BLOB, BOOLEAN)
-- 2. NOT NULL — prevent NULL values
-- 3. DEFAULT — provide fallback values
-- 4. PRIMARY KEY — unique row identifier
-- 5. UNIQUE — ensure no duplicates in a column
-- 6. CHECK — validate data with conditions
-- 7. FOREIGN KEY — enforce referential integrity
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Basic Table
-- =============================================================================

SELECT '--- Create users table with AUTOINCREMENT and UNIQUE constraints ---' AS note;

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now'))
);

SELECT '--- Insert sample users ---' AS note;

INSERT INTO users (username, email, password_hash) VALUES
    ('alice', 'alice@example.com', 'hash_abc123'),
    ('bob', 'bob@example.com', 'hash_def456');

SELECT '--- Users table ---' AS note;

SELECT * FROM users;


-- =============================================================================
-- Table with CHECK Constraints
-- =============================================================================

SELECT '--- Create products table with CHECK constraints ---' AS note;

CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL CHECK (price > 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    category TEXT CHECK (category IN ('Electronics', 'Furniture', 'Stationery'))
);

SELECT '--- Insert valid products ---' AS note;

INSERT INTO products (name, price, stock, category) VALUES
    ('Laptop', 999.99, 50, 'Electronics'),
    ('Desk', 299.99, 20, 'Furniture');

-- This would fail: price <= 0
-- INSERT INTO products (name, price, stock, category) VALUES ('Free', -1, 0, 'Stationery');

SELECT '--- Products table ---' AS note;

SELECT * FROM products;


-- =============================================================================
-- Table with FOREIGN KEY
-- =============================================================================

SELECT '--- Create categories and items tables with FOREIGN KEY ---' AS note;

CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category_id INTEGER,
    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

SELECT '--- Insert categories and items ---' AS note;

INSERT INTO categories (name) VALUES ('Electronics'), ('Furniture');

INSERT INTO items (name, category_id) VALUES
    ('Laptop', 1),
    ('Desk', 2),
    ('Unassigned', NULL);

SELECT '--- Items with their categories (LEFT JOIN) ---' AS note;

SELECT
    i.name AS item,
    c.name AS category
FROM items i
LEFT JOIN categories c ON i.category_id = c.id;


-- =============================================================================
-- Table with Composite Primary Key
-- =============================================================================

SELECT '--- Create enrollments table with composite PRIMARY KEY ---' AS note;

CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrolled_at TEXT DEFAULT (datetime('now')),
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

SELECT '--- Insert enrollment records ---' AS note;

INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (1, 101, 'A'),
    (1, 102, 'B'),
    (2, 101, 'A');

-- This would fail: duplicate (student_id, course_id)
-- INSERT INTO enrollments (student_id, course_id, grade) VALUES (1, 101, 'C');

SELECT '--- Enrollments table ---' AS note;

SELECT * FROM enrollments;


-- =============================================================================
-- ALTER TABLE
-- =============================================================================

SELECT '--- ALTER TABLE: add and rename columns ---' AS note;

-- Add a column
ALTER TABLE users ADD COLUMN last_login TEXT;

-- Rename a column (SQLite 3.25+)
ALTER TABLE users RENAME COLUMN is_active TO active;

-- SQLite doesn't support DROP COLUMN directly before 3.35.0
-- In other databases: ALTER TABLE users DROP COLUMN last_login;


-- =============================================================================
-- Cleanup
-- =============================================================================

SELECT '--- Cleanup: dropping all tables ---' AS note;

DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS enrollments;
