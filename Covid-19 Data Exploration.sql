

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4


--Select some data

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
SELECT location, date,total_deaths, total_cases, (total_cases/total_deaths)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Africa'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Africa'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Africa'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Africa' 
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null 
order by 2,3

---using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(decimal, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

---OR
---USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths Dea
Join CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
--where Dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(decimal, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3


