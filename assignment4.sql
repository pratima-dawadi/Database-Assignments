-- ASSIGNMENT 4

-- Download dataset from https://www.kaggle.com/datasets/krishujeniya/salary-prediction-of-data-professions?resource=download 
-- Ingest the dataset from your local machine storage into postgresQL database 
--             Hint: use copy command in sql editor which will copy your csv file to postgres DB
-- For ingesting csv you might also need to create table according to the column  structure of your CSV file ahead of executing copy command

-- Once the table is populated please complete following queries:

-- CREATING SCHEMA

CREATE SCHEMA IF NOT EXISTS assignment4;
SET search_path TO ASSIGNMENT4;

-- CREATING TABLE

CREATE TABLE IF NOT EXISTS salary_prediction(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50),
	sex VARCHAR(5),
	doj DATE,
	current DATE,
	designation VARCHAR(50),
	age INTEGER,
	salary INTEGER,
	unit VARCHAR(50),
	leaves_used INTEGER,
	leaves_remaining INTEGER,
	ratings INTEGER,
	past_exp INTEGER
);

-- Ingest the dataset from your local machine storage into postgresQL database 
COPY salary_prediction(first_name, last_name, sex, doj,current,designation,age,salary,unit,leaves_used,leaves_remaining,ratings,past_exp)
FROM 'D:\LF fellowship\assignments\DB\salary.csv'
DELIMITER ','
CSV HEADER;

-- Common Table Expressions (CTEs):
-- Question 1: Calculate the average salary by department for all Analysts.
WITH salary_analysts AS(
	SELECT unit, AVG(salary) 
	FROM salary_prediction WHERE designation='Analyst'
	GROUP BY unit
)
SELECT * FROM salary_analysts;

-- Question 2: List all employees who have used more than 10 leaves.
WITH employee_leaves_used AS(
	SELECT first_name,last_name,leaves_used 
	FROM salary_prediction 
	WHERE leaves_used>10
)
SELECT * FROM employee_leaves_used;

-- Views:
-- Question 3: Create a view to show the details of all Senior Analysts.
CREATE VIEW senior_analysts_details AS
	SELECT first_name, last_name,designation 
	FROM salary_prediction 
	WHERE designation='Senior Analyst';

SELECT * FROM senior_analysts_details;

-- Materialized Views:
-- Question 4: Create a materialized view to store the count of employees by department.
CREATE MATERIALIZED VIEW count_of_employees AS
	SELECT unit,COUNT(first_name)
	FROM salary_prediction
	GROUP BY unit;
	
SELECT * FROM count_of_employees;

-- Procedures (Stored Procedures):
-- Question 6: Create a procedure to update an employee's salary by their first name and last name.
CREATE OR REPLACE PROCEDURE update_salary(
    first_name_input VARCHAR(50),
    last_name_input VARCHAR(50),
    updated_salary INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE salary_prediction
    SET salary = updated_salary
    WHERE first_name = first_name_input
    AND last_name = last_name_input;
END;
$$;


CALL update_salary('TOMASA', 'ARMEN', 50000);
CALL update_salary('OLIVE', 'ANCY', 60000);

-- Question 7: Create a procedure to calculate the total number of leaves used across all departments.
CREATE OR REPLACE PROCEDURE no_of_leaves_used()
LANGUAGE plpgsql
AS $$
DECLARE
    total_leaves INTEGER;
BEGIN
    SELECT SUM(leaves_used) 
    INTO total_leaves
    FROM salary_prediction;
	
	RAISE NOTICE 'Total number of leaves used across all departments: %', total_leaves;

END;
$$;

CALL no_of_leaves_used();

