--select* from projectportfolio..CovidDeaths$
--order by 3, 4

--select* from projectportfolio..['Covid vaccination$']
----order by 3, 4

--selecting the needed data
select location, date, total_cases, new_cases, total_deaths, population 
from projectportfolio..CovidDeaths$
where continent is not null
order by 1,2

--finding total cases vs total deaths to show the probability of death as a result of covid infection in a given location

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_in_percentage
from projectportfolio..CovidDeaths$
where location like '%germany%' and continent is not null
order by 1,2

-- total cases vs the population to show the total percentage of population who has contracted covid

select location, date,population, total_cases, (total_cases/population)*100 as percentage_infection_per_population
from projectportfolio..CovidDeaths$
where location like '%germany%' and continent is not null
order by 1,2

--to see the countries with highest infection rates compared to population

select location,population, MAX(total_cases) as  highest_infection_rates, MAX((total_cases/population))*100 as percentage_infection_per_population
from projectportfolio..CovidDeaths$
where continent is not null
group by population, location
order by percentage_infection_per_population desc

-- to see the countries with the highest death rates from covid infections per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from projectportfolio..CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

--exploration of the data by continent per population (total death count)

select continent, MAX(cast(total_deaths as int)) as total_death_count
from projectportfolio..CovidDeaths$
where continent is not null
group by continent
order by total_death_count desc

--global numbers (total death, cases, and death percentage accross the world)

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage --total_deaths, (total_deaths/total_cases)*100 as death_in_percentage
from projectportfolio..CovidDeaths$
--where location like '%germany%' 
where continent is not null
--group by date
order by 1,2

--joining the two needed tables (covid vaccination table on covid death table)

select* from projectportfolio..CovidDeaths$ dea
join projectportfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date= vac.date
order by 1,2

--looking at the total population vs vaccination (total vaccinated individuals)
--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingvaccinated
--, (rollingvaccinated/dea.population) * 100
from projectportfolio..CovidDeaths$ dea
join projectportfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

select*,(rollingvaccinated/population)*100
from popvsvac




--TEMPORARY TABLE (INCASE IF NEED BE FOR ALTERATIONS)

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingvaccinated
--, (rollingvaccinated/dea.population) * 100
from projectportfolio..CovidDeaths$ dea
join projectportfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
select*,(rollingvaccinated/population)*100
from #PercentagePopulationVaccinated

--Creating views for subsequent data visualisation

create view PercentagePopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingvaccinated
--, (rollingvaccinated/dea.population) * 100
from projectportfolio..CovidDeaths$ dea
join projectportfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
