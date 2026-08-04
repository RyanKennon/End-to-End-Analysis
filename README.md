# Layoffs End-to-End Analysis

## Overview

This project is an end-to-end data analysis covering the full workflow: sourcing raw data, cleaning it, analyzing it, and visualizing findings. Unlike the previous two projects in this portfolio (which used the pre-cleaned Northwind sample database), this project uses a real-world, messy dataset tracking tech layoffs, requiring genuine data cleaning before any analysis could begin.

---

## Dataset

- **Source:** [Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022) by Swapnil Tripathi on Kaggle
- **Description:** Tracks tech layoffs reported from Bloomberg, San Francisco Business Times, TechCrunch, and The New York Times, from COVID-19 (2019) to present
- **Format:** CSV
- **Size:** 4,540 rows, 11 columns: `company`, `location`, `total_laid_off`, `date`, `percentage_laid_off`, `industry`, `source`, `stage`, `funds_raised`, `country`, `date_added`

---

## Setup / Prerequisites
- Download the dataset from the source linked above
- Open the CSV in Excel
- Formulas/PivotTables in this repo's workbook can be used to reproduce the analysis

---

## Tools Used
- **Excel** — used for data cleaning, analysis, and visualization

---

## Data Cleaning

The raw dataset had several columns with missing values. Each was reviewed individually and handled based on whether the missing value could be reliably determined:

- **`total_laid_off` (1,570 blank) and `percentage_laid_off` (1,693 blank):** Many companies reported only one of these two figures, or neither. These blanks were left as-is rather than estimated, since there was no reliable way to calculate one from the other without additional data (like company headcount). 741 rows had both values blank; these rows were kept in the dataset but excluded from any analysis calculating total people laid off or average layoff percentage.
- **`location` (1 blank):** The single missing value (Product Hunt) was filled in based on publicly known company information (SF Bay Area), matching this dataset's existing location format.
- **`industry` (2 blank):** Eyeo and Appsmith were missing an industry. Both were manually classified into the closest existing category based on what each company does (Eyeo → Consumer, Appsmith → Product), rather than left blank.
- **`source` (3 blank):** Trellix, N-able Technologies, and Tapas Media were missing a source citation. These were left blank, since finding and verifying the original article was outside the scope of this cleaning pass, and this field doesn't affect any analysis.
- **`country` (2 blank):** Fit Analytics and Ludia were missing a country. Both were filled in based on publicly known company headquarters locations (Germany and Canada, respectively).
- **`stage` (8 blank):** Eight companies (Zondacrypto, Flex AI, OP Labs, Soundwide, Advata, Spreetail, Gatherly, Zapp) were missing a funding stage. Rather than researching each company's funding history individually, these were filled in as "Unknown" to stay consistent with the existing "Unknown" category already used elsewhere in the dataset.
- **Formatting check:** Industry, stage, and country columns were reviewed for near-duplicate values (inconsistent casing, extra spacing) — none were found.
- **Duplicate rows:** No exact duplicate rows were found in the dataset.

---

## Business Questions & Findings

### 1. Which industries had the most layoffs?

- Query: [Layoffs by Industry](queries/layoffs_by_industry.sql)

```sql
SELECT industry, SUM(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY industry
ORDER BY TotalLaidOff DESC;
```

<p align="center">
  <img width="219" height="280" alt="image" src="https://github.com/user-attachments/assets/10b01cd0-e362-4e6b-83fb-e2a2241d6eec" />
</p>

- Finding: "Other" leads in total layoffs at 115,800, though this is a catch-all category rather than a specific industry, making it less informative on its own. Among clearly defined industries, Retail (108,006) and Hardware (105,200) had the highest layoff totals, followed by Consumer (97,997) and Finance (70,162).

### 2. Which companies had the largest layoffs?

- Query: [Layoffs by Company](queries/layoffs_by_company.sql)

```sql
SELECT
    company,
    sum(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY company
ORDER BY TotalLaidOff DESC
LIMIT 10;
```

<p align="center">
  <img width="182" height="286" alt="image" src="https://github.com/user-attachments/assets/28137005-1f7f-4e31-8dd4-b0c0f29c8fd7" />
</p>

- Finding: Amazon had the largest total layoffs of any single company at 59,291, well ahead of Intel (43,115) and Meta (35,700). Microsoft (34,855) and Dell (23,650) round out the top 5. These figures reflect large tech companies with correspondingly large workforces, so a high total doesn't necessarily mean a high percentage of that company's staff was affected.

### 3. How have layoffs trended over time?

- Query: [Layoffs Over Time](queries/layoffs_over_time.sql)

```sql
SELECT 
    substr(date, -4) AS year,
    SUM(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY year
ORDER BY year ASC;
```

<p align="center">
  <img width="127" height="204" alt="image" src="https://github.com/user-attachments/assets/8ce8fe21-d4ec-47b6-90ae-521d4c5c49b7" />
</p>

- Finding: Layoffs peaked in 2023 at 265,660, more than triple the 2020 total of 80,998. 2020's lower total likely reflects the earliest phase of COVID-era disruption before the larger wave of tech layoffs hit in 2022-2023. 2026 shows a decline to 124,538, though this year's data is only partial (through July), so it's not yet clear whether this reflects a genuine slowdown or simply an incomplete year.

### 4. Which countries were hit hardest?

- Query: [Layoffs by Country](queries/layoffs_by_country.sql)

```sql
SELECT
    country,
    sum(total_laid_off) AS TotalLaidOff
FROM layoffs
GROUP BY country
ORDER BY TotalLaidOff DESC
LIMIT 10;
```

<p align="center">
  <img width="215" height="284" alt="image" src="https://github.com/user-attachments/assets/1986b53e-42e4-42d5-8ff7-fe8b78fcf157" />
</p>

- Finding: The United States accounts for the largest share of tracked layoffs by far, at 657,447, with India a distant second at 67,509, followed by Germany (32,055), the United Kingdom (24,694), and the Netherlands (22,175). This gap is likely inflated somewhat by the dataset's sourcing — the underlying news outlets (Bloomberg, SF Business Times, TechCrunch, NYT) are largely US-based, so US layoffs are probably tracked more thoroughly than layoffs in other countries, rather than the US necessarily accounting for this large a share of layoffs in reality.

### 5. Does funding stage relate to layoff likelihood?

- Query 1: [Layoffs Count by Stage](queries/layoffs_event_count_by_stage.sql)

```sql
SELECT stage, COUNT(*) AS EventCount
FROM layoffs
GROUP BY stage
ORDER BY EventCount DESC;
```

<p align="center">
  <img width="214" height="441" alt="image" src="https://github.com/user-attachments/assets/6757abbd-eaf6-4a9d-b9b0-5bce90bcd12f" />
</p>

- Query 2: [Layoffs Percent by Stage](queries/layoffs_avg_percent_by_stage.sql)

```sql
SELECT stage, ROUND(AVG(percentage_laid_off), 2) AS AvgPercentLaidOff
FROM layoffs
GROUP BY stage
ORDER BY AvgPercentLaidOff DESC;
```

<p align="center">
  <img width="250" height="436" alt="image" src="https://github.com/user-attachments/assets/d7a77d2b-cf33-4700-a0ca-995660ff49e5" />
</p>

- Finding: Post-IPO companies had by far the most layoff events (1,091), likely reflecting how many large, established companies fall into this stage. However, when layoffs did occur, they tended to be relatively contained, cutting an average of about 16.5% of the workforce. Seed-stage companies show the opposite pattern: far fewer layoff events overall, but when they happen, they're much more severe, cutting an average of about 83% of the workforce. This suggests funding stage relates more to the severity of layoffs than to how often they happen, with early-stage companies less likely to lay off staff but more likely to be shutting down or drastically downsizing when they do, while later-stage companies have more frequent but comparatively smaller workforce reductions.

---

## Dashboard Overview

📊 [Download the interactive dashboard (.pbix file)](layoff_db.pbix) — requires [Power BI Desktop](https://www.microsoft.com/en-us/power-platform/products/power-bi/downloads) to open

Full dashboard screenshot:

![Layoffs Dashboard](images/dashboard_full.png)

### KPI Summary
The top of the dashboard shows two key metrics at a glance: Total Layoffs and total Layoff Events tracked across the dataset.

### Total Layoffs by Industry
![Layoffs by industry](images/dashboard_industry.png)
- What it shows: Total layoffs broken down by industry, sorted highest to lowest.
- Finding: Consistent with the SQL analysis, "Other" leads (a catch-all category), followed by Retail, Hardware, and Consumer among clearly defined industries.

### Total Layoffs by Company
![Layoffs by company](images/dashboard_company.png)
- What it shows: The top 10 companies by total layoffs.
- Finding: Amazon leads by a wide margin, followed by Intel and Meta, matching the SQL analysis exactly.

### Total Layoffs by Year
![Layoffs by year](images/dashboard_year.png)
- What it shows: Total layoffs trended by year.
- Finding: Layoffs peaked in 2023, with a decline into 2026 that likely reflects partial-year data rather than a genuine slowdown, consistent with the SQL findings.

### Total Layoffs by Country
![Layoffs by country](images/dashboard_country.png)
- What it shows: A map visual showing layoffs by country worldwide.
- Finding: The United States accounts for the large majority of tracked layoffs, likely influenced by the dataset's US-centric news sourcing, consistent with the SQL analysis.

### Layoff Events and Severity by Funding Stage
![Layoffs by stage](images/dashboard_stage.png)
- What it shows: Two side-by-side charts — number of layoff events per funding stage, and average percentage of workforce laid off per stage.
- Finding: Post-IPO companies have the most layoff events but the lowest average severity, while Seed-stage companies have far fewer events but by far the highest average percentage laid off, confirming the pattern found in the SQL analysis.

### Interactivity
All visuals on the dashboard are cross-filterable — clicking on any bar, line point, or map bubble filters the other visuals to show related data.
