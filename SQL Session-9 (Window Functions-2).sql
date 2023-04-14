--SQL SESSION-9, 25.01.2023, (Window Functions-2)

--*** Windowed functions can only appear in the SELECT or ORDER BY clauses.

--3. ANALYTIC NUMBERING FUNCTIONS--

--ROW_NUMBER() - RANK() - DENSE_RANK() - CUME_DIST() - PERCENT_RANK() - NTILE()

--The ORDER BY clause is mandatory because these functions are order sensitive.
--They are not used with window frames.

--////////////////////////

--QUESTION: Assign an ordinal number to the product prices for each category in ascending order.
--(Herbir kategori içinde ürünlerin fiyat sýralamasýný yapýnýz - artan fiyata göre 1'den baþlayýp birer birer artacak)

SELECT
	category_id, list_price,
	ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price) row_num	
FROM
	product.product


--Lets try previous query again using RANK() and DENSE_RANK() functions.

SELECT
	category_id, list_price,
	ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price) row_num,
	RANK() OVER(PARTITION BY category_id ORDER BY list_price) rnk,
	DENSE_RANK() OVER(PARTITION BY category_id ORDER BY list_price) dense_rnk
FROM
	product.product


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


--QUESTION: Write a query that returns both of the followings:
-- * Average product price.
-- * The average product price of orders.

SELECT
	DISTINCT
	order_id,
	AVG(list_price) OVER() avg_price,
	AVG(list_price) OVER(PARTITION BY order_id) avg_price_of_orders

FROM
	sale.order_item


--////////////////////////

--QUESTION: Which orders' average product price is lower than the overall average price?
--(Hange sipariþlerin ortalama ürün fiyatý genel ortalama fiyattan daha düþüktür?)

SELECT
	*
FROM(
	SELECT
		DISTINCT
		order_id,
		AVG(list_price) OVER() avg_price,
		AVG(list_price) OVER(PARTITION BY order_id) avg_price_of_orders

	FROM
		sale.order_item) t
WHERE
	avg_price_of_orders < avg_price
ORDER BY
	avg_price_of_orders DESC;



--////////////////////////

--QUESTION: Calculate the stores' weekly cumulative count of orders for 2018.
--(maðazalarýn 2018 yýlýna ait haftalýk kümülatif sipariþ sayýlarýný hesaplayýnýz)


SELECT	
	DISTINCT
	o.store_id, s.store_name,
	DATEPART(WEEK, o.order_date) week_of_year,
	COUNT(o.order_id) OVER(PARTITION BY o.store_id, DATEPART(WEEK, o.order_date)) total_order,
	COUNT(o.order_id) OVER(PARTITION BY o.store_id ORDER BY DATEPART(WEEK, o.order_date)) cume_total_order  --DEFAULT: range between unbounded preceding and current row
FROM
	sale.orders o
	LEFT JOIN
	sale.store s ON o.store_id=s.store_id
WHERE
	YEAR(order_date) = 2018



--////////////////////////

--QUESTION: Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.
--('2018-03-12' ve '2018-04-12' arasýnda satýlan ürün sayýsýnýn 7 günlük hareketli ortalamasýný hesaplayýn)

WITH cte AS(
	SELECT 
		DISTINCT
		a.order_date,
		SUM(b.quantity) OVER(PARTITION BY a.order_date) sum_quantity
	FROM
		sale.orders a
		LEFT JOIN
		sale.order_item b ON a.order_id=b.order_id
	WHERE
		a.order_date BETWEEN '2018-03-12' AND '2018-04-12'
)
SELECT 
	*,
	AVG(sum_quantity) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) sales_moving_average_7
FROM cte


------- with group by
SELECT 
	a.order_date,
	SUM(b.quantity) sum_quantity,
	AVG(SUM(b.quantity)) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) sales_moving_average_7
FROM
	sale.orders a
	LEFT JOIN
	sale.order_item b ON a.order_id=b.order_id
WHERE
	a.order_date BETWEEN '2018-03-12' AND '2018-04-12'
GROUP BY
	a.order_date



--////////////////////////

--QUESTION: Write a query that returns the highest daily turnover amount for each week on a yearly basis.
--(Yýl bazýnda her haftaya ait en yüksek günlük ciro miktarýný döndüren bir sorgu yazýnýz)

;WITH cte AS(
	SELECT 
		DISTINCT
		DATEPART(YEAR, a.order_date) order_year,
		DATEPART(WEEK, a.order_date) order_week,
		SUM(b.quantity * b.list_price * (1-b.discount)) OVER(PARTITION BY a.order_date) daily_turnover
	FROM
		sale.orders a
		LEFT JOIN
		sale.order_item b ON a.order_id=b.order_id
)
SELECT
	DISTINCT
	order_year,order_week,
	MAX(daily_turnover) OVER(PARTITION BY order_year, order_week) highest_turnover
FROM
	cte 


-----with group by
SELECT 
	DISTINCT
	YEAR(a.order_date) order_year,
	DATEPART(ISOWW, a.order_date) order_week,
	FIRST_VALUE(SUM(b.quantity * b.list_price * (1-b.discount))) OVER(
			PARTITION BY YEAR(a.order_date), DATEPART(ISOWW, a.order_date)
			ORDER BY SUM(b.quantity * b.list_price * (1-b.discount)) DESC) highest_turnover
FROM
	sale.orders a
	LEFT JOIN
	sale.order_item b ON a.order_id=b.order_id
GROUP BY
	a.order_date



--////////////////////////

--QUESTION: List customers whose have at least 2 consecutive orders are not shipped.
--(Peþpeþe en az 2 sipariþi gönderilmeyen müþterileri bulunuz)

;WITH t1 AS(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status
	FROM
		sale.orders
), t2 AS(
	SELECT
		*,
		LEAD(delivery_status) OVER(PARTITION BY customer_id ORDER BY order_id) next_delivery_status
	FROM
		t1
)
SELECT
	customer_id
FROM
	t2
WHERE
	delivery_status='not delivered' AND next_delivery_status='not delivered'


----2nd solution

SELECT customer_id
FROM(
	SELECT
		order_id, customer_id, order_date, shipped_date,
		CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END delivery_status,
		LEAD(CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END) OVER(
			PARTITION BY customer_id ORDER BY order_date) next_delivery_status
	FROM
		sale.orders
) t
WHERE 
	delivery_status='not delivered' AND next_delivery_status='not delivered'



--////////////////////////

--QUESTION: Write a query that returns how many days are between the third and fourth order dates of each staff.
--(Her bir personelin üçüncü ve dördüncü sipariþleri arasýndaki gün farkýný bulunuz)












--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--////////////////////////

--CUME_DIST()

--creates a column that contain cumulative distribution of the sorted column values.
--cume_dist = row number / total rows

--////////////////////////

--QUESTION: Write a query that returns the cumulative distribution of the list price in product table by brand.
--(product tablosundaki list price' larýn kümülatif daðýlýmýný marka kýrýlýmýnda hesaplayýnýz)

SELECT
	brand_id, list_price,
	ROUND(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) cume_distr
FROM
	product.product



--////////////////////////

-- PERCENT_RANK()

--creates a column that contain relative standing of a value in the sorted column values.
--percent_rank = (row number-1) / (total rows-1)

--////////////////////////

--QUESTION: Write a query that returns the relative standing of the list price in the product table by brand.

SELECT
	brand_id, list_price,
	FORMAT(ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3), 'P') percent_rnk
FROM
	product.product



--////////////////////////

--NTILE()

--divides the sorted column into equal groups according to the given parameter (N) value and returns which group the each values are in.

--////////////////////////

--QUESTION: Divide customers into 5 groups based on the quantity of product they order.

;with t1 as
(
SELECT A.customer_id, SUM(quantity) product_quantity
FROM sale.orders A, sale.order_item B
where A.order_id= B.order_id
GROUP BY A.customer_id
)
select customer_id, product_quantity,
       ntile(5) over(order by product_quantity) group_dist
from t1
order by 2,3 DESC;