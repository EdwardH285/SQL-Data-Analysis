-- Select Data that will be used

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid-19 in the UK

SELECT Location, Date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM CovidDeaths
WHERE Location like '%Kingdom%'
and Continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19

SELECT Location, Date, Population, total_cases, (cast(total_cases as float)/cast(Population as float))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE Location like '%Kingdom%'
and Continent is not NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(cast(total_cases as int)) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE Location like '%Kingdom%'
WHERE Continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
 
-- Total Death Count by Continent

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Showing Continents with the Highest Death Count per Population

SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT Date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST
  (New_deaths as int))/NULLIF (SUM(New_cases),0)*100 as DeathPercentage
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not NULL
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Creating View to store data for later visualisations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated