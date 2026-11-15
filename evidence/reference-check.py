from pathlib import Path
import re
import sqlite3
from datetime import date, timedelta
from collections import Counter
root = Path(__file__).resolve().parents[1]
db = sqlite3.connect(":memory:", isolation_level=None)
db.execute("PRAGMA foreign_keys=ON")
def source(name):
    return re.sub(r"^(CREATE DATABASE .*|USE uniresult_db;)\n", "", (root/name).read_text(encoding="utf8"), flags=re.M).replace(" ENGINE=InnoDB", "").replace("START TRANSACTION;", "BEGIN;")
for file in ("schema.sql", "seed.sql"):
    db.executescript(source("01-design/"+file))
counts = [db.execute("SELECT COUNT(*) FROM "+table).fetchone()[0] for table in ("departments","students","lecturers","courses","course_offerings","registrations","results")]
assert counts == [3,6,3,4,5,12,11], counts
assert not db.execute("PRAGMA foreign_key_check").fetchall()
for statement in (
    "INSERT INTO registrations VALUES (901,1,11,'2024-10-12')",
    "INSERT INTO results VALUES (902,80)",
    "UPDATE results SET score=101 WHERE registration_id=101",
):
    try:
        db.execute(statement)
    except sqlite3.IntegrityError:
        continue
    raise AssertionError(statement)
q = source("02-optimisation/queries.sql")
queries = [q for q in q.split(";") if q.strip()]
a,b,c,d,e = [db.execute(statement).fetchall() for statement in queries]
assert [(row[4],row[7]) for row in a] == [(2024,"F"),(2025,"B")], a
assert b[0] == ("UR/24/0001",2024,1,4.6) and len(b)==8, b
assert c[-1][-3:-1] == (2,1) and d == [("CSC301",)] and len(e)==11
txn = source("03-transactions/commit_rollback.sql")
checkpoints = []
for statement in txn.split(";"):
    if not statement.strip():
        continue
    cursor = db.execute(statement)
    if cursor.description:
        checkpoints.append(cursor.fetchall())
assert checkpoints == [[(101,78)],[(101,79),(109,66)],[(101,78)],[(101,79),(109,66)]], checkpoints
assert db.execute("SELECT registration_id,score FROM results WHERE registration_id IN (101,109)").fetchall() == [(101,78)]
rows = Counter((n%97+1, date(2024,9,1)+timedelta(days=n//97%180)) for n in range(100000))
selected = sum(count for (offering, day), count in rows.items() if offering==42 and date(2024,10,1)<=day<date(2024,11,1))
assert sum(rows.values()) == 100000 and selected == 186
print(f"PASS SQLite {sqlite3.sqlite_version} portable schema, seed, FK check and three constraint rejection probes.")
print("PASS SQLite five reporting queries, retake history, eight GPA rows and Amara's 4.60 GPA.")
print("PASS SQLite transaction snapshots and cleanup in one connection.")
print("PASS Python benchmark oracle: 100000 rows, 186 match the offered date range.")
