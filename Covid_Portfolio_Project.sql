select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- looking at total cases vs total deaths
-- likelyhood of dying from covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at total cases vs population
-- show percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as OddsPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compaired to population
select location, population, max(total_cases) as HighestInfection, max((total_cases/population))*100 as PercentPopulation
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulation desc


-- countries with higherst death count per capita
select location, max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Break it down by continent
select location, max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- showing the continents with the highest death count
select continent, max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations

--use CTE
with PopvsVac (continent, location, date, population, new_vacinations, RollingPeopleVax)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVax --breaks it up by location
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVax /population)*100
from PopvsVac


--Temp Table
drop table if exists #PercentPopulationVac
create table #PercentPopulationVac
(
	continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vacinations numeric,
	RollingPeopleVax numeric
)

Insert into #PercentPopulationVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVax --breaks it up by location
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVax /population)*100
from #PercentPopulationVac

--create the view to store data for later visualizations
create view PercentPopulationVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVax --breaks it up by location
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


