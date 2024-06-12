select *
from project2..CovidDeaths
where continent is not null
order by 3,4

--select *
--from project2..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from project2..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from project2..CovidDeaths
where location like '%indonesia%'
	and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from project2..CovidDeaths
where location like '%indonesia%'
	and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infection, 
		MAX((total_cases/population))*100 as infection_percentage
from project2..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location, population
order by infection_percentage desc


-- Showing the countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as total_death_count
from project2..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by total_death_count desc



----- BREAK THINGS DOWN BY CONTINENT -----

-- Showing continent with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as total_death_count
from project2..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by total_death_count desc


-----  GLOBAL NUMBERS -----

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from project2..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2


-- Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated,
	--(rolling_people_vaccinated/population)*100
from project2..CovidDeaths dea
join project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	--,(rolling_people_vaccinated/population)*100
from project2..CovidDeaths dea
join project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (rolling_people_vaccinated/population)*100
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	rolling_people_vaccinated numeric
)
insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	--,(rolling_people_vaccinated/population)*100
from project2..CovidDeaths dea
join project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated



-- Creating view to store data for later visualizations
create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as rolling_people_vaccinated
	--,(rolling_people_vaccinated/population)*100
from project2..CovidDeaths dea
join project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPeopleVaccinated