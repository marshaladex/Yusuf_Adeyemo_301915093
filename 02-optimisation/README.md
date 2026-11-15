# Portfolio 2 · SQL and optimisation (7 marks)

Run queries.sql and experiment.sql. The first script returns transcripts, weighted GPA, an offering dashboard, a failure report and ranked scores. Expect the only failing course to be CSC301 and offering 21 to have two registrations and one posted score before the transaction exercise.

The benchmark isolates access paths on 100,000 deterministic registration-like rows. A suppresses the index, B lets MySQL choose it for an offering and half-open date range, and C wraps the indexed date in DATE_FORMAT. Equality on the leading offering column followed by a date range gives B a contiguous index interval. C can still exploit the leading column but ordinarily filters date values after reading the offering slice. A full scan is the baseline hypothesis. The counts should match at 186 each. Wider indexes increase storage and maintenance work on writes.

Save the actual JSON and ANALYZE output. Record access type, chosen key, used key parts, estimated rows, actual rows and loops at the scan/filter nodes. The aggregate itself emits one row. Repeat just the measurement statements after an initial warm-up, alternating A/B/C for at least five rounds in the same session. Report median root elapsed time with units and server version. State any deviations from the access path hypotheses. MySQL's ANALYZE includes instrumentation overhead.

[MySQL EXPLAIN manual](https://dev.mysql.com/doc/refman/8.4/en/explain.html)
