-- SQL DATA ANALYSIS Project -------- 
-- Tool : MySQL Workbench 
-- Database Used : ClassicModels
-- Objective : Perform SQL- based business data analysis using ClassicModels database

-- Topics Covered : 
-- SELECT, WHERE, DISTINCT, LIKE
-- CASE Statements
-- GROUP BY & HAVING
-- JOINS
-- SELF JOIN
-- DDL Commands
-- VIEWS
-- STORED PROCEDURES
-- WINDOW FUNCTIONS
-- SUBQUERIES
-- ERROR HANDLING
-- TRIGGERS
-------------------


-- Question 1 (A) : SELECT Clause with WHERE, AND , DISTINCT and LIKE
-- Objective : Retrieve specific employee records and unique product lines--
USE classicmodels;
SELECT employeeNumber, FirstName, LastName 
From employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;

-- Question 1 (B)--
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%Cars';

  -- Question  2 : Customer Segmentation using CASE Statement --
  -- Objective : Categorize customers into regions based on country --
  SELECT customerNumber, customerName, 
  CASE WHEN country IN ('USA','Canada') THEN 'North America'
  WHEN country IN ('UK','France','Germany')THEN 'Europe'
  ELSE 'Other' END AS CustomerSegment
  FROM customers;
  
  -- Question 3 (A) : GROUP BY , HAVING and Date Functions --
  -- Objective : Analyze product order quantity and monthly payment frequency --
  SELECT productCode, SUM(quantityOrdered) AS total_ordered
  FROM orderdetails
  GROUP BY productCode
  ORDER BY total_ordered DESC LIMIT 10;
  
  -- QUESTION 3 (B) -- Monthly payment frequency analysis
  SELECT MONTHNAME (paymentDate) AS payment_month,
  COUNT(*) AS num_payments
  FROM payments
  GROUP BY payment_month
  HAVING COUNT(*)>20
  ORDER BY num_payments DESC;
  
  -- QUESTION 4 : SQL CONSTRAINTS 
  -- Objective: Create tables using Primary key, Foreign Key, Unique , Check, and Not Null constraints --
  -- Create Database--
  CREATE DATABASE Customers_Orders;
  
  -- Use Database --
  USE Customers_Orders;
  
  -- QUESTION 4 (A) -- Create Customers table
  CREATE TABLE Customers( customer_id INT AUTO_INCREMENT PRIMARY KEY, 
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone_number VARCHAR(20));
  INSERT INTO Customers (first_name,last_name,email,phone_number)
  VALUES('DEEPAK','KUMAR','deepakawsm24@gmail.com','7973635061');
  SELECT*FROM Customers;
  
  
  -- QUESTION 4 (B) -- Create Orders table
  CREATE TABLE Orders (order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2),
  FOREIGN KEY (customer_id)
  REFERENCES Customers(customer_id),
  CHECK (total_amount>0));
  SHOW TABLES;
  SELECT* FROM Customers;

-- QUESTION 5 (A) : SQL JOINS -- 
-- Objective: Find the top 5 countries based on order count --
USE CLASSICMODELS;
SELECT c.country, COUNT(o.orderNumber)
 AS order_count
FROM customers c
JOIN orders o
ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC 
LIMIT 5;

  -- QUESTION 6 -- SELF JOIN --
  -- Objective : Display employees and their managers using self join --
  -- Table Create Query--
  DROP TABLE project;
  CREATE TABLE project(EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
  FullName VARCHAR(50) NOT NULL,
  GENDER VARCHAR(10),
  ManagerID INT);
  
  -- Insert Data -- 
-- SELF JOIN QUERY --
SELECT m.FULLNAME AS 'MANAGER NAME',
e.FULLNAME AS 'EMP NAME'
FROM PROJECT e
JOIN PROJECT m
ON e.MANAGERID = m.EMPLOYEEID;

-- QUESTION NO- 7 DDL Commands --
-- Objective : Create, Alter tables and add new columns --
-- Create Table - Facility --
CREATE TABLE FACILITY (FACILITY_ID INT,
NAME VARCHAR (100),
STATE VARCHAR(100),
COUNTRY VARCHAR (100));

-- ALTER TABLE-PRIMARY KEY + AUTO INCREMENT--
ALTER TABLE FACILITY MODIFY FACILITY_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- ADD NEW COLUMN- CITY (AFTER NAME)--
ALTER TABLE FACILITY ADD CITY VARCHAR (100) NOT NULL AFTER NAME;

INSERT INTO FACILITY (NAME, CITY, STATE, COUNTRY) VALUES ('HOSPITAL A' , 'DELHI','DELHI','INDIA');
 
SELECT*FROM FACILITY;
DESC FACILITY;
  
  -- QUESTION 8 : SQL VIEWS --
  -- Objective : Create a view to analyze product category sales --
  -- CREATE VIEW- PRODUCT_CATEGORY_SALES
  CREATE VIEW product_category_sales AS SELECT pl.productLine,
  SUM(od.quantityOrdered*od.priceEach)
  AS total_sales,
  COUNT(DISTINCT o.orderNumber)
  AS number_of_orders
  FROM productlines pl
  JOIN products p
  ON pl.productline = p.productLine
  JOIN orderdetails od
  ON p.productCode = od.productCode
  JOIN orders o
  ON od.orderNumber = o.orderNumber
  GROUP BY pl.productLine;
  
SELECT*FROM product_category_sales;

  -- QUESTION 9 STORED PROCEDURES --
  -- Objective : Create a procedure to get country wise payments --
  -- STORED PROCEDURE-GET_COUNTRY_PAYMENTS--
  -- Procedure Create--
  DELIMITER //
  CREATE PROCEDURE get_country_payments(IN p_year INT, IN p_country VARCHAR (50))
  BEGIN
  SELECT YEAR (payments.paymentDate) AS YEAR,
  customers.country,
  CONCAT(ROUND(SUM(payments.amount)/1000),'K') 
  AS Total_Amount
  FROM payments
  JOIN customers
  ON payments.customerNumber = customers.customerNumber
  WHERE YEAR(payments.paymentDate) = p_year
  AND customers.country = p_country
  GROUP BY YEAR (payments.paymentDate),
  customers.country;
  END // 
  DELIMITER ;
  
  CALL get_country_payments(2003,'France');
  
  -- QUESTION 10 : WINDOW FUNCTIONS --
  -- Objective : Use RANK, LAG functions for order analysis --
  -- QUESTION 10 (A) RANK THE CUSTOMERS BASED ON THEIR ORDER FREQUENCY
 SELECT
 customerName,
 order_count,
 RANK() OVER (ORDER BY order_count DESC) AS order_frequency_rnk
 FROM( SELECT c.customerName, COUNT(o.orderNumber)
 AS order_count
 FROM customers c
 JOIN orders o
 ON c.customerNumber = o.customerNumber
 GROUP BY c.customerName)t;
 
  -- QUESTION 10(B) --
  -- Year Wise , Month name wise order count and YoY % change --
  SELECT
  YEAR(orderDate) AS YEAR, 
  MONTHNAME(orderDate) AS MONTH,
  COUNT(orderNumber) AS Total_Orders,
  CONCAT(
  ROUND(
  (COUNT(orderNumber) - 
  LAG ( COUNT(orderNumber)) OVER(ORDER BY
  YEAR ( orderDate), MONTH(orderDate)))
  /
  LAG(COUNT(orderNumber)) OVER(ORDER BY 
  YEAR (orderDate), MONTH(orderDate))
  *100,0),'%') AS 'YOY CHANGE'
  FROM orders
  GROUP BY YEAR (orderDate),
  MONTH(orderDate), MONTHNAME(orderDate)
  ORDER BY YEAR (orderDate),
  MONTH (orderDate);
  
  -- QUESTION NO (11) SUBQUERIES --
  -- Objective : Identify product lines with above average buy price --
  SELECT productLine,
  COUNT(*) AS TOTAL
  FROM PRODUCTS
  WHERE BUYPRICE>
  (
  SELECT AVG(BUYPRICE)
  FROM PRODUCTS
  )
  GROUP BY PRODUCTLINE;
  
  -- QUESTION 12  ERROR HANDLING --
  -- Objective : Implement exception handling using stored procedure --
  
  CREATE TABLE Emp_EH(
  EmpID INT PRIMARY KEY, 
  EmpName VARCHAR(50),
  EmailAddress VARCHAR(100));
  DELIMITER //
  CREATE PROCEDURE insert_emp_eh(
  IN p_EmpID INT,
  IN p_EmpName VARCHAR(50),
  IN p_EmailAddress VARCHAR(100))
  BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  SELECT ' Error occurred';
  INSERT INTO Emp_EH
  VALUES(p_EmpID,p_EmpName,p_EmailAddress);
  END // 
  DELIMITER ;
  
  DESC Emp_EH;
  SELECT*FROM Emp_EH;
  CALL insert_emp_eh( 1 ,'DEEPAK','deepakawsm24@gmail.com');
  
  -- QUESTION 13 : SQL TRIGGERS --
  -- Objective : Create a trigger to convert negative working hours into positive values before insert --
  -- TABLE CREATE QUERY --
  CREATE TABLE Emp_BIT(
  NAME VARCHAR (50),
  OCCUPATION VARCHAR(50),
  WORKING_DATE DATE,
  WORKING_HOURS INT);
  
  -- INSERT DATA QUERY --
  INSERT INTO EMP_BIT VALUES
  ('ROBIN','SCIENTIST','2020-10-04',12),
  ('WARNER','ENGINEER','2020-10-04',10),
  ('PETER','ACTOR','2020-10-04',13),
  ('MARCO','DOCTOR','2020-10-01',14),
  ('BRAYDEN','TEACHER','2020-10-04',12),
  ('ANTONIO','BUSINESS','2020-10-04',11);
  
  -- BEFORE INSERT TRIGGER --
  DELIMITER $$
  CREATE TRIGGER trg_before_insert_emp
  BEFORE INSERT ON Emp_BIT
  FOR EACH ROW
  BEGIN
  IF NEW.Working_hours < 0 THEN
  SET NEW.Working_hours = 
  ABS(NEW.Working_hours);
  END IF;
  END$$
  DELIMITER ;
  
  INSERT INTO Emp_BIT VALUES 
  ('John','MANAGER','2020-10-04',-8);
  
  SELECT*FROM Emp_BIT;
  DESCRIBE Emp_BIT;
  SHOW TABLES;
  
  
  
  
  
  
  
						
