-- View all Covid mortality info
select * 
from dbo.CovidDeaths
order by 3,4

-- View all Covid vaccination info
select * 
from dbo.CovidVaccinations
order by 3,4



-- Root fields for mortality queries
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1, 2



-- Total cases vs total deaths
-- Shows percentage of mortality, number of deaths divided by number of cases
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--and location = 'United States'
order by 1, 2



-- Total cases vs population
-- Shows percentage of population that contracted Covid
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--and location = 'United States'
order by 1, 2



-- Highest infection count
-- Shows ountries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population)*100) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
--and location = 'United States'
group by location, population
order by PercentPopulationInfected desc



-- Highest mortality count by location
-- Shows countries with the highest mortality count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
--and location = 'United States'
group by location
order by TotalDeathCount desc



-- Highest mortality count by continent
-- Shows continents with the highest mortality count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global numbers by date
-- Shows worldwide mortality counts by date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1, 2

-- Global numbers by total
-- Shows worldwide mortality total counts
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1, 2



-- Total population vs vaccinations
-- Shows locations vaccination counts with rolling total as vaccinations increase
with PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select *, (RollingPeopleVaccinated/population) * 100 from PopulationVsVaccination 
order by 2, 3
