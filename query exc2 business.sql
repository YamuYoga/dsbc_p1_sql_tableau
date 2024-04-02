/* 
3. Answer business questions

Whenever you feel ready for it, go through the questions below. Note that in many cases, you will have to translate business terms into tables, columns and aggregations. Whenever needed, make your own educated guesses or assumptions (e.g. what can be considered a “tech” or an “expensive” product).
3.1. In relation to the products:

    What categories of tech products does Magist have?
    How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
    What’s the average price of the products being sold?
    Are expensive tech products popular? *

* TIP: Look at the function CASE WHEN to accomplish this task.
3.2. In relation to the sellers:

    How many months of data are included in the magist database?
    How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
    What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
    Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

3.3. In relation to the delivery time:

    What’s the average time between the order being placed and the product being delivered?
    How many orders are delivered on time vs orders delivered with a delay?
    Is there any pattern for delayed orders, e.g. big products being delayed more often?

*/
use magist;
select*
from product_category_name_translation;
-- 3.1 computers computers_accessories electronics small_appliances pc_gamer home_appliances home_appliances_2 air_conditioning

select product_category_name_english as pcn, count(distinct(order_id)),avg(price), count(product_id)-- , FORMAT(count(product_id)*avg(price),0)
from products as p
 
inner join `product_category_name_translation`
using(product_category_name)
inner join order_items
using(product_id)
inner join order_payments
using(order_id)
where product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning")
Group by product_category_name_english;

  -- How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?

select count(distinct(order_id)),avg(price), count(p.product_id),
	CASE WHEN product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning") THEN "Tech"
    ELSE "others"
    END AS category 
from products as p 
inner join `product_category_name_translation`
using(product_category_name)
inner join order_items
using(product_id)
inner join order_payments
using(order_id)
Group by category;

select count(product_id), ROUND(count(product_id)/(Select count(product_id) from order_items),2) as share ,
	CASE WHEN product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning") THEN "Tech"
    ELSE "others"
    END AS category
-- count(product_id(having category =="Tech"))/(count(product_id(having category =="Tech"))+count(product_id(having category =="others")))
from products as p 
inner join `product_category_name_translation`
using(product_category_name)
inner join order_items
using(product_id)
inner join order_payments
using(order_id)
Group by category;

Select count(*)
from order_items;


select*
from order_items;
select product_category_name_english as pcn, count(distinct(order_id)),
	CASE
		WHEN price > 1000 THEN "high"
		Else "low"
	END as pcat

from products as p
	-- CASE
	-- WHEN price > 1000 THEN "high"
    -- Else "low"
	-- END as pcat
inner join `product_category_name_translation`
using(product_category_name)
inner join order_items
using(product_id)
right join order_payments
using(order_id)
where product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning")
Group by product_category_name_english, pcat;

/*****************************************************************************************************************************************/
-- 3.2
-- How many months of data are included in the magist database?
Select count(distinct(month(order_purchase_timestamp))) as "months with data", (year(order_purchase_timestamp)) as y
from orders
group by y;
SELECT -ROUND(DATEDIFF(min(order_purchase_timestamp),(max(order_purchase_timestamp)))/30.5,0) 
from orders;

--     How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
Select count(distinct(seller_id)) as "unique sellers"
from sellers;

select count(product_id), count(distinct(seller_id)), Format(sum(price),0),
CASE WHEN product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning") THEN "Tech"
    ELSE "others"
    END AS category
from order_items
left join products
using(product_id)
join product_category_name_translation
using(product_category_name)
group by category;

select count(distinct(seller_id))
from order_items;

Select count(distinct(
			CASE WHEN product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning") THEN seller_id END)
			, count(distinct(seller_id)))
from order_items oi
left join products p using(product_id)
join product_category_name_translation
using(product_category_name);

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

select count(product_id), count(distinct(seller_id)), Format(sum(price),0), Format(sum(price)/count(distinct(seller_id)),2) as "avg inc p/seller", year(order_purchase_timestamp) as ye, month(order_purchase_timestamp) as mo,
CASE WHEN product_category_name_english in ("computers", "computers_accessories", "electronics", "small_appliances", "pc_gamer", "home_appliances", "home_appliances_2", "air_conditioning") THEN "Tech"
    ELSE "others"
    END AS category
from order_items
left join products
using(product_id)
join product_category_name_translation
using(product_category_name)
join orders
using(order_id)
group by  ye, mo , category;

/***********************************************************************************************************************************************************/

-- What’s the average time between the order being placed and the product being delivered?
SELECT avg(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) as "avg days to delivery"
FROM orders;
SELECT*
from orders;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- Heavier packages are slighty more often delayed than lighter ones
-- bulky packages are also more delayed than smaller ones

Select count(distinct(order_id)),
			CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 1 THEN "on time"
            ELSE "delayed"
            END AS punctuality,
            CASE WHEN product_weight_g > 20000 THEN "heavy"
            ELSE "light"
            END AS weight
FROM orders
JOIN order_items
USING(order_id)
JOIN products
USING(product_id)
Group by weight, punctuality;

Select count(distinct(order_id)),
			CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 1 THEN "on time"
            ELSE "delayed"
            END AS punctuality,
            CASE WHEN product_length_cm > 60 OR product_height_cm > 60 OR product_width_cm > 60 THEN "bulky"
            ELSE "manageable"
            END AS wieldiness
FROM orders
JOIN order_items
USING(order_id)
JOIN products
USING(product_id)
Group by  wieldiness, punctuality;

