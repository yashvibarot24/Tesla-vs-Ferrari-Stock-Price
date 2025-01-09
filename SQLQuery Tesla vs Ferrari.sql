--## Create Database and Use It ##

CREATE DATABASE StockAnalysis;
USE StockAnalysis;


-- # Create Tesla Stock Table

CREATE TABLE tesla_stock (
    [Date] DATE,
    [Open] DECIMAL(10, 2),
    [High] DECIMAL(10, 2),
    [Low] DECIMAL(10, 2),
    [Close] DECIMAL(10, 2),
    [Adj_Close] DECIMAL(10, 2),
    [Volume] INT
);


-- # Create Ferrari Stock Table

CREATE TABLE ferrari_stock (
    [Date] DATE,
    [Open] DECIMAL(10, 2),
    [High] DECIMAL(10, 2),
    [Low] DECIMAL(10, 2),
    [Close] DECIMAL(10, 2),
    [Adj_Close] DECIMAL(10, 2),
    [Volume] INT
);


-- # Import Tesla Data

BULK INSERT tesla_stock
FROM 'C:/Tesla project/merged data/Tesla 2015 - 23.csv'
WITH
(
    FIELDTERMINATOR = ',',  -- Specify the delimiter
    ROWTERMINATOR = '\n',   -- Specify the row terminator
    FIRSTROW = 2           -- Skip header row
);


-- # Import Ferrari Data

BULK INSERT ferrari_stock
FROM 'C:/Tesla project/merged data/Ferrari 2015 - 23.csv'
WITH
(
    FIELDTERMINATOR = ',',  -- Specify the delimiter
    ROWTERMINATOR = '\n',   -- Specify the row terminator
    FIRSTROW = 2           -- Skip header row
);


-- # View the Top 10 Rows from Tesla Stock Table

SELECT TOP 10 * FROM tesla_stock;


-- # View the Top 10 Rows from Ferrari Stock Table

SELECT TOP 10 * FROM ferrari_stock;


-- # Calculate Average Closing Price for Tesla by Year

SELECT YEAR([Date]) AS Year, AVG([Close]) AS Avg_Close_Tesla
FROM tesla_stock
GROUP BY YEAR([Date])
ORDER BY Year;


-- # Calculate Average Closing Price for Ferrari by Year

SELECT YEAR([Date]) AS Year, AVG([Close]) AS Avg_Close_Ferrari
FROM ferrari_stock
GROUP BY YEAR([Date])
ORDER BY Year;


-- # Calculate Daily Volatility for Tesla (High - Low)

SELECT [Date], ([High] - [Low]) AS Daily_Volatility_Tesla
FROM tesla_stock
ORDER BY [Date];


-- # Calculate Daily Volatility for Ferrari (High - Low)

SELECT [Date], ([High] - [Low]) AS Daily_Volatility_Ferrari
FROM ferrari_stock
ORDER BY [Date];


-- # Calculate 50-Day Moving Average for Tesla

SELECT [Date], 
       AVG([Close]) OVER (ORDER BY [Date] ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS Moving_Avg_Tesla
FROM tesla_stock
ORDER BY [Date];

-- # Calculate 50-Day Moving Average for Ferrari

SELECT [Date], 
       AVG([Close]) OVER (ORDER BY [Date] ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS Moving_Avg_Ferrari
FROM ferrari_stock
ORDER BY [Date];

-- # Calculate Pearson Correlation Between Tesla and Ferrari Closing Prices

SELECT 
    (COUNT(*) * SUM(tesla.[Close] * ferrari.[Close]) - SUM(tesla.[Close]) * SUM(ferrari.[Close])) / 
    (SQRT((COUNT(*) * SUM(tesla.[Close] * tesla.[Close]) - SUM(tesla.[Close]) * SUM(tesla.[Close])) * 
          (COUNT(*) * SUM(ferrari.[Close] * ferrari.[Close]) - SUM(ferrari.[Close]) * SUM(ferrari.[Close])))) AS Pearson_Correlation
FROM tesla_stock AS tesla
JOIN ferrari_stock AS ferrari ON tesla.[Date] = ferrari.[Date];


-- # Calculate Max and Min Closing Prices for Tesla

SELECT MAX([Close]) AS Max_Close_Tesla, MIN([Close]) AS Min_Close_Tesla
FROM tesla_stock;


-- # Calculate Max and Min Closing Prices for Ferrari

SELECT MAX([Close]) AS Max_Close_Ferrari, MIN([Close]) AS Min_Close_Ferrari
FROM ferrari_stock;


-- # Monthly Average Closing Price for Tesla

SELECT YEAR([Date]) AS Year, MONTH([Date]) AS Month, AVG([Close]) AS Avg_Close_Tesla
FROM tesla_stock
GROUP BY YEAR([Date]), MONTH([Date])
ORDER BY Year, Month;

--# Monthly Average Closing Price for Ferrari

SELECT YEAR([Date]) AS Year, MONTH([Date]) AS Month, AVG([Close]) AS Avg_Close_Ferrari
FROM ferrari_stock
GROUP BY YEAR([Date]), MONTH([Date])
ORDER BY Year, Month;

-- #Price Difference Between Tesla and Ferrari
SELECT tesla.[Date], 
       tesla.[Close] - ferrari.[Close] AS Price_Difference
FROM tesla_stock AS tesla
JOIN ferrari_stock AS ferrari ON tesla.[Date] = ferrari.[Date]
ORDER BY tesla.[Date];


-- #  Largest Price Change for Tesla (Top 10)
SELECT TOP 10 [Date], 
              ABS(([Close] - [Open]) / [Open]) * 100 AS Price_Change_Percentage_Tesla
FROM tesla_stock
ORDER BY Price_Change_Percentage_Tesla DESC;


-- # Largest Price Change for Ferrari (Top 10)
SELECT TOP 10 [Date], 
              ABS(([Close] - [Open]) / [Open]) * 100 AS Price_Change_Percentage_Ferrari
FROM ferrari_stock
ORDER BY Price_Change_Percentage_Ferrari DESC;



-- Cumulative Return for Tesla

WITH Tesla_Returns AS (
    SELECT [Date], [Close], 
           (SELECT TOP 1 [Close] FROM tesla_stock ORDER BY [Date] ASC) AS Initial_Close
    FROM tesla_stock
)
SELECT [Date], [Close], 
       ([Close] - Initial_Close) / Initial_Close * 100 AS Cumulative_Return_Tesla
FROM Tesla_Returns
ORDER BY [Date];


-- Cumulative Return for Ferrari

WITH Ferrari_Returns AS (
    SELECT [Date], [Close], 
           (SELECT TOP 1 [Close] FROM ferrari_stock ORDER BY [Date] ASC) AS Initial_Close
    FROM ferrari_stock
)
SELECT [Date], [Close], 
       ([Close] - Initial_Close) / Initial_Close * 100 AS Cumulative_Return_Ferrari
FROM Ferrari_Returns
ORDER BY [Date];


-- Price Momentum for Tesla
SELECT [Date], 
       ([Close] - LAG([Close], 1) OVER (ORDER BY [Date])) AS Tesla_Momentum
FROM tesla_stock
ORDER BY [Date];

-- Price Momentum for Ferrari
SELECT [Date], 
       ([Close] - LAG([Close], 1) OVER (ORDER BY [Date])) AS Ferrari_Momentum
FROM ferrari_stock
ORDER BY [Date];
