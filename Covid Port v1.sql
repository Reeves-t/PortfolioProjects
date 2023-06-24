Select *
From dbo.CovidDeaths 
Where continent is not null 
order by 3,4

Select *
From dbo.CovidVaccinations 

--Select Data that we are going to be using 

Select  Location, date, total_cases, new_cases, total_deaths, population 
From dbo.CovidDeaths 
Where continent is not null 
order by 1,2 


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths 
Where location like '%states%'
order by 1,2 


-- Looking at Total Cases Vs Population 
-- Shows what percentage of population got covid 


Select  Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths 
Where continent is not null 
--Where location like '%states%'
order by 1,2 


-- Looking at Countries with Highest Infection Rate compared to Population 


Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths 
Where continent is not null 
--Where location like '%states%'
Group by Location, population 
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths 
Where continent is not null 
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths 
Where continent is not null 
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc



-- GlOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int))--, SUM(cast(new_cases as int)) / SUM (new_deaths)*100 as DeathPercentage
--Where location like '%states%'
From dbo.CovidDeaths
where continent is not null
Group By date
order by 1,2 


SELECT
  date,
  SUM(new_cases) AS TotalNewCases,
  SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
  SUM(CAST(new_deaths AS int)) / ABS(SUM(COALESCE(new_cases, 0))) * 100 AS DeathPercentage
FROM
  dbo.CovidDeaths
WHERE
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  date, TotalNewCases;


  Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/ABS(SUM(COALESCE(new_cases, 0))) * 100 as DeathPercentage
From dbo.CovidDeaths 
--Where location like '%states%'
Group by date
order by 1,2 

SELECT
  SUM(new_cases) AS TotalNewCases,
  SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN 0 -- Handling division by zero when new_cases is 0
	 WHEN SUM(new_deaths) = 0 THEN 0 -- Handling division by zero when new_deaths is 0
    ELSE SUM(CAST(new_deaths AS int)) / ABS(SUM(new_cases)) * 100
  END AS DeathPercentage
FROM dbo.CovidDeaths
WHERE
  continent IS NOT NULL
--GROUP BY date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date)  as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac. location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visulizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date)  as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated