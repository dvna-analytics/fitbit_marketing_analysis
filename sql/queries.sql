-----------------------------------------
-- 1. Dataset Overview / Summary Metrics
-----------------------------------------
-- Total interactions, impressions, clicks, conversions, revenue
SELECT
	COUNT(*) AS total_interactions,
	SUM(Impressions) AS total_impressions,
	SUM(Clicks) AS total_clicks,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue
FROM
	fitbit_ads;
-- Average conversion rate
SELECT
	ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate
FROM
	fitbit_ads;

-----------------------------------------
-- 2. Engagement by Platform
-----------------------------------------
-- Identify which ad platform has the highest click-through rate (CTR)
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

-----------------------------------------
-- 3. Revenue / ROI by Product Category
-----------------------------------------
-- Which products are the most profitable
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

-----------------------------------------
-- 4. Campaign Performance
-----------------------------------------
-- Compare campaigns by revenue and conversions
SELECT 
    CampaignID,
    SUM(Clicks) AS total_clicks,
    SUM(Conversions) AS total_conversions,
    SUM(ConversionValue) AS revenue,
    ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Clicks),0),2) AS revenue_per_click
FROM 
	fitbit_ads
GROUP BY 
	CampaignID
ORDER BY 
	revenue DESC;

-----------------------------------------
-- 5. Demographics Insights
-----------------------------------------
-- Which age groups and genders are most responsive
SELECT 
    AgeGroup,
    Gender,
    SUM(Clicks) AS total_clicks,
    SUM(Conversions) AS total_conversions,
    ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	AgeGroup, 
	Gender
ORDER BY 
	conversion_rate_percent DESC;

-----------------------------------------
-- 6. Geography Analysis
-----------------------------------------
-- Top countries by revenue
SELECT 
    Country,
    SUM(Conversions) AS total_conversions,
    SUM(ConversionValue) AS total_revenue
FROM 
	fitbit_ads
GROUP BY 
	Country
ORDER BY 
	total_revenue DESC;
-- Top ad campaign per country
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



-----------------------------------------
-- 7. Time-Based Trends
-----------------------------------------
-- What time of the day are users most active?
SELECT 
    EXTRACT(HOUR FROM DateTime) AS hour,
    SUM(Clicks) AS total_clicks,
    SUM(Conversions) AS total_conversions,
    ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	hour
ORDER BY 
	conversion_rate_percent ASC;
-- What day of the week are users most active?
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

-----------------------------------------
-- 8. Conversion Efficiency
-----------------------------------------
-- Compare platforms by conversions per click
SELECT 
    AdPlatform,
    SUM(Conversions) AS total_conversions,
    SUM(Clicks) AS total_clicks,
    ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	AdPlatform
ORDER BY 
	conversion_rate_percent DESC;
-- Compare product categories by conversions per click
SELECT 
    ProductCategory,
    SUM(Conversions) AS total_conversions,
    SUM(Clicks) AS total_clicks,
    ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	ProductCategory
ORDER BY 
	conversion_rate_percent DESC;
-- Compare platform-product combinations by conversions per click
SELECT 
	AdPlatform,
    ProductCategory,
    SUM(Conversions) AS total_conversions,
    SUM(Clicks) AS total_clicks,
    ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100,2) AS conversion_rate_percent
FROM 
	fitbit_ads
GROUP BY 
	AdPlatform,
	ProductCategory
ORDER BY 
	conversion_rate_percent DESC;
