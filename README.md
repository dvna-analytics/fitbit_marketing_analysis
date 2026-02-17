# fitbit_marketing_analysis

## Project Overview

This project analyzes a sample marketing dataset from Fitbit to uncover insights about **ad performance, demographics, engagement, and conversion efficiency**. The goal is to demonstrate SQL-based data modeling, transformation, and exploratory analysis techniques.

**Dataset:** `FitBitMarketing.csv` (9,500 rows, 12 columns)
> **Data Source Note:** The dataset used in this project was obtained from a public source and is used for educational and analytical purposes. The real-world authenticity of the data could not be independently verified.

**Key columns:**

| Column            | Description                                      |
|------------------|-------------------------------------------------|
| DateTime          | Timestamp of ad interaction                     |
| CustomerID        | Unique customer identifier                       |
| AgeGroup          | Customer age group                               |
| Gender            | Customer gender                                  |
| Country           | Country of the interaction                       |
| ProductCategory   | Fitbit product category                          |
| CampaignID        | ID of the ad campaign                            |
| AdPlatform        | Ad platform (Google, Facebook, Instagram, etc.) |
| Impressions       | Number of ad impressions                         |
| Clicks            | Number of clicks                                 |
| Conversions       | Number of conversions                            |
| ConversionValue   | Revenue generated from conversions               |

---

## Project Structure
```powershell
fitbit_marketing_analysis/
│
├─ data/
│   └─ FitBitMarketing.csv      # Raw dataset
├─ sql/
│   ├─ table_setup.sql          # Creates table & loads CSV
│   └─ queries.sql              # Analysis queries
├─ results/                     # Optional: query outputs
└─ README.md                    # This documentation
```
---
## Setup Instructions

**1.** Install PostgreSQL (or ensure you have it installed).

**2.** Clone the repository:
```bash
git clone https://github.com/yourusername/fitbit_marketing_analysis.git
cd fitbit_marketing_analysis
```

**3.** Create a database:
```sql
CREATE DATABASE fitbit;
\c fitbit
```

**4.** Run table setup to create the table and load data:
```bash
psql -d fitbit -f sql/table_setup.sql
```

**5.** Run analysis queries:
```bash
psql -d fitbit -f sql/queries.sql
```
> *Make sure the CSV is located at `data/FitBitMarketing.csv` relative to the repo root.*

---

## Key Analyses

Below are high-level analysis areas, with representative SQL snippets. Full queries are in `queries.sql`.

### **1. Dataset Overview**  
  
**Objective:** Summarize interactions, impressions, clicks, conversions, and revenue.
```sql
SELECT
	COUNT(*) AS total_interactions,
	SUM(Impressions) AS total_impressions,
	SUM(Clicks) AS total_clicks,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue
FROM
	fitbit_ads;
```
**Results:**

| Metric                | Value       |
|-----------------------|------------|
| Total Interactions    | 9,500      |
| Total Impressions     | 47,774     |
| Total Clicks          | 4,830      |
| Total Conversions     | 1,496      |
| Total Revenue ($)     | 411,044.00 |
| Conversion Rate (%)   | 30.98      |

>**Key Insight:** *Overall, the dataset shows a strong conversion performance relative to total clicks, indicating effective ad targeting.*

### **2. Engagement by Platform**

**Objective:** Identify which ad platform drives the highest click-through rate CTR.
```sql
SELECT
	AdPlatform,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent
FROM
	fitbit_ads
GROUP BY
	AdPlatform
ORDER BY
	CTR_percent DESC;
```
**Results:**
| Ad Platform | Total Clicks | Total Impressions | CTR (%) |
|------------|--------------|-----------------|---------|
| Facebook   | 1,447        | 14,074           | **10.28 🔥** |
| Google     | 1,984        | 19,328           | **10.26 🔥** |
| Instagram  | 944          | 9,556            | 9.88    |
| Twitter    | 455          | 4,816            | 9.45    |
>**Key Insight:**  *Google and Facebook drive the highest engagement (CTR ~10%), while Instagram and Twitter slightly lower.*

### **3. Revenue / ROI by Product Category**
**Objective:** Determine most profitable product categories and efficiency per impression.
```sql
SELECT
	ProductCategory,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM
	fitbit_ads
GROUP BY
	ProductCategory
ORDER BY
	revenue_per_impression DESC;
```
**Results:**
| Product Category   | Total Conversions | Total Revenue ($) | Revenue per Impression |
|------------------|-----------------|-----------------|----------------------|
| Accessories       | 334             | 95,308           | **9.82 🔥**          |
| Smartphones       | 463             | 127,983          | 8.91                 |
| Laptops           | 362             | 95,928           | 8.34                 |
| Home Entertainment| 131             | 37,492           | 8.14                 |
| Wearables         | 206             | 54,333           | 7.15                 |
>**Key Insight:** *Accessories generate the highest revenue per impression, while Smartphones lead in total revenue and conversions.*

### **4. Geography Insights**
**Objective:** Revenue by country and top campaign per country.
```sql
WITH country_ad_ranks AS (
	SELECT
		Country,
		CampaignID,
		AdPlatform,
		SUM(Conversions) AS total_conversions,
	    SUM(ConversionValue) AS total_revenue,
	    ROW_NUMBER() OVER(PARTITION BY Country ORDER BY SUM(ConversionValue) DESC) AS ad_rank
	FROM
		fitbit_ads
	GROUP BY
		Country,
		CampaignID,
		AdPlatform
	ORDER BY 
		total_revenue DESC
)
SELECT
	*
FROM
	country_ad_ranks
WHERE 
	ad_rank = 1;
```
> **Key Insight:** *Among the top-performing campaigns in each country, Google appears most frequently, with Facebook leading in Canada and Instagram in the USA.*

### **5. Time-Based Trends**
**Objective:** Activity by hour and day of week.
```sql
SELECT 
    CASE 
    	WHEN EXTRACT(DOW FROM DateTime) = 0 THEN '1. Sunday'
    	WHEN EXTRACT(DOW FROM DateTime) = 1 THEN '2. Monday'
    	WHEN EXTRACT(DOW FROM DateTime) = 2 THEN '3. Tuesday'
    	WHEN EXTRACT(DOW FROM DateTime) = 3 THEN '4. Wednesday'
    	WHEN EXTRACT(DOW FROM DateTime) = 4 THEN '5. Thursday'
    	WHEN EXTRACT(DOW FROM DateTime) = 5 THEN '6. Friday'
    	ELSE '7. Saturday' 
    END AS day_of_week,
    SUM(Clicks) AS total_clicks,
    SUM(Conversions) AS total_conversions,
	ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	day_of_week
ORDER BY 
	day_of_week ASC;
```
**Results:**
| Day of Week | Total Clicks | Total Conversions | Conversion Rate (%) |
|------------|--------------|------------------|-------------------|
| Sunday     | 663          | 208              | 31.37             |
| Monday     | 682          | 208              | 30.50             |
| Tuesday    | 710          | 233              | **32.82 🔥**             |
| Wednesday  | 698          | 209              | 29.94             |
| Thursday   | 696          | 209              | 30.03             |
| Friday     | 684          | 204              | 29.82             |
| Saturday   | 697          | 225              | **32.28 🔥**           |

> **Key Insight:** *Conversion rates peak on Tuesday and Saturday, while click volume is fairly consistent across the week.*
