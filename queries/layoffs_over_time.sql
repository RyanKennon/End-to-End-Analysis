SELECT 
    substr(date, -4) AS year,
    SUM(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY year
ORDER BY year ASC;
