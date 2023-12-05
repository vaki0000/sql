Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,  (total_deaths/total_cases)*100
From PortfolioProject..CovidDeaths
Where Location like 'Turkey' and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date,population, total_deaths, (total_deaths/population)*100
From CovidDeaths
Where Location like 'Turkey' and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
   -- -N�fusa g�re En Y�ksek Enfeksiyon Oran�na Sahip �lkeler

select Location,population, Max(total_cases), MAX(total_cases/population)*100
from CovidDeaths
Where continent is not null 
group by Location,population
order by MAX(total_cases/population)*100 desc

-- N�fus ba��na en y�ksek �l�m say�s� olan �lkeler

select location, max(total_deaths)
from CovidDeaths
Where continent is not null 
group by location
order by max(total_deaths) desc
----- BREAKING THINGS DOWN BY CONTINENT
--N�fus ba��na en y�ksek �l�m say�s�na sahip k�talar g�steriliyor

select continent, max(total_deaths)
from CovidDeaths
Where continent is not null 
group by continent
order by max(total_deaths) desc

 --GLOBAL NUMBERS(kuresel say�lar)


Select   SUM(new_cases),sum(new_deaths),(SUM(new_deaths)/sum(new_cases)*100)
From PortfolioProject..CovidDeaths
--Where Location like 'Turkey'  
Where continent is not null 
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
---(-- Toplam N�fus vs A��lar
-- En az bir Covid A��s� alan n�fusun y�zdesini g�sterir.)

select  dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths  dea
join CovidVaccinations vac 

on   dea.location=vac.location and
dea.date=vac.date
where vac.continent is not null


order by 2,3
 
 ----USE CTE
With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select  dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from CovidDeaths  dea
join CovidVaccinations vac 

on   dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3
 
 ---TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select  dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths  dea
join CovidVaccinations vac 

on   dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 2,3
 
 --Creating View to  store Data for later visualizations

Create View PercentPopulationVaccinated as

select  dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,dea.total_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths  dea
join CovidVaccinations vac 
on   dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--drop view PercentPopulationVaccinated

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated
order by 2,3



--Bu sorgu, her bir �lke i�in maksimum a��lama y�zdesini hesaplar ve bu y�zdelikleri g�sterir. GROUP BY ifadesi, her bir
--�lkeyi gruplar ve MAX i�levi, her grup i�indeki maksimum a��lama y�zdesini hesaplar.

SELECT continent,location,population,max(RollingPeopleVaccinated) rollingvaccinated, max(total_vaccinations) as totalvac,
       MAX(RollingPeopleVaccinated/population) AS MaxVaccinationPercentage
FROM PercentPopulationVaccinated
GROUP BY continent,location, population
ORDER BY MaxVaccinationPercentage DESC;
  


--Her �lkenin ilk a��lama tarihini ve a��lama oran�n� g�steren bir sorgu:
 --219 ulke var
 --9 tane k�tas� null olan var


select continent, location,Population,MIN(date) as FirstVaccinationDate, max(RollingPeopleVaccinated/population) AS Vaccination_Rate
from PercentPopulationVaccinated
where new_vaccinations>0 --and continent is not null
group by continent,location,population
order by 4 desc


--hastal�klarla   Ya�l� N�fus Aras�ndaki Korelasyon:
Create View aged_65_population as
select ( population* aged_65_older) /100 as population_65, ( population* aged_70_older) /100 as population_70,aged_70_older,
location,aged_65_older,population
from Coviddeaths  
where  continent is not null 
group by location ,( population* aged_65_older) /100 ,aged_65_older,population,( population* aged_70_older) /100,aged_70_older

select *
from aged_65_population


select dea.location,dea.population,65.population_65,65.population_70
from aged_65_population
order by 3 desc


--"Diyabet prevalans�", bir pop�lasyon i�inde diyabet s�kl���n� veya yayg�nl���n� ifade eden bir terimdir. Prevalans,
--belirli bir zamanda veya belirli bir d�nemde diyabetli bireylerin say�s�n� toplam pop�lasyona oranlayarak hesaplan�r.
--Diyabet prevalans�, bir b�lgede veya �lkede diyabetin ne kadar yayg�n oldu�unu anlamak i�in kullan�lan �nemli bir �l��tt�r.
--�rne�in, bir �lkenin median age de�eri 35 ise, bu demektir ki bu �lkedeki n�fusun yar�s� 35 ya��ndan b�y�k,
--di�er yar�s� ise 35 ya��ndan k���kt�r.

SELECT PV.location, PV.population,  CV.median_age,  CV.aged_65_older,  CV.cardiovasc_death_rate,   CV.diabetes_prevalence,
CV.people_vaccinated,  max(PV.RollingPeopleVaccinated /PV.population) AS VaccinationRate
       
FROM PercentPopulationVaccinated AS PV
JOIN CovidVaccinations AS CV ON PV.location = CV.location
GROUP BY PV.location,PV.population,CV.aged_65_older,CV.median_age,CV.cardiovasc_death_rate,CV.diabetes_prevalence,CV.people_vaccinated
ORDER BY 6 DESC;


--
-- Pfizer ve BioNTech firmalar�n�n geli�tirdi�i a�� ilk olarak 2020 y�l�nda ��kt�. 
--�u ana kadar d�nya genelinde uygulanan doz say�s� 10 milyar� a�t�.
--K�resel �apta a��lama oran�na bak�ld���nda d�nya n�fusunun yakla��k y�zde 60'�na en az bir doz a�� uyguland�. Birinci ve
--ikinci doz a�� yapt�ranlar�n toplam oran� ocak 2022 y�l� sonu tarihi itibar�yla y�zde 59 d�zeyinde.31 Oca 2022
--30 nisan 2021 
--T�rkiye'de COVID-19 a��lamas�, Sa�l�k Bakanl��� taraf�ndan �inli a�� ureticisi sinovac�n " CoronaVac" a��s�na 
--"Acil Kullan�m Onay�" verilmesinin ard�ndan 14 Ocak 2021'de ba�lad�.

--Bu sorgu, tablodaki t�m �lkelerin a��lama oranlar�n� toplar ve toplam n�fusa b�ler, ard�ndan sonucu y�zde cinsinden hesaplar.
--Bu �ekilde t�m d�nyada toplam a��lanma oran�n� buluruz.



--150.289.743 (Toplam yap�lan a�� say�s�)
--57.885.256 (1. doz uygulanan ki�i say�s�)
--53.115.593 (2. doz uygulanan ki�i say�s�)
--27.749.860 (3. doz uygulanan ki�i say�s�)
--28.206.135 (4. doz uygulanan ki�i say�s�)
--G�ncelleme: 8 A�ustos 2022, 01:17


SELECT sum(sum_vaccinated) AS Totalvaccinated,sum(sum_population) AS TotalPopulation,sum(sum_population)/sum(sum_vaccinated)
FROM (
    SELECT location,  sum(RollingPeopleVaccinated)/count(location)*100 AS sum_vaccinated,
	SUM(population)/count(location) AS sum_population
    FROM PercentPopulationVaccinated
    WHERE continent IS not NULL
    GROUP BY location
) AS subquery;


--her ulkenin max a��lanan insan say�s�n� g�steren sorgu: 
select continent,location, population, max(RollingPeopleVaccinated)as maxvac,
max(RollingPeopleVaccinated/population) as vaccinationrate
from PercentPopulationVaccinated
group by location, population,continent
order by 4 desc
 
--Her �lkenin maximum  a�� say�s�n� ve maxsimum �lm say�s�n�  s�ralayan bir sorgu:
SELECT dea.location, dea.population,vac.cardiovasc_death_rate,max(dea.date),  max(vac.total_vaccinations) AS TotalVaccinations, max(dea.total_deaths) AS TotalDeaths
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
group by dea.location, dea.population,vac.cardiovasc_death_rate
ORDER by 6 desc;

-- A��lanan ki�i say�s� ile �nsani Geli�im Endeksi aras�ndaki ili�kiyi incelemek i�in bir sorgu:
�nsani Geli�im Endeksi (�GE), Birle�mi� Milletler Kalk�nma Program� (UNDP) taraf�ndan her y�l yay�nlanan bir endekstir.
�GE, �lkelerin sadece ekonomik b�y�me ile de�il, ayn� zamanda insanlar�n ya�am kalitesi, sa�l�k, e�itim ve gelir d�zeyi 
gibi fakt�rler a��s�ndan da nas�l bir geli�me g�sterdi�ini �l�er. �GE, �lkelerin insan geli�imi a��s�ndan s�ralamas�n�
belirler ve d�nya genelindeki e�itsizlikleri g�sterir.
--gdp_per_capita: Ki�i ba��na d��en gayri safi yurti�i has�lay� ifade eder.
--extreme_poverty: A��r� yoksulluk oran�n� g�sterir.
--handwashing_facilities: Ellerini y�kama imkanlar�n� ifade eder.


SELECT dea.location,dea.population, dea.extreme_povert,dea.gdp_per_capita,max(handwashing_facilities),MAX(dea.people_vaccinated) AS MaxPeopleVaccinated,
MAX(pp.RollingPeopleVaccinated / pp.population)  as vaccinatedrate, AVG(dea.human_development_index) AS AverageHDI
FROM CovidDeaths dea  JOIN PercentPopulationVaccinated pp
on dea.location = pp.location 
and dea.date=pp.date
where dea.location like 'world' and dea.continent is not null
GROUP BY dea.location,dea.population,dea.extreme_poverty,dea.gdp_per_capita
ORDER BY 4 DESC;

--stringency_index: �lkenin pandemi k�s�tlamalar�n�n s�k�l���n� temsil eden bir endeks.

SELECT location,max(stringency_index) as stringency_index, max(new_cases) as newcases, max(new_tests) as new_test,
max(new_tests*positive_rate) as total_positif, max(hosp_patients) as hospital,max(icu_patients) as icu, max(new_deaths)as deaths
FROM coviddeaths
WHERE date = '2020-12-30'
group by location
ORDER BY 5 DESC;


Select  max(population)
,max(date),SUM(new_cases)as total_cases,sum(new_deaths)as total_deaths,(SUM(new_deaths)/sum(new_cases))as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like 'Turkey'  
where location = 'World'
--group by date
--order by 1,2

select max(rollingpeoplevaccinated) from percentpopulationvaccinated order by 1 desc
