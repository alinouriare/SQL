use AdventureWorks2014
GO
SELECT
YEAR(OrderDate),
SUM( SubTotal) AS TOTAL 
FROM
Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
GO
SELECT
YEAR(OrderDate),
MONTH(OrderDate),
SUM( SubTotal) AS TOTAL 
FROM
Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate),MONTH(OrderDate)
ORDER BY YEAR(OrderDate),MONTH(OrderDate)
GO

SELECT P.Color,COUNT(D.SalesOrderID) AS NUMBERCOLOR FROM Sales.SalesOrderDetail D
JOIN Production.Product P
ON D.ProductID=P.ProductID
WHERE P.Color IS NOT NULL
GROUP BY P.Color
ORDER BY P.Color
GO

SELECT P.Color,COUNT(D.SalesOrderID) AS NUMBERCOLOR FROM Sales.SalesOrderDetail D
JOIN Production.Product P
ON D.ProductID=P.ProductID
WHERE P.Color IN('Black','Blue','Silver')
GROUP BY ALL P.Color
ORDER BY P.Color

go
SELECT YEAR(h.OrderDate) as y,d.ProductID,count(d.SalesOrderID) FROM Sales.SalesOrderDetail d
JOIN Production.Product p
on d.ProductID=d.ProductID
join Sales.SalesOrderHeader h
on d.SalesOrderID=h.SalesOrderID
group by YEAR(h.OrderDate) ,d.ProductID
having count(d.SalesOrderID) >50000
order by YEAR(h.OrderDate)

go

SELECT YEAR(D.OrderDate),MONTH(D.OrderDate),SUM(D.SubTotal)
FROM Sales.SalesOrderHeader D
GROUP BY YEAR(D.OrderDate),MONTH(D.OrderDate) WITH ROLLUP
--ORDER BY YEAR(D.OrderDate),MONTH(D.OrderDate)
GO
SELECT YEAR(D.OrderDate),SUM(D.SubTotal),MONTH(d.OrderDate)
,GROUPING(YEAR(D.OrderDate)) AS Group_Year
,GROUPING(month(D.OrderDate)) AS Group_Year
FROM Sales.SalesOrderHeader D
GROUP BY YEAR(D.OrderDate) ,MONTH(d.OrderDate) WITH ROLLUP
go

--Group By در Cube استفاده از
GO
--مشاهده جمع سفارش های هر سال
SELECT 
	YEAR(OrderDate) AS [Year],SUM(SubTotal) AS Sum_SubTotal
FROM Sales.SalesOrderHeader 
GROUP BY YEAR(OrderDate) WITH CUBE
--GROUP BY CUBE(YEAR(OrderDate))
GO
--مشاهده جمع سفارش های هر سال و ماه
SELECT 
	YEAR(OrderDate) AS [Year],MONTH(OrderDate) AS [MONTH]
	,SUM(SubTotal) AS Sum_SubTotal
FROM Sales.SalesOrderHeader 
GROUP BY YEAR(OrderDate),MONTH(OrderDate) WITH CUBE
--**********
--Group By در CUBE تشخیص سطرهای حاصل از
GO
--مشاهده جمع سفارش های هر سال و ماه
SELECT 
	YEAR(OrderDate) AS [Year],MONTH(OrderDate) AS [MONTH]
	,SUM(SubTotal) AS Sum_SubTotal
	,GROUPING(YEAR(OrderDate)) AS GROUPING_Year
	,GROUPING(MONTH(OrderDate)) AS GROUPING_Month
FROM Sales.SalesOrderHeader 
GROUP BY YEAR(OrderDate),MONTH(OrderDate) WITH ROLLUP
-----------------------------

SELECT YEAR(D.OrderDate),SUM(D.SubTotal),d.CustomerID

FROM Sales.SalesOrderHeader D
GROUP BY grouping sets(
YEAR(D.OrderDate),
d.CustomerID
)
--Group By با استفاده از Pivot Table ساخت 
GO
USE NikAmoozShop
GO
 SELECT 
	SUBSTRING(OrderDate_Shamsi,1,4) AS [سال شمسی],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '01' THEN 1 ELSE 0 END)AS [فروردین],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '02' THEN 1 ELSE 0 END)AS [اردیبهشت],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '03' THEN 1 ELSE 0 END)AS [خرداد],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '04' THEN 1 ELSE 0 END)AS [تیر],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '05' THEN 1 ELSE 0 END)AS [مرداد],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '06' THEN 1 ELSE 0 END)AS [شهریور],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '07' THEN 1 ELSE 0 END)AS [مهر],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '08' THEN 1 ELSE 0 END)AS [آبان],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '09' THEN 1 ELSE 0 END)AS [آذر],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '10' THEN 1 ELSE 0 END)AS [دی],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '11' THEN 1 ELSE 0 END)AS [بهمن],
	SUM(CASE SUBSTRING(OrderDate_Shamsi,6,2) WHEN '12' THEN 1 ELSE 0 END)AS [اسفند]
FROM Sales.OrderHeader
GROUP BY SUBSTRING(OrderDate_Shamsi,1,4) WITH CUBE
GO
--Grouping_ID استفاده از

-- به برنامه نویس امکان میدهد بداند در هر سطر از نتیجه كوئري، کدام ستونها از گروه بندی غایب هستند GROUPING_ID
--با استفاده این تابع می توان فهمید که گروه بندی به ازای کدامیک از ستون ها انجام شده است

--ارزش بیتی
/*
GROUPING_ID(EmployeeID,ShipStateCode,SUBSTRING(OrderDate_Shamsi,1,4))
				2^2			2^1					2^0
*/			
SELECT 	
	--EmployeeID,
	ShipStateCode,
	SUBSTRING(OrderDate_Shamsi,1,4) AS Year_Shamsi,
	COUNT(OrderHeaderID) AS COUNT_OrderHeaderID,
	GROUPING_ID(EmployeeID,ShipStateCode,SUBSTRING(OrderDate_Shamsi,1,4)) AS [GROUPING_ID]
FROM Sales.OrderHeader
GROUP BY GROUPING SETS 
	(
		ShipStateCode,
		(SUBSTRING(OrderDate_Shamsi,1,4),EmployeeID),
		SUBSTRING(OrderDate_Shamsi,1,4)
	)
---------------
SELECT 	
	EmployeeID,
	ShipStateCode,
	SUBSTRING(OrderDate_Shamsi,1,4) AS Year_Shamsi,
	COUNT(OrderHeaderID) AS COUNT_OrderHeaderID,
	GROUPING_ID(EmployeeID,ShipStateCode,SUBSTRING(OrderDate_Shamsi,1,4)) AS [GROUPING_ID],
	CASE GROUPING_ID(EmployeeID,ShipStateCode,SUBSTRING(OrderDate_Shamsi,1,4)) 
		WHEN 2 THEN N'سال و کارمند'
		WHEN 5 THEN N'استان'
		WHEN 6 THEN N'سال'
	END AS N'گروه بندی بر اساس'
FROM Sales.OrderHeader
GROUP BY GROUPING SETS 
	(
		ShipStateCode,
		(SUBSTRING(OrderDate_Shamsi,1,4),EmployeeID),
		SUBSTRING(OrderDate_Shamsi,1,4)
	)
GO
