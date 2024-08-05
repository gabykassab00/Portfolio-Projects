SELECT *
FROM PortfolioProject..covidDeath 
WHERE continent is not null
ORDER BY 3,4
SELECT * 
FROM PortfolioProject..covidvaccination
ORDER BY 3,4

--SELECT DATA THAT WE GOING TO BE USING 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeath
ORDER BY 1,2

--looking at total cases vs total deaths 
--shows likelihood of dying if you contract covid in your country 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..coviddeath
WHERE location like '%states'
ORDER BY 1,2

--looking at total cases vs population 
--shows what percentage of population got covid 
SELECT location,date,total_cases,(total_cases/population)*100 ,population
FROM PortfolioProject..coviddeath
WHERE location like '%states'
ORDER BY 1,2

--looking at countries with highetsv infection rate compared to population 

SELECT location,population,MAX(total_cases) as highestinfection,max((total_cases/population))*100 as 
percentpopulationinfected
FROM PortfolioProject..coviddeath
GROUP BY location , population
ORDER BY percentpopulationinfected desc


--showing countries with highest death count per population 

SELECT location,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..coviddeath
where continent is not null
GROUP BY location 
ORDER BY totaldeathcount desc


--lets break things down by continent 


SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..coviddeath
where continent is not null
GROUP BY continent 
ORDER BY totaldeathcount desc


--global numbers 

SELECT SUM(new_cases),SUM(cast(new_deaths as int )),SUM(new_deaths)/SUM(new_cases)*100 as deathpercent
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
where continent is not null 
--group by date 
ORDER BY 1,2

--looking at total population vs vaccination 
SELECT DEA.continent,DEA.date,DEA.location,DEA.location,VAC.new_vaccinations
,SUM(CAST(VAC.new_vaccinations as int )) OVER (partition by DEA.location ORDER BY DEA.location,DEA.Date)  as rollingpeoplevaccinated 
FROM PortfolioProject..covidDeath DEA 
JOIN  PortfolioProject..covidvaccination VAC 
ON  DEA.location = VAC.location 
AND DEA.date =VAC.date
where DEA.continent is not null
ORDER BY 1,2,3

--use cte 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--temp table 

DROP TABLE IF EXISTS #percentPopulcationvaccinated
CREATE TABLE #percentpopulationvaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime , 
population numeric ,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #percentpopulationvaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #percentpopulationvaccinated



-- creating view to store data for later visualizations

create view percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.. covidDeath dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT*
FROM percentpopulationvaccinated
