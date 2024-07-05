-- Create queries:

-- Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    student_age INT,
    student_grade_id INT,
    FOREIGN KEY (student_grade_id) REFERENCES Grades(grade_id)
);

-- Grades table
CREATE TABLE Grades (
    grade_id INT PRIMARY KEY,
    grade_name VARCHAR(10)
);

-- Courses table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50)
);

-- Enrollments table
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Insert queries:

-- Insert into Grades table
INSERT INTO Grades (grade_id, grade_name) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C');

-- Insert into Courses table
INSERT INTO Courses (course_id, course_name) VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'History');

-- Insert into Students table
INSERT INTO Students (student_id, student_name, student_age, student_grade_id) VALUES
(1, 'Alice', 17, 1),
(2, 'Bob', 16, 2),
(3, 'Charlie', 18, 1),
(4, 'David', 16, 2),
(5, 'Eve', 17, 1),
(6, 'Frank', 18, 3),
(7, 'Grace', 17, 2),
(8, 'Henry', 16, 1),
(9, 'Ivy', 18, 2),
(10, 'Jack', 17, 3);

-- Insert into Enrollments table
INSERT INTO Enrollments (enrollment_id, student_id, course_id, enrollment_date) VALUES
(1, 1, 101, '2023-09-01'),
(2, 1, 102, '2023-09-01'),
(3, 2, 102, '2023-09-01'),
(4, 3, 101, '2023-09-01'),
(5, 3, 103, '2023-09-01'),
(6, 4, 101, '2023-09-01'),
(7, 4, 102, '2023-09-01'),
(8, 5, 102, '2023-09-01'),
(9, 6, 101, '2023-09-01'),
(10, 7, 103, '2023-09-01');

-- Questions:

-- Find all students enrolled in the Math course.

SELECT * FROM Students s
JOIN Enrollments e ON s.student_id=e.student_id
JOIN Courses c ON e.course_id=c.course_id
WHERE c.course_name='Math';

-- Using SubQuery
SELECT * FROM Students 
WHERE student_id IN 
(SELECT student_id FROM Enrollments
WHERE course_id IN 
(SELECT course_id FROM Courses 
WHERE course_name = 'Math') 
);

-- List all courses taken by students named Bob.
SELECT * FROM Courses c
JOIN Enrollments e ON c.course_id=e.course_id
JOIN Students s ON e.student_id=s.student_id
WHERE s.student_name='Bob';

-- Using SubQuery
SELECT * FROM Courses 
WHERE course_id = (
SELECT course_id FROM Enrollments 
WHERE student_id = (
SELECT student_id FROM Students WHERE student_name = 'Bob' ) 
);

-- Find the names of students who are enrolled in more than one course.
SELECT * FROM Students s
JOIN Enrollments e ON s.student_id=e.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(e.course_id)>1;

-- Using SubQuery
SELECT * FROM Students s 
WHERE EXISTS (
SELECT 1 FROM Enrollments e WHERE e.student_id = s.student_id
GROUP BY e.student_id 
HAVING COUNT(e.course_id) > 1
);

-- List all students who are in Grade A (grade_id = 1).
SELECT student_name from Students WHERE student_grade_id=1;

-- Find the number of students enrolled in each course.
SELECT c.course_name, COUNT(e.student_id) as Total_student
FROM Courses c
JOIN Enrollments e ON c.course_id=e.course_id
GROUP BY c.course_name;

-- Using SubQuery
SELECT course_name,
(SELECT COUNT(student_id) FROM Enrollments e 
WHERE e.course_id = c.course_id) AS Total_student FROM Courses c;

-- Retrieve the course with the highest number of enrollments.
SELECT c.course_name
FROM Courses c
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name
ORDER BY COUNT(e.student_id) DESC
LIMIT 1;

-- Using SubQuery
SELECT course_name
FROM Courses
WHERE course_id = (
SELECT course_id
FROM Enrollments
GROUP BY course_id
ORDER BY COUNT(student_id) DESC
LIMIT 1
);

-- List students who are enrolled in all available courses.
SELECT s.student_name FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(e.course_id) = (SELECT COUNT(*) FROM Courses);

-- Using SubQuery
SELECT student_name
FROM Students
WHERE student_id = ANY (
SELECT student_id
FROM Enrollments
GROUP BY student_id
HAVING COUNT(course_id) = (SELECT COUNT(*) FROM Courses)
);

-- Find students who are not enrolled in any courses.
SELECT s.student_name FROM Students s
WHERE NOT EXISTS (
SELECT * FROM Enrollments e WHERE e.student_id = s.student_id
);

-- Retrieve the average age of students enrolled in the Science course.
SELECT AVG(s.student_age) AS Average_Age
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE c.course_name = 'Science';

-- Using SubQuery
SELECT AVG(student_age) AS Average_Age FROM Students
WHERE student_id IN (
SELECT student_id FROM Enrollments
WHERE course_id = (
SELECT course_id FROM Courses
WHERE course_name = 'Science'
LIMIT 1
)
);

-- Find the grade of students enrolled in the History course.
SELECT g.grade_name
FROM Grades g
JOIN Students s ON g.grade_id = s.student_grade_id
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE c.course_name = 'History';

-- Using SubQuery
SELECT grade_name FROM Grades
WHERE grade_id=(
SELECT DISTINCT student_grade_id FROM Students
WHERE student_id IN (
SELECT student_id FROM Enrollments
WHERE course_id = (
SELECT course_id FROM Courses
WHERE course_name = 'History'
LIMIT 1))
LIMIT 1
);


-- Assignment:
-- Please design and create the necessary tables (Books, Authors, Publishers, Customers, Orders, Book_Authors, Order_Items) for an online bookstore database. Ensure each table includes appropriate columns, primary keys, and foreign keys where necessary. Consider the relationships between these tables and how they should be defined.

CREATE SCHEMA IF NOT EXISTS assignment2;
SET SEARCH_PATH TO assignment2;

CREATE TABLE IF NOT EXISTS Authors(
	author_id INT PRIMARY KEY,
	author_name VARCHAR(100),
	birth_date DATE,
	nationality VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Publishers(
	publisher_id INT PRIMARY KEY,
	publisher_name VARCHAR(100),
	country VARCHAR(25)
);

CREATE TABLE IF NOT EXISTS Books(
	book_id INT PRIMARY KEY,
	title VARCHAR(100),
	genre VARCHAR(50),
	publisher_id int,
	publication_year DATE,
	FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id)
);

CREATE TABLE IF NOT EXISTS Customers(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(100),
	email VARCHAR(50),
	address VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Orders(
	order_id INT PRIMARY KEY,
	order_date DATE,
	customer_id INT,
	total_amount DECIMAL (10,2),
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE IF NOT EXISTS Book_Authors(
	book_id INT,
	author_id INT,
	FOREIGN KEY (book_id) REFERENCES Books(book_id),
	FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

CREATE TABLE IF NOT EXISTS Order_Items(
	order_id INT,
	book_id INT,
	FOREIGN KEY (order_id) REFERENCES Orders(order_id),
	FOREIGN KEY (book_id) REFERENCES Books(book_id)
);
