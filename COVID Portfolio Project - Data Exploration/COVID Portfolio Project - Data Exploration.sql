SELECT *
FROM "Portfolio Project"..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM "PortfolioProject"..CovidVaccinations
--order by 3,4

--SELECT Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population 
From "Portfolio Project"..CovidDeaths 
Where continent is not null
order by 1,2


--Looking at Total cases vs Total Deaths 
--Shiows likelihood of dying if you contarct in your country 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From "Portfolio Project"..CovidDeaths 
Where location  like '%states%'
and continent is not null
order by 1,2

-- we take these out as they are not included in the above queries and want to stay consistent 
-- European union is part of Europe 
--2

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM "Portfolio Project"..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;
 


--Looking at Total cases vs Populations 
--Shiows Percentage of Population got Covid

Select Location, date, Population, (total_deaths/population)*100 as PercentPopulationInfected  
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
--3

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/population)*100 as PercentPopulationInfected 
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast( Total_deaths as int)) as TotalDeathCount
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's breake things down by continent 

--Sowing cotintents with Highest Death per population 

Select continent, MAX(cast( Total_deaths as int)) as TotalDeathCount
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (New_Cases)*100 as DeathPercentage
From "Portfolio Project"..CovidDeaths 
--Where location  like '%states%'
Where continent is not null
--Group by date 
order by 1,2



--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPepoleVaccinated 
--, (RollingPepoleVaccinated/Population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3 
 
 --USE CTE 

with Popvsvac (continent, Location, Date, Population, new_vaccinations, RollingPepoleVaccinated) 
 as 
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPepoleVaccinated 
--, (RollingPepoleVaccinated/Population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPepoleVaccinated/Population)*100
From Popvsvac


--TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPepoleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPepoleVaccinated 
--, (RollingPepoleVaccinated/Population)*100
From "Portfolio Project"..CovidDeaths dea
Join "Portfolio Project"..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3 

Select *, (RollingPepoleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Drop the view if it exists
DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO

-- Recreate the view
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM "Portfolio Project"..CovidDeaths dea
JOIN "Portfolio Project"..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;