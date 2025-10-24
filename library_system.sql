--Library Management System Project 2

--Creating tables

CREATE TABLE branch(
	branch_id  VARCHAR(10) PRIMARY KEY	,
	manager_id	VARCHAR(10)	,
	branch_address	VARCHAR(55)	,
	contact_no VARCHAR(10) 
	);
alter table branch
alter column contact_no type VARCHAR(20);
	
CREATE TABLE employees(
	emp_id	VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(55)	,
	position	VARCHAR(55)	,
	salary	int,
	branch_id VARCHAR(10)	
	),

CREATE TABLE books(
	isbn	VARCHAR(20) PRIMARY KEY,
	book_title	VARCHAR(70),
	category	VARCHAR(20),
	rental_price	FLOAT,
	status	VARCHAR(20),
	author	VARCHAR(30),
	publisher VARCHAR(55)
	);

CREATE TABLE members(
	member_id	VARCHAR(20) PRIMARY KEY,
	member_name	VARCHAR(25),
	member_address	VARCHAR(70),
	reg_date DATE
	);

CREATE TABLE issued_status(
	issued_id VARCHAR(20) PRIMARY KEY,
	issued_member_id VARCHAR(20),
	issued_book_name VARCHAR(75),
	issued_date	DATE,
	issued_book_isbn	VARCHAR(20),
	issued_emp_id VARCHAR(20)
	);

create table return_status(
	return_id	VARCHAR(20) PRIMARY KEY,
	issued_id	VARCHAR(20) , 
	return_book_name  VARCHAR(75),
	return_date DATE ,
	return_book_isbn VARCHAR(20)	
	);
-- foreign key constrains

ALTER TABLE issued_status
ADD CONSTRAINT f_k
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT f_kBOOK
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT f_kemployee
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT f_k_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT f_k_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

--Task 1. Create a New Book Record -- "978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co

INSERT INTO bookS
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co');
SELECT * FROM books;

--Task 2: Update an Existing Member's Address

SELECT * FROM members;
UPDATE members
SET member_address = '125 Main ST'
WHERE MEMBER_ID ='C101';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;
DELETE FROM issued_status
WHERE ISSUED_ID ='IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT *
FROM issued_status
WHERE issued_emp_id='E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id , COUNT(*) AS num_of_issues_books
FROM issued_status
GROUP BY issued_emp_id
HAVING  COUNT(*)>1
ORDER BY 2;

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE  summary_table
AS 
( SELECT b.isbn , b.book_title, COUNT(*)
FROM books as b JOIN issued_status  as i ON
b.isbn = i.issued_book_isbn
GROUP BY 1,2);

SELECT * 
FROM summary_table;

--Task 7. Retrieve All Books in a Specific Category:

SELECT *
FROM books
WHERE category ='Fantasy';

--Task 8: Find Total Rental Income by Category:

SELECT  sum(b.rental_price) , b.category
FROM books as b JOIN issued_status  as i ON
b.isbn = i.issued_book_isbn 
GROUP BY 2
ORDER BY SUM;

--Task 9:List Members Who Registered in the Last 550 Days:

SELECT * FROM MEMBERS
WHERE  REG_DATE > current_date - INTERVAL '550DAYS';

--Task 10 :List Employees with Their Branch Manager's Name and their branch details:

select * from employees;
select * from branch;

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE  price
AS (SELECT *
FROM books
WHERE rental_price>6);
SELECT * from price;

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT i.* 
FROM issued_status AS i LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
where return_id IS NULL;

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT e.emp_id , e.emp_name , i.issued_book_name,i.issued_date , (current_date -  i.issued_date ) as overdue
FROM issued_status AS i 
LEFT JOIN return_status AS r
	ON i.issued_id = r.issued_id
JOIN employees AS e 
	on i.issued_emp_id = e.emp_id
WHERE (coalesce(r.return_date,current_date) -  i.issued_date )>30 and return_date is  null;


/*Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.*/

SELECT distinct br.branch_id , COUNT(IST.ISSUED_ID) 
,COUNT(rs.return_ID)  , sum(bk.rental_price)
FROM branch as br
JOIN employees as em
	on br.branch_id =em.branch_id
JOIN issued_status as ist
	on em.emp_id = ist.issued_emp_id
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1
order by 1;