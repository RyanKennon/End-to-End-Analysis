SELECT
    country,
    sum(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY country
ORDER BY TotalLaidOff DESC
LIMIT 10;
