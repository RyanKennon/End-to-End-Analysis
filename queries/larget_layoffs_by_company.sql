SELECT
    company,
    sum(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY company
ORDER BY TotalLaidOff DESC
LIMIT 10;
