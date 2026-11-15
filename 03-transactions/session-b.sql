-- B0. Execute before A1 in an independent physical connection B.
USE uniresult_db;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION innodb_lock_wait_timeout=120;

-- B1. Execute after A1 and before A2. Plain SELECT should read 78.
START TRANSACTION;
SELECT score FROM results WHERE registration_id=101;
-- The locking read waits for A2, then should see 79.
SELECT score FROM results WHERE registration_id=101 FOR UPDATE;

-- B2. An edit submitted against the previously read 78 is now stale.
UPDATE results SET score=80 WHERE registration_id=101 AND score=78;
SELECT ROW_COUNT() AS applied;
ROLLBACK;
SELECT score FROM results WHERE registration_id=101;
