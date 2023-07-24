


---Lab-3 


-- Davi techno ma�azas�ndaki �r�nlerin stok bilgilerini d�nd�ren bir sorgu yaz�n. 
-- Bu �r�nlerin The BFLO Store ma�azas�nda sto�u bulunmuyor.


SELECT *
FROM	product.stock



SELECT COUNT (DISTINCT product_id)
FROM	product.product


SELECT	store_id, COUNT (DISTINCT product_id)
FROM	product.stock
GROUP BY store_id



SELECT *
FROM	product.stock
WHERE	product_id = 6
AND		store_id = 1



----





SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0

EXCEPT

SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'The BFLO Store'
AND		a.quantity>0


------



SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		NOT EXISTS (
						SELECT	1
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity>0
						AND		A.product_id = X.product_id
						)


------------




SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		A.product_id NOT IN (
						SELECT	product_id
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity>0
						)

------


SELECT	product_id
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		A.product_id IN (
						SELECT	product_id
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity = 0
						)

----------------------


WITH CTE as
(
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'Davi techno Retail'
), CTE2 AS (
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'The BFLO Store'
)
SELECT *
FROM CTE cte
WHERE product_id NOT IN (SELECT product_id FROM CTE2 WHERE quantity > 0)



---------------------

-- QUESTION: Write a query that returns the net amount of their first order for customers who placed their first order after 2019-10-01.
-- (�lk sipari�ini 2019-10-01 tarihinden sonra veren m��terilerin ilk sipari�lerinin net tutar�n� d�nd�r�n�z)


WITH T1 AS (
	SELECT	customer_id, MIN (order_id) min_orders
	FROM	sale.orders
	GROUP BY
			customer_id
)
SELECT	A.customer_id, A.order_id, SUM(quantity* list_price* (1-discount)) net_amount
FROM	sale.orders A 
		INNER JOIN
		sale.order_item B
		ON	A.order_id = B.order_id
		INNER JOIN
		T1 ON A.order_id = T1.min_orders
WHERE
		A.order_date > '2019-10-01'
GROUP BY
		A.customer_id, A.order_id



-------------------------------

-- QUESTION: Write a query that returns the count of the orders day by day in a pivot table format that has been shipped two days later.
-- 2 g�nden ge� kargolanan sipari�lerin haftan�n g�nlerine g�re da��l�m�n� hesaplay�n�z.


SELECT	order_id, DATENAME(WEEKDAY, order_date) weekofday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2




SELECT	 SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Monday' THEN 1 ELSE 0 END) Monday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Tuesday' THEN 1 ELSE 0 END) Tuesday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Wednesday' THEN 1 ELSE 0 END) Wednesday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Thursday' THEN 1 ELSE 0 END) Thursday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Friday' THEN 1 ELSE 0 END) Friday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Saturday' THEN 1 ELSE 0 END) Saturday
		,SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Sunday' THEN 1 ELSE 0 END) Sunday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2












