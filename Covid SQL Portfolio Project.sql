Select Location , Date, total_cases, new_cases, total_deaths, population
from MyPortfolioProj3ct..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select Location , Date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from MyPortfolioProj3ct..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at the total_cases vs Population
-- Shows what percentage got COVID

Select Location , Date, total_cases, Population ,(total_cases/population)*100 as PercentpopulationInfected
from MyPortfolioProj3ct..CovidDeaths$
Where continent is not null
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location , population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentpopulationInfected
from MyPortfolioProj3ct..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group By Location,Population
order by PercentpopulationInfected desc

-- Showing the countries with the highest death count per population

Select Location , Max(cast(total_deaths as int)) as TotalDeathCount
from MyPortfolioProj3ct..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group By Location
order by TotalDeathCount desc 

-- Looking at Total cases vs Population
-- SHows what percentage of population got covid

Select Location , date,population,(total_cases/population)*100 as Percentpopupulationinfected
from MyPortfolioProj3ct..CovidDeaths$
where location like '%states%'
order by 1, 2 

-- Lets BREAK THINGS DOWN BY CONTINENT


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from MyPortfolioProj3ct..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group By continent 
order by TotalDeathCount desc  

--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from MyPortfolioProj3ct..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc 

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from MyPortfolioProj3ct..CovidDeaths$
--where location like '%states%'
Where continent is not null
--group by date 
order by 1,2

--Vacinations join Deaths
-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated

from MyPortfolioProj3ct..CovidDeaths$ dea
JOIN MyPortfolioProj3ct..CovidVaccinations$ vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- Use CTE
with PopvsVac (continent, location,date, population,New_vaccinations, RollingPeopleVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from MyPortfolioProj3ct..CovidDeaths$ dea
JOIN MyPortfolioProj3ct..CovidVaccinations$ vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *
from PopvsVac 

-- TEMP TABLE 
DROP Table if exists #PercentpopulationVaccinated 
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from MyPortfolioProj3ct..CovidDeaths$ dea
JOIN MyPortfolioProj3ct..CovidVaccinations$ vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating Views to store later

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from MyPortfolioProj3ct..CovidDeaths$ dea
JOIN MyPortfolioProj3ct..CovidVaccinations$ vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated