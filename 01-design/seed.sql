USE uniresult_db;
START TRANSACTION;
INSERT INTO departments VALUES (1,'Computer Science'),(2,'Mathematics'),(3,'Statistics');
INSERT INTO students VALUES
 (1,'UR/24/0001','Amara Okeke','amara@example.test',1),
 (2,'UR/24/0002','Tunde Bello','tunde@example.test',1),
 (3,'UR/24/0003','Aisha Yusuf','aisha@example.test',2),
 (4,'UR/24/0004','Efe Daniels','efe@example.test',3),
 (5,'UR/24/0005','Kemi Afolabi','kemi@example.test',1),
 (6,'UR/25/0006','Ibrahim Musa','ibrahim@example.test',2);
INSERT INTO lecturers VALUES
 (1,'STF-019','Ada Nwosu',1),(2,'STF-025','Sola Akinyi',2),(3,'STF-031','Nneka Obi',3);
INSERT INTO courses VALUES
 (1,'CSC301','Database Systems',3,1),(2,'MAT305','Linear Algebra',2,2),
 (3,'STA307','Applied Statistics',3,3),(4,'CSC315','Data Structures',3,1);
INSERT INTO course_offerings VALUES
 (11,1,1,2024,1),(12,2,2,2024,1),(13,3,3,2024,1),(14,4,1,2024,2),(21,1,1,2025,1);
INSERT INTO registrations VALUES
 (101,1,11,'2024-10-07'),(102,1,12,'2024-10-07'),(103,2,11,'2024-10-08'),
 (104,3,12,'2024-10-08'),(105,4,13,'2024-10-09'),(106,5,11,'2024-10-09'),
 (107,2,21,'2025-10-06'),(108,1,14,'2025-03-03'),(109,6,21,'2025-10-08'),
 (110,4,12,'2024-10-09'),(111,5,14,'2025-03-03'),(112,3,13,'2024-10-10');
INSERT INTO results VALUES
 (101,78),(102,64),(103,38),(104,91),(105,58),(106,72),
 (107,62),(108,69),(110,47),(111,40),(112,55);
COMMIT;
