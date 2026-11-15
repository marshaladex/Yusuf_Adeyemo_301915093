# Verification and evidence

See [reference-check.log](reference-check.log) for the checks run in the authoring environment. Reproduce the portable checks with Python 3 via `python evidence/reference-check.py` and use `node --check` on the two JavaScript files. SQLite compatibility checks exercise the relational fixture and portable queries after removing MySQL-specific database and storage-engine clauses. They do not verify MySQL syntax or behaviour. JavaScript parsing checks do not verify mongosh semantics. No MySQL, MongoDB or Docker executables were found on the command path, and WSL was unavailable. Engine-specific execution remains pending.

| Portfolio | Native evidence to record |
|---|---|
| 1 | MySQL version, SHOW TABLES, SHOW CREATE TABLE registrations, SHOW CREATE TABLE results and successful check.sql output |
| 2 | Query results, JSON and ANALYZE outputs for A/B/C, equal counts, per-run time and median, and your analysis |
| 3 | Before/after rows for both transactions, distinct connection IDs, waiting locking read, late stale-edit outcome and cleanup |
| 4 | MongoDB server version, collection sample, GPA and validation checks, and actual winning plan |
| 5 | Compose topology, before/after primary and majority marker outputs, recovered membership and observed outage interval if measured |

Use complete console exports or clearly labelled screenshots. Name files for the portfolio and test. Keep original results, including unexpected behaviour when relevant to the analysis. Exclude credentials and private information. Expected results in the scripts or README files are test oracles.
