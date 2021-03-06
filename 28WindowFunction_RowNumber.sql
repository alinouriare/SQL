USE AdventureWorks2014
GO
SELECT ROW_NUMBER()OVER (ORDER BY SALESORDERID) AS PART
,H.* FROM Sales.SalesOrderHeader H
GO
SELECT ROW_NUMBER()OVER (ORDER BY ORDERDATE) AS PART
,H.* FROM Sales.SalesOrderHeader H

GO

SELECT * FROM
(SELECT ROW_NUMBER() OVER (ORDER BY CustomerId) AS ROW_NO,* FROM Sales.SalesOrderHeader )P
WHERE P.ROW_NO BETWEEN 100 AND 200
go

USE tempdb
GO
CREATE TABLE #T ([NAME] NVARCHAR(50) )
GO
INSERT INTO #T 
SELECT 'ALI' UNION ALL
SELECT 'REZA' UNION ALL
SELECT 'HASAN'  
GO
SELECT *,ROW_NUMBER() OVER(ORDER BY [NAME]) AS NUMBER FROM #T
GO

SELECT *,ROW_NUMBER() OVER(ORDER BY (SELECT 100)) AS NUMBER FROM #T
GO
SELECT *,ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NUMBER FROM #T
GO
SELECT *,ROW_NUMBER() OVER() AS NUMBER FROM #T
GO

USE AdventureWorks2014
GO
SELECT * FROM(SELECT SalesOrderID,OrderDate,CustomerID,SubTotal
,ROW_NUMBER() OVER
(PARTITION BY CustomerID ORDER BY SalesOrderID ) AS NUB
FROM Sales.SalesOrderHeader

)P
WHERE P.NUB=2
GO

SELECT * FROM(SELECT SalesOrderID,OrderDate,CustomerID,SubTotal
,ROW_NUMBER() OVER
(PARTITION BY CustomerID ORDER BY SalesOrderID ) AS NUB
FROM Sales.SalesOrderHeader

)P
WHERE P.NUB=2
GO

SELECT * FROM(SELECT SalesOrderID,OrderDate,CustomerID,SubTotal
,ROW_NUMBER() OVER
(PARTITION BY CustomerID ORDER BY OrderDate DESC ) AS NUB
FROM Sales.SalesOrderHeader

)P
WHERE P.NUB=1
GO

