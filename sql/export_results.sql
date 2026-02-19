-----------------------------------------
-- 1. Dataset Overview / Summary Metrics
-----------------------------------------

\COPY (SELECT COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads) TO 'results/overview_summary_metrics.csv' CSV HEADER;

-----------------------------------------
-- 2. Engagement by Platform
-----------------------------------------

\COPY (SELECT AdPlatform, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY AdPlatform ORDER BY ctr_percent DESC) TO 'results/engagement_by_platform.csv' CSV HEADER;

-----------------------------------------
-- 3. Revenue / ROI by Product Category
-----------------------------------------

\COPY (SELECT ProductCategory, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY ProductCategory ORDER BY revenue_per_impression DESC) TO 'results/roi_by_product_category.csv' CSV HEADER;

\COPY (SELECT ProductCategory, TO_CHAR(datetime, 'FMMonth') AS month, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY ProductCategory, month ORDER BY month) TO 'results/roi_by_product_category_over_time.csv' CSV HEADER;

-----------------------------------------
-- 4. Campaign Performance
-----------------------------------------

\COPY (SELECT CampaignID, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY CampaignID ORDER BY revenue DESC) TO 'results/campaign_performance.csv' CSV HEADER;

-----------------------------------------
-- 5. Demographics Insights
-----------------------------------------

\COPY (SELECT AgeGroup, Gender, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY AgeGroup, Gender ORDER BY conversion_rate_percent DESC) TO 'results/demographics_conversion_by_age_gender.csv' CSV HEADER;

-----------------------------------------
-- 6. Geography Analysis
-----------------------------------------

\COPY (SELECT Country, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY Country ORDER BY total_revenue DESC) TO 'results/revenue_by_country.csv' CSV HEADER;

\COPY (SELECT Country, CampaignID, AdPlatform, total_conversions, total_revenue FROM (SELECT Country, CampaignID, AdPlatform, SUM(Conversions) AS total_conversions, SUM(ConversionValue) AS total_revenue, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY SUM(ConversionValue) DESC) AS ad_rank FROM fitbit_ads GROUP BY Country, CampaignID, AdPlatform) ranked WHERE ad_rank = 1) TO 'results/top_campaign_per_country.csv' CSV HEADER;

-----------------------------------------
-- 7. Time-Based Trends
-----------------------------------------

\COPY (SELECT EXTRACT(HOUR FROM DateTime) AS hour_of_day, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY hour_of_day ORDER BY revenue_per_impression DESC) TO 'results/conversion_by_hour_of_day.csv' CSV HEADER;

\COPY (SELECT CASE WHEN EXTRACT(DOW FROM DateTime) = 0 THEN 'Sunday' WHEN EXTRACT(DOW FROM DateTime) = 1 THEN 'Monday' WHEN EXTRACT(DOW FROM DateTime) = 2 THEN 'Tuesday' WHEN EXTRACT(DOW FROM DateTime) = 3 THEN 'Wednesday' WHEN EXTRACT(DOW FROM DateTime) = 4 THEN 'Thursday' WHEN EXTRACT(DOW FROM DateTime) = 5 THEN 'Friday' ELSE 'Saturday' END AS day_of_week, COUNT(*) AS total_exposures, SUM(Clicks) AS total_clicks, SUM(Impressions) AS total_impressions, ROUND((SUM(Clicks)::DECIMAL / NULLIF(SUM(Impressions),0)*100),2) AS CTR_percent, SUM(Conversions) AS total_conversions, ROUND((SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0)*100),2) AS conversion_rate, SUM(ConversionValue) AS total_revenue, ROUND(SUM(ConversionValue)::DECIMAL / NULLIF(SUM(Impressions),0),2) AS revenue_per_impression FROM fitbit_ads GROUP BY day_of_week ORDER BY day_of_week) TO 'results/conversion_by_day_of_week.csv' CSV HEADER;

-----------------------------------------
-- 8. Conversion Efficiency
-----------------------------------------

\COPY (SELECT AdPlatform, SUM(Conversions) AS total_conversions, SUM(Clicks) AS total_clicks, ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0) * 100, 2) AS conversion_rate_percent FROM fitbit_ads GROUP BY AdPlatform ORDER BY conversion_rate_percent DESC) TO 'results/conversion_efficiency_by_platform.csv' CSV HEADER;

\COPY (SELECT ProductCategory, SUM(Conversions) AS total_conversions, SUM(Clicks) AS total_clicks, ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0) * 100, 2) AS conversion_rate_percent FROM fitbit_ads GROUP BY ProductCategory ORDER BY conversion_rate_percent DESC) TO 'results/conversion_efficiency_by_product_category.csv' CSV HEADER;

\COPY (SELECT AdPlatform, ProductCategory, SUM(Conversions) AS total_conversions, SUM(Clicks) AS total_clicks, ROUND(SUM(Conversions)::DECIMAL / NULLIF(SUM(Clicks),0) * 100, 2) AS conversion_rate_percent FROM fitbit_ads GROUP BY AdPlatform, ProductCategory ORDER BY conversion_rate_percent DESC) TO 'results/conversion_efficiency_by_platform_product.csv' CSV HEADER;
