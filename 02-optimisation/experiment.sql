USE uniresult_db;
-- Isolated benchmark table. Reruns replace only this synthetic table.
DROP TABLE IF EXISTS benchmark_registrations;
CREATE TABLE benchmark_registrations (
 registration_id INT PRIMARY KEY,
 offering_id INT NOT NULL,
 registered_on DATE NOT NULL,
 KEY ix_offering_date (offering_id, registered_on)
) ENGINE=InnoDB;
INSERT INTO benchmark_registrations (registration_id, offering_id, registered_on)
WITH digits AS (
 SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
)
SELECT n+1, MOD(n,97)+1, DATE_ADD('2024-09-01', INTERVAL MOD(n DIV 97,180) DAY)
FROM (
 SELECT a.d + 10*b.d + 100*c.d + 1000*d.d + 10000*e.d AS n
 FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e
) AS sequence_rows;
ANALYZE TABLE benchmark_registrations;
SELECT VERSION() AS server_version, COUNT(*) AS benchmark_rows FROM benchmark_registrations;

-- A. Baseline. Disable the candidate index for this statement.
EXPLAIN FORMAT=JSON SELECT COUNT(*) FROM benchmark_registrations IGNORE INDEX (ix_offering_date)
WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01';
EXPLAIN ANALYZE SELECT COUNT(*) FROM benchmark_registrations IGNORE INDEX (ix_offering_date)
WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01';

-- B. Isolate index availability while preserving the predicate.
EXPLAIN FORMAT=JSON SELECT COUNT(*) FROM benchmark_registrations
WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01';
EXPLAIN ANALYZE SELECT COUNT(*) FROM benchmark_registrations
WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01';

-- C. Hold the index available and wrap the date in a function.
EXPLAIN FORMAT=JSON SELECT COUNT(*) FROM benchmark_registrations
WHERE offering_id=42 AND DATE_FORMAT(registered_on,'%Y-%m')='2024-10';
EXPLAIN ANALYZE SELECT COUNT(*) FROM benchmark_registrations
WHERE offering_id=42 AND DATE_FORMAT(registered_on,'%Y-%m')='2024-10';

SELECT
 (SELECT COUNT(*) FROM benchmark_registrations IGNORE INDEX (ix_offering_date)
  WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01') AS baseline,
 (SELECT COUNT(*) FROM benchmark_registrations
  WHERE offering_id=42 AND registered_on >= '2024-10-01' AND registered_on < '2024-11-01') AS indexed,
 (SELECT COUNT(*) FROM benchmark_registrations
  WHERE offering_id=42 AND DATE_FORMAT(registered_on,'%Y-%m')='2024-10') AS wrapped;
