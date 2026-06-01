-- CREATING DATABASE
CREATE DATABASE ShopEase_Solutions;

-- Using DATABASE
USE ShopEase_Solutions;

/* Creating Tables:
1- Customer table
2- products table
3- order table
4- oder_item table*/

CREATE TABLE customers(
customer_id INT ,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
city VARCHAR(50) NOT NULL,
state VARCHAR(50) NOT NULL,
join_date DATE NOT NULL,
is_premium BOOLEAN DEFAULT FALSE,
PRIMARY KEY(customer_id)
);

CREATE TABLE products(
product_id INT,
product_name VARCHAR(100) NOT NULL,
category VARCHAR(50) NOT NULL,
brand VARCHAR(50) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >0) ,
stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >=0),
PRIMARY KEY(product_id)
);

CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT NOT NULL,
order_date DATE NOT NULL,
status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')),
total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >=0),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);


CREATE TABLE order_items ( 
item_id  INT   PRIMARY KEY, 
order_id   INT  NOT NULL, 
product_id  INT  NOT NULL, 
quantity INT NOT NULL  CHECK (quantity > 0), 
unit_price  DECIMAL(10,2) NOT NULL  CHECK (unit_price > 0), 
discount_pct DECIMAL(5,2)  DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100), 
FOREIGN KEY (order_id)   REFERENCES orders(order_id), 
FOREIGN KEY (product_id) REFERENCES products(product_id) 
); 

CREATE INDEX idx_customers_city     ON customers(city);
CREATE INDEX idx_customers_state    ON customers(state);
CREATE INDEX idx_products_category  ON products(category);
CREATE INDEX idx_orders_date        ON orders(order_date);
CREATE INDEX idx_orders_status      ON orders(status);



-- INSERTING VALUES in the TABLES
-- customer table
INSERT INTO customers VALUES 
(101, 'Aarav',  'Sharma', 'aarav.s@email.com',  'Mumbai',    'Maharashtra', '2024-01-15', TRUE), 
(102, 'Priya',  'Patel',  'priya.p@email.com',  'Ahmedabad', 'Gujarat',     '2024-02-20', FALSE), 
(103, 'Rohan',  'Gupta',  'rohan.g@email.com',  'Delhi',     'Delhi',       '2024-03-10', TRUE), 
(104, 'Sneha',  'Reddy',  'sneha.r@email.com',  'Hyderabad', 'Telangana',   '2024-04-05', FALSE), 
(105, 'Vikram', 'Singh',  'vikram.s@email.com', 'Jaipur',    'Rajasthan',   '2024-05-12', TRUE), 
(106, 'Ananya', 'Iyer',   'ananya.i@email.com', 'Chennai',   'Tamil Nadu',  '2024-06-18', FALSE), 
(107, 'Karan',  'Mehta',  'karan.m@email.com',  'Pune',      'Maharashtra', '2024-07-22', TRUE), 
(108, 'Divya',  'Nair',   'divya.n@email.com',  'Kochi',     'Kerala',      '2024-08-30', FALSE); 

-- product table
INSERT INTO products VALUES 
(201, 'Wireless Earbuds', 'Electronics', 'BoAt',1499.00, 250), 
(202, 'Cotton T-Shirt', 'Clothing', 'Levis',799.00,  500), 
(203, 'Smart Watch', 'Electronics', 'Noise',2999.00, 150), 
(204, 'Running Shoes', 'Clothing','Nike',4599.00, 120), 
(205, 'Bluetooth Speaker', 'Electronics','JBL', 3499.00, 200), 
(206, 'Bedsheet Set',  'Home','Spaces', 1299.00, 300), 
(207, 'Laptop Stand', 'Electronics','AmazonBasics',899.00,  180), 
(208, 'Cushion Covers (Set)', 'Home', 'HomeCenter', 599.00,  400); 


-- order table
INSERT INTO orders VALUES 
(1001, 101, '2024-08-01', 'Delivered',  4498.00), 
(1002, 102, '2024-08-03', 'Delivered',  799.00), 
(1003, 103, '2024-08-05', 'Shipped',    7498.00), 
(1004, 101, '2024-08-10', 'Delivered',  3499.00), 
(1005, 104, '2024-08-12', 'Cancelled',  2999.00), 
(1006, 105, '2024-08-15', 'Delivered',  5898.00), 
(1007, 106, '2024-08-18', 'Pending',    1299.00), 
(1008, 103, '2024-08-20', 'Delivered',  899.00), 
(1009, 107, '2024-08-25', 'Shipped',    6098.00), 
(1010, 108, '2024-08-28', 'Delivered',  1598.00); 

-- order_item table
INSERT INTO order_items VALUES 
(5001, 1001, 201, 2, 1499.00, 0), 
(5002, 1001, 207, 1, 899.00,  10), 
(5003, 1002, 202, 1, 799.00,  0), 
(5004, 1003, 203, 1, 2999.00, 0), 
(5005, 1003, 204, 1, 4599.00, 5), 
(5006, 1004, 205, 1, 3499.00, 0), 
(5007, 1005, 203, 1, 2999.00, 0), 
(5008, 1006, 201, 1, 1499.00, 10), 
(5009, 1006, 204, 1, 4599.00, 5), 
(5010, 1007, 206, 1, 1299.00, 0), 
(5011, 1008, 207, 1, 899.00,  0), 
(5012, 1009, 205, 1, 3499.00, 0), 
(5013, 1009, 208, 2, 599.00,  15), 
(5014, 1010, 206, 1, 1299.00, 0), 
(5015, 1010, 208, 1, 599.00,  0);

	



/* Section A — SQL Basics (SELECT, Constraints, Primary Keys) 

These questions test your understanding of basic data retrieval, table structure, and database constraints. 

Q1. Write a query to display all columns and rows from the customer's table. 

Q2. Retrieve only the first_name, last_name, and city of all customers. 

Q3. List all unique categories available in the products table. 

Q4. Identify the Primary Key of each table in the schema. Explain why a Primary Key must be unique and NOT NULL. 

Q5. What constraints are applied to the email column in the customers table? What would happen if you tried to insert a duplicate email? 

Q6. Try inserting a product with unit_price = -50. What happens and which constraint prevents it? Write both the INSERT statement and explain the error. */


-- Ques 1
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;


-- Ques 2
SELECT 
	first_name,last_name,city
FROM customers;


-- Ques 3
SELECT 
	DISTINCT category
FROM products;


-- Ques 4
/* Primary Keys:
	1. customer Table - customer_id
	2. product Table - product_id
	3. order Table - order_id
	4. order_items - item_id

	A Primary Key must be unique and NOT NULL
	because it is used to identify each row in a table.
	Uniqueness ensures that no two records have the same identifier,
	while the NOT NULL constraint ensures that every record has a valid ID. Without these rules,
	the database would not be able to accurately identify, update, or relate records,
	leading to data inconsistency and confusion.
*/

-- Ques 5
/* Two constraints are applied to email in the customers table: UNIQUE and NOT NULL.
   If we try to insert a duplicate email, the UNIQUE constraint is violated and MySQL
   rejects the row with a "Duplicate entry" error, ensuring no two customers share the
   same email. NOT NULL also requires every customer to have an email value.*/

-- Ques 6
INSERT INTO products VALUES(209,'Pillow Cover','Home','AmazonBasics',-50,20);
/*
- What happens?
     The insert fails with a CHECK constraint violation error; the row is not inserted.
     
 - Which constraint prevents it?
     The CHECK (unit_price > 0) constraint on the products table.
 
 - Error explained:
     We attempt to insert unit_price = -50, which violates CHECK (unit_price > 0).
     MySQL evaluates the CHECK condition before inserting and rejects the row,
     reporting that the check constraint is violated.
*/


/* Section B — Filtering & Optimization (WHERE, Indexes) 

These questions test your ability to filter data effectively and understand how indexes improve query performance. 

Q7. Retrieve all orders with status = 'Delivered'. 

Q8. Find all products in the 'Electronics' category with a unit_price greater than ₹2000. 

Q9. List all customers who joined in the year 2024 and belong to the state 'Maharashtra'. 

Q10. Find all orders placed between '2024-08-10' and '2024-08-25' (inclusive) that are NOT cancelled. 

Q11. Explain what the index idx_orders_date does. How would it improve the performance of a query that filters orders by order_date? Write a sample query that would benefit from this index. 

Q12. If you run: SELECT * FROM customers WHERE YEAR(join_date) = 2024; — would the index on join_date be used? Explain why or why not, and rewrite the query to be index-friendly (SARGable).*/

 -- Ques 7
 SELECT *
 FROM orders
 WHERE status = 'Delivered';
 
 -- Ques 8
  SELECT *
 FROM products
 WHERE category = 'Electronics' AND unit_price > 2000;
 
 -- Ques 9
 SELECT *
 FROM customers
 WHERE state = 'Maharashtra' AND join_date >= '2024-01-01' AND join_date < '2025-01-01';
 
 
 -- Ques -10
SELECT *
FROM orders
WHERE status <> 'Cancelled' AND order_date BETWEEN '2024-08-10' AND '2024-08-25';
 
-- Ques 11
/* idx_orders_date is a B-tree index on orders(order_date). It stores order_date
   values in sorted order with pointers to the matching rows, so the database can
   jump straight to the relevant dates instead of scanning every row (a full table
   scan). This speeds up range and equality filters on order_date. */
  
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-08-01' AND '2024-08-15';


-- Ques 12
/* No. Wrapping the column in a function, YEAR(join_date), makes the predicate
   non-SARGable: MySQL must compute YEAR() for every row before comparing, so it
   cannot use the sorted index and falls back to a full table scan. Rewrite it as a
   range on the raw column so the index can be used: */
   
SELECT *
FROM customers
WHERE join_date >= '2024-01-01' AND join_date < '2025-01-01';
   



/*Section C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX) 

These questions test your ability to summarize and aggregate data. 

Q13. Count the total number of orders in the orders table. 

Q14. Find the total revenue (SUM of total_amount) from all 'Delivered' orders. 

Q15. Calculate the average unit_price of products in each category. 

Q16. For each order status, find the count of orders and the total revenue. Sort the result by total revenue in descending order. 

Q17. Find the most expensive (MAX) and cheapest (MIN) product in each category. 

Q18. List all product categories where the average unit_price is greater than ₹2000. (Hint: Use HAVING clause) 
*/

-- Ques 13
SELECT 
	COUNT(*) As total_orders
FROM orders;

-- Ques 14
SELECT 
	SUM(total_amount) AS total_delivered_revenue
FROM orders
WHERE status = 'Delivered';


-- Ques 15
SELECT
    category,
    AVG(unit_price) AS avg_price
FROM products
GROUP BY category;


-- Ques 16

SELECT 
	status,
	COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;
    
-- Ques 17
SELECT
	category,
	MAX(unit_price) AS Maximum_Price,
    MIN(unit_price) As Minimum_Price
FROM products
GROUP BY category;

-- Ques 18
SELECT
	category,
    AVG(unit_price) as Avg_price
FROM products
GROUP BY category
HAVING Avg_price > 2000;

/*Section D — Joins & Relationships 

These questions test your ability to combine data from multiple tables using different types of JOINs. 

Q19. Write an INNER JOIN query to display each order along with the customer's first_name and last_name. Show: order_id, order_date, first_name, last_name, total_amount. 

Q20. Using a LEFT JOIN, list ALL customers and their orders (if any). Customers with no orders should still appear with NULL values for order columns. 

Q21. Write a query using JOINs across three tables (orders → order_items → products) to show: order_id, product_name, quantity, unit_price, and discount_pct for each order item. 

Q22. Explain the difference between LEFT JOIN and RIGHT JOIN with an example from this schema. When would you use a FULL OUTER JOIN? 

Q23. Identify all Foreign Key relationships in the schema. Explain what would happen if you tried to insert an order with customer_id = 999 (which doesn't exist in customers).
 */
 
 -- Ques 19
SELECT 
	c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id;

-- Ques 20
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers AS c
LEFT JOIN orders AS o 
ON c.customer_id = o.customer_id;

-- Ques 21
SELECT
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct
FROM orders AS o
INNER JOIN order_items AS oi
	ON o.order_id = oi.order_id
INNER JOIN products AS p
	ON oi.product_id = p.product_id;

-- Ques 22
/* LEFT JOIN returns all rows from the LEFT table plus matching rows from the right
   (unmatched right side = NULL). RIGHT JOIN does the reverse: all rows from the RIGHT
   table plus matches from the left.
     LEFT:  customers LEFT JOIN orders  -> every customer, even those with no orders.
     RIGHT: customers RIGHT JOIN orders -> every order, even if its customer were missing.
   A FULL OUTER JOIN returns all rows from BOTH tables, matched where possible and NULL
   where not. You would use it to find unmatched rows on either side at once (e.g.
   customers with no orders AND orders with no customer). MySQL has no FULL OUTER JOIN
   keyword; it is emulated with a LEFT JOIN UNION a RIGHT JOIN. */
   
   
-- Ques 23
/* Foreign Key relationships:
     orders.customer_id     -> customers.customer_id
     order_items.order_id   -> orders.order_id
     order_items.product_id -> products.product_id

   Inserting an order with customer_id = 999 fails: 999 does not exist in customers,
   so it violates the foreign key constraint. MySQL rejects it with a "Cannot add or
   update a child row: a foreign key constraint fails" error. This enforces referential
   integrity — every order must point to a real customer. */



/*Section E — Advanced Concepts (CASE, ACID, Transactions) 

These questions test your understanding of conditional logic, database reliability principles, and transaction management. 

Q24. Write a query using CASE to classify products into price tiers: 
  • 'Budget'    → unit_price < 1000 
  • 'Mid-Range' → unit_price BETWEEN 1000 AND 3000 
  • 'Premium'   → unit_price > 3000 
Display: product_name, unit_price, price_tier. 

Q25. Using a CASE statement inside an aggregate function, count how many orders are 'Delivered' vs 'Not Delivered' (all other statuses). Display the result in a single row. 

Q26. Explain each letter of ACID: 
  • A – Atomicity 
  • C – Consistency 
  • I – Isolation 
  • D – Durability 
Give a real-world example (e.g., bank transfer) showing why each property is important. 

Q27. Write a SQL transaction that does the following atomically: 
  1. Insert a new order (order_id=1011, customer_id=102, today's date, 'Pending', 1598.00) 
  2. Insert two order items for that order 
  3. Update the stock_qty of the purchased products 
  4. If any step fails, ROLLBACK the entire transaction. Otherwise, COMMIT. 
Write the complete BEGIN...COMMIT/ROLLBACK block. */

-- Ques 24
SELECT
    product_name,
    unit_price,
    CASE
        WHEN unit_price < 1000 THEN 'Budget'
        WHEN unit_price BETWEEN 1000 AND 3000 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_tier
FROM products;

-- Ques 25
SELECT
    SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN status <> 'Delivered' THEN 1 ELSE 0 END) AS not_delivered_orders
FROM orders;

-- Ques 26
/* ACID — using a bank transfer (e.g. transferring 1000 from account A to account B):
   A - Atomicity:   All steps succeed or none do. The debit from A and the credit to B
                    happen together; if the credit fails, the debit is rolled back, so
                    money never disappears.
   C - Consistency: A transaction moves the database from one valid state to another,
                    honoring all constraints. The total money across both accounts is
                    the same before and after the transfer.
   I - Isolation:   Concurrent transactions do not interfere. If two transfers run at
                    once, each sees a consistent view and does not observe another
                    transaction's half-finished work.
   D - Durability:  Once committed, the result survives crashes or power loss. After the
                    transfer commits, the new balances persist even if the server
                    restarts immediately afterward. */
                    

-- Ques 27
START TRANSACTION;

-- 1. Insert the new order
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
VALUES (1011, 102, CURDATE(), 'Pending', 2098.00);

-- 2. Insert two order items for that order (item_id is required — it is the PK)
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount_pct)
VALUES
    (5016, 1011, 201, 1, 1499.00, 0),
    (5017, 1011, 208, 1,  599.00, 0);

-- 3. Update the stock_qty of the purchased products
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 201;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 208;

-- 4. Commit if every step succeeded.
COMMIT;
-- If any statement above raised an error, run  ROLLBACK;  instead of COMMIT.

