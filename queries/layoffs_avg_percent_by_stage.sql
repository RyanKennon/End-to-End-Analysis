SELECT stage, ROUND(AVG(percentage_laid_off), 2) AS AvgPercentLaidOff
FROM layoffs
GROUP BY stage
ORDER BY AvgPercentLaidOff DESC;
