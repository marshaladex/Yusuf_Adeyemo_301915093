USE uniresult_db;
-- Transcript, with all attempts.
SELECT * FROM transcript WHERE matric_number='UR/24/0002'
ORDER BY session_start, semester, course_code;

-- Weighted semester GPA for posted results.
SELECT matric_number, session_start, semester,
 ROUND(1.0 * SUM(credits * grade_points)/SUM(credits),2) AS gpa
FROM transcript GROUP BY matric_number, session_start, semester
ORDER BY matric_number, session_start, semester;

-- Offering dashboard including empty offerings and pending results.
SELECT o.offering_id, c.course_code, COUNT(r.registration_id) AS enrolled,
 COUNT(x.registration_id) AS posted, ROUND(AVG(x.score),2) AS mean_score
FROM course_offerings o JOIN courses c USING (course_id)
LEFT JOIN registrations r USING (offering_id)
LEFT JOIN results x USING (registration_id)
GROUP BY o.offering_id,c.course_code ORDER BY o.offering_id;

-- Courses with at least one posted failure, using a correlated subquery.
SELECT c.course_code FROM courses c WHERE EXISTS (
 SELECT 1 FROM course_offerings o JOIN registrations r USING (offering_id)
 JOIN results x USING (registration_id)
 WHERE o.course_id=c.course_id AND x.score < 40)
ORDER BY c.course_code;

-- Top posted scores by offering, with ties.
SELECT offering_id, matric_number, score,
 DENSE_RANK() OVER (PARTITION BY offering_id ORDER BY score DESC) AS score_rank
FROM registrations JOIN results USING (registration_id) JOIN students USING (student_id)
ORDER BY offering_id,score_rank,matric_number;
