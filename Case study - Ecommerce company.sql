create database E_Commerce_Company;

use E_Commerce_Company;

-- 1. Analyzing the data by describing the content
DESC Customers;
DESC Products;
DESC Orders;
DESC OrderDetails;

-- 2. Market Segment Analysis 
-- Identifying the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization
SELECT location,Count(*) AS number_of_customers
FROM Customers 
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;

-- 3. Identifying Top cities which should be focused as a part of marketing strategies
Delhi,Chennai,Jaipur

-- 4.Engagement Depth Analysis 
-- It will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.
SELECT NumberOfOrders,Count(*)  AS CustomerCount
FROM
   (SELECT customer_id,COUNT(*) AS NumberOfOrders
     FROM Orders 
     GROUP BY customer_id)as order_count 
     GROUP BY NumberOfOrders
     ORDER BY NumberOfOrders;
     
-- Here we can analyse as the number of order increases , the Customer count Descreases
-- In Engagement Depth Analysis, we can identify that major customer belong to Occasional Shoppers

-- 5.Purchase High Value Products
-- Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
SELECT product_id,AVG(quantity) AS AvgQuantity,SUM(quantity*price_per_unit) as TotalRevenue
FROM orderdetails
GROUP BY product_id
HAVING AvgQuantity=2
ORDER BY TotalRevenue DESC;
-- Product 1 Exhibits the highest Total Revenue

-- 6.Category-wise Customer reach
-- For each product category, calculate the unique number of customers purchasing from it
SELECT Products.category, COUNT(DISTINCT Orders.customer_ID)as unique_customers
FROM Products
JOIN Orderdetails on Products.product_id=Orderdetails.product_id
JOIN Orders ON Orderdetails.order_id = Orders.order_id
GROUP BY Products.category
ORDER BY unique_customers DESC;
-- Electronics category needs more focus as it is in high demand among the customers.

-- 7.Sales Trend Analysis
-- It involves analyzing the month-on-month percentage change in total sales to identify growth trends.
WITH sales as
(SELECT DATE_FORMAT(order_date,'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY Month)
SELECT Month,TotalSales,
ROUND(((TotalSales-LAG(TotalSales) over (order by Month))/LAG(TotalSales) Over(order by Month))*100 ,2)AS PercentChange
FROM sales;
-- As per Sales Trend Analysis , February 2024 experienced the largest decline in sales

-- 8.Average Order Value Fluctuation
-- the objective is to analyse how the average order value changes month on month
With avg_sales as
(SELECT DATE_FORMAT(order_date,'%Y-%m') AS Month, AVG(total_amount) AS AvgOrderValue 
FROM Orders
GROUP BY Month)
SELECT Month,AvgOrderValue,
ROUND((AvgOrderValue-LAG(AvgOrderValue)over(order by month)),2) as ChangeInValue
FROM avg_sales
ORDER BY ChangeInValue desc;
-- December has the highest average order value

-- 9.Inventory Refresh Rate
-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking
SELECT product_id,Count(*) as SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;
-- product_id 7 has the highest turnover rates and needs to be restocked frequently

-- 10.Low Engagement Products
-- List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest
SELECT Products.product_id,Products.name,COUNT(Distinct Customers.Customer_id) AS UniqueCustomerCount
FROM Products
JOIN  Orderdetails ON Products.product_id=Orderdetails.product_id
JOIN Orders on Orderdetails.order_id=Orders.order_id
JOIN Customers on Orders.customer_id=Customers.customer_id
GROUP BY Products.product_id,Products.name
HAVING UniqueCustomerCount < 0.4*(SELECT COUNT(Distinct Customer_id)) FROM Customers;

-- 11.Customer Acquisition Trends
-- month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts
With FirstPurchases as
(SELECT Customer_id,MIN(order_date)AS FirstPurchasesMonth
FROM Orders
GROUP BY Customer_id)
SELECT DATE_FORMAT(FirstPurchasesMonth,'%Y-%m') AS FirstPurchaseMonth,
COUNT(Distinct Customer_id) AS TotalNewCustomers
FROM FirstPurchases
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth ASC;
-- There is a downward trend which implies marketing campaign is not much effective

-- 12. Peak Sales Period Identification
-- identifying the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
SELECT DATE_FORMAT(order_date,'%Y-%m') as Month, SUM(total_amount) as TotalSales
FROM Orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;
-- September,December will require major restocking of product and increased staffs




