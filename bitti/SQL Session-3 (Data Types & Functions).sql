-- SQL SESSION-3, 14.01.2023, Data Types & Built-in Functions

-- String Data Types
-- varchar vs. nvarchar (unicode / non-unicode)

SELECT N'قمر'

SELECT CONVERT(VARCHAR, N'قمر')
SELECT CONVERT(NVARCHAR, N'قمر')

SELECT N'😀'


-- char vs. varchar

SELECT DATALENGTH(CONVERT(CHAR(50), 'clarusway'))
SELECT DATALENGTH(CONVERT(VARCHAR(50), 'clarusway'))


-------------------------------------------------------------------------
--DATE FUNCTIONS---------------
-------------------------------------------------------------------------

----//////////////////////////////////////////////
---Data Types and getdate() function

SELECT GETDATE()

CREATE TABLE t_date_time (
	A_time [time],
	A_date [date],
	A_smalldatetime [smalldatetime],
	A_datetime [datetime],
	A_datetime2 [datetime2],
	A_datetimeoffset [datetimeoffset]
);

SELECT * FROM t_date_time

INSERT t_date_time 
VALUES (GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE())


----//////////////////////////////////////////////
---Functions for return date or time parts

SELECT	A_date,
		DATENAME(DW, A_date) [weekday],             
		DATEPART(DW, A_date) [weekday_2],           
		DATENAME(M, A_date) [month],              
		DATEPART(month, A_date) [month_2],
		DAY(A_date) [day],
		MONTH(A_date) [month_3],
		YEAR(A_date) [year],
		A_time,
		DATEPART (minute, A_time) [minute],
		DATEPART (NANOSECOND, A_time) [nanosecond]
FROM	t_date_time;

/*  YEAR / YYYY / YY
	QUARTER / QQ / Q
	MONTH / MM / M
	DAYOFYEAR / DY / Y
	WEEK / WW / WK
	WEEKDAY / DW
	DAY / DD / D
	HOUR / HH
	MINUTE / MI / N
	SECOND / SS / S
	MILLISECOND / MS
	MICROSECOND / MCS
	NANOSECOND / NS  */


----//////////////////////////////////////////////
---Functions for return date or time differences

SELECT A_date,        
        A_datetime,
        GETDATE() AS [CurrentTime],
        DATEDIFF (DAY, '2020-11-30', A_date) Diff_day,
        DATEDIFF (MONTH, '2020-11-30', A_date) Diff_month,
        DATEDIFF (YEAR, '2020-11-30', A_date) Diff_year,
        DATEDIFF (HOUR, A_datetime, GETDATE()) Diff_Hour,
        DATEDIFF (MINUTE, A_datetime, GETDATE()) Diff_Min
FROM   t_date_time;


SELECT * FROM sale.orders

select	order_date, shipped_date,
		DATEDIFF(DAY, order_date, shipped_date) day_diff, 
		DATEDIFF(DAY, shipped_date, order_date) day_diff
from	sale.orders
where	order_id = 1;


----//////////////////////////////////////////////
---Functions for Modify date and time

SELECT	order_date,
		DATEADD(YEAR, 5, order_date), 
		DATEADD(DAY, 5, order_date),
		DATEADD(DAY, -5, order_date)		
FROM	sale.orders
where	order_id = 1

SELECT GETDATE(), DATEADD(HOUR, 5, GETDATE())

SELECT	order_date, EOMONTH(order_date) end_of_month,
		EOMONTH(order_date, 2) eomonth_next_two_months
FROM	sale.orders
where	order_id = 1;


----//////////////////////////////////////////////
---Function for Validate date and time

SELECT ISDATE('123')

SELECT ISDATE('20230114')

--SELECT 1 + '1'

SELECT ISDATE('2021-12-02')  --2021/12/02  ||| 2021.12.02  |||  20211202

SELECT ISDATE('02/12/2022')  --02-12-2022  |||  02.12.2022

SELECT ISDATE('02122022') --ERROR


----//////////////////////////////////////////////
---QUERY TIME

--Write a query returns orders that are shipped more than two days after the order date. 
--2 günden geç kargolanan siparişlerin bilgilerini getiriniz.

SELECT *, DATEDIFF (DAY, order_date, shipped_date) date_diff
FROM sale.orders
WHERE DATEDIFF (DAY, order_date, shipped_date) > 2
order by date_diff desc;


-------------------------------------------------------------------------
--STRING FUNCTIONS---------------
-------------------------------------------------------------------------

-----LEN

SELECT LEN('welcome')

SELECT LEN(' welcome')

SELECT LEN(' welcome ')

SELECT LEN(123456789)


--If there is a quote in the string

SELECT 'Jack''s Phone'


-----CHARINDEX

SELECT CHARINDEX('C', 'CHARACTER')

SELECT CHARINDEX('C', 'CHARACTER', 2)

SELECT CHARINDEX('CT', 'CHARACTER')

SELECT CHARINDEX('ct', 'CHARACTER')


--PATINDEX()

SELECT PATINDEX('%R', 'CHARACTER')

SELECT PATINDEX('R%', 'CHARACTER')

SELECT PATINDEX('%[RC]%', 'CHARACTER')

SELECT PATINDEX('_H%' , 'CHARACTER')


--LEFT

SELECT LEFT('CHARACTER', 5)

SELECT LEFT(' CHARACTER', 5)


--RIGHT

SELECT RIGHT('CHARACTER', 5)

SELECT RIGHT('CHARACTER ', 5)
SELECT RIGHT(12345, 5)


--SUBSTRING

SELECT SUBSTRING('CHARACTER', 3, 5)

SELECT SUBSTRING('CHARACTER', 0, 5)

SELECT SUBSTRING('CHARACTER', -1, 5)

SELECT SUBSTRING(88888888, 3, 3) --error


--LOWER

SELECT LOWER('CHARACTER')


--UPPER

SELECT UPPER('character')


--How to grow the first character of the 'character' word.

SELECT UPPER(LEFT('character',1)) + LOWER(RIGHT('character', LEN('character')-1))


------------------------------------------
---TRIM, LTRIM, RTRIM

SELECT TRIM('  CHARACTER   ')

SELECT TRIM('  CHARA CTER   ')

SELECT TRIM('?, ' FROM '    ?SQL Server,    ') AS TrimmedString;

SELECT LTRIM('  CHARACTER   ')

SELECT RTRIM('  CHARACTER   ')


---REPLACE

SELECT REPLACE('CHARACTER STRING', ' ', '/')

SELECT REPLACE(123456, 2, 0)


---CONCAT

SELECT first_name + ' ' + last_name
FROM sale.customer

SELECT CONCAT(first_name,' ',last_name)
FROM sale.customer


-------------------------------------------------------------------------
--OTHER FUNCTIONS---------------
-------------------------------------------------------------------------

---CAST

--SELECT 1 + '1'
--SELECT 1 + 'GG'

SELECT CAST(12345 AS CHAR)

SELECT CAST(123.95 AS INT)

SELECT CAST(123.95 AS DEC(3,0)) --DECIMAL(3,0)


---CONVERT

SELECT CONVERT(int, 30.60)

SELECT CONVERT(VARCHAR(10), '2020-10-10')
SELECT CONVERT(DATETIME, '2020-10-10')


---SQL Server Datetime Formatting
---Converting a Datetime to a Varchar

SELECT CONVERT(VARCHAR, GETDATE(), 7) 
SELECT CONVERT(NVARCHAR, GETDATE(), 100) --0 / 100
SELECT CONVERT(NVARCHAR, GETDATE(), 112)
SELECT CONVERT(NVARCHAR, GETDATE(), 113) --13 / 113

SELECT CAST('20201010' AS DATE)
SELECT CONVERT(NVARCHAR, CAST('20201010' AS DATE), 103)


---Converting a Varchar to a Datetime

SELECT convert(DATE, '25 Oct 21', 6)
----
select convert(varchar, getdate(), 6)

https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/ 


---ROUND

SELECT ROUND(123.4567, 2)

SELECT ROUND(123.4567, 2, 0)

SELECT ROUND(123.4567, 2, 1)

SELECT CONVERT(INT, 123.9999)
SELECT CONVERT(DECIMAL(18,2), 123.4567)


---ISNUMERIC
---The ISNUMERIC() function checks whether a value can be converted
---to a numeric data type

SELECT ISNUMERIC(11111)
SELECT ISNUMERIC('11111')
SELECT ISNUMERIC('clarusway')


---COALESCE
---EĞER İLK İFADE NULL İSE BİR SONRAKİ DEĞERİ GETİRİR, O DA NULL İSE BİR SONRAKİNİ

SELECT COALESCE(NULL, 'Hi', 'Hello', NULL) result;

SELECT COALESCE(NULL, NULL ,'Hi', 'Hello', NULL) result;

SELECT COALESCE(NULL, NULL ,'Hi', 'Hello', 100, NULL) result;
---This function doesn't limit the number of arguments, but they must all be of the same data type.

SELECT COALESCE(NULL, NULL) result;


---ISNULL()
---replaces NULL with a specified value

SELECT ISNULL(NULL, 1)

SELECT ISNULL(phone, 'no phone')
FROM sale.customer

---difference between coalesce and isnull

SELECT ISNULL(phone, 0)
FROM sale.customer

SELECT COALESCE(phone, 0) --ERROR
FROM sale.customer


---NULLIF
---returns NULL if two arguments are equal. Otherwise, it returns the first expression.

SELECT NULLIF(10,10)

SELECT NULLIF('Hello', 'Hi') result;

SELECT NULLIF(2, '2')


-------------------------------------------------------------------------
--QUERY TIME FOR YOU---------------
-------------------------------------------------------------------------

-- How many customers have yahoo mail?
-- (yahoo mailine sahip kaç müşteri vardır?)


SELECT count(customer_id)
FROM sale.customer
WHERE PATINDEX('%yahoo%', email) > 0;


-------------------------------------------------------
---Write a query that returns the name of the streets, where the third character of the streets is numeric.
---(street sütununda soldan üçüncü karakterin rakam olduğu kayıtları getiriniz)





-------------------------------------------------------
--Add a new column to the customers table that contains the customers' contact information. 
--If the phone is not null, the phone information will be printed, if not, the email information will be printed.

--her müşteriye ulaşabileceğim telefon veya email bilgisini istiyorum.
--Müşterinin telefon bilgisi varsa email bilgisine gerek yok.
--telefon bilgisi yoksa email adresi iletişim bilgisi olarak gelsin.
--beklenen sütunlar: customer_id, first_name, last_name, contact





-------------------------------------------------------
--Split the mail addresses into two parts from ‘@’, and place them in separate columns.

--@ işareti ile mail sütununu ikiye ayırın. Örneğin
--ronna.butler@gmail.com	/ ronna.butler	/ gmail.com



