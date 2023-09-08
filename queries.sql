-- Find all employees
SELECT *
FROM employee;

-- Find all clients
SELECT *
FROM clients;

-- Find all employees ordered by salary
SELECT *
FROM employee
ORDER BY salary ASC; -- ORDER the column BY ascending

-- Find all employees ordered by sex then name
SELECT *
FROM employee
ORDER BY sex, name;

-- Find the first 5 employees in the table
SELECT *
from employee
LIMIT 5;

-- Find the first and last names of all employees
SELECT first_name, employee.last_name
FROM employee;

-- Find the forename and surnames names of all employees
SELECT first_name AS forename, employee.last_name AS surname
FROM employee;

-- Find out all the different genders
SELECT DISTINCT sex
FROM employee;

-- Find all male employees
SELECT *
FROM employee
WHERE sex = 'M';

-- Find all employees at branch 2
SELECT *
FROM employee
WHERE branch_id = 2;

-- Find all employee's id's and names who were born after 1969
SELECT emp_id, first_name, last_name
FROM employee
WHERE birth_day >= 1970-01-01;

-- Find all female employees at branch 2
SELECT *
FROM employee
WHERE branch_id = 2 AND sex = 'F';

-- Find all employees who are female & born after 1969 or who make over 80000
SELECT *
FROM employee
WHERE (birth_day >= '1970-01-01' AND sex = 'F') OR salary > 80000;

-- Find all employees born between 1970 and 1975
SELECT *
FROM employee
WHERE birth_day BETWEEN '1970-01-01' AND '1975-01-01';

-- Find all employees named Jim, Michael, Johnny or David
SELECT *
FROM employee
WHERE first_name IN ('Jim', 'Michael', 'Johnny', 'David');

-- Find the number of employees
SELECT COUNT(super_id)
FROM employee;

-- Find the average of all employee's salaries
SELECT AVG(salary)
FROM employee;

-- Find the sum of all employee's salaries
SELECT SUM(salary)
FROM employee;

-- Find out how many males and females there are
SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;

-- Find the total sales of each salesman
SELECT SUM(total_sales), emp_id
FROM works_with
GROUP BY emp_id;

-- Find the total amount of money spent by each client
SELECT SUM(total_sales), client_id
FROM works_with
GROUP BY client_id;

-- Find any client's who are an LLC
SELECT *
FROM client
WHERE client_name LIKE '%LLC';

-- Find any branch suppliers who are in the label business
SELECT *
FROM branch_supplier
WHERE supplier_name LIKE '% Label%';

-- Find any employee born on the 10th day of the month
SELECT *
FROM employee
WHERE birth_day LIKE '_____10%';

-- Find any clients who are schools
SELECT *
FROM client
WHERE client_name LIKE '%Highschool%';

-- Find a list of employee and branch names
SELECT employee.first_name AS Employee_Branch_Names
FROM employee
UNION
SELECT branch.branch_name
FROM branch;

-- Find a list of all clients & branch suppliers' names
SELECT client.client_name AS Non_Employee_Entities, client.branch_id AS Branch_ID
FROM client
UNION
SELECT branch_supplier.supplier_name, branch_supplier.branch_id
FROM branch_supplier;

-- Find all branches and the names of their managers
SELECT employee.emp_id, employee.first_name, branch.branch_name -- Wanted columns
FROM employee -- First column
JOIN branch    -- LEFT JOIN, RIGHT JOIN -- Second column
ON employee.emp_id = branch.mgr_id; -- What do they share in common?

-- Find names of all employee and client pairs who have
-- sold over 30,000 to a single client
-- and list their totals
SELECT a.emp_id AS Employee_ID, a.first_name AS First_Name, a.last_name AS Last_Name, b.client_id AS Client_ID, c.client_name AS Client_Name, b.total_sales AS Total_Sales
FROM employee a -- Renames the table in the query
JOIN works_with b
	ON b.emp_id = a.emp_id
JOIN client c
	ON b.client_id = c.client_id
WHERE b.total_sales > 30000;

-- Find names of all employees who have sold over 50,000
SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (SELECT works_with.emp_id
                          FROM works_with
                          WHERE works_with.total_sales > 50000
                          );

-- Find all clients who are handled by the branch that Michael Scott manages
-- Assume you know Michael's ID
SELECT client.client_id, client.client_name
FROM client
WHERE client.branch_id = (SELECT branch.branch_id
                          FROM branch
                          WHERE branch.mgr_id = 102);

 -- Find all clients who are handled by the branch that Michael Scott manages
 -- Assume you DONT'T know Michael's ID
 SELECT client.client_id, client.client_name
 FROM client
 WHERE client.branch_id = (SELECT branch.branch_id
                           FROM branch
                           WHERE branch.mgr_id = (SELECT employee.emp_id
                                                  FROM employee
                                                  WHERE employee.first_name = 'Michael' AND employee.last_name ='Scott'
                                                  LIMIT 1));

-- Find the names of employees who work with clients handled by the scranton branch
-- Assume you don't know the scanton branch id
SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
                         SELECT works_with.emp_id
                         FROM works_with
                         )
AND employee.branch_id = (
	SELECT branch.branch_id
    FROM branch
    WHERE branch.branch_name = 'Scranton');

-- Find the names of all clients who have spent more than 100,000 dollars
SELECT client.client_name
FROM client
WHERE client.client_id IN (
                          SELECT client_id
                          FROM (
                                SELECT SUM(works_with.total_sales) AS totals, client_id
                                FROM works_with
                                GROUP BY client_id) AS total_client_sales
                          WHERE totals > 100000
);

-- Find the clients and their total sales who have spent more than the average of total sales
SELECT c.client_id, c.client_name, SUM(ww.total_sales) AS total
FROM client c
JOIN works_with ww 
	ON c.client_id = ww.client_id
GROUP BY c.client_id
HAVING total > 
	(SELECT (SUM(works_with.total_sales)/COUNT(DISTINCT client_id)) as average
	FROM works_with);
    
-- OR    

SELECT ww.client_id, c.client_name, SUM(ww.total_sales)
FROM works_with AS ww
JOIN client AS c 
	ON ww.client_id = c.client_id
GROUP BY ww.client_id
HAVING SUM(ww.total_sales) > (SELECT AVG(totals.total_sales_grouped)
								FROM (SELECT SUM(ww2.total_sales) AS total_sales_grouped
										FROM works_with AS ww2
										GROUP BY ww2.client_id) AS totals);