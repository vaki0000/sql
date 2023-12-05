--CREATE DATABASE "PortfolioProject";

USE PortfolioProject


-- datadan veri gelirken hatali geliyor . virguller yerine nokta yapmak icin kullanildi . 
DECLARE @tableName NVARCHAR(255)
DECLARE @sql NVARCHAR(MAX)
DECLARE @columnName NVARCHAR(255)

SET @tableName = 'CovidVaccinations' -- Tablo adýný buraya yazýn

DECLARE column_cursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName
  AND DATA_TYPE IN ('nvarchar', 'varchar') -- Sadece metin türü sütunlarý seçiyoruz

OPEN column_cursor
FETCH NEXT FROM column_cursor INTO @columnName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'UPDATE ' + @tableName + ' SET ' + @columnName + ' = REPLACE(' + @columnName + ', '','' , ''.'' );'
    EXEC sp_executesql @sql

    FETCH NEXT FROM column_cursor INTO @columnName
END

CLOSE column_cursor
DEALLOCATE column_cursor;


SELECT
	*
FROM
	dbo.CovidVaccinations
WHERE
	location = 'Turkey'

SELECT
	SUM(total_vaccinations)
FROM
	dbo.CovidVaccinations
WHERE
	location = 'Turkey';
GO
-- datadan veri gelirken hatali geliyor . virguller yerine nokta yapmak icin kullanildi . 
DECLARE @tableName NVARCHAR(255)
DECLARE @sql NVARCHAR(MAX)
DECLARE @columnName NVARCHAR(255)

SET @tableName = 'CovidDeath' -- Tablo adýný buraya yazýn

DECLARE column_cursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName
  AND DATA_TYPE IN ('nvarchar', 'varchar') -- Sadece metin türü sütunlarý seçiyoruz

OPEN column_cursor
FETCH NEXT FROM column_cursor INTO @columnName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'UPDATE ' + @tableName + ' SET ' + @columnName + ' = REPLACE(' + @columnName + ', '','' , ''.'' );'
    EXEC sp_executesql @sql

    FETCH NEXT FROM column_cursor INTO @columnName
END

CLOSE column_cursor
DEALLOCATE column_cursor;

GO

SELECT
	*
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey';

-- Select Data that we are going to be using
GO

SELECT
	location, date, total_cases,new_cases, total_deaths, population
FROM
	dbo.CovidDeath
ORDER BY
	1, 2
;

-- Looking at Total Cases vs Total Deaths

SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM
	dbo.CovidDeath
ORDER BY
	1, 2;
GO
SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage,
	MAX((total_deaths/total_cases) * 100) OVER()
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey'
ORDER BY
	1, 2
;
GO
--ulkelere gore ; total vakalarin olum oranlarinin max olmasi durumu . 

WITH MaxCte AS(SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage,
	MAX((total_deaths/total_cases) * 100) OVER() AS Max_Ratio
FROM
	dbo.CovidDeath
WHERE
	location = 'United States'
)

SELECT
	*
FROM
	MaxCte
WHERE
	DeathPercentage = Max_Ratio

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT
	location, date, population,total_cases, (total_cases/population) * 100 as PercentPopulationInfect,
	MAX((total_cases/population) * 100) OVER()
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey'
ORDER BY
	1, 2

--Looking at Countries with Highest Infection Rate Compared to Population
SELECT
	location, population, max(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM
	dbo.CovidDeath
--WHERE
--	location = 'Turkey'
GROUP BY
	location, population
ORDER BY
	4 DESC