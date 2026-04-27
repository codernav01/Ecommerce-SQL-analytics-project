Create database ECommerce_Project;
Create table customers(
customer_id INT PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
signup_date DATE);

INSERT INTO customers VALUES
(1, 'Amit Roy', 'amit@example.com', 'Delhi', 'Delhi', '2022-03-10'),
(2, 'Sonal Jain', 'sonal@example.com', 'Mumbai', 'Maharashtra', '2023-01-22'),
(3, 'Rakesh Singh', 'rakesh@example.com', 'Lucknow', 'UP', '2021-11-05');

select * from customers;

create table Products(
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(100),
price DECIMAL,
stock_quantity INT);

INSERT INTO products VALUES
(101, 'Wireless Mouse', 'Electronics', 599, 100),
(102, 'Bluetooth Speaker', 'Electronics', 1299, 50),
(103, 'Cotton Shirt', 'Fashion', 899, 200),
(104, 'Cooking Oil 1L', 'Grocery', 175, 300);

select * from products;

create table orders(
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
status VARCHAR(100));

INSERT INTO orders VALUES
(1001, 1, '2024-06-01', 'Delivered'),
(1002, 2, '2024-06-05', 'Delivered'),
(1003, 1, '2024-06-10', 'Returned'),
(1004, 3, '2024-06-11', 'Cancelled');

select * from orders;

create table order_items(
item_id INT PRIMARY KEY,
order_id INT ,
product_id INT,
quantity INT,
price_each DECIMAL,
Foreign key (order_id) References orders(order_id),
Foreign key (Product_id) References products(product_id));

INSERT INTO order_items VALUES
(1, 1001, 101, 2, 599),
(2, 1002, 103, 1, 899),
(3, 1003, 102, 1, 1299),
(4, 1004, 104, 5, 175);

select * from order_items;

Create table Payments(
payment_id INT PRIMARY KEY,
order_id INT,
payment_method VARCHAR(100), -- 'Credit Card', 'Net Banking', 'UPI', etc.
payment_date DATE,
payment_amount DECIMAL,
Foreign key (order_id) references orders(order_id));

INSERT INTO payments VALUES
(501, 1001, 'Credit Card', '2024-06-01', 1198),
(502, 1002, 'UPI', '2024-06-05', 899),
(503, 1003, 'Net Banking', '2024-06-10', 1299);

select * from payments;

create table reviews(
review_id INT PRIMARY KEY,
order_id int References orders(order_id),
rating int Check(rating between 1 AND 5),
review_text TEXT,
review_date DATE );

INSERT INTO reviews VALUES
(901, 1001, 5, 'Great product', '2024-06-03'),
(902, 1002, 4, 'Good fit and quality', '2024-06-06'),
(903, 1003, 2, 'Stopped working in 2 days', '2024-06-12');

select * from reviews;

select * from customers;

#1) Count the number of customers per state

select state,count(customer_id) as customers from customers
group by state;

#show total orders in june 2024

select * from orders;
select count(order_date) as total_orders from orders
where year(order_date)=2024 and month(order_date)=06;

#find the most sold product by quantity

select * from products;
select product_name,stock_quantity from products
order by stock_quantity desc
limit 1;

#list all customers who signed up before 2023

select name,signup_date from customers
where year(signup_date)<2023;

#Find products with price above average price

select product_name,price from products
where price>(select avg(price) from products);

#Find buyer details per order

select customers.customer_id,orders.order_id,customers.name,customers.city,customers.state,customers.signup_date,order_date,orders.status
from customers inner join orders
on customers.customer_id=orders.customer_id;

#Find product names per order

select order_items.item_id,order_items.order_id,products.product_id,products.product_name
from order_items inner join products
on order_items.product_id=products.product_id;

#analyze feedback by region 

select customers.customer_id,customers.name,orders.order_id,orders.order_date,orders.status,reviews.review_id,reviews.rating,reviews.review_text,reviews.review_date
from reviews inner join orders 
on orders.order_id=reviews.order_id
inner join customers
on orders.customer_id = customers.customer_id;


#find all products bought by a specific customer 

select customers.customer_id,customers.name,products.product_id,products.product_name
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join order_items
on orders.order_id=order_items.order_id
inner join products
on order_items.product_id=products.product_id
where customers.customer_id=1;

#list orders which were returned but still have payment records

select orders.customer_id,orders.order_id,orders.order_date,orders.status,payments.payment_id,payments.payment_method,payments.payment_date,
payments.payment_amount
from orders inner join payments
on orders.order_id=payments.order_id
where orders.status="Returned";

#Calulate total revenue per product category

select * from products;
select category,sum(price) as total_revenue from products
group by category
order by total_revenue desc;

#find average rating per product

select order_items.order_id,products.product_id,products.product_name,avg(reviews.rating)
from products left join order_items
on products.product_id=order_items.product_id
left join reviews
on order_items.order_id=reviews.order_id
group by order_items.order_id,products.product_id,products.product_name;

#count the number of review per rating level

select rating,count(review_id) as num_review from reviews
group by rating
order by rating desc;

#find monthly order count trends

select month(order_date) as monthly,year(order_date)as yearly,count(order_id) as order_count from orders
group by month(order_date),year(order_date);

#Total Value of orders placed by each customers

select customers.customer_id,customers.name,orders.order_id,sum(order_items.quantity*order_items.price_each) as total_value
from customers left join orders
on customers.customer_id=orders.customer_id
left join order_items
on orders.order_id=order_items.order_id
group by customers.customer_id,customers.name,orders.order_id
order by total_value desc;

#Rank customers by total sales value

with join_db as (select customers.customer_id,customers.name, orders.order_id,sum(order_items.quantity*order_items.price_each) as total_sales
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join order_items
on orders.order_id=order_items.order_id
group by customers.customer_id,customers.name,orders.order_id)
select customer_id,order_id,name,total_sales,
dense_rank() over( order by total_sales desc) as rank_customer
from join_db;

#compare customer spending across consecutive orders???

with joining as(
select customers.customer_id,customers.name,orders.order_date,orders.status,sum(order_items.quantity*order_items.price_each) as amount
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join order_items
on orders.order_id=order_items.order_id
group by customers.customer_id,customers.name,orders.order_date,orders.status)
select customer_id,name,order_date,status,amount,
lag(amount) over(partition by name order by amount desc )-amount
from joining;

#identify high-value customers (total spend>2000)

with high_value as (select customers.customer_id,customers.name,count( Distinct orders.order_id) as order_id,
sum(order_items.quantity*order_items.price_each) as total_spend
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join order_items
on orders.order_id=order_items.order_id
group by customers.customer_id,customers.name)
select * from high_value
where total_spend>2000
order by total_spend desc;

#calculate category-wise sales performance

with category_sales_perform as (select order_items.order_id,products.product_id,products.category,
sum(order_items.quantity*order_items.price_each) as sales,orders.status
from orders inner join order_items
on orders.order_id=order_items.order_id
inner join products
on order_items.product_id=products.product_id
where orders.status="Delivered"
group by order_items.order_id,products.product_id,products.category,orders.status)
select * from category_sales_perform
order by sales desc;

#extract all orders with lower ratings(<3)
with lower_rating as (select customers.customer_id,customers.name,orders.order_id,orders.order_date,reviews.rating,reviews.review_text,
reviews.review_date
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join reviews
on orders.order_id=reviews.order_id
where reviews.rating<3)

select * from lower_rating;

#get all orders by a customer ID.

Delimiter //
create procedure customerid_d(in x int)
Begin
select customers.customer_id,customers.name,orders.order_id,orders.order_date,products.product_id,products.product_name,products.category,
order_items.quantity,order_items.price_each
from customers inner join orders
on customers.customer_id=orders.customer_id
inner join order_items
on orders.order_id=order_items.order_id
inner join products
on order_items.product_id=products.product_id
where orders.customer_id=x;
End//
Delimiter ;

call customerid_d(3);

#calculate total revenue between two dates

Delimiter //
create procedure totalrevenu(in start_date date,in end_date date)
Begin
select sum(payment_amount) as total_revenue from payments
where payment_date between start_date and end_date;
END //
DELIMITER ;

call totalrevenu("2024-06-01","2024-06-10");

#show top rated products in a given category

Delimiter //
create procedure top_rated_product(in x varchar(100))
begin
select products.product_id,products.product_name,products.category,reviews.rating
from products inner join order_items
on products.product_id=order_items.product_id
inner join reviews
on order_items.order_id=reviews.order_id
where products.category=x
order by reviews.rating desc
limit 1;
END //
DELIMITER ;

call top_rated_product("Electronics");

#calculate average product per rating

Delimiter //
create function average_rat_per_pro(w int)
Returns decimal(3,2)
Deterministic
Begin
declare avg_rating decimal(3,2);
select avg(reviews.rating) into avg_rating
from reviews inner join order_items
on reviews.order_id=order_items.order_id
inner join products
on order_items.product_id=products.product_id
where products.product_id=w;
return  avg_rating;
end //
Delimiter ;

select average_rat_per_pro(102) as average_rating;

#flag late reviews (posted after 5 days of dilivery).

Delimiter //
create function flag_rate(x int)
returns varchar(10)
Deterministic
Begin
declare delivery_date Date;
declare review_date date;
declare status varchar(10);
declare flag varchar(10);

select orders.order_date,orders.status,reviews.review_date into
delivery_date,status,review_date
from orders inner join reviews
on orders.order_id=reviews.order_id
where orders.order_id=x;

if status='Delivered' and datediff(review_date,delivery_date)>5 then
set flag="late";
else
set flag="on-Time";
end if;
return flag;
END //
DELIMITER ;

select flag_rate(1004) as flag;

#assign order status scores ("Delivered"=5,"Returned"=2,"Cancelled"=0)

DELIMITER //
Create function status_scores(status varchar(100))
returns int
Deterministic
Begin
Declare score int;
if status="Delivered" then
    set score=5;
elseif status="Returned" then
    set score=2;
Else
    set score=0;
End if;
return score;
END //
DELIMITER ;

select order_id, status, status_scores(status) as score from orders;