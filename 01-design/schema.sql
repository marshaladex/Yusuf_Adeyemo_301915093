CREATE DATABASE IF NOT EXISTS uniresult_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE uniresult_db;

CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  matric_number VARCHAR(20) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB;
CREATE TABLE lecturers (
  lecturer_id INT PRIMARY KEY,
  staff_number VARCHAR(20) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB;
CREATE TABLE courses (
  course_id INT PRIMARY KEY,
  course_code VARCHAR(12) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  credits TINYINT NOT NULL CHECK (credits BETWEEN 1 AND 6),
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB;
CREATE TABLE course_offerings (
  offering_id INT PRIMARY KEY,
  course_id INT NOT NULL,
  lecturer_id INT NOT NULL,
  session_start SMALLINT NOT NULL CHECK (session_start BETWEEN 2000 AND 2100),
  semester TINYINT NOT NULL CHECK (semester IN (1,2)),
  UNIQUE (course_id, session_start, semester),
  FOREIGN KEY (course_id) REFERENCES courses(course_id),
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(lecturer_id)
) ENGINE=InnoDB;
CREATE TABLE registrations (
  registration_id INT PRIMARY KEY,
  student_id INT NOT NULL,
  offering_id INT NOT NULL,
  registered_on DATE NOT NULL,
  UNIQUE (student_id, offering_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id)
) ENGINE=InnoDB;
CREATE TABLE results (
  registration_id INT PRIMARY KEY,
  score DECIMAL(5,2) NOT NULL CHECK (score BETWEEN 0 AND 100),
  FOREIGN KEY (registration_id) REFERENCES registrations(registration_id)
) ENGINE=InnoDB;

CREATE VIEW transcript AS
SELECT s.matric_number, c.course_code, c.title, c.credits,
       o.session_start, o.semester, x.score,
       CASE WHEN x.score >= 70 THEN 'A' WHEN x.score >= 60 THEN 'B'
            WHEN x.score >= 50 THEN 'C' WHEN x.score >= 45 THEN 'D'
            WHEN x.score >= 40 THEN 'E' ELSE 'F' END AS grade,
       CASE WHEN x.score >= 70 THEN 5 WHEN x.score >= 60 THEN 4
            WHEN x.score >= 50 THEN 3 WHEN x.score >= 45 THEN 2
            WHEN x.score >= 40 THEN 1 ELSE 0 END AS grade_points
FROM results x JOIN registrations r USING (registration_id)
JOIN students s USING (student_id)
JOIN course_offerings o USING (offering_id)
JOIN courses c USING (course_id);
