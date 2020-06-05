GO
--Analytical Function در Over بررسی نحوه استفاده از اپراتور 
GO
--Lead , Lag بررسی

GO
IF OBJECT_ID('Revenue')>0
	DROP TABLE Revenue
GO
--ایجاد جدول درآمد
CREATE TABLE Revenue
(
	DepartmentID int,
	Revenue int,
	Year int
)
 GO
 --درج تعدادی رکورد تستی در جدول
INSERT INTO Revenue VALUES 
	(1,10030,1998),(2,20000,1998),(3,40000,1998),
	(1,20000,1999),(2,60000,1999),(3,50000,1999),
	(1,40000,2000),(2,40000,2000),(3,60000,2000),
	(1,30000,2001),(2,30000,2001),(3,70000,2001),
	(1,90000,2002),(2,20000,2002),(3,80000,2002),
	(1,10300,2003),(2,1000,2003), (3,90000,2003),
	(1,10000,2004),(2,10000,2004),(3,10000,2004),
	(1,20000,2005),(2,20000,2005),(3,20000,2005),
	(1,40000,2006),(2,30000,2006),(3,30000,2006),
	(1,70000,2007),(2,40000,2007),(3,40000,2007),
	(1,50000,2008),(2,50000,2008),(3,50000,2008),
	(1,20000,2009),(2,60000,2009),(3,60000,2009),
	(1,30000,2010),(2,70000,2010),(3,70000,2010),
	(1,80000,2011),(2,80000,2011),(3,80000,2011),
	(1,10000,2012),(2,90000,2012),(3,90000,2012)
GO
--مشاهده رکوردهای درج شده در جدول درآمد 
SELECT 
	DepartmentID, Revenue, Year
FROM Revenue WHERE DepartmentID = 1
GO
--Lead,Lag استفاده از  
--Lead : دسترسی به داده‌های سطر بعدی نسبت به سطر جاری
--Lag : دسترسی به داده‌های سطر قبلی نسبت به سطر جاری
GO

select DepartmentID,Revenue,Year,
LEAD(Revenue) over (order by [year])  as 'next val',
LAG(Revenue) over (order by [year]) as 'left val'
from Revenue
where DepartmentID=1
order by [year]
go

select DepartmentID,Revenue,Year,
LEAD(Revenue,2) over (order by [year])  as 'next val',
LAG(Revenue,2) over (order by [year]) as 'left val'
from Revenue
where DepartmentID=1
order by [year]
go

select DepartmentID,Revenue,Year,
LEAD(Revenue,2,0) over (order by [year])  as 'next val',
LAG(Revenue,2,0) over (order by [year]) as 'left val'
from Revenue
where DepartmentID=1
order by [year]
go
--FIRST_VALUE,LAST_VALUE بررسی 
GO
USE AdventureWorks2014
GO
--FIRST_VALUE : باز گرداندن اولین مقدار از یک مجموعه
--LAST_VALUE : باز گرداندن آخرین مقدار از یک مجموعه
--Window Frame ترکیب با 
SELECT 
	SalesOrderID,SalesOrderDetailID,OrderQty,
	FIRST_VALUE(SalesOrderDetailID) OVER (ORDER BY SalesOrderDetailID) FstValue,
	LAST_VALUE(SalesOrderDetailID) OVER (ORDER BY SalesOrderDetailID RANGE BETWEEN UNBOUNDED PRECEDING  AND UNBOUNDED FOLLOWING) LstValue
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY SalesOrderID,SalesOrderDetailID,OrderQty
GO
SELECT 
	SalesOrderID,SalesOrderDetailID,OrderQty,
	FIRST_VALUE(SalesOrderDetailID) OVER (PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID RANGE BETWEEN UNBOUNDED PRECEDING  AND UNBOUNDED FOLLOWING) FstValue,
	LAST_VALUE(SalesOrderDetailID) OVER (PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID RANGE BETWEEN UNBOUNDED PRECEDING  AND UNBOUNDED FOLLOWING) LstValue
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY SalesOrderID,SalesOrderDetailID,OrderQty
GO
--------------------------------------------------------------------
--Cume_Dist بررسی تابع 
--توزیع تجمعی
SELECT 
	SalesOrderID, OrderQty,
	CUME_DIST() OVER(ORDER BY SalesOrderID) AS CDist
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY CDist DESC
GO
/*
--وجود دارد SalesOrderID=43667 چه تعداد رکورد با شرط 
A1=4
*********
--وجود دارد SalesOrderID<43667 چه تعداد رکورد با شرط 
A2=1
*********
--تعداد کل رکوردها چقدر است
A3=10
*********
--43667 محاسبه برای سطر
CUME_DIST()=(A1+A2)/A3 ===> (4+1)/10=0.5
*/
GO
--------------------------------------------------------------------
USE AdventureWorks2014
GO
--Percent_Rank بررسی تابع
--تعیین رتبه‌بندی 
--PERCENT_RANK () = (RANK () – 1) / (Total Rows – 1)
GO
SELECT 
	SalesOrderID, OrderQty, ProductID,
	RANK() OVER(PARTITION BY SalesOrderID ORDER BY ProductID ) Rnk,
	PERCENT_RANK() OVER(PARTITION BY SalesOrderID ORDER BY ProductID ) AS PctDist
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN (43670, 43669, 43667, 43663)
ORDER BY PctDist DESC
GO
--------------------------------------------------------------------