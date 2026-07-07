#!/usr/bin/env bash
#
# run_sql.sh — Execute SQL files against SQLite, MySQL, or PostgreSQL
#
# Usage:
#   ./run_sql.sh                          # Run all files in SSE_000_SQL_Basics with SQLite
#   ./run_sql.sh -f SSE_000_SQL_Basics/SB_01_select.sql   # Run a single file
#   ./run_sql.sh -d SSE_030_Joins -db postgres             # Run all .sql in a directory with PostgreSQL
#   ./run_sql.sh -db mysql                                  # Run default directory with MySQL
#   ./run_sql.sh -l                                          # List available databases
#

set -euo pipefail

# ─── Defaults ────────────────────────────────────────────────────────────────
DB_DRIVER="sqlite"
TARGET_DIR="SSE_000_SQL_Basics"
SINGLE_FILE=""
LIST_ONLY=false

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Helpers ─────────────────────────────────────────────────────────────────
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -f, --file FILE        Run a single .sql file
  -d, --dir DIR          Run all .sql files in a directory (default: SSE_000_SQL_Basics)
  -db, --database DB     Database driver: sqlite, mysql, postgres (default: sqlite)
  -l, --list             List available database CLIs on this system
  -h, --help             Show this help

Examples:
  ./run_sql.sh
  ./run_sql.sh -f SSE_000_SQL_Basics/SB_01_select.sql
  ./run_sql.sh -d SSE_000_SQL_Basics -db mysql
  ./run_sql.sh -db postgres
EOF
}

list_databases() {
    echo -e "${BOLD}Available database CLIs:${NC}"
    for cmd in sqlite3 mysql psql; do
        if command -v "$cmd" &>/dev/null; then
            local ver
            ver=$("$cmd" --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "  ${GREEN}✓${NC} $cmd  ($ver)"
        else
            echo -e "  ${RED}✗${NC} $cmd  (not installed)"
        fi
    done
}

check_driver() {
    local driver="$1"
    case "$driver" in
        sqlite)
            command -v sqlite3 &>/dev/null || { err "sqlite3 not found. Install it: sudo apt install sqlite3"; exit 1; }
            ;;
        mysql)
            command -v mysql &>/dev/null || { err "mysql client not found. Install it: sudo apt install mysql-client"; exit 1; }
            ;;
        postgres|psql)
            command -v psql &>/dev/null || { err "psql not found. Install it: sudo apt install postgresql-client"; exit 1; }
            ;;
        *)
            err "Unknown database driver: $driver"
            err "Supported: sqlite, mysql, postgres"
            exit 1
            ;;
    esac
}

run_sqlite() {
    local file="$1"
    info "Running with SQLite: $(basename "$file")"
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    sqlite3 < "$file" 2>&1
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    ok "Done"
}

run_mysql() {
    local file="$1"
    info "Running with MySQL: $(basename "$file")"
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    mysql -u root < "$file" 2>&1 || mysql < "$file" 2>&1
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    ok "Done"
}

run_postgres() {
    local file="$1"
    info "Running with PostgreSQL: $(basename "$file")"
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    psql -f "$file" 2>&1
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"
    ok "Done"
}

run_file() {
    local file="$1"
    local driver="$2"

    if [[ ! -f "$file" ]]; then
        err "File not found: $file"
        return 1
    fi

    case "$driver" in
        sqlite)  run_sqlite "$file"  ;;
        mysql)   run_mysql "$file"   ;;
        postgres) run_postgres "$file" ;;
    esac
}

# ─── Parse args ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            SINGLE_FILE="$2"; shift 2 ;;
        -d|--dir)
            TARGET_DIR="$2"; shift 2 ;;
        -db|--database)
            DB_DRIVER="$2"; shift 2 ;;
        -l|--list)
            LIST_ONLY=true; shift ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            err "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ─── Main ────────────────────────────────────────────────────────────────────
if $LIST_ONLY; then
    list_databases
    exit 0
fi

check_driver "$DB_DRIVER"

if [[ -n "$SINGLE_FILE" ]]; then
    # Run single file
    run_file "$SINGLE_FILE" "$DB_DRIVER"
else
    # Run all .sql files in target directory
    if [[ ! -d "$TARGET_DIR" ]]; then
        err "Directory not found: $TARGET_DIR"
        exit 1
    fi

    shopt -s nullglob
    files=("$TARGET_DIR"/*.sql)
    shopt -u nullglob

    if [[ ${#files[@]} -eq 0 ]]; then
        warn "No .sql files found in $TARGET_DIR"
        exit 0
    fi

    echo ""
    echo -e "${BOLD}Running ${#files[@]} SQL file(s) from ${TARGET_DIR} with ${DB_DRIVER}${NC}"
    echo ""

    for file in "${files[@]}"; do
        run_file "$file" "$DB_DRIVER"
        echo ""
    done

    echo -e "${BOLD}${GREEN}All files executed successfully!${NC}"
fi
