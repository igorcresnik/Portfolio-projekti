--select* from CovidVaccanations ORDER BY 3,4

select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2

-- pogled na skupno število primerov v primerjavi s skupnim številom smrti
-- verjetnost, da umreš, èe se okužiš s Covidom v Sloveniji
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / NULLIF(total_cases, 0)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%slo%'
ORDER BY DeathPercentage desc;

-- skupno število primerov v primerjavi s prebivalstvom
SELECT location, date, total_cases, population, 
       (total_cases / NULLIF(population, 0)*100) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%slo%'
ORDER BY InfectedPercentage desc;

-- države z najvišjimi stopnjami okužb v primerjavi s prebivalstvom
SELECT location, MAX(total_cases) as HighestInfectionRate, population, 
       MAX((total_cases / NULLIF(population, 0) * 100)) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY InfectedPercentage DESC;

-- države z najveèjim številom smrti glede na prebivalstvo
SELECT location, MAX(total_deaths) as HighestDeathRate, population, 
       MAX((total_deaths / NULLIF(population, 0) * 100)) AS HighestDeathRatePercentage
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY HighestDeathRatePercentage DESC;

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	   WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	   WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- grupiramo na kontinent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	   WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- globalne stevilke
SELECT location, date, total_cases, total_deaths population, 
       (total_deaths / NULLIF(total_cases, 0)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2 desc;


SELECT 
    SUM(new_cases) as total_cases, 
    SUM(cast(new_deaths as int)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(cast(new_deaths as float)) / SUM(new_cases)) * 100 
    END as death_percentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date ASC;

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
	(new_deaths as int)) / SUM(new_cases) * 100 as death_percentage
	FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL
ORDER BY 1,2;

-- total population vs vaccanation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths dea

join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
	where dea.continent is not null

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated,
--	   (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- use CTE
WITH PopvsVac (continent, date, population, location, newVaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, 
           TRY_CAST(dea.date AS date) AS date,  -- Cast date to date type
           TRY_CAST(dea.population AS bigint) AS population,  -- Cast population to bigint
           vac.location,  -- Ensure location is included
           vac.new_vaccinations, 
           SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY TRY_CAST(dea.date AS date)) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated / NULLIF(population, 0)) * 100 AS VaccinationPercentage
FROM PopvsVac;


-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    date DATE,
    population BIGINT,
    location NVARCHAR(255),
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    date DATE,
    population BIGINT,
    location NVARCHAR(255),
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);

-- Step 1: Create the temporary table
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    date DATE,
    population BIGINT,
    location NVARCHAR(255),
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);


-- Temp Table
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    date DATE,
    population BIGINT,
    location NVARCHAR(255),
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
       TRY_CAST(dea.date AS date) AS date,
       TRY_CAST(dea.population AS bigint) AS population,
       vac.location,
       vac.new_vaccinations, 
       SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY TRY_CAST(dea.date AS date)) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / NULLIF(population, 0)) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;

-- optional
DROP TABLE #PercentPopulationVaccinated;


CREATE VIEW vw_TotalDeathCount AS
SELECT continent, 
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;

select * from vw_TotalDeathCount

