USE uniresult_db;
DROP PROCEDURE IF EXISTS verify_design;
DELIMITER //
CREATE PROCEDURE verify_design()
BEGIN
  DECLARE rejected INT DEFAULT 0;
  IF (SELECT COUNT(*) FROM registrations) <> 12 OR
     (SELECT COUNT(*) FROM results) <> 11 OR
     (SELECT SUM(credits * grade_points) / SUM(credits) FROM transcript
      WHERE matric_number='UR/24/0001' AND session_start=2024 AND semester=1) <> 4.6 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected seed counts or GPA';
  END IF;
  START TRANSACTION;
  BEGIN
    DECLARE CONTINUE HANDLER FOR 1062, 1452, 3819 SET rejected = rejected + 1;
    INSERT INTO registrations VALUES (901,1,11,'2024-10-12');
    INSERT INTO results VALUES (902,80);
    UPDATE results SET score=101 WHERE registration_id=101;
  END;
  ROLLBACK;
  IF rejected <> 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Expected duplicate, FK and range rejections';
  END IF;
  SELECT 'Design checks passed' AS outcome;
END//
DELIMITER ;
CALL verify_design();
DROP PROCEDURE verify_design;
