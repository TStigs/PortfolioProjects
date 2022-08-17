
SELECT *
FROM coviddeaths
WHERE continent != ''
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent != ''
ORDER BY 1,2;


-- Total cases vs Total deaths 
-- The death rate from covid in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location LIKE 'Canada' and continent != ''
ORDER BY 1,2;

-- Total cases vs population
-- Percentage of people that contracted Covid in countries by date
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
ORDER BY 1,2;

-- Countries with Highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Countries with highest death count vs population NEED TO FIX
-- SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS TotalDeathPercentage
-- WHERE continent != ''
-- ORDER BY TotalDeathCount desc;

-- By continent

-- Continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeathCount
FROM coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global Numbers

-- Global Death Percentage (total cases/total deaths) by day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as UNSIGNED)) AS total_deaths, 
SUM(CAST(new_deaths AS UNSIGNED))/(SUM(new_cases))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent != ''
GROUP BY date
ORDER BY 1,2;

-- Global Death Percentage (total cases/total deaths) at end
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as UNSIGNED)) AS total_deaths, 
SUM(CAST(new_deaths AS UNSIGNED))/(SUM(new_cases))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent != ''
ORDER BY 1,2;

-- vaccinations
SELECT * 
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date;

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 1,2,3;

-- Total Population vs Vaccinations w/ rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3;

-- USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaxed
FROM PopVsVac;

-- USE Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int, 
RollingPeopleVaccinated int
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '';

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaxed
FROM PercentPopulationVaccinated;


-- Creating view to store data for later vizualizaitons
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '';

