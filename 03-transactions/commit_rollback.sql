USE uniresult_db;
SELECT registration_id, score FROM results WHERE registration_id IN (101,109);

START TRANSACTION;
UPDATE results SET score=79 WHERE registration_id=101;
INSERT INTO results VALUES (109,66);
SELECT registration_id, score FROM results WHERE registration_id IN (101,109);
ROLLBACK;
SELECT registration_id, score FROM results WHERE registration_id IN (101,109);

START TRANSACTION;
UPDATE results SET score=79 WHERE registration_id=101;
INSERT INTO results VALUES (109,66);
COMMIT;
SELECT registration_id, score FROM results WHERE registration_id IN (101,109);

-- Restore the fixture after collecting evidence.
START TRANSACTION;
UPDATE results SET score=78 WHERE registration_id=101;
DELETE FROM results WHERE registration_id=109;
COMMIT;
