/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select *
From CovidDeaths
Where continent is not null
Order by 3,4

	

-- Select Data that we will be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2

	

-- Look at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in the United Kingdom

Select location, date, total_cases, total_deaths, (Convert(float,total_deaths)/Convert(float,total_cases))*100 as DeathPercentage
From CovidDeaths
where location like '%Kingdom%'
and continent is not null
Order by 1,2

	

-- Look at Total Cases vs Population 
-- Shows what percentage of UK population got COVID

Select location, date, total_cases, population, (Convert(float,total_cases)/population)*100 as PercentPopulationInfected
From CovidDeaths
where location like '%Kingdom%'
and continent is not null
Order by 1,2

	

-- Look at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((Convert(float,total_cases)/population))*100 as PercentPopulationInfected
From CovidDeaths
--where location like '%Kingdom%'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

	

-- Look at Countries with highest death count per population

Select location, MAX(Convert(float,total_deaths)) as TotalDeathCount
From CovidDeaths
--where location like '%Kingdom%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

	

-- Look at Continents with highest death count per population 

Select location, MAX(Convert(float,total_deaths)) as TotalDeathCount
From CovidDeaths
--where location like '%Kingdom%'
Where continent is null
and location not like '%income%'
Group by location 
Order by TotalDeathCount desc

	

-- Look at Global death percentage

Select date, SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths ,(SUM(new_deaths)/ NULLIF(SUM(new_cases),0)) *100 as DeathPercentage
From CovidDeaths
where continent is not null
Group by date
Order by 1,2

	

-- Look at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3 

	

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac


	
-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


	
--Creating view for to store data for later visualisation

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
