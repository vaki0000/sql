--SQL SESSION-12, 30.01.2023, (SQL Programming)


--/////////////////////////////////////////

--VARIABLES
--*******************************************

-----assigning a value to a variable

DECLARE @number AS INT

SET @number=10

--SELECT @number

PRINT @number


-----multiple variables

DECLARE @num1 INT, @num2 INT, @SUM INT

SET @num1 = 10

SELECT @num2 = 20

SELECT @SUM=@num1 + @num2

SELECT @SUM
GO

-------------

DECLARE @num1 INT, @num2 INT, @SUM INT

SELECT @num1 = 10, @num2 = 20, @SUM=@num1 + @num2

PRINT @SUM


-----referring to a variable in a query

DECLARE @cust_id INT=5

SELECT
	*
FROM
	sale.customer
WHERE
	customer_id=@cust_id


-----GLOBAL VARIABLES

SELECT @@ROWCOUNT

SELECT @@ROWCOUNT FROM product.product

SELECT * FROM product.product
SELECT @@ROWCOUNT

SELECT @@VERSION
SELECT @@SERVERNAME
SELECT @@SERVICENAME
GO

--/////////////////////////////////////////

--STORED PROCEDURE
--*******************************************

--Türkçe'de "saklý yordam" adýyla bilinmekte olup veritabanýnda saklanan SQL ifadeleridir. Kýsaca derlenmiþ SQL cümleciði denebilir.
--Ýstenilen zamanda istediðiniz yerde çaðýrabileceðiniz, parametre alarak bir deðer döndürebilen dinamik kod bloklarýdýr.
--Veritabanlarýnda saklandýðýndan dolayý daha hýzlý çalýþýrlar. 
--SP'ler ilk çalýþtýrýldýðýnda derlenirler ve hafýzaya alýnýrlar, tekrar çalýþtýklarýnda derlenmezler. Veritabanýnda derlenmiþ bir "execution plan" halinde saklanýrlar. Bu nedenle daha iyi performans saðlarlar.
--SQL komutu çaðýrýldýðýnda ayrýþtýrma, derleme ve çalýþtýrma aþamalarýndan geçmektedir. SP’ler daha önceden derlendikleri için, normal kullanýlan bir SQL sorgusundan çok daha performanslý olup ayrýca að trafiðini de yormazlar.
--Parametrelerle kullanýlabiliyor olmasý veri temininde esneklik saðlar.

--------------------------------

--creating a basic procedure

CREATE PROCEDURE spProducts
AS
BEGIN
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	ORDER BY
		list_price
END


--executing stored procedures

EXECUTE spProducts

EXEC spProducts
GO

spProducts
GO

--making changes to a procedure

ALTER PROCEDURE spProducts
AS
BEGIN
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	ORDER BY
		list_price DESC
END


EXEC spProducts
GO


--deleting a procedure

DROP PROCEDURE spProducts
GO

-----------------------------------------------

--stored procedure parameters


CREATE PROC sp_products
	(
		@model_year INT
		,@prod_name VARCHAR(MAX)
	)
AS
BEGIN
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	WHERE
		model_year=@model_year
		AND product_name LIKE '%' + @prod_name + '%'
END


EXECUTE sp_products @model_year=2020, @prod_name='speaker'
GO


---optional parameters

ALTER PROC sp_products
	(
		@model_year INT=NULL
		,@prod_name VARCHAR(MAX)
	)
AS
BEGIN
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	WHERE
		(@model_year IS NULL OR model_year=@model_year)
		AND product_name LIKE '%' + @prod_name + '%'
END


EXECUTE sp_products @prod_name='speaker'
GO


--drop procedure

DROP PROCEDURE sp_products


--/////////////////////////////////////////

--IF STATEMENTS
--*******************************************

DECLARE @number INT

SET @number=10

IF @number > 10
	PRINT 'bigger than 10'
ELSE
	PRINT 'smaller than 10'

-----------

DECLARE @prod_id INT, @total_quantity INT

SET @prod_id=500

SET @total_quantity = (SELECT SUM(quantity) FROM sale.order_item WHERE product_id=@prod_id)

IF @total_quantity >= 50
	BEGIN
		SELECT
			COUNT(DISTINCT c.state) [NumOfStates]
		FROM
			sale.order_item a
			INNER JOIN
			sale.orders b ON a.order_id=b.order_id
			INNER JOIN
			sale.customer c ON b.customer_id=c.customer_id
		WHERE
			a.product_id=@prod_id
	END

ELSE IF @total_quantity < 50
	BEGIN
		SELECT
			STRING_AGG([states], ',') [state]
		FROM(
			SELECT
				DISTINCT c.state [states]
			FROM
				sale.order_item a
				INNER JOIN
				sale.orders b ON a.order_id=b.order_id
				INNER JOIN
				sale.customer c ON b.customer_id=c.customer_id
			WHERE
				a.product_id=@prod_id) subq
	END

ELSE
	PRINT 'This product has not yet been ordered.'


--/////////////////////////////////////////

--WHILE LOOPS
--*******************************************

--In SQL Server there is only one type of loop: a WHILE loop.
--Don't forget to use BEGIN-END statement


DECLARE @num_of_iter INT, @counter INT

SET @num_of_iter=10
SET @counter=0

WHILE @counter <= @num_of_iter
	BEGIN
		PRINT @counter
		SET @counter += 1
	END
GO


--SELECT Statements in a Loop
--(using break to exit a loop)

DECLARE @counter INT, @max_brand_id INT, @total_products INT

SET @counter=1
SET @max_brand_id = (SELECT MAX(brand_id) FROM product.brand)

WHILE @counter <= @max_brand_id
	BEGIN
		SET @total_products = (SELECT COUNT(product_id) FROM product.product WHERE brand_id=@counter)
		
		IF @total_products < 20 BREAK

		PRINT 'There are ' + CAST(@total_products AS VARCHAR(10)) 
						   + ' products belonging to brand_id ' 
						   + CAST(@counter AS VARCHAR(2))
		SET @counter += 1
	END
GO

--/////////////////////////////////////////

--USER DEFINED FUNCTIONS
--*******************************************

-- you must call functions with their schema names
-- user-defined functions'lar tanýmlanýrken schema adý kullanýmý optional'dýr, kullanýlmazsa default olarak "dbo" schema ismiyle kaydedilir. Ancak scalar-valued function'lar çaðýrýlýrken schema ismi ile çaðýrýlmasý zorunludur.


--------------------------------------------------

--1. Scalar-Valued Functions (or scalar functions)

--Tek bir deðer döndürürler.
--Derlenmiþ yapýlardýr ve satýr satýr çaðýrýlýrlar. Bu nedenle satýr sayýsý çoðaldýkça sorgu süresi uzar.
--Aldýklarý input parametreye göre bir sonuç üretirler.
--Benzer bilgileri içeren farklý tablolar içinde kodun deðiþtirilmesine gerek kalmadan kullanýlabilirler.

CREATE FUNCTION fnc_uppertext
	(
		@inputtext VARCHAR(MAX)
	)
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN UPPER(@inputtext)
END
GO


SELECT dbo.fnc_uppertext('clarusway')

PRINT dbo.fnc_uppertext('clarusway')

SELECT first_name, dbo.fnc_uppertext(first_name) FROM sale.customer


--deleting a function

DROP FUNCTION dbo.fnc_uppertext
go

-------------

CREATE FUNCTION svf_prod_quantity
	(
		@prod_id INT
	)
RETURNS INT
AS
BEGIN
	RETURN (SELECT SUM(quantity) FROM sale.order_item WHERE product_id=@prod_id)
END
GO

SELECT dbo.svf_prod_quantity(20)

SELECT *, dbo.svf_prod_quantity(product_id) FROM product.product


--drop function

DROP FUNCTION dbo.svf_prod_quantity
GO

--------------------------------------------------------

CREATE FUNCTION svf_delivery
	(
		@order_id INT
	)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @order_status VARCHAR(50)
	DECLARE @date_diff INT

	SELECT
		@date_diff = DATEDIFF(day, required_date, shipped_date)
	FROM
		sale.orders
	WHERE
		order_id = @order_id

	IF @date_diff > 0
		SET @order_status='Late Delivery'
	ELSE IF @date_diff < 0
		SET @order_status='Early Delivery'
	ELSE IF @date_diff = 0
		SET @order_status='On Time Delivery'
	ELSE
		SET @order_status='Pending'	
		
	RETURN @order_status
END
GO

PRINT dbo.svf_delivery(100)
go

SELECT *, dbo.svf_delivery(order_id) FROM sale.orders
GO

SELECT * FROM sale.orders WHERE dbo.svf_delivery(order_id)='pending'
GO


--using scalar-valued functions with check constraint

CREATE TABLE ON_TIME_ORDER
	(
	Order_ID INT,
	Delivery_Status VARCHAR(50),
	CONSTRAINT check_status CHECK (dbo.svf_delivery(Order_ID) = 'On Time Delivery')
);
GO

SELECT * FROM ON_TIME_ORDER
GO

INSERT INTO  ON_TIME_ORDER (Order_ID, Delivery_Status) VALUES (7, 'On Time Delivery')
GO

DROP TABLE ON_TIME_ORDER
GO


--drop function

DROP FUNCTION dbo.svf_delivery
GO

--------------------------------------------------

--2. Table-Valued Functions (or scalar functions)

--FROM statement içinde tablo gibi kullanýlýr. (Store proceduru bir tablo olarak kullanamayýz, sadece çalýþtýrýp sonucu alýrýz)
--TVF bize SP'lerden farklý olarak tablolarý kullanabilme imkaný sunar.
--TVF ile diðer tablolar JOIN edilebilir. Bunun için CROSS APPLY kullanýlmalýdýr.


CREATE FUNCTION tvf_prod_info (@prod_id INT)
RETURNS TABLE
AS
RETURN
	SELECT
		SUM(a.quantity) [sales_quantity],
		FORMAT(CAST(SUM(a.quantity * a.list_price * (1-a.discount)) AS DECIMAL(18,2)), 'C') [sales_amount],
		COUNT(DISTINCT customer_id) [num_of_cust],
		MAX(b.order_date) [last_order_date]
	FROM
		sale.order_item a
		INNER JOIN
		sale.orders b ON a.order_id=b.order_id
	WHERE
		product_id=@prod_id


SELECT * FROM tvf_prod_info(20)
GO

--CROSS APPLY

SELECT	
	*
FROM
	product.product
CROSS APPLY
	tvf_prod_info(product_id)
GO

--DROP FUNCTION

DROP FUNCTION tvf_prod_info
GO






