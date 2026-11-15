# UniResult | MIT 8103 Advanced Database Systems

Yusuf Adeyemo · Student ID 301915093

UniResult models a fictional university's student registrations, marks and transcripts. Students consult results, lecturers enter scores, departmental administrators manage enrolment and examination officers oversee corrections.

| Portfolio | Guide | Evidence |
|---|---|---|
| 1. Database design and modelling | [ER diagram, schema and 3NF](01-design/README.md) | [MySQL design check passed](evidence/p1-design-checks.png) |
| 2. Query processing and optimisation | [Queries and benchmark](02-optimisation/README.md) | [MySQL 8.4.13 plans and results](evidence/p2-optimisation-verified.txt) |
| 3. Transactions and concurrency | [Commit, rollback and two-session schedule](03-transactions/README.md) | [Commit and rollback](evidence/p3-commit-rollback.png), [two-session lock and stale update](evidence/p3-concurrency.png) |
| 4. NoSQL modelling | [MongoDB implementation](04-mongodb/README.md) | Shell unavailable during attempted run |
| 5. Distributed and cloud databases | [Replica-set procedure and cloud design](05-distributed/README.md) | Failover results pending |

## Run the labs

With MySQL 8.4 and a fresh lab database, run schema.sql, seed.sql and check.sql in 01-design. Run queries.sql and the corrected experiment.sql in 02-optimisation. Run commit_rollback.sql in 03-transactions and follow its README for the two-session exercise. Use MongoDB Community Server and mongosh for 04-mongodb, and Docker Compose for 05-distributed.

## Observed results

The benchmark loaded 100,000 rows and all three variants matched 186. In one recorded run, the baseline scanned 100,000 rows, the composite range scan read 186 and the function-wrapped filter read 1,031 from the offering index. The observed aggregate elapsed times were 25.2, 0.076 and 0.305 ms respectively. Earlier benchmark attempts failed with MySQL error 1137. See the verified log for the run with the corrected script.

Rollback restored score 78.00 and removed the newly posted result. Commit saved both changes. The two-session test showed a waiting locking read return 79.00 after commit and a stale update affect zero rows.

The repository includes [test instructions and portable reference checks](evidence/README.md), the [editable LMS summary](lms-summary.md) and the [AI use declaration](AI-USE.md). Sources include the MIT 8103 assessment brief and the MySQL and MongoDB documentation linked in the portfolio guides.
