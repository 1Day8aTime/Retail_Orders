
-- Create database

CREATE DATABASE retail_orders;

-- Create table orders

CREATE TABLE orders(
	order_id int primary key,
    order_date date,
    ship_mode varchar(20),
    segment varchar(20) ,
    country varchar(20),
    city varchar(20),
    state varchar(20),
    postal_code varchar(20),
    region varchar(20),
    category varchar(20),
    sub_category varchar(20),
    product_id varchar(50),
    quantity int,
    discount decimal(10,2),
    sale_price decimal(10,2),
    profit decimal(10,2),
    final_sale decimal(10,2)
);

select * from orders;

-- Load dataset from csv to orders table in the retail_orders database

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order.csv' INTO TABLE orders
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- ANALYSIS

-- 1.  FIND TOP 10 HIGHEST REVENUE GENERATING PRODUCTS
select 
	product_id, 
    sum(final_sale) as sales
from orders
group by product_id
order by sum(final_sale) desc
limit 10
;


-- 2. FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION
with cte as (
	select 
		region, 
        product_id, 
        sum(final_sale) as sales,
		row_number() over(partition by region order by sum(final_sale) desc) as rn
	from orders
	group by region, product_id
)
select *
from cte
where rn <= 5
;

-- 3. FIND MONTH OVER MONTH GROWTH COMPARISON FOR 2022 AND 2023 SALES 
-- (eg, JAN 2022 VS JAN 2023)
with cte as(
	select 
		left(order_date,4) as year, 
        substring(order_date,6,2) as month, 
        sum(sale_price) as sales
	from orders
	group by left(order_date,4), substring(order_date,6,2) 
)
select *
from cte c1, cte c2
where c1.month = c2.month and c1.year != c2.year and c1.year > c2.year;

-- 4. DETERMINE THE MONTH WITH HIGHEST SALES IN EACH CATEGORY
with cte as(
select 
	category, 
    substring(order_date,1,4) as year,
    substring(order_date,6,2) as month,
    sum(sale_price) as sales,
	row_number() over(partition by category order by sum(sale_price) desc) as rn
from orders
group by category, substring(order_date,1,4) , substring(order_date,6,2)
)
select *
from cte
where rn = 1
;

-- 5. which sub-category had the highest growth by profit in 2023 compared to 2022
with cte as(
	select 
		sub_category, 
        left(order_date,4) as year, 
        sum(profit) as sales
	from orders
	group by sub_category, left(order_date,4)
)
select *, 
	(c1.sales - c2.sales)*100/c1.sales as growth_percent
from cte c1, cte c2
where c1.sub_category = c2.sub_category and c1.year > c2.year
order by growth_percent desc
limit 1
;

