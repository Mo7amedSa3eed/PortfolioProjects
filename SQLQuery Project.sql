select *
from PortfolioProject..CovidDeaths$
where continent is not null


-- Select Data that we are going to be starting with
select location,date,population,new_cases,total_cases,new_deaths,total_deaths
from PortfolioProject.dbo.CovidDeaths$
--where location like 'egypt' 
where continent is not null



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
--where location like '%Egypt%'
where continent is not null
order by DeathPercentage desc


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location,date,population,total_cases,(total_cases/population)*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths$
--where location like '%Egypt%'
where continent is not null
order by CasePercentage desc


-- Countries with Highest Infection Rate compared to Population
select location,population,MAX(total_cases) as AllCases,(MAX(total_cases)/population)*100 as MaxCasePercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like 'egypt'
group by location,population
order by MaxCasePercentage desc


-- Countries with Highest Death Rate compared to Population
select location,population,MAX(cast (total_deaths as int)) as AllDeaths,(MAX(cast(total_deaths as int))/population)*100 as MaxDeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like 'egypt'
group by location,population
order by MaxDeathPercentage desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
select continent,max(cast(total_deaths as int)) as AllDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by AllDeaths desc


-- GLOBAL NUMBERS
select sum(new_cases) as AllCases,sum(cast(new_deaths as int)) as AllDeaths
	, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select Death.location,Death.date,Death.population,Vacc.new_vaccinations
	,SUM(CONVERT(int,Vacc.new_vaccinations)) over (partition by death.location order by Death.location , Death.date) as AllNewVacc
	,(SUM(CONVERT(int,Vacc.new_vaccinations)) over (partition by death.location order by Death.location , Death.date)/Death.population)*100 as AllVaccPercentage
from PortfolioProject..CovidDeaths$ as Death inner join PortfolioProject..CovidVaccinations$ as Vacc 
	on Death.date = Vacc.date and Death.location = Vacc.location
where Death.continent is not null
order by 1,2 asc


-- Using CTE to perform Calculation on Partition By in previous query
with CTE_PopVsVacc (location,date,population,new_vaccinations,AllNewVacc)
as
(
select Death.location,Death.date,Death.population,Vacc.new_vaccinations
	,sum(convert(int,Vacc.new_vaccinations)) over(partition by Death.location order by death.location , death.date ) as AllNewVacc
from PortfolioProject..CovidDeaths$ as Death inner join PortfolioProject..CovidVaccinations$ as Vacc 
	on Death.date = Vacc.date and Death.location = Vacc.location
where Death.continent is not null
)

select *,(AllNewVacc/population)*100 as AllVaccPercentage
from CTE_PopVsVacc
order by 1,2


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PopVsVacc
create table #PopVsVacc
(location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
AllNewVacc numeric,
)
insert into #PopVsVacc
select Death.location,Death.date,Death.population,Vacc.new_vaccinations
	,sum(convert(int,Vacc.new_vaccinations)) over(partition by Death.location order by death.location , death.date ) as AllNewVacc
from PortfolioProject..CovidDeaths$ as Death inner join PortfolioProject..CovidVaccinations$ as Vacc 
	on Death.date = Vacc.date and Death.location = Vacc.location
where Death.continent is not null

select *,(AllNewVacc/population)*100 as AllVaccPercentage
from #PopVsVacc
order by 1,2


-- Creating View to store data for later visualizations
create view PopVsVacc as
select Death.continent, Death.location,Death.date,Death.population,Vacc.new_vaccinations
	,SUM(CONVERT(int,Vacc.new_vaccinations)) over (partition by death.location order by Death.location , Death.date) as AllNewVacc
	,(SUM(CONVERT(int,Vacc.new_vaccinations)) over (partition by death.location order by Death.location , Death.date)/Death.population)*100 as AllVaccPercentage
from PortfolioProject..CovidDeaths$ as Death inner join PortfolioProject..CovidVaccinations$ as Vacc 
	on Death.date = Vacc.date and Death.location = Vacc.location
where Death.continent is not null
--order by 1,2 asc

select *
from PopVsVacc
