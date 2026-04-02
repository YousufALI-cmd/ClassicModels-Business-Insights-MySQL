use classicmodels;

select * from employees;
select * from products;
select * from customers;
select * from orderdetails;
select * from payments;
select * from orders;
select * from productlines;

/*	Retrieve the employee number, first name, and last name of all employees 
	who are Sales Representatives and report to employee 1102. 	*/
select employeeNumber, firstName, lastName 
from employees 
where jobTitle = "Sales Rep" and reportsTo  = 1102;

-- List all unique product lines that contain the word 'Cars'. 
select distinct productLine 
from products 
where productLine like '%Cars';


/* Classify customers into regions based on their country:
	USA, Canada → North America
	UK, France, Germany → Europe
	Others → Other */
select customerNumber, customerName, case
when country in ("USA","Canada") then "North America"
when country in ("UK","France","Germany") then "Europe"
else "Other" 
end as CustomerSegment from customers;

-- Identify the top 10 products based on total quantity ordered. 
select productCode, sum(quantityOrdered) as total_ordered 
from orderdetails 
group by productCode 
order by total_ordered desc limit 10; 

-- Find months where the number of payments is greater than 20.
select monthname(paymentDate) as payment_month, count(paymentDate) as num_payments  
from payments 
group by payment_month having count(paymentDate) > 20 
order by count(paymentDate) desc;


-- Create a database and a Customers table with appropriate constraints.
create database Customers_Orders;
use Customers_Orders;

create table Customers (customer_id int primary key auto_increment, first_name varchar(50) not null,
last_name varchar(50) not null, 
email varchar(255) unique, phone_number varchar(20));

-- Create an Orders table with a foreign key reference to Customers and ensure total amount is greater than 0.
create table Orders (order_id int primary key auto_increment, customer_id int, 
foreign key(customer_id) references customers(customer_id), 
order_date int, total_amount decimal(10,2) check (total_amount > 0));


-- Find the top 5 countries with the highest number of orders.
select distinct a.country, count(b.orderNumber) as orders_count from customers as a 
inner join orders as b on a.customerNumber = b.customerNumber 
group by a.country order by orders_count desc limit 5;


-- Create a table and display employees along with their respective managers.
create table Project (EmployeeID int primary key auto_increment, FullName varchar(50) not null, 
Gender varchar(50) check(Gender in ('Male','Female')), ManagerID int);

INSERT INTO project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);

select * from project;
select a.FullName as Manager_Name, b.FullName as Emp_Name 
from project as a join project as b 
on a.EmployeeID = b.ManagerID
order by a.EmployeeID, b.EmployeeID;


/* Modify the facility table by:
	Setting Facility_ID as primary key and auto increment
	Adding a City column */
create table facility (Facility_ID int, Name varchar(100), State varchar(100), Country varchar(100));
desc facility;

alter table facility modify column Facility_ID int not null primary key auto_increment;
alter table facility add column City varchar(100) not null after Name;


-- Create a view to calculate total sales and number of orders for each product line.
select * from products;
select * from orderdetails;
select * from orders;
select * from productlines;

create view product_category_sales as select pl.productLine as productLine, 
sum(od.quantityOrdered * od.priceEach) as total_sales, 
count(distinct o.orderNumber) as number_of_orders 
from productlines pl
join products p on  pl.productLine = p.productLine
join orderdetails od on  p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
group by pl.productline;

select * from product_category_sales;
		
        
--  Execute a stored procedure to retrieve country-wise payments for France in 2003.
call Get_country_payments('2003','France');


-- Rank customers based on the number of orders using a window function.
select c.customerName, count(distinct o.orderNumber)Order_count, 
dense_rank() over(order by count( distinct o.orderNumber) desc)order_frequency_rnk 
from customers c join orders o on c.customerNumber = o.customerNumber 
group by c.customername; 

-- Calculate the percentage change in total orders month-over-month.
with ord_details as(
select year(orderDate) as Year, 
month(orderDate) as mnthnum,
monthname(orderDate) as Month, 
count(distinct orderNumber)as Total_Orders 
from orders group by year(orderDate), month(orderDate), monthname(orderDate))
select Year, Month, Total_Orders, 
concat(round(((total_orders - lag(total_orders,1) over(order by Year,Mnthnum))*100 / lag(total_orders,1) over(order by Year,mnthnum)),0), '%') as `%_YOY_change`
from ord_details;


-- Find product lines where the buy price is above the average buy price.
select productLine, count(productLine)as Total 
from products where buyPrice > (
select avg(buyPrice) from products) 
group by productLine 
order by Total desc;


-- Insert employee records and handle duplicate primary key errors.
create table Emp_EH (EmpID int primary key, EmpName varchar(20), EmailAddress varchar(30));
call Insert_Emp_EH(1, "Yousuf Ali", "samptic121@gmail.com");	# Inserted
call Insert_Emp_EH(1, "Sam Altmen","Leyland109@gmail.com");		# Error Occured
select * from Emp_EH;


-- Insert employee working hours and observe behavior when invalid data (negative hours) is inserted.
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_Date DATE,
    Working_Hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);
select * from Emp_BIT;

INSERT INTO Emp_BIT VALUES ('Steve', 'Driver', '2020-11-06', -12);
select * from Emp_BIT;


