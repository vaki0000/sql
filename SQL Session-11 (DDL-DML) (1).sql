--SQL Session-11, 28.01.2023, (DDL - DML)

-- CREATE
--*************************************

CREATE DATABASE LibraryDB

USE LibraryDB

--create schemas
CREATE SCHEMA Book
CREATE SCHEMA Person

--Create Tables

--create Book.Book table
CREATE TABLE [Book].[Book](
	[Book_ID] INT PRIMARY KEY NOT NULL,
	[Book_Name] [nvarchar](100) NOT NULL,
	[Author_ID] INT NOT NULL,
	[Publisher_ID] INT NOT NULL);

--create Book.Author table
CREATE TABLE [Book].[Author](
	[Author_ID] INT,
	[Author_FirstName] NVARCHAR(50) NOT NULL,
	[Author_LastName] NVARCHAR(50) NOT NULL);

--create Book.Publisher Table
CREATE TABLE [Book].[Publisher](
	[Publisher_ID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Publisher_Name] NVARCHAR(100) NULL);

--create Person.Person table
CREATE TABLE [Person].[Person](
	[SSN] BIGINT PRIMARY KEY CHECK(LEN(SSN)=11),
	--[SSN] BIGINT PRIMARY KEY CONSTRAINT ck_size CHECK(LEN(SSN)=11)
	[Person_FirstName] NVARCHAR(50) NULL,
	[Person_LastName] NVARCHAR(50) NULL);

--create Person.Loan table
CREATE TABLE [Person].[Loan](
	[SSN] BIGINT NOT NULL,
	[Book_ID] INT NOT NULL,
	PRIMARY KEY ([SSN], [Book_ID])); --composite key

--create Person.Person_Phone table
CREATE TABLE [Person].[Person_Phone](
	[Phone_Number] BIGINT PRIMARY KEY,
	[SSN] BIGINT NOT NULL REFERENCES [Person].[Person]);

--create Person.Person_Mail table
CREATE TABLE [Person].[Person_Mail](
	[Mail_ID] INT PRIMARY KEY IDENTITY(1,1),
	[Mail] NVARCHAR(MAX) NOT NULL,
	[SSN] BIGINT UNIQUE NOT NULL,
	CONSTRAINT FK_SSNum FOREIGN KEY (SSN) REFERENCES Person.Person(SSN));


-- INSERT
--*************************************

SELECT * FROM Person.Person

INSERT INTO Person.Person ([SSN],[Person_FirstName],[Person_LastName])
	VALUES (78945612344, N'Zehra', N'Tekin')

INSERT INTO Person.Person ([Person_FirstName],[SSN],[Person_LastName])
	VALUES (N'Eylem', 12345678977, N'Doðan')

INSERT INTO Person.Person ([SSN],[Person_FirstName])
	VALUES (25896374199, N'Zehra')

--it is not mandatory to use column names & INTO is optional

INSERT Person.Person VALUES (55008479341, N'Kerim', N'Öztürk')

INSERT Person.Person VALUES (95028479341, N'Ali', NULL)

--primary key constraint
INSERT INTO Person.Person ([SSN],[Person_FirstName],[Person_LastName]) --ERROR
	VALUES (78945612344, N'Zehra', N'Tekin')

--Check constraint
INSERT INTO Person.Person ([SSN],[Person_FirstName],[Person_LastName]) --ERROR
	VALUES (789456123448, N'Zehra', N'Tekin')

--data type constraint
INSERT INTO Person.Person ([SSN],[Person_FirstName],[Person_LastName]) --ERROR
	VALUES (N'Zehra', N'Zehra', N'Tekin')

----------------------------------------------

SELECT * FROM Person.Person_Mail
SELECT * FROM Person.Person

INSERT INTO Person.Person_Mail (Mail, SSN) 
	VALUES (N'eylemdog@gmail.com', 12345678977),
		   (N'zehrtek@hotmail.com', 78945612344),
		   (N'kemözt@gmail.com', 55008479341)

--foreign key constraint
SELECT * FROM Person.Person

INSERT INTO Person.Person_Mail (Mail, SSN) 
VALUES (N'ahm@gmail.com', 11111111111)  --ERROR

--IDENTITY constraint
INSERT INTO Person.Person_Mail (Mail_ID, Mail, SSN) 
VALUES (10, N'takutlu@gmail.com', 46056688505) --ERROR


----------------------------------------------

--insert with SELECT statement
CREATE TABLE Names (
	[Name] varchar(50));

SELECT * FROM Names

--from different database
INSERT Names
SELECT first_name FROM [SampleRetail].sale.customer WHERE first_name LIKE N'M%';


-- SELECT INTO
--*************************************

SELECT * FROM Person.Person

SELECT *
INTO Person.Person_2
FROM Person.Person

SELECT * FROM Person.Person_2

--different database
SELECT *
INTO Person.Person_3
FROM [SampleRetail].sale.customer
WHERE 1=0;

SELECT * FROM Person.Person_3



-- DEFAULT (insert default values)
--*************************************

INSERT Book.Publisher
DEFAULT VALUES

SELECT * FROM Book.Publisher


-- UPDATE
--*************************************

--Update iþleminde koþul tanýmlamaya dikkat ediniz. Eðer herhangi bir koþul tanýmlamazsanýz sütundaki tüm deðerlere deðiþiklik uygulanacaktýr.

SELECT * FROM Person.Person_2

UPDATE Person.Person_2
SET Person_FirstName=N'Tahsin'

UPDATE Person.Person_2
SET Person_FirstName=N'Ali' WHERE SSN=95028479341

--update with JOIN

SELECT * FROM Person.Person

UPDATE Person.Person_2 SET Person_FirstName = B.Person_FirstName 
FROM Person.Person_2 A Inner Join Person.Person B ON A.SSN=B.SSN

SELECT * FROM Person.Person_2

--update with functions

UPDATE Person.Person_2
SET SSN = LEFT(SSN, 10)

SELECT * FROM Person.Person_2


-- DELETE
--*************************************

--IDENTITY constraint
SELECT * FROM Book.Publisher

INSERT Book.Publisher 
VALUES (N'Ýþ Bankasý Kültür Yayýncýlýk'), (N'Can Yayýncýlýk'), (N'Ýletiþim Yayýncýlýk')

DELETE FROM Book.Publisher

INSERT Book.Publisher 
VALUES (N'Ýþ Bankasý Kültür Yayýncýlýk')

SELECT * FROM Book.Publisher

--------------------

SELECT * FROM Person.Person_2

DELETE FROM Person.Person_2
WHERE SSN=9502847934

DELETE FROM Person.Person_2
WHERE Person_LastName IS NULL;

--FOREIGN KEY-REFERENCE CONSTRAINT
DELETE FROM Person.Person
WHERE SSN > 80000000;  --ERROR


-- DROP
--*************************************

DROP TABLE [dbo].[Names]
DROP TABLE [Person].[Person_2]
DROP TABLE [Person].[Person_3]

--foreign key constraint
DROP TABLE Person.Person --error


-- TRUNCATE
--*************************************

SELECT * FROM Person.Person_Mail
SELECT * FROM Book.Publisher

TRUNCATE TABLE Person.Person_Mail;
TRUNCATE TABLE Book.Publisher;

TRUNCATE TABLE Person.Person;  --ERROR


-- ALTER
--*************************************

--ADD KEY CONSTRAINTS

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ALTER COLUMN Author_ID INT NOT NULL

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Book.Publisher (Publisher_ID)

--Person.Loan Table

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_PERSON FOREIGN KEY (SSN) REFERENCES Person.Person (SSN)

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_book FOREIGN KEY (Book_ID) REFERENCES Book.Book (Book_ID)
--ON DELETE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default
--ON UPDATE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default

--ADD CHECK CONSTRAINTS
ALTER TABLE Person.Person_Phone 
ADD CONSTRAINT FK_Phone_check CHECK (Phone_Number BETWEEN 700000000 AND 9999999999)

SELECT * FROM Person.Person_Phone; 
SELECT * FROM Person.Person;

INSERT Person.Person_Phone VALUES(600000000, 12345678977)

--drop constraints
ALTER TABLE Person.Person_Phone
DROP CONSTRAINT FK_Phone_check;


