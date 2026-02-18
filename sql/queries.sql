-----------------------------------------
-- 1. Dataset Overview / Summary Metrics
-----------------------------------------
-- Total interactions, impressions, clicks, conversions, revenue
SELECT
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM
	fitbit_ads;

-----------------------------------------
-- 2. Engagement by Platform
-----------------------------------------
-- Identify which ad platform has the highest click-through rate (CTR)
SELECT
	AdPlatform,
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
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
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM
	fitbit_ads
GROUP BY
	ProductCategory
ORDER BY
	revenue_per_impression DESC;
-- How do the products rank in terms of ROI each month
SELECT
	ProductCategory,
	TO_CHAR(datetime, 'Month') AS month,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM
	fitbit_ads
GROUP BY
	ProductCategory,
	month
ORDER BY
	month;

-----------------------------------------
-- 4. Campaign Performance
-----------------------------------------
-- Compare campaigns by revenue and conversions
SELECT 
    CampaignID,
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM 
	fitbit_ads
GROUP BY 
	CampaignID
ORDER BY 
	total_revenue DESC;

-----------------------------------------
-- 5. Demographics Insights
-----------------------------------------
-- How are age group-gender combinations performing in terms of total revenue (volume), revenue per impression/return on advtertising spend (ROAS), and conversion rate (CVR).
SELECT 
    AgeGroup,
    Gender,
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM 
	fitbit_ads
GROUP BY 
	AgeGroup, 
	Gender
ORDER BY 
	total_revenue DESC;

-----------------------------------------
-- 6. Geography Analysis
-----------------------------------------
-- How are countries performing in terms of total revenue (volume), revenue per impression/return on advtertising spend (ROAS), and conversion rate (CVR).
SELECT 
    Country,
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
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
		COUNT(*) AS total_exposures,
		SUM(Clicks) AS total_clicks,
		SUM(Impressions) AS total_impressions,
		ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
		SUM(Conversions) AS total_conversions,
		SUM(ConversionValue) AS total_revenue,
		ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression,
		ROW_NUMBER() OVER (PARTITION BY Country ORDER BY SUM(ConversionValue) DESC) AS ad_rank
	FROM
		fitbit_ads
	GROUP BY
		Country,
		CampaignID,
		AdPlatform
)
SELECT
	*
FROM
	country_ad_ranks
WHERE 
	ad_rank = 1
ORDER BY
	total_revenue DESC;

-----------------------------------------
-- 7. Time-Based Trends
-----------------------------------------
-- What time of the day are users most active?
SELECT 
    EXTRACT(HOUR FROM DateTime) AS hour,
	COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
FROM 
	fitbit_ads
GROUP BY 
	hour
ORDER BY 
	total_revenue DESC;
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
    COUNT(*) AS total_exposures,
	SUM(Clicks) AS total_clicks,
	SUM(Impressions) AS total_impressions,
	ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent,
	SUM(Conversions) AS total_conversions,
	SUM(ConversionValue) AS total_revenue,
	ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression
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
