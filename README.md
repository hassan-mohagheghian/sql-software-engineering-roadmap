# SQL Software Engineering Roadmap

A structured learning path covering SQL fundamentals through advanced database engineering.

## Topics

| # | Topic | Directory |
|---|-------|-----------|
| 000 | SQL Basics | `SSE_000_SQL_Basics/` |
| 010 | Data Types | `SSE_010_Data_Types/` |
| 020 | Filtering & Sorting | `SSE_020_Filtering_Sorting/` |
| 030 | Joins | `SSE_030_Joins/` |
| 040 | Aggregations | `SSE_040_Aggregations/` |
| 050 | Subqueries | `SSE_050_Subqueries/` |
| 060 | Set Operations | `SSE_060_Set_Operations/` |
| 070 | Indexes | `SSE_070_Indexes/` |
| 080 | Views | `SSE_080_Views/` |
| 090 | Stored Procedures | `SSE_090_Stored_Procedures/` |
| 100 | Triggers | `SSE_100_Triggers/` |
| 110 | Transactions | `SSE_110_Transactions/` |
| 120 | Normalization | `SSE_120_Normalization/` |
| 130 | Query Optimization | `SSE_130_Query_Optimization/` |
| 140 | Window Functions | `SSE_140_Window_Functions/` |
| 150 | CTEs | `SSE_150_CTEs/` |
| 160 | Advanced SQL | `SSE_160_Advanced_SQL/` |
| 170 | Database Design | `SSE_170_Database_Design/` |
| 180 | Performance | `SSE_180_Performance/` |
| 190 | Security | `SSE_190_Security/` |
| 200 | PostgreSQL | `SSE_200_PostgreSQL/` |
| 210 | MySQL | `SSE_210_MySQL/` |
| 220 | SQLite | `SSE_220_SQLite/` |
| 230 | Other Databases | `SSE_230_Other_Databases/` |
| 240 | Database Administration | `SSE_240_Database_Administration/` |

### Files

| Topic | Files |
|-------|-------|
| 000 SQL Basics | `SB_01_select.sql` `SB_02_insert.sql` `SB_03_update.sql` `SB_04_delete.sql` `SB_05_create_table.sql` |
| 010 Data Types | `DT_01_numeric_types.sql` `DT_02_string_types.sql` `DT_03_date_time_types.sql` `DT_04_boolean_and_null.sql` `DT_05_type_casting.sql` |
| 020 Filtering & Sorting | `FS_01_where_clause.sql` `FS_02_order_by.sql` `FS_03_limit_offset.sql` `FS_04_case_expression.sql` `FS_05_distinct.sql` |
| 030 Joins | `JO_01_inner_join.sql` `JO_02_left_right_join.sql` `JO_03_cross_join.sql` `JO_04_self_join.sql` `JO_05_multiple_joins.sql` |
| 040 Aggregations | `AG_01_count_and_sum.sql` `AG_02_avg_min_max.sql` `AG_03_group_concat.sql` `AG_04_rollup_cuberite.sql` `AG_05_pivot.sql` |
| 050 Subqueries | `SQ_01_basic_subqueries.sql` `SQ_02_correlated_advanced.sql` `SQ_03_exists_patterns.sql` `SQ_04_subquery_dml.sql` `SQ_05_lateral_derived.sql` |

## Running Examples

Use `run_sql.sh` to execute SQL files against any supported database:

```bash
# Run all files in SSE_000_SQL_Basics with SQLite (default)
./run_sql.sh

# Run a single file
./run_sql.sh -f SSE_000_SQL_Basics/SB_01_select.sql

# Run with MySQL
./run_sql.sh -db mysql

# Run with PostgreSQL
./run_sql.sh -db postgres

# Run files from a different directory
./run_sql.sh -d SSE_030_Joins

# Check which databases are installed
./run_sql.sh -l
```

## Database Setup

```bash
# SQLite (lightweight, no server needed)
sudo apt install sqlite3

# MySQL
sudo apt install mysql-server mysql-client

# PostgreSQL
sudo apt install postgresql postgresql-client
```

## Database Compatibility

The SQL examples are written for **SQLite** by default. To run on MySQL or PostgreSQL, some syntax differences apply:

| Syntax | SQLite | MySQL | PostgreSQL |
|--------|--------|-------|------------|
| `AUTOINCREMENT` | `INTEGER PRIMARY KEY AUTOINCREMENT` | `AUTO_INCREMENT` | `SERIAL` |
| Ignore duplicates | `INSERT OR IGNORE` | `INSERT IGNORE` | `ON CONFLICT DO NOTHING` |
| Current timestamp | `datetime('now')` | `NOW()` | `NOW()` |
| String concat | `||` | `CONCAT()` | `||` |
| Boolean type | `INTEGER` | `BOOLEAN` | `BOOLEAN` |

## License

Open source — use freely for learning.
