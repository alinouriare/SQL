USE AdventureWorks2014
GO

SELECT 
MIN(UnitPrice) AS MIN_UnitPrice,
MAX(UnitPrice) AS MAX_UnitPrice,
COUNT(UnitPrice)AS COUNT_UnitPrice,
COUNT_BIG(UnitPrice) AS COUNT_BIG_UnitPrice,
SUM(UnitPrice) AS SUM_UnitPrice,
AVG(UnitPrice) AS AVG_UnitPrice,
AVG(UnitPrice*1.00)AS AVG_UnitPrice
FROM Sales.SalesOrderDetail
GO
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID=43667
GO
SELECT * FROM Sales.SalesOrderDetail
WHERE SalesOrderID=43667
GO
SELECT SUM(UnitPrice*OrderQty) FROM Sales.SalesOrderDetail
WHERE SalesOrderID=43667
GO

SELECT 
SUM(DISTINCT UnitPrice) AS SUM_DISTINCT_UnitPrice,
SUM(UnitPrice) AS SUM_UnitPrice

FROM Sales.SalesOrderDetail
GO

select CustomerID,SalesOrderID,cast (OrderDate as date) as [date]
,sum( SubTotal) over (partition by CustomerID order by OrderDate) as total
,SubTotal
from Sales.SalesOrderHeader


USE AdventureWorks2014
GO
SELECT SalesOrderID, ProductID, OrderQty
    ,SUM(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Total'
    ,AVG(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Avg'
    ,COUNT(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Count'
    ,MIN(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Min'
    ,MAX(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Max'
FROM Sales.SalesOrderDetail 
--WHERE SalesOrderID IN(43659,43664)
GO
SELECT 
	sd.SalesOrderID, sd.ProductID, sd.OrderQty,
    (SELECT SUM(sd1.OrderQty) FROM Sales.SalesOrderDetail sd1 WHERE sd1.SalesOrderID = sd.SalesOrderID) AS 'Total',
	(SELECT AVG(sd1.OrderQty) FROM Sales.SalesOrderDetail sd1 WHERE sd1.SalesOrderID = sd.SalesOrderID) AS 'Avg',
	(SELECT COUNT(sd1.OrderQty) FROM Sales.SalesOrderDetail sd1 WHERE sd1.SalesOrderID = sd.SalesOrderID) AS 'Count',
	(SELECT MIN(sd1.OrderQty) FROM Sales.SalesOrderDetail sd1 WHERE sd1.SalesOrderID = sd.SalesOrderID) AS 'Min',
	(SELECT MAX(sd1.OrderQty) FROM Sales.SalesOrderDetail sd1 WHERE sd1.SalesOrderID = sd.SalesOrderID) AS 'Max'
FROM Sales.SalesOrderDetail sd
--WHERE sd.SalesOrderID IN (43659, 43664)
GROUP BY sd.SalesOrderID, sd.ProductID, sd.OrderQty
GO
-----------------