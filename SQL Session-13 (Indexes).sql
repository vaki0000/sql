--SQL Session-13, 01.02.2023, (Indexes)

--creating a new table
---------------------------------------------------

create table website_visitor(
		visitor_id int,
		first_name varchar(50),
		last_name varchar(50),
		phone_number bigint,
		city varchar(50)
);


--inserting random values into the table
---------------------------------------------------

DECLARE @i int = 1
DECLARE @RAND AS INT
WHILE @i<200000
BEGIN
	SET @RAND = RAND()*81
	INSERT website_visitor
		SELECT 
			@i , 
			'visitor_name' + cast (@i as varchar(20)), 
			'visitor_surname' + cast (@i as varchar(20)),
			5326559632 + @i, 
			'city' + cast(@RAND as varchar(2))

	SET @i +=1
END;


SELECT TOP 100 *
FROM website_visitor


--STATISTICS
---------------------------------------------------

SET STATISTICS IO ON
--SET STATISTICS TIME ON



--without primary key/clustered index
---------------------------------------------------

SELECT *
FROM website_visitor
WHERE visitor_id=100  --SELECT 1879*8  --- 15032 kb

EXEC sp_spaceused website_visitor  ---15048 kb, 8 kb, TABLE SCAN	


--with primary key/clustered index
---------------------------------------------------

CREATE CLUSTERED INDEX cls_idx ON website_visitor(visitor_id)

SELECT visitor_id
FROM website_visitor
WHERE visitor_id=100  --SELECT 3*8  --- 24 kb


SELECT *
FROM website_visitor
WHERE visitor_id=100


EXEC sp_spaceused website_visitor  ---15688 kb, 136 kb, clustered index seek


--without nonclustered index
---------------------------------------------------

SELECT first_name
FROM website_visitor
WHERE first_name='visitor_name17'  --SELECT 1871*8  --- 14968 kb, clustered index scan


--with nonclustered index
---------------------------------------------------

CREATE NONCLUSTERED INDEX non_cls_idx_1 ON website_visitor(first_name);

SELECT first_name
FROM website_visitor
WHERE first_name='visitor_name17'  --SELECT 3*8  --- 24 kb, nonclustered index scan

EXEC sp_spaceused website_visitor  ---22800 kb, 6536 kb


--with nonclustered index and multiple columns
---------------------------------------------------

SELECT first_name, last_name
FROM website_visitor
WHERE first_name='visitor_name17' --SELECT 6*8  --- 48 kb, nonclustered index scan


CREATE NONCLUSTERED INDEX non_cls_idx_1 
ON website_visitor(first_name)
INCLUDE(last_name)
WITH(DROP_EXISTING=ON);

--Bir sorgunun en performanslý hali idealde Sorgu costunun %100 Index Seek yöntemi ile getiriliyor olmasýdýr!

SELECT first_name, last_name
FROM website_visitor
WHERE first_name='visitor_name17'


EXEC sp_spaceused website_visitor  ---27536 kb, 11424 kb


--filtering another column of nonclustered index
---------------------------------------------------

SELECT first_name, last_name
FROM website_visitor
WHERE last_name='visitor_surname17'
ORDER BY last_name;


SELECT *
FROM website_visitor
WHERE city='city78'
ORDER BY last_name;



------------------------------

CREATE NONCLUSTERED INDEX [xxxx]
ON [dbo].[website_visitor] ([city])
INCLUDE ([first_name],[last_name],[phone_number])


EXEC sp_spaceused website_visitor  ---42854 kb, 25856 kb