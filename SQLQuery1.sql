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
   -- -Nüfusa göre En Yüksek Enfeksiyon Oranýna Sahip Ülkeler

select Location,population, Max(total_cases), MAX(total_cases/population)*100
from CovidDeaths
Where continent is not null 
group by Location,population
order by MAX(total_cases/population)*100 desc

-- Nüfus baþýna en yüksek ölüm sayýsý olan ülkeler

select location, max(total_deaths)
from CovidDeaths
Where continent is not null 
group by location
order by max(total_deaths) desc
----- BREAKING THINGS DOWN BY CONTINENT
--Nüfus baþýna en yüksek ölüm sayýsýna sahip kýtalar gösteriliyor

select continent, max(total_deaths)
from CovidDeaths
Where continent is not null 
group by continent
order by max(total_deaths) desc

 --GLOBAL NUMBERS(kuresel sayýlar)


Select   SUM(new_cases),sum(new_deaths),(SUM(new_deaths)/sum(new_cases)*100)
From PortfolioProject..CovidDeaths
--Where Location like 'Turkey'  
Where continent is not null 
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
---(-- Toplam Nüfus vs Aþýlar
-- En az bir Covid Aþýsý alan nüfusun yüzdesini gösterir.)

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



--Bu sorgu, her bir ülke için maksimum aþýlama yüzdesini hesaplar ve bu yüzdelikleri gösterir. GROUP BY ifadesi, her bir
--ülkeyi gruplar ve MAX iþlevi, her grup içindeki maksimum aþýlama yüzdesini hesaplar.

SELECT continent,location,population,max(RollingPeopleVaccinated) rollingvaccinated, max(total_vaccinations) as totalvac,
       MAX(RollingPeopleVaccinated/population) AS MaxVaccinationPercentage
FROM PercentPopulationVaccinated
GROUP BY continent,location, population
ORDER BY MaxVaccinationPercentage DESC;
  


--Her ülkenin ilk aþýlama tarihini ve aþýlama oranýný gösteren bir sorgu:
 --219 ulke var
 --9 tane kýtasý null olan var


select continent, location,Population,MIN(date) as FirstVaccinationDate, max(RollingPeopleVaccinated/population) AS Vaccination_Rate
from PercentPopulationVaccinated
where new_vaccinations>0 --and continent is not null
group by continent,location,population
order by 4 desc


--hastalýklarla   Yaþlý Nüfus Arasýndaki Korelasyon:
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


--"Diyabet prevalansý", bir popülasyon içinde diyabet sýklýðýný veya yaygýnlýðýný ifade eden bir terimdir. Prevalans,
--belirli bir zamanda veya belirli bir dönemde diyabetli bireylerin sayýsýný toplam popülasyona oranlayarak hesaplanýr.
--Diyabet prevalansý, bir bölgede veya ülkede diyabetin ne kadar yaygýn olduðunu anlamak için kullanýlan önemli bir ölçüttür.
--Örneðin, bir ülkenin median age deðeri 35 ise, bu demektir ki bu ülkedeki nüfusun yarýsý 35 yaþýndan büyük,
--diðer yarýsý ise 35 yaþýndan küçüktür.

SELECT PV.location, PV.population,  CV.median_age,  CV.aged_65_older,  CV.cardiovasc_death_rate,   CV.diabetes_prevalence,
CV.people_vaccinated,  max(PV.RollingPeopleVaccinated /PV.population) AS VaccinationRate
       
FROM PercentPopulationVaccinated AS PV
JOIN CovidVaccinations AS CV ON PV.location = CV.location
GROUP BY PV.location,PV.population,CV.aged_65_older,CV.median_age,CV.cardiovasc_death_rate,CV.diabetes_prevalence,CV.people_vaccinated
ORDER BY 6 DESC;


--
-- Pfizer ve BioNTech firmalarýnýn geliþtirdiði aþý ilk olarak 2020 yýlýnda çýktý. 
--Þu ana kadar dünya genelinde uygulanan doz sayýsý 10 milyarý aþtý.
--Küresel çapta aþýlama oranýna bakýldýðýnda dünya nüfusunun yaklaþýk yüzde 60'ýna en az bir doz aþý uygulandý. Birinci ve
--ikinci doz aþý yaptýranlarýn toplam oraný ocak 2022 yýlý sonu tarihi itibarýyla yüzde 59 düzeyinde.31 Oca 2022
--30 nisan 2021 
--Türkiye'de COVID-19 aþýlamasý, Saðlýk Bakanlýðý tarafýndan çinli aþý ureticisi sinovacýn " CoronaVac" aþýsýna 
--"Acil Kullaným Onayý" verilmesinin ardýndan 14 Ocak 2021'de baþladý.

--Bu sorgu, tablodaki tüm ülkelerin aþýlama oranlarýný toplar ve toplam nüfusa böler, ardýndan sonucu yüzde cinsinden hesaplar.
--Bu þekilde tüm dünyada toplam aþýlanma oranýný buluruz.



--150.289.743 (Toplam yapýlan aþý sayýsý)
--57.885.256 (1. doz uygulanan kiþi sayýsý)
--53.115.593 (2. doz uygulanan kiþi sayýsý)
--27.749.860 (3. doz uygulanan kiþi sayýsý)
--28.206.135 (4. doz uygulanan kiþi sayýsý)
--Güncelleme: 8 Aðustos 2022, 01:17


SELECT sum(sum_vaccinated) AS Totalvaccinated,sum(sum_population) AS TotalPopulation,sum(sum_population)/sum(sum_vaccinated)
FROM (
    SELECT location,  sum(RollingPeopleVaccinated)/count(location)*100 AS sum_vaccinated,
	SUM(population)/count(location) AS sum_population
    FROM PercentPopulationVaccinated
    WHERE continent IS not NULL
    GROUP BY location
) AS subquery;


--her ulkenin max aþýlanan insan sayýsýný gösteren sorgu: 
select continent,location, population, max(RollingPeopleVaccinated)as maxvac,
max(RollingPeopleVaccinated/population) as vaccinationrate
from PercentPopulationVaccinated
group by location, population,continent
order by 4 desc
 
--Her ülkenin maximum  aþý sayýsýný ve maxsimum ölm sayýsýný  sýralayan bir sorgu:
SELECT dea.location, dea.population,vac.cardiovasc_death_rate,max(dea.date),  max(vac.total_vaccinations) AS TotalVaccinations, max(dea.total_deaths) AS TotalDeaths
from coviddeaths dea join covidvaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
group by dea.location, dea.population,vac.cardiovasc_death_rate
ORDER by 6 desc;

-- Aþýlanan kiþi sayýsý ile Ýnsani Geliþim Endeksi arasýndaki iliþkiyi incelemek için bir sorgu:
Ýnsani Geliþim Endeksi (ÝGE), Birleþmiþ Milletler Kalkýnma Programý (UNDP) tarafýndan her yýl yayýnlanan bir endekstir.
ÝGE, ülkelerin sadece ekonomik büyüme ile deðil, ayný zamanda insanlarýn yaþam kalitesi, saðlýk, eðitim ve gelir düzeyi 
gibi faktörler açýsýndan da nasýl bir geliþme gösterdiðini ölçer. ÝGE, ülkelerin insan geliþimi açýsýndan sýralamasýný
belirler ve dünya genelindeki eþitsizlikleri gösterir.
--gdp_per_capita: Kiþi baþýna düþen gayri safi yurtiçi hasýlayý ifade eder.
--extreme_poverty: Aþýrý yoksulluk oranýný gösterir.
--handwashing_facilities: Ellerini yýkama imkanlarýný ifade eder.


SELECT dea.location,dea.population, dea.extreme_povert,dea.gdp_per_capita,max(handwashing_facilities),MAX(dea.people_vaccinated) AS MaxPeopleVaccinated,
MAX(pp.RollingPeopleVaccinated / pp.population)  as vaccinatedrate, AVG(dea.human_development_index) AS AverageHDI
FROM CovidDeaths dea  JOIN PercentPopulationVaccinated pp
on dea.location = pp.location 
and dea.date=pp.date
where dea.location like 'world' and dea.continent is not null
GROUP BY dea.location,dea.population,dea.extreme_poverty,dea.gdp_per_capita
ORDER BY 4 DESC;

--stringency_index: Ülkenin pandemi kýsýtlamalarýnýn sýkýlýðýný temsil eden bir endeks.

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
