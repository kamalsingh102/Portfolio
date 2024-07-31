Select *
From Portfolio..CovidDeaths
Where continent is not null 
order by 3,4;


Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null 
order by 1,2;

--total cases vs total deaths
-- chances of dying from covid
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths / total_cases) * 100 AS death_percent
FROM
    Portfolio..CovidDeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2;


alter table Portfolio..CovidDeaths
alter column population float;


-- total cases vs population

select location, date, population, total_cases, (total_cases/population) *100 as case_percent
from portfolio..CovidDeaths
where location = 'India'
order by 1,2;


select location, population,
max(total_cases) as highest_infection_count ,
max((total_cases/population) *100) as percent_population_affected
from portfolio..CovidDeaths
--where location = 'India'
group by location, population
order by percent_population_affected desc;


-- countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc;

-- breaking by continent

select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;

select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolio..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc;


--global numbers
Select date, SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
Group By date
having SUM(New_Cases) != 0
order by 1,2; -- daily deaths and cases across the world

Select  SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
--Group By date
order by 1,2; -- total deaths abd cases across the world


-- total populations vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio..coviddeaths dea
join portfolio..covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

alter table portfolio..covidvaccinations
alter column new_vaccinations int

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    --, (RollingPeopleVaccinated/population)*100
FROM 
    Portfolio..CovidDeaths dea
JOIN 
    Portfolio..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3;


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--creating temp table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
