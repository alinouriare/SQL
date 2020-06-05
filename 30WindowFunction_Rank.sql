--RANKنحوه استفاده از 
GO
--جهت دادن رتبه به جداول مورد استفاده قرار می گیرد
--دارای گپ بین مقادیر می باشد
use AdventureWorks2014
GO

SELECT BusinessEntityID,TerritoryID
,SalesQuota ,RANK() OVER (ORDER BY SalesQuota)
AS [RANK] FROM Sales.SalesPerson
GO

SELECT I.ProductID,I.LocationID,P.Name
,I.Quantity,I.LocationID,
RANK() OVER(PARTITION BY LocationID  ORDER BY I.Quantity) AS [RANK]
FROM Production.ProductInventory I
JOIN Production.Product P
ON I.ProductID=P.ProductID
WHERE I.LocationID BETWEEN 3 AND 4
ORDER BY I.LocationID

GO

SELECT  *, RANK() OVER (PARTITION BY YEAR( RateChangeDate) 
ORDER BY RATE DESC)
FROM HumanResources.EmployeePayHistory


-DENSE_RANK نحوه استفاده از 
GO
--جهت دادن رتبه به جداول مورد استفاده قرار می گیرد
--عدم گپ بین مقادیر می باشد
SELECT 
	BusinessEntityID,TerritoryID,SalesQuota,
	DENSE_RANK() OVER (ORDER BY SalesQuota) AS Rank
FROM Sales.SalesPerson
GO
--تخصیص رتبه به جدول رکوردهای جدول موجودی محصول
SELECT 
	i.ProductID, p.Name, i.LocationID, i.Quantity,
    DENSE_RANK() OVER (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank
FROM Production.ProductInventory AS i 
INNER JOIN Production.Product AS p 
    ON i.ProductID = p.ProductID
WHERE i.LocationID BETWEEN 3 AND 4
ORDER BY i.LocationID;
GO
--ده رکورد رتبه برتر جدول تاریخچه پرداخت به کارمندان
SELECT TOP(10) 
	BusinessEntityID, Rate, 
    DENSE_RANK() OVER (ORDER BY Rate DESC) AS RankBySalary
FROM HumanResources.EmployeePayHistory
GO
--------------------------------------------------------------------

--NTILE نحوه استفاده از 
--تبدیل رکوردهای جدول به گروه های دلخواه
GO
DECLARE @NTILE_Var int = 7;
SELECT 
	BusinessEntityID,TerritoryID,SalesQuota,
	NTILE(@NTILE_Var) OVER (ORDER BY SalesQuota) AS NTILE
FROM Sales.SalesPerson
GO
/*
--RecCount= Count_NTile * (RecCount / Count_NTile) + (RecCount % Count_NTile)

   |  7
17	-------	
14 |  2
---
3

===> 7*2+3 
هفت گروه ایجاد می شود که هر کدام 2 رکورد دارند 3 رکورد باقی مانده از بالا تخصیص داده می شود
*/
GO
--Window Function کاربرد
--Finding the First N Rows of Every Group پیدا کردن ان سطر اول از هر گروه
--بدست آوردن آخرین سفارش هر مشتری

/*
--Show Execution Plan
--Show SQL Query Stress
	Iteration : 10
	Thread : 200
-----
SELECT 
	session_id,
	start_time,
	command,
	database_id,
	plan_handle,
	wait_type,
	last_wait_type,
	ST.text,
	QP.query_plan
FROM sys.dm_exec_requests R
	CROSS APPLY sys.dm_exec_sql_text(R.plan_handle) ST
	CROSS APPLY sys.dm_exec_query_plan(R.plan_handle) QP
WHERE session_id>50
*/
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
--Window Function استفاده از 
SELECT * FROM 
(
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS ROW_NO
		,SalesOrderID,OrderDate,
		CustomerID,SubTotal
	FROM Sales.SalesOrderHeader
) Q
WHERE Q.ROW_NO=1
GO
--Cross Apply استفاده از 
SELECT 
	DISTINCT Q1.CustomerID,
	Q2.*
FROM Sales.SalesOrderHeader Q1
	CROSS APPLY 
	(
		SELECT TOP 1 
			SalesOrderID,OrderDate,
			SubTotal 
		FROM 
			Sales.SalesOrderHeader 
		WHERE 
			CustomerID=Q1.CustomerID
		ORDER BY OrderDate DESC
	) Q2
ORDER BY Q1.CustomerID
GO
--حذف رکوردهای تکراری
USE tempdb
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('DupData')>0
	DROP TABLE DupData
GO
--ایجاد جدول تستی
CREATE TABLE DupData
(
	ID INT IDENTITY PRIMARY KEY,
	StudentCode VARCHAR(10),
	FullName NVARCHAR(100),
	BDate CHAR(10)
)
GO
--درج تعدادی رکورد تستی در جدول 
INSERT INTO DupData (StudentCode,FullName,BDate) VALUES
	(1000,N'مسعود طاهری','1361/06/01'),
	(2000,N'فرید طاهری','1362/06/01'),
	(3000,N'مجید طاهری','1368/06/01'),
	(4000,N'علیرضا طاهری','1393/06/01'),
	(1000,N'علی طاهری','1378/06/01'),
	(2000,N'احمد غفاری','1363/06/01'),
	(1000,N'خدیجه افروزنیا','1363/06/01'),
	(5000,N'علیرضا نصیری','1360/06/01'),
	(6000,N'حامد اکبری مقدم','1369/06/01'),
	(1000,N'محمد صباغی','1363/06/01')
GO		
--مشاهده رکوردها تستی موجود در جدول
SELECT * FROM DupData ORDER BY StudentCode
GO
--تخصیص شماره ردیف به رکوردهای جدول
SELECT 
	ROW_NUMBER() OVER (PARTITION BY StudentCode ORDER BY BDate) AS Row_No,
	*
FROM DupData
GO
--مشاهده رکوردهای تکراری
SELECT * FROM 
(
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY StudentCode ORDER BY BDate) AS Row_No,
		*
	FROM DupData
)Q
WHERE Q.Row_No>1
GO
--CTE مشاهده رکوردهای تکراری * استفاده از 
;WITH CTE_Dup AS 
(
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY StudentCode ORDER BY BDate) AS Row_No,
		*
	FROM DupData
)
SELECT * FROM CTE_Dup
	WHERE Row_No>1
GO
--CTE حذف رکوردهای تکراری * استفاده از 
;WITH CTE_Dup AS 
(
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY StudentCode ORDER BY BDate) AS Row_No,
		*
	FROM DupData
)
DELETE FROM CTE_Dup
	WHERE Row_No>1
GO
--مشاهده کلیه رکوردهای جدول
SELECT * FROM DupData
GO
--حذف جدول
DROP TABLE DupData
GO
