#!/usr/bin/env python3
import os, getpass, sys, textwrap
from typing import Optional
from tabulate import tabulate
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError

# ----------- config (env first, then prompts if needed) -----------
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

HOST   = os.getenv("MYSQL_HOST", "127.0.0.1")
PORT   = int(os.getenv("MYSQL_PORT", "3306"))
USER   = os.getenv("MYSQL_USER", "root")
PWD    = os.getenv("MYSQL_PASSWORD") or getpass.getpass("MySQL password: ")
SCHEMA = os.getenv("MYSQL_SCHEMA", "Camera/Video Equipment Rental DBMS")  # with spaces/slash ok via USE
DDL_FILE  = "ddl.sql"
SEED_FILE = "seed.sql"

BANNER = f"""
==================== Camera/Video Rental DB (SQLAlchemy) ====================
MySQL: {HOST}:{PORT}  User: {USER}
Schema (selected via USE): `{SCHEMA}`
=======================================================================
"""

MENU = """
1) Drop Tables
2) Create Tables  (run ddl.sql)
3) Populate Tables (run seed.sql)
4) Query Tables   (pick a saved query)
0) Exit
"""

def make_engine() -> Engine:
    """
    Create a SQLAlchemy engine WITHOUT specifying database in the URL,
    so names with spaces/slash won't break. We'll run USE `schema`.
    """
    url = f"mysql+mysqlconnector://{USER}:{PWD}@{HOST}:{PORT}"
    return create_engine(url, pool_pre_ping=True, future=True)

def use_schema(conn):
    conn.execute(text(f"CREATE DATABASE IF NOT EXISTS `{SCHEMA}`;"))
    conn.execute(text(f"USE `{SCHEMA}`;"))

def exec_sql_script(path: str):
    if not os.path.exists(path):
        print(f"[!] File not found: {path}")
        return
    sql = open(path, "r", encoding="utf-8").read()
    # Split safely on semicolons that end statements.
    # Simple splitter: not perfect for procedures, but fine for DDL/INSERTs.
    stmts = [s.strip() for s in sql.split(";") if s.strip()]
    eng = make_engine()
    with eng.begin() as conn:
        use_schema(conn)
        for s in stmts:
            conn.execute(text(s))
    print(f"[✓] Executed {path}")

def drop_all_tables():
    eng = make_engine()
    with eng.begin() as conn:
        use_schema(conn)
        # Drop views first, then tables
        views = conn.execute(text("""
            SELECT TABLE_NAME
            FROM information_schema.views
            WHERE TABLE_SCHEMA = DATABASE();
        """)).scalars().all()
        tables = conn.execute(text("""
            SELECT TABLE_NAME
            FROM information_schema.tables
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_TYPE='BASE TABLE';
        """)).scalars().all()
        conn.execute(text("SET FOREIGN_KEY_CHECKS=0;"))
        for v in views:
            conn.execute(text(f"DROP VIEW IF EXISTS `{v}`"))
        for t in tables:
            conn.execute(text(f"DROP TABLE IF EXISTS `{t}`"))
        conn.execute(text("SET FOREIGN_KEY_CHECKS=1;"))
    print(f"[✓] Dropped {len(tables)} tables and {len(views)} views.")

# ---------------- queries (simple, readable) ----------------
QUERIES = {
    "1": ("All customers (selection + ORDER BY)", """
        SELECT customer_id, Full_Name, email, phone, status
        FROM customer
        ORDER BY Full_Name;
    """),
    "2": ("Rentals per branch (JOIN + GROUP BY)", """
        SELECT b.branch_id, b.name AS branch, COUNT(*) AS total_rentals
        FROM rental r
        JOIN branch b ON b.branch_id = r.branch_id
        GROUP BY b.branch_id, b.name
        ORDER BY total_rentals DESC;
    """),
    "3": ("Equipment under maintenance (selection)", """
        SELECT equip_id, Name AS equipment_name, brand, model, daily_rate, status
        FROM equipment
        WHERE status = 'Maintenance'
        ORDER BY brand, model;
    """),
    "4": ("Copies per equipment (JOIN + GROUP BY)", """
        SELECT e.equip_id, e.Name AS equipment_name, COUNT(*) AS copy_count
        FROM equip_info ei
        JOIN equipment e ON e.equip_id = ei.equip_id
        GROUP BY e.equip_id, e.Name
        ORDER BY copy_count DESC, equipment_name;
    """),
}

def run_query():
    print("\nAvailable queries:")
    for k in sorted(QUERIES, key=lambda x: int(x)):
        print(f"  [{k}] {QUERIES[k][0]}")
    pick = input("Pick query number (or Enter to cancel): ").strip()
    if not pick or pick not in QUERIES:
        return
    title, sql = QUERIES[pick]
    eng = make_engine()
    try:
        with eng.connect() as conn:
            use_schema(conn)
            rs = conn.execute(text(sql))
            rows = rs.fetchall()
            headers = rs.keys()
        print(f"\n=== {title} ===")
        if not rows:
            print("(no rows)")
        else:
            print(tabulate(rows, headers=headers, tablefmt="github", floatfmt=".2f"))
    except SQLAlchemyError as e:
        print("[✗] Query error:", e)

def main():
    print(BANNER)
    while True:
        print(MENU)
        choice = input("Select: ").strip()
        try:
            if choice == "0":
                print("Bye!"); break
            elif choice == "1":
                drop_all_tables()
            elif choice == "2":
                exec_sql_script(DDL_FILE)
            elif choice == "3":
                exec_sql_script(SEED_FILE)
            elif choice == "4":
                run_query()
            else:
                print("Invalid option.")
        except SQLAlchemyError as e:
            print("[✗] SQL error:", e)
        except Exception as ex:
            print("[✗] Error:", ex)

if __name__ == "__main__":
    main()
