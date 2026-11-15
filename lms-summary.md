# UniResult technical portfolio summary

MIT 8103 Advanced Database Systems · September 2026 cohort
Yusuf Adeyemo · Student ID 301915093
Private GitHub repository [paste assessor-accessible URL]

## Portfolio 1 Database design

UniResult is a simulated university system for registering students in course offerings, posting marks and generating transcripts. Students consult their records, lecturers enter marks, administrators manage registrations and examination officers oversee corrections. Seven InnoDB tables separate departments, students, lecturers, courses, offerings, registrations and results. The student–offering key prevents duplicate enrolment, while an optional result row holds a posted score. The transcript view derives grade points and calculates credit-weighted GPA through reporting queries. On MySQL 8.4.13 the design checks passed, including the constraint rejection tests and a fixture GPA of 4.60. See evidence/p1-design-checks.png.

## Portfolio 2 Query processing and optimisation

The benchmark loaded 100,000 rows and all three query variants returned 186 matches. In the saved EXPLAIN ANALYZE run, the baseline scanned 100,000 rows and took 25.2 ms at the aggregate. The composite index range scanned 186 rows and took 0.076 ms. Wrapping the date in DATE_FORMAT retained the offering lookup, scanned 1,031 rows and took 0.305 ms. The date range let MySQL constrain both index columns. These timings are from one instrumented run. See evidence/p2-optimisation-verified.txt for the plans and output.

## Portfolio 3 Transactions and concurrency

Rollback restored registration 101 to 78.00 and removed the result for 109. Commit published 79.00 and 66.00 together. In two READ COMMITTED connections, the reader saw 78.00, its locking read waited and then returned 79.00 after the writer committed, and the stale update applied zero rows. See evidence/p3-commit-rollback.png and evidence/p3-concurrency.png.

<!-- Page break for the PDF draft -->

## Portfolio 4 MongoDB document model

The model stores one document per student and term with embedded course attempts. A compound unique index identifies each transcript, and score validation and a guarded update support posting a pending result. The aggregation applies the same credit-weighted GPA rule as the MySQL reports. The script was prepared, but the run stopped before execution because PowerShell could not find mongosh. The repository includes the implementation and run instructions.

## Portfolio 5 Distributed and cloud design

The exercise defines a three-member MongoDB replica set. The procedure records a majority-acknowledged marker, stops the primary, and checks whether the new primary can read that marker and acknowledge another write. A managed equivalent would place replicas in separate availability zones and keep application connections private. Majority acknowledgement improves resilience to primary failover, and sharding could distribute transcript storage if workload growth warrants it. This section documents the design and procedure. No failover results were recorded.

## Individual technical reflection

[Add your own short reflection. You could discuss the benchmark load error, how you verified the corrected run, and what comparing the plans taught you. Use your own account of the work.]

## AI use declaration

OpenAI ChatGPT and Codex assisted with the reference design, scripts, synthetic data, troubleshooting and documentation. Student-run MySQL evidence is linked in the repository. [Add what you personally reviewed, changed or verified and how you checked it.]

## References

MIT 8103 Advanced Database Systems continuous assessment brief, September 2026 cohort, pp. 1–8. MySQL 8.4 Reference Manual, EXPLAIN Statement. MongoDB Database Manual, Write Concern for Replica Sets and Read Concern. See repository guides for documentation links.
