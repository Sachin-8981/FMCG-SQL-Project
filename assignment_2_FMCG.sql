create database assignment_2_FMCG;
use assignment_2_FMCG;

alter table orders
modify column orderdate date;

/* 1. Customers With Decreasing Purchase Trend. */
WITH OrderRanks AS (
    SELECT 
        o.CustomerID,
        o.OrderID,
        o.Quantity,
        ROW_NUMBER() OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate DESC) AS OrderRank
    FROM orders o
)
SELECT 
    r1.CustomerID,
    r1.Quantity AS LatestQty,
    r2.Quantity AS PreviousQty,
    (r1.Quantity - r2.Quantity) AS QuantityChange
FROM OrderRanks r1
JOIN OrderRanks r2 
    ON r1.CustomerID = r2.CustomerID AND r1.OrderRank = 1 AND r2.OrderRank = 2
WHERE r1.Quantity < r2.Quantity;

/* 2. Repeat Customers vs. One-Time Buyers */
WITH OrderCounts AS (
    SELECT CustomerID, COUNT(*) AS OrderCount
    FROM orders
    GROUP BY CustomerID
)
SELECT 
    c.Name,
    o.OrderCount,
    CASE 
        WHEN o.OrderCount > 1 THEN 'Repeat Buyer'
        ELSE 'One-Time Buyer'
    END AS CustomerType
FROM OrderCounts o
JOIN customers c ON o.CustomerID = c.CustomerID;

/* 3. Find top 5 customers who spent the most. */
select c.name , round(sum(o.quantity * p.price),2) as Total_spent
from orders o 
join customers c on c.customerid = o.customerid
join products p on p.productid = o.productid
group by c.name
order by Total_spent desc
limit 5;

/* 4. Customer Spending Quartiles. */
WITH Spending AS (
    SELECT 
        o.CustomerID,
        c.Name,
        SUM(o.Quantity * p.Price) AS TotalSpent
    FROM orders o
    JOIN customers c ON o.CustomerID = c.CustomerID
    JOIN products p ON o.ProductID = p.ProductID
    GROUP BY o.CustomerID, c.Name
)
SELECT *,
    NTILE(4) OVER (ORDER BY TotalSpent DESC) AS SpendingQuartile
FROM Spending;

/* 5. Find the most ordered product category. */
select count(o.orderid ) as Total_orders , p.category
from orders o 
join products p on o.productid = p.productid
group by p.category
order by Total_orders desc
limit 1;

/* 6. Show each customer's total spending and their rank based on spending within their city. */
with cte as (
SELECT 
    c.Name,
    c.Location,
    round(SUM(o.Quantity * p.Price),2) AS TotalSpent
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN products p ON o.ProductID = p.ProductID
GROUP BY c.CustomerID, c.Name, c.Location)
select *, dense_rank() OVER (ORDER BY TOTALSPENT DESC) FROM CTE;


