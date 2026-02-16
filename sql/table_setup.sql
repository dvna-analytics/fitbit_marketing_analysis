-- 1. Create the table
CREATE TABLE fitbit_ads (
  DateTime TIMESTAMP,
  CustomerID INT,
  AgeGroup VARCHAR(5),
  Gender VARCHAR(6),
  Country VARCHAR(10),
  ProductCategory VARCHAR(20),
  CampaignID INT,
  AdPlatform VARCHAR(10),
  Impressions INT,
  Clicks INT,
  Conversions INT,
  ConversionValue DECIMAL(10,2)
);

-- 2. Import csv into the table
\COPY fitbit_ads(DateTime, CustomerID, AgeGroup, Gender, Country, ProductCategory, 
  CampaignID, AdPlatform, Impressions, Clicks, Conversions, ConversionValue)
FROM 'data/FitBitMarketing.csv'
DELIMITER ','
CSV HEADER;
