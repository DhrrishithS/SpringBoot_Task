CREATE DATABASE testdb; USE testdb;

-- Departments
CREATE TABLE department (
  department_id INT PRIMARY KEY,
  department_name VARCHAR(100)
);

INSERT INTO department (department_id, department_name) VALUES
(1,'HR'),
(2,'Finance'),
(3,'Engineering'),
(4,'Sales'),
(5,'Marketing'),
(6,'IT');

-- Employees
CREATE TABLE employee (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  dob DATE,
  gender VARCHAR(10),
  department INT
);

INSERT INTO employee (emp_id, first_name, last_name, dob, gender, department) VALUES
(1,'John','Williams','1980-05-15','Male',3),
(2,'Sarah','Johnson','1990-07-20','Female',2),
(3,'Michael','Smith','1985-02-10','Male',3),
(4,'Emily','Brown','1992-11-30','Female',4),
(5,'David','Jones','1988-09-05','Male',5),
(6,'Olivia','Davis','1995-04-12','Female',1),
(7,'James','Wilson','1983-03-25','Male',6),
(8,'Sophia','Anderson','1991-08-17','Female',4),
(9,'Liam','Miller','1979-12-01','Male',1),
(10,'Emma','Taylor','1993-06-28','Female',5);

-- Payments
CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  emp_id INT,
  amount DECIMAL(12,2),
  payment_time DATETIME,
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

INSERT INTO payments (payment_id, emp_id, amount, payment_time) VALUES
(1,2,65784.00,'2025-01-01 13:44:12'),
(2,4,62736.00,'2025-01-06 18:36:37'),
(3,1,69437.00,'2025-01-01 10:19:21'),
(4,3,67183.00,'2025-01-02 17:21:57'),
(5,2,66273.00,'2025-02-01 11:49:15'),
(6,5,71475.00,'2025-01-01 07:24:14'),
(7,1,70837.00,'2025-02-03 19:11:31'),
(8,6,69628.00,'2025-01-02 10:41:15'),
(9,4,71876.00,'2025-02-01 12:16:47'),
(10,3,70098.00,'2025-02-03 10:11:17'),
(11,6,67827.00,'2025-02-02 19:21:27'),
(12,5,69871.00,'2025-02-05 17:54:17'),
(13,2,72984.00,'2025-03-05 09:37:35'),
(14,1,67982.00,'2025-03-01 06:09:51'),
(15,6,70198.00,'2025-03-02 10:34:35'),
(16,4,74998.00,'2025-03-02 09:27:26');

WITH high_paid AS (
  SELECT DISTINCT e.emp_id,
         e.first_name,
         e.last_name,
         e.department AS department_id,
         TIMESTAMPDIFF(YEAR, e.dob, CURDATE()) AS age
  FROM employee e
  JOIN payments p ON e.emp_id = p.emp_id
  WHERE p.amount > 70000
),
ranked AS (
  SELECT hp.*,
         ROW_NUMBER() OVER (PARTITION BY hp.department_id ORDER BY hp.emp_id) AS rn
  FROM high_paid hp
),
emp_list_per_dept AS (
  SELECT department_id,
         GROUP_CONCAT(CONCAT(first_name, ' ', last_name) ORDER BY emp_id SEPARATOR ', ') AS employee_list
  FROM ranked
  WHERE rn <= 10
  GROUP BY department_id
),
avg_age_per_dept AS (
  SELECT department_id, ROUND(AVG(age), 2) AS average_age
  FROM high_paid
  GROUP BY department_id
)
SELECT d.department_name AS DEPARTMENT_NAME,
       a.average_age AS AVERAGE_AGE,
       COALESCE(e.employee_list, '') AS EMPLOYEE_LIST
FROM department d
LEFT JOIN avg_age_per_dept a ON d.department_id = a.department_id
LEFT JOIN emp_list_per_dept e ON d.department_id = e.department_id
ORDER BY d.department_id DESC;