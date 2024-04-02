-- 1.  How many orders are there in the dataset? The orders table contains a row for each order, so this should be easy to find out!

USE magist;

Select count(distinct(order_id))
from orders;

-- 2. Are orders actually delivered? Look at the columns in the orders table: one of them is called order_status. Most orders seem to be delivered, but some aren’t. 
-- Find out how many orders are delivered and how many are cancelled, unavailable, or in any other status by grouping and aggregating this column.
USE magist;
Select order_status, count(order_id)
from orders
group by order_status
order by count(order_id) desc;

-- 3. Is Magist having user growth? A platform losing users left and right isn’t going to be very useful to us. It would be a good idea to check for the number of orders grouped by year and month. 
-- Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.
USE magist;

-- Select order_purchase_timestamp as opt, count(order_id), year(order_purchase_timestamp) as y, month(order_purchase_timestamp) as m
Select count(order_id), year(order_purchase_timestamp) as y, month(order_purchase_timestamp) as m
from orders
group by y, m
order by y;

-- 4. How many products are there on the products table? (Make sure that there are no duplicate products.)
select*
from products;
select count(distinct(product_id))
from products;
-- 5. Which are the categories with the most products? Since this is an external database and has been partially anonymized, we do not have the names of the products. But we do know which categories products belong to. #
-- This is the closest we can get to knowing what sellers are offering in the Magist marketplace. By counting the rows in the products table and grouping them by categories, we will know how many products are offered in each category. 
-- This is not the same as how many products are actually sold by category. To acquire this insight we will have to combine multiple tables together: we’ll do this in the next lesson.
select count(distinct(product_id)) as products, product_category_name as category
from products
group by product_category_name
order by products desc;

-- 6. How many of those products were present in actual transactions? The products table is a “reference” of all the available products. Have all these products been involved in orders? Check out the order_items table to find out!
select count(distinct(product_id))
from order_items; -- Yes all were present comparing to 4.
-- 7. What’s the price for the most expensive and cheapest products? Sometimes, having a broad range of prices is informative. Looking for the maximum and minimum values is also a good way to detect extreme outliers.
Select max((price)/order_item_id), min((price)/order_item_id)
from order_items;
Select*
from order_items;
Select product_id, price
From products
Right join order_items
Using(product_id)
order by price desc
limit 1;

-- 8. What are the highest and lowest payment values? Some orders contain multiple products. What’s the highest someone has paid for an order? Look at the order_payments table and try to find it out.
Select max(payment_value) as max_val, min(payment_value) as min_val, order_id, sum(payment_value) as sum
from order_payments
group by order_id
order by sum desc;
Select max(payment_value) as max_val, min(payment_value) as min_val
from order_payments;