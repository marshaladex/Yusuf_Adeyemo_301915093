-- Execute each numbered block separately in physical connection A.
-- A1. Begin after B has selected its session settings.
USE uniresult_db;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT score FROM results WHERE registration_id=101 FOR UPDATE;
UPDATE results SET score=79 WHERE registration_id=101;

-- A2. Execute only while B1 is waiting.
COMMIT;

-- A3. Execute after B2 and after saving both sessions' evidence.
UPDATE results SET score=78 WHERE registration_id=101;
