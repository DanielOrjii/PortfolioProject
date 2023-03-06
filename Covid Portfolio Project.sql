SELECT *
FROM CovidDeaths cd 
WHERE population 
Order by population DESC 

/*SELECT *
FROM CovidVaccinations cv 
Order by 3,4*/

/*Select cd.continent, cd.population, cv.total_vaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
on cd.iso_code=cv.iso_code ;*/

SELECT location , date, total_cases, new_cases, total_deaths, population  
FROM CovidDeaths cd 
Order by 1,2

-- Total Cases vs Total Deaths
--Shoows likelihood of dying if you contract covid in yoour country
SELECT location, date, total_cases, total_deaths, (CAST (total_deaths as float)/CAST (total_cases as float))*100 as DeathPercent
FROM CovidDeaths cd 
WHERE location like '%states%'
Order by 1;


--Looking at Total cases vs Population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases, (CAST (total_cases as float)/CAST (population as float))*100 as CovidPercent
FROM CovidDeaths cd 
---WHERE location like '%states%'
Order by 1;

--Looking at Countries with Highest Infection Rate compared Population

SELECT location, population,Max(total_cases) as HighestInfected, MAX((CAST (total_cases as float)/CAST (population as float)))*100 as HighestInfectedPercent
FROM CovidDeaths cd 
WHERE total_cases 
GROUP by location,population 
Order by HighestInfectedPercent DESC;


--Showing Countries with Highest Death Count per Population

SELECT location, population, Max(total_deaths) as HighestDeath, MAX((CAST (total_deaths as float)/CAST (population as float)))*100 as HighestDeathPercent
FROM CovidDeaths cd 
WHERE total_deaths and continent <> ''
GROUP by location, population 
Order by  HighestDeath DESC;


--Lets Break Things down by continent
--Showing continents with the highest death count per population 

SELECT continent, Max(total_deaths) as TotalDeathCount
FROM CovidDeaths cd 
WHERE total_deaths and continent <> ''
GROUP by continent 
Order by  TotalDeathCount DESC;

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (CAST (SUM(new_deaths) as float)/CAST (SUM(new_cases) as float))*100 as DeathPercent
FROM CovidDeaths cd 
--WHERE location like '%states%'
WHERE continent <>''
GROUP BY date 
Order by 1 ;

--Looking at Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) over (PARTITION By cd.location ORDER By cd.location, cd.date) as RollingPeopleVaccine
--(RollingPeopleVaccine/population)*100
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location 
AND cd.date = cv.date 
where cd.continent <> '' AND cv.new_vaccinations 
order by 2,3;

--To find the percentage of people that got vaccinated
--Using Cte
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccine) as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) over (PARTITION By cd.location ORDER By cd.location, cd.date) as RollingPeopleVaccine
--(RollingPeopleVaccine/population)*100
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location 
AND cd.date = cv.date 
where cd.continent <> '' AND cv.new_vaccinations 
--order by 2,3
)
SELECT continent, location, population, new_vaccinations, RollingPeopleVaccine, MAX((CAST (RollingPeopleVaccine as float)/cast (population as float))*100) as TotalPercentVaccinated
FROM PopvsVac
Group By location 

--Temp TABLE 

Drop Table if exists PercentPopVaccinated
Create Temporary Table PercentPopVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccine numeric
)
Insert into PercentPopVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) over (PARTITION By cd.location ORDER By cd.location, cd.date) as RollingPeopleVaccine
--(RollingPeopleVaccine/population)*100
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location 
AND cd.date = cv.date 
where cd.continent <> '' --AND cv.new_vaccinations 
--order by 2,3

SELECT *, (CAST (RollingPeopleVaccine as float)/cast (population as float))*100 as TotalPercentVaccinated
FROM PercentPopVaccinated
--Group By location 

--Creating views to store data for later visualization
Create view PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) over (PARTITION By cd.location ORDER By cd.location, cd.date) as RollingPeopleVaccine
--(RollingPeopleVaccine/population)*100
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location 
AND cd.date = cv.date 
where cd.continent <> '' --AND cv.new_vaccinations 
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated 
