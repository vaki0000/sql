--SQL SESSION-8, 23.01.2023, (Window Functions-1)

--Window Functions (WF) vs. GROUP BY
--Let's review the following two queries for differences between GROUP BY and WF.
---------------------------------------------------------------------

--QUESTION: Write a query that returns the total stock amount of each product in the stock table.
--(ürünlerin stock sayýlarýný bulunuz)

-----with Group By

SELECT product_id, SUM(quantity) total_stock
FROM product.stock
GROUP BY product_id
ORDER BY product_id


-----with WF

SELECT *, SUM(quantity) OVER(PARTITION BY product_id) total_stock
FROM product.stock

SELECT DISTINCT product_id, SUM(quantity) OVER(PARTITION BY product_id) total_stock
FROM product.stock

SELECT *, SUM(quantity) OVER() total_stock
FROM product.stock


--///////////////////////////////
--QUESTION: Write a query that returns average product prices of brands. 
--(markalara göre ort. ürün fiyatlarýný hem Group By hem de Window Functions ile hesaplayýnýz)

SELECT brand_id, AVG(list_price) avg_price
FROM product.product
GROUP BY brand_id

---with WF

SELECT *, AVG(list_price) OVER(PARTITION BY brand_id) avg_price
FROM product.product


SELECT DISTINCT brand_id, AVG(list_price) OVER(PARTITION BY brand_id) avg_price
FROM product.product


-------------------------------------------------------------------------
--1. ANALYTIC AGGREGATE FUNCTIONS
--MIN() - MAX() - AVG() - SUM() - COUNT()
-------------------------------------------------------------------------

--QUESTION: What is the cheapest product price for each category?
--(Her bir kategorideki en ucuz ürünün fiyatý)

select *, min(list_price) over(partition by category_id) as min_price
from product.product


select distinct category_id, min(list_price) over(partition by category_id) as min_price
from product.product



--///////////////////////////////
--QUESTION:	How many different product in the product table?
--(product tablosunda toplam kaç farklý ürün bulunmaktadýr)

select distinct count(product_id) over() cnt_products
from product.product


--///////////////////////////////
--QUESTION: How many different product in the order_item table?
--(order_item tablosunda kaç farklý ürün bulunmaktadýr)


-----following queries don't return the correct result.

select count(product_id) over()
from sale.order_item


select count(product_id) over(partition by product_id) num_of_products
from sale.order_item


select distinct count(product_id) over(partition by product_id) num_of_products
from sale.order_item


select distinct product_id, 
	count(product_id) over(partition by product_id) num_of_products
from sale.order_item

-----true result

select count(distinct product_id)
from sale.order_item

-----or
select distinct count(product_id) over() num_of_products
from(
	select distinct product_id
	from sale.order_item
) t


--///////////////////////////////
--QUESTION: Write a query that returns how many products are in each order?
--(her sipariþte kaç ürün olduðunu döndüren bir sorgu yazýn)

select * from sale.order_item


select distinct order_id, 
	sum(quantity) over(partition by order_id) total_quantity
from sale.order_item


--///////////////////////////////
--QUESTION: Write a query that returns the number of products in each category of brands.
--(her bir markanýn farklý kategorilerdeki ürün sayýlarý)

select category_id, brand_id,
	count(product_id) over(partition by category_id, brand_id) num_of_products
from product.product


select distinct category_id, brand_id,
	count(product_id) over(partition by category_id, brand_id) num_of_products
from product.product


-------------------------------------------------------------------------
--WINDOW FRAMES
-------------------------------------------------------------------------

select brand_id, model_year,
	count(product_id) over(),
	count(product_id) over(partition by brand_id),
	count(product_id) over(partition by brand_id order by model_year)
from product.product

-----with window frames

select brand_id, model_year,
	count(product_id) over(partition by brand_id order by model_year),
	count(product_id) over(partition by brand_id order by model_year range between unbounded preceding and current row) [range], --default
	count(product_id) over(partition by brand_id order by model_year rows between unbounded preceding and current row) [row],
	count(product_id) over(partition by brand_id order by model_year rows between 1 preceding and current row) [row_1_preceding],
	count(product_id) over(partition by brand_id order by model_year rows between unbounded preceding and unbounded following) [row_un],
	count(product_id) over(partition by brand_id order by model_year range between unbounded preceding and unbounded following) [range_un]
from product.product

-------

select brand_id, model_year,
	count(product_id) over(partition by brand_id order by model_year rows between current row and unbounded following) [row_un],
	count(product_id) over(partition by brand_id order by model_year range between current row and unbounded following) [range_un]
from product.product



-------------------------------------------------------------------------
--2. ANALYTIC NAVIGATION FUNCTIONS
-------------------------------------------------------------------------

--It's mandatory to use ORDER BY.

--******FIRST_VALUE()*****--
--/////////////////////////////////


select *, first_value(first_name) over(order by first_name) 
from sale.staff

select *, first_value(first_name) over(order by last_name) 
from sale.staff


--QUESTION: Write a query that returns first order date by month.
--(Her ay için ilk sipariþ tarihini bulunuz)


select * from sale.orders

select distinct YEAR(order_date) years, MONTH(order_date) months,
	first_value(order_date) over(partition by YEAR(order_date), MONTH(order_date) order by order_date)
from sale.orders



--QUESTION: Write a query that returns customers and their most valuable order with total amount of it.


with cte as
(
		select a.customer_id, b.order_id,
			SUM(quantity * list_price * (1-discount)) net_price
		from sale.orders a
			inner join sale.order_item b
			on a.order_id=b.order_id
		group by a.customer_id, b.order_id
		order by a.customer_id, b.order_id
)
select distinct customer_id,
	first_value(order_id) over(partition by customer_id order by net_price desc),
	first_value(net_price) over(partition by customer_id order by net_price desc)
from cte



--/////////////////////////////////
--******LAST_VALUE()*****--


--QUESTION: Write a query that returns last order date by month.
--(Her ay için son sipariþ tarihini bulunuz)

select distinct YEAR(order_date) years, MONTH(order_date) months,
	last_value(order_date) over(partition by YEAR(order_date), MONTH(order_date) order by order_date rows between unbounded preceding and unbounded following) last_date
from sale.orders



--/////////////////////////////////
--******LAG() & LEAD()*****--


--LAG() SYNTAX

/*LAG(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/


--QUESTION: Write a query that returns the order date of the one previous sale of each staff (use the LAG function)
--(Her bir personelin bir önceki satýþýnýn sipariþ tarihini yazdýrýnýz)

select a.order_id, b.staff_id, b.first_name, b.last_name, a.order_date,
	lag(a.order_date) over(partition by b.staff_id order by a.order_id)
from sale.orders a, sale.staff b
where a.staff_id=b.staff_id


----------------------------------

--LEAD() SYNTAX

/*LEAD(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/

--QUESTION: Write a query that returns the order date of the one next sale of each staff (use the LEAD function)
--(Her bir personelin bir sonraki satýþýnýn sipariþ tarihini yazdýrýnýz)

select a.order_id, b.staff_id, b.first_name, b.last_name, a.order_date,
	lead(a.order_date, 1) over(partition by b.staff_id order by a.order_id)
from sale.orders a, sale.staff b
where a.staff_id=b.staff_id


select a.order_id, b.staff_id, b.first_name, b.last_name, a.order_date,
	lead(a.order_date, 3) over(partition by b.staff_id order by a.order_id)
from sale.orders a, sale.staff b
where a.staff_id=b.staff_id


----------------------------------------------------------------------

--QUESTION: Write a query that returns the difference order count between the current month and the previous month for each year. 
--(Her bir yýl için peþ peþe gelen aylarýn sipariþ sayýlarý arasýndaki farklarý bulunuz)

with t1 as(
	select distinct year(order_date) years, month(order_date) months,
		count(order_id) over(partition by year(order_date), month(order_date)) total_orders
	from sale.orders
)
select years, months, total_orders,
	lag(total_orders) over(partition by years order by years, months) previous_month,
	total_orders - lag(total_orders) over(partition by years order by years, months) 'difference'
from t1




