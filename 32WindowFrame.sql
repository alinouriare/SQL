USE AdventureWorks2014
GO

SELECT SalesOrderID,CustomerID,
SubTotal,
SUM(SubTotal) OVER (PARTITION BY CustomerID ORDER BY ORDERDATE)

FROM Sales.SalesOrderHeader
--------
--[ROWS | RANGE] BETWEEN <Start expr> AND <End expr>

--<Start expr> is one of:

--UNBOUNDED PRECEDING: The window starts in the first row of the partition
--CURRENT ROW: The window starts in the current row
--<unsigned integer literal> PRECEDING or FOLLOWING
----------------------------------------
--<End expr> is one of:

--UNBOUNDED FOLLOWING: The window ends in the last row of the partition
--CURRENT ROW: The window ends in the current row
--<unsigned integer literal> PRECEDING or FOLLOWING
*/

/*
ROWS : A physical operator. Looks at the position of the rows.
RANGE : A logical operator, but not fully implemented in SQL Server 2012 and 2014. Looks at the value of an expression over the rows.
UNBOUNDED PRECEDING : The frame starts at the first row in the set.
UNBOUNDED FOLLOWING : The frame ends at the final row in the set.
N PRECEDING : A physical number of rows before the current row. Supported only with ROWS.
N FOLLOWING : A physical number of rows after the current row. Supported only with ROWS.
CURRENT ROW : The row of the current calculation.
*/

--ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--ROWS BETWEEN UNBOUNDED PRECEDING AND  CURRENT ROW
--ROWS BETWEEN 1 PRECEDING AND  CURRENT ROW

--کار می شود دقت کنیدWindow Frame به محدوده ای که توسط
--محدوده آن در سطح پارتیشن مورد نظر می باشد

SELECT SalesOrderID,CustomerID,
SubTotal,
SUM(SubTotal) OVER (PARTITION BY CustomerID ORDER BY ORDERDATE
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS TOATA

FROM Sales.SalesOrderHeader
GO

SELECT SalesOrderID,CustomerID,
SubTotal,
SUM(SubTotal) OVER (PARTITION BY CustomerID ORDER BY ORDERDATE
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS TOATA

FROM Sales.SalesOrderHeader

GO

--------------------------------------
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS RunningTotal
FROM Sales.SalesOrderHeader
GO
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS UNBOUNDED PRECEDING
			--ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS RunningTotal
FROM Sales.SalesOrderHeader
GO
--------------------------------------
--خطا
--تعیین نقطه پایان بدون در نظر گرفتن نقطه شروع
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS UNBOUNDED FOLLOWING
		) AS RunningTotal
FROM Sales.SalesOrderHeader
GO
--همیشه ردیف جاری در نظر گرفته می شود
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS CURRENT ROW  
		) AS RunningTotal
FROM Sales.SalesOrderHeader
GO
SELECT YEAR(OrderDate) AS YEARS,
MONTH(OrderDate) AS MONTHS
,COUNT(*) COUNTS,
SUM(COUNT(*)) OVER (ORDER BY YEAR(OrderDate),MONTH(OrderDate)
ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
)AS MOTHTOW
FROM
Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2012-01-01' AND '2013-01-01'
GROUP BY YEAR(OrderDate),MONTH(OrderDate)


--Rows & Range تفاوت 
SELECT 
	SalesOrderID, OrderDate,CustomerID, SubTotal,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		)AS ROWS_RT,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW --مقادیر که تاریخ یکسانی دارند ارزش آنها یکسان می شود
		)AS RANGE_RT
FROM Sales.SalesOrderHeader
WHERE 
	CustomerID = 29837
GO
--------------------------------------------------------------------
--Show Execution Plan
--Show IO Statistics
-- توجه داشته باشید که نتیجه هر دو کوئری یکسان می باشد
USE AdventureWorks2014
GO
SET STATISTICS IO ON;
GO
--Window Frame بدون استفاده از Running Total ایجاد یک 
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
		) AS RunningTotal
FROM Sales.SalesOrderHeader;
GO
--Window Frame با استفاده از Running Total ایجاد یک 
SELECT 
	SalesOrderID, SubTotal, CustomerID,
	SUM(SubTotal) 
		OVER
		(
			PARTITION BY CustomerID ORDER BY OrderDate
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS RunningTotal
FROM Sales.SalesOrderHeader
GO
--------------------------------------------------------------------
