DECLARE @EMPCODE INT=120
SELECT
CASE @EMPCODE
WHEN 100 THEN 'علی نوری'
WHEN 200 THEN 'امید خالقی'
WHEN 300 THEN 'سعید'
ELSE 'NOT'
END
go

DECLARE @EMPCODE INT=100
SELECT
CASE 
WHEN @EMPCODE <200 THEN 'علی نوری'
WHEN 200 BETWEEN 100 AND 400 THEN 'امید خالقی'
WHEN @EMPCODE =100 THEN 'سعید'
ELSE 'NOT'
END
go
USE AdventureWorks2014
GO

SELECT ProductID,Color,Name,ProductNumber,
CASE Color
WHEN 'Black' THEN N'سیاه'
WHEN 'Silver' THEN N'نقره ای'
WHEN 'Yellow' THEN N'زرد'
ELSE NULL
END AS [رنگ]
FROM
Production.Product
GO

SELECT ProductID,Color,Name,ProductNumber,
[رنگ]=CASE Color
WHEN 'Black' THEN N'سیاه'
WHEN 'Silver' THEN N'نقره ای'
WHEN 'Yellow' THEN N'زرد'
ELSE NULL
END 
FROM
Production.Product
GO
SELECT SalesOrderID,SalesOrderDetailID,
ProductID,UnitPrice,
CASE 
WHEN UnitPrice <=100 THEN	N'کم'
WHEN UnitPrice >100 and UnitPrice <500 THEN	N'متوسط'
WHEN UnitPrice BETWEEN 500 AND 1200 THEN	N'خوب'
WHEN UnitPrice >1200 THEN	N'بالا'
END AS UnitPriceDesc
FROM Sales.SalesOrderDetail
GO

SELECT SalesOrderID,SalesOrderDetailID,
ProductID,UnitPrice,
CASE 
WHEN UnitPrice <=100 THEN	N'کم'
WHEN UnitPrice >100 and UnitPrice <500 THEN	N'متوسط'
WHEN UnitPrice BETWEEN 500 AND 1200 THEN	N'خوب'
WHEN UnitPrice >1200 THEN	N'بالا'
END AS UnitPriceDesc
FROM Sales.SalesOrderDetail
ORDER BY
CASE
WHEN UnitPrice <=100 THEN	2
WHEN UnitPrice >100 and UnitPrice <500 THEN	 1
WHEN UnitPrice BETWEEN 500 AND 1200 THEN	3
WHEN UnitPrice >1200 THEN	4
END 
GO