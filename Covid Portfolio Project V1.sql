--The Tableau viz can be viewed here: https://tinyurl.com/2evcz32c

SELECT *
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project 01]..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Selecting data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths
--Likeihood of death if contracted

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage_vs_Total_Cases
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Population Canada
--Percentage of covid contractions in Canada

SELECT location, date, population, total_cases, (total_cases/population)*100 as Cases_vs_Population
FROM [Portfolio Project 01]..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2

--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/Population))*100 as Percent_of_Population_Infected
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Percent_of_Population_Infected desc

--Countries with highest death count compared to population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count 
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc

--BREAKING CASES DOWN BY CONTINENT
--Continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count 
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

--Global new cases vs deaths

SELECT SUM(new_cases) as New_Cases, SUM(cast(new_deaths as int)) as New_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deaths_Percentage
FROM [Portfolio Project 01]..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM [Portfolio Project 01]..CovidDeaths dea
JOIN [Portfolio Project 01]..CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
	WHERE dea.continent is not null
ORDER BY 2,3

--use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM [Portfolio Project 01]..CovidDeaths dea
JOIN [Portfolio Project 01]..CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
	WHERE dea.continent is not null)

SELECT *, (rolling_people_vaccinated/population)*100 as percentage_of_people_vaccinated
FROM PopVsVac

--Temptable

DROP TABLE IF exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations bigint, rolling_people_vaccinated numeric)
INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM [Portfolio Project 01]..CovidDeaths dea
JOIN [Portfolio Project 01]..CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100 as percentage_of_people_vaccinated
FROM #Percent_Population_Vaccinated

--Creating view to store data for later visualization

CREATE VIEW Percent_Population_Vaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM [Portfolio Project 01]..CovidDeaths dea
JOIN [Portfolio Project 01]..CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM Percent_Population_Vaccinated


/*

Queries used for Tableau Project

*/



--Creating table for 'Global Numbers' to be pasted into Excel then imported into Tableau

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project 01]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Creating table for 'Death Count Per Continent' to be pasted into Excel then imported into Tableau

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project 01]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Creating table for 'Highest Infection Count and Percentage Per Country' to be pasted into Excel then imported into Tableau

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project 01]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Creating table for 'Infection Count and Percentage Per Country Per Day' to be pasted into Excel then imported into Tableau

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project 01]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
