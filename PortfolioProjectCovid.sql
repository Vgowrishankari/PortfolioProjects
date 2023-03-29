--PORTFOLIO PROJECT SQL QUERIES
--COVID_DEATHS
--COVID_VACCINATIONS

select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4


select location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Total cases Vs Total deaths in percentage in United States

select location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Total cases Vs Population
--Shows what percentage of population got Covid

select location,
	   date,
	   total_cases,
	   population,
	   (total_cases/population)*100 as TotalCovidCasePercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

select location,
	   max(total_cases) as TotalCases,
	   population,
	  max( (total_cases)/population)*100 as TotalCovidCasePercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location,population
order by 4 desc

--Showing Countries with Highest Death Count per Population 

select location,
	   max(cast(total_deaths as bigint)) as TotalDeathcount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by 2 desc

--Let's Break things down by Continent
--Showing continents with the highest death count per population

select continent,
	   max(cast(total_deaths as bigint)) as TotalDeathcount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global Numbers

select sum(new_cases) as Total_New_Cases,
	   sum(cast(new_deaths as bigint)) as Total_New_deaths,
	   sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercent
from PortfolioProject.dbo.CovidDeaths
where continent is not null

--CTE
--Total Population Vs Total Vaccination
with CTE_Vaccination (continent,location,date,population,newVaccination,RollingCountOfPeopleVaccinated)
as
(
select cd.continent,
	   cd.location,
	   cd.date,
	   cd.population ,
	   cv.new_vaccinations,
	   sum(convert(bigint,cv.new_vaccinations)) over(partition by cd.location
									 order by cd.location,cd.date) as RollingCountOfPeopleVaccinated
  from PortfolioProject.dbo.CovidDeaths CD
  join PortfolioProject.dbo.CovidVaccinations CV
  on cd.location=cv.location
 and cd.date=cv.date
 where cd.continent is not null
 --order by 2,3 
 )
 select *,
		(RollingCountOfPeopleVaccinated/population)*100 as TotalVaccinatedPeoplePercentage
 from CTE_Vaccination

--Temp Table
--Total Population Vs Total Vaccination

drop table if exists #temp_PopulationVsVaccinated
create table #temp_PopulationVsVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfPeopleVaccinated numeric
)

insert into #temp_PopulationVsVaccinated
select cd.continent,
	   cd.location,
	   cd.date,
	   cd.population ,
	   cv.new_vaccinations,
	   sum(convert(bigint,cv.new_vaccinations)) over(partition by cd.location
									 order by cd.location,cd.date) as RollingCountOfPeopleVaccinated
  from PortfolioProject.dbo.CovidDeaths CD
  join PortfolioProject.dbo.CovidVaccinations CV
  on cd.location=cv.location
 and cd.date=cv.date
 where cd.continent is not null
	
select * from #temp_PopulationVsVaccinated

select *,
		(RollingCountOfPeopleVaccinated/population)*100 as TotalVaccinatedPeoplePercentage
 from #temp_PopulationVsVaccinated

--Creating View to store data for later Visualizations

CREATE OR ALTER VIEW PopulationVsVaccinated as
select cd.continent,
	   cd.location,
	   cd.date,
	   cd.population ,
	   cv.new_vaccinations,
	   sum(convert(bigint,cv.new_vaccinations)) over(partition by cd.location
									 order by cd.location,cd.date) as RollingCountOfPeopleVaccinated
  from PortfolioProject.dbo.CovidDeaths CD
  join PortfolioProject.dbo.CovidVaccinations CV
  on cd.location=cv.location
 and cd.date=cv.date
 where cd.continent is not null