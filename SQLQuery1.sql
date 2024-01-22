--select * from PortofolioProject..CovidDeaths 
--order by 3,4

--select * from PortofolioProject..CovidVaccinations
--order by 3,4

select location,date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2


-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
--order by 1,2


-- Total cases in Asia from highest to lowest
select location, MAX(total_cases ) as TotalCases
from PortofolioProject..CovidDeaths
where continent = 'asia'
group by location
order by TotalCases desc


-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where total_cases IS NOT NULL AND total_deaths IS NOT NULL AND location like '%indonesia%' 
--where location like '%states%'
order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortofolioProject..CovidDeaths
where total_cases IS NOT NULL AND total_deaths IS NOT NULL AND location like '%indonesia%' 
--where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
from PortofolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by InfectionPercentage desc


-- Showing countries with Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
order by 1,2


----Looking at total population vs Vaccinations
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--from PortofolioProject..CovidDeaths dea
--JOIN PortofolioProject..CovidVaccinations vac
-- ON dea.location = vac.location
-- AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3



--Looking at total population vs Vaccinations
With PopvsCac(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population) * 100
from PopvsCac


-- With Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
--where dea.continent is not null 


select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
where dea.continent is not null 