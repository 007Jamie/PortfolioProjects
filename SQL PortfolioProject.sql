SELECT *
FROM CovidVaccinations
WHERE continent is not null 


SELECT *
FROM CovidDeaths
ORDER BY 3, 4

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM CovidDeaths
where continent is not null
ORDER BY 1, 2

--Looking at Death Percentage per Case
-- Shows the probability of dying if covid is contracted, filter by location
-- Using the where clause to show ony figures for Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
and continent is not null
ORDER BY 1, 2

--Looking at Case Percentage Per population
-- Shows the percentage of the population that has contracted covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
 WHERE continent is not null
ORDER BY 1, 2

--Looking at Highest Infection Rate Per Population

SELECT location, population, MAX(total_cases)  InfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%Nigeria%' 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing DeathCount
--Using the 'where' clause here to  filter out statistics for continents

SELECT Location, MAX(cast(total_deaths as int ))  TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Death Count by continent
 --Showing numbers on a global scale

SELECT location, MAX(cast(total_deaths as int ))  TotalDeathCount
FROM CovidDeaths
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC
 
 --Showing  Global Death Percentage by the day
  
  SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100
  as DeathPercentage
  FROM CovidDeaths
  WHERE continent is not null
  GROUP BY date
  ORDER BY 1, 2

  --Showing Global Death Percentage
  SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100
  as DeathPercentage
  FROM CovidDeaths
  WHERE continent is not null
 -- GROUP BY date
  ORDER BY 1, 2


-- Showing a join on both tables
SELECT *
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.Date
   
   --Showing Total Population against Total Vaccination

 SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_Vaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.Date
 WHERE Dea.continent is not null
 ORDER BY 2, 3

  --Showing Total Population against Total Vaccination

 SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_Vaccinations,
 SUM(CAST( new_Vaccinations as int)) 
 OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.Date
 WHERE Dea.continent is not null
 ORDER BY 2, 3


 --Looking at the percentage of world population that got vaccinated, using CTE

 WITH POPvsVAC (continent, location,date, population, new_vaccination, RollingVaccinations)
 as
(
 SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_Vaccinations
 ,SUM(CAST( new_Vaccinations as int)) 
 OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.date
 WHERE Dea.continent is not null
 )

 SELECT continent,location population, new_vaccination, RollingVaccinations ,MAX((RollingVaccinations/population)) as VaccinationPercentage
FROM POPvsVAC
GROUP BY continent, location, population,  new_vaccination, RollingVaccinations 



 --Creating a Temp Table with the above values
 DROP  TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar (255),
 date datetime,
 population int,
   new_Vaccinations int,
   RollingVaccinations int

)
  insert into #PercentPopulationVaccinated
 SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_Vaccinations
 ,SUM(CAST( Vac.new_Vaccinations as int)) 
 OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.date
 WHERE Dea.continent is not null


 SELECT *,(RollingVaccinations/population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisation
 
 CREATE VIEW PercentPopulationVaccinated as
  SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_Vaccinations
 ,SUM(CAST( Vac.new_Vaccinations as int)) 
 OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
 ON Dea.location = Vac.location
 AND Dea.date = Vac.date
 WHERE Dea.continent is not null