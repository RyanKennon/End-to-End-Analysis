SELECT stage, COUNT(*) AS EventCount
FROM layoffs
GROUP BY stage
ORDER BY EventCount DESC;
