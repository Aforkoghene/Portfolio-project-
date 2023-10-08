SELECT*
FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
ORDER BY 1,2

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
ORDER BY 1,2

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

SELECT location,MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT location,MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'France'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


WITH PopvsVac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated) 
AS
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations))OVER(partition by Dea.location,Dea.date)AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location=Vac.location
and Dea.date=Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3
)
SELECT*,(Rollingpeoplevaccinated/population)*100
FROM PopvsVac



DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #Percentpopulationvaccinated
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations))OVER(partition by Dea.location,Dea.date)AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location=Vac.location
and Dea.date=Vac.date
--WHERE Dea.continent is not null
--ORDER BY 2,3

SELECT*,(Rollingpeoplevaccinated/population)*100
FROM #Percentpopulationvaccinated


--Create View


CREATE VIEW Percentpopulationvaccinated AS 
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(INT,Vac.new_vaccinations))OVER(partition by Dea.location,Dea.date)AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location=Vac.location
and Dea.date=Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3


SELECT*
FROM [dbo].[Percentpopulationvaccinated]
