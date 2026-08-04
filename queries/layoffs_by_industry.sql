SELECT industry, SUM(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY industry
ORDER BY TotalLaidOff DESC;
