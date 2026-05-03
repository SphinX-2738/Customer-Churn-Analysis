-- ============================================
-- Customer Churn Analysis — SQL Queries
-- Author: Ankur Sharma
-- Dataset: IBM Telco Customer Churn (Real Data)
-- Source: IBM Watson Analytics Sample Dataset
-- Tool: MySQL Workbench
-- Total Customers: 7,032 | Churn Rate: 26.58%
-- ============================================

-- ─────────────────────────────────────────────
-- PRE-PROCESSING: Fix carriage return characters
-- Run these before any queries
-- ─────────────────────────────────────────────

SET SQL_SAFE_UPDATES = 0;
UPDATE customers SET Churn = TRIM(REPLACE(Churn, '\r', ''));
UPDATE customers SET Contract = TRIM(REPLACE(Contract, '\r', ''));
UPDATE customers SET PaymentMethod = TRIM(REPLACE(PaymentMethod, '\r', ''));
UPDATE customers SET InternetService = TRIM(REPLACE(InternetService, '\r', ''));
UPDATE customers SET TechSupport = TRIM(REPLACE(TechSupport, '\r', ''));
UPDATE customers SET OnlineSecurity = TRIM(REPLACE(OnlineSecurity, '\r', ''));
UPDATE customers SET OnlineBackup = TRIM(REPLACE(OnlineBackup, '\r', ''));
UPDATE customers SET DeviceProtection = TRIM(REPLACE(DeviceProtection, '\r', ''));
UPDATE customers SET StreamingTV = TRIM(REPLACE(StreamingTV, '\r', ''));
UPDATE customers SET StreamingMovies = TRIM(REPLACE(StreamingMovies, '\r', ''));
UPDATE customers SET MultipleLines = TRIM(REPLACE(MultipleLines, '\r', ''));
UPDATE customers SET Partner = TRIM(REPLACE(Partner, '\r', ''));
UPDATE customers SET Dependents = TRIM(REPLACE(Dependents, '\r', ''));
UPDATE customers SET PhoneService = TRIM(REPLACE(PhoneService, '\r', ''));
UPDATE customers SET PaperlessBilling = TRIM(REPLACE(PaperlessBilling, '\r', ''));
UPDATE customers SET gender = TRIM(REPLACE(gender, '\r', ''));
SET SQL_SAFE_UPDATES = 1;

-- ─────────────────────────────────────────────
-- BEGINNER QUERIES
-- ─────────────────────────────────────────────

-- Query 1: Overall churn rate
-- Business Question: What percentage of customers have churned?
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM customers;
-- Result: 26.58% churn rate — above industry average of 15-20%

-- Query 2: Total annual revenue at risk
-- Business Question: How much revenue is the business losing to churn?
SELECT 
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(MonthlyCharges), 2) AS Total_Monthly_Revenue_Lost,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS Annual_Revenue_At_Risk,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges_Churned
FROM customers
WHERE Churn = 'Yes';
-- Result: $1,669,570 in annual revenue at risk

-- Query 3: Churn rate by contract type
-- Business Question: Which contract type has the highest churn?
SELECT 
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges
FROM customers
GROUP BY Contract
ORDER BY Churn_Rate_Pct DESC;
-- Result: Month-to-month 42.71% vs Two year 2.85% — 15x difference

-- Query 4: Churn rate by payment method
-- Business Question: Which payment method is most associated with churn?
SELECT 
    PaymentMethod,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM customers
GROUP BY PaymentMethod
ORDER BY Churn_Rate_Pct DESC;
-- Result: Electronic check 45.29% — 3x higher than automatic payment methods

-- ─────────────────────────────────────────────
-- INTERMEDIATE QUERIES
-- ─────────────────────────────────────────────

-- Query 5: Churn rate by internet service type
-- Business Question: Does internet service type affect churn?
SELECT 
    InternetService,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges,
    ROUND(AVG(tenure), 1) AS Avg_Tenure_Months
FROM customers
GROUP BY InternetService
ORDER BY Churn_Rate_Pct DESC;
-- Result: Fiber optic 41.89% vs DSL 19.00% — higher cost drives higher churn

-- Query 6: Churn rate by tenure band
-- Business Question: How does customer loyalty affect churn risk?
SELECT 
    CASE 
        WHEN tenure BETWEEN 1 AND 12 THEN '01 - 0-12 Months (New)'
        WHEN tenure BETWEEN 13 AND 24 THEN '02 - 13-24 Months'
        WHEN tenure BETWEEN 25 AND 36 THEN '03 - 25-36 Months'
        WHEN tenure BETWEEN 37 AND 48 THEN '04 - 37-48 Months'
        WHEN tenure BETWEEN 49 AND 60 THEN '05 - 49-60 Months'
        WHEN tenure BETWEEN 61 AND 72 THEN '06 - 61-72 Months (Loyal)'
    END AS Tenure_Band,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges
FROM customers
GROUP BY Tenure_Band
ORDER BY Tenure_Band;
-- Result: New customers (0-12 months) churn at 47.68% — highest risk group

-- Query 7: Impact of TechSupport on churn
-- Business Question: Does having tech support reduce churn?
SELECT 
    TechSupport,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges
FROM customers
GROUP BY TechSupport
ORDER BY Churn_Rate_Pct DESC;
-- Result: No TechSupport = 41.64% churn vs Yes TechSupport = 15.17% — 26% difference

-- Query 8: Average charges for churned vs retained customers
-- Business Question: Do churned customers pay more or less than retained ones?
SELECT 
    Churn,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges,
    ROUND(AVG(TotalCharges), 2) AS Avg_Total_Charges,
    ROUND(AVG(tenure), 1) AS Avg_Tenure_Months
FROM customers
GROUP BY Churn;
-- Result: Churned customers pay more monthly but less total — they leave before accumulating value

-- ─────────────────────────────────────────────
-- ADVANCED QUERIES
-- ─────────────────────────────────────────────

-- Query 9: Rank top churn risk factors by churn rate
-- Business Question: Which single factor drives churn the most?
WITH churn_factors AS (
    SELECT 'Contract: Month-to-Month' AS Risk_Factor,
        ROUND(SUM(CASE WHEN Contract = 'Month-to-month' AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END), 2) AS Churn_Rate_Pct
    FROM customers
    UNION ALL
    SELECT 'Payment: Electronic Check',
        ROUND(SUM(CASE WHEN PaymentMethod = 'Electronic check' AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END), 2)
    FROM customers
    UNION ALL
    SELECT 'Internet: Fiber Optic',
        ROUND(SUM(CASE WHEN InternetService = 'Fiber optic' AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END), 2)
    FROM customers
    UNION ALL
    SELECT 'No TechSupport',
        ROUND(SUM(CASE WHEN TechSupport = 'No' AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN TechSupport = 'No' THEN 1 ELSE 0 END), 2)
    FROM customers
    UNION ALL
    SELECT 'No OnlineSecurity',
        ROUND(SUM(CASE WHEN OnlineSecurity = 'No' AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN OnlineSecurity = 'No' THEN 1 ELSE 0 END), 2)
    FROM customers
    UNION ALL
    SELECT 'Tenure: 0-12 Months (New Customers)',
        ROUND(SUM(CASE WHEN tenure <= 12 AND Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN tenure <= 12 THEN 1 ELSE 0 END), 2)
    FROM customers
)
SELECT 
    Risk_Factor,
    Churn_Rate_Pct,
    RANK() OVER (ORDER BY Churn_Rate_Pct DESC) AS Risk_Rank
FROM churn_factors
ORDER BY Risk_Rank;
-- Result: New customers (0-12 months) rank #1 at 47.68%

-- Query 10: High risk customers not yet churned — retention target list
-- Business Question: Which current customers are most likely to churn next?
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    tenure,
    Contract,
    InternetService,
    TechSupport,
    OnlineSecurity,
    PaymentMethod,
    MonthlyCharges,
    ROUND(MonthlyCharges * 12, 2) AS Annual_Revenue_At_Risk,
    ROUND(MonthlyCharges * tenure, 2) AS Customer_Lifetime_Value
FROM customers
WHERE Churn = 'No'
    AND Contract = 'Month-to-month'
    AND InternetService = 'Fiber optic'
    AND (TechSupport = 'No' OR OnlineSecurity = 'No')
    AND tenure <= 12
ORDER BY MonthlyCharges DESC
LIMIT 20;
-- Result: Top 20 high-value customers matching exact churn profile — actionable retention list

-- Query 11: Average CLV of churned vs retained by contract type
-- Business Question: How much lifetime value are we losing per churned customer?
SELECT 
    Contract,
    Churn,
    COUNT(*) AS Total_Customers,
    ROUND(AVG(MonthlyCharges * tenure), 2) AS Avg_CLV,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges,
    ROUND(AVG(tenure), 1) AS Avg_Tenure_Months
FROM customers
GROUP BY Contract, Churn
ORDER BY Contract, Churn;
-- Result: Retained Two Year customers have 10x higher CLV than churned Month-to-month

-- Query 12: Highest churn rate combination of contract + internet + payment method
-- Business Question: What is the deadliest customer profile combination?
SELECT 
    Contract,
    InternetService,
    PaymentMethod,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS Annual_Revenue_At_Risk
FROM customers
GROUP BY Contract, InternetService, PaymentMethod
HAVING COUNT(*) > 50
ORDER BY Churn_Rate_Pct DESC
LIMIT 10;
-- Result: Month-to-month + Fiber optic + Electronic check = 60.37% churn rate
-- This combination churns at more than DOUBLE the company average