--صفحه بندی رکوردها 
/*
ORDER BY order_by_expression
    [ COLLATE collation_name ] 
    [ ASC | DESC ] 
    [ ,...n ] 
[ <offset_fetch> ]
 
 
<offset_fetch> ::=
{ 
    OFFSET { integer_constant | offset_row_count_expression } { ROW | ROWS }
    [
      FETCH { FIRST | NEXT } {integer_constant | fetch_row_count_expression } { ROW | ROWS } ONLY
    ]
}
--OFFSET نقطه شروع
--FETCH تعداد رکوردهای قابل نمایش
--FIRST | NEXT هر دو یکسان هستند
--ROW | ROWS  هر دو یکسان هستند
*/
USE AdventureWorks2014
GO
SELECT * FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID
OFFSET 3 ROWS FETCH FIRST 10 ROWS ONLY
GO
SELECT 
	* 
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID
	OFFSET 3 ROWS 
	-----------
	--صفحه بندی رکوردها* مقایسه روش های مختلف پیاده سازی

USE AdventureWorks2014
GO
-- SQL Server 2000
DECLARE @RowsPerPage INT = 10, @PageNumber INT = 6
SELECT 
	SalesOrderDetailID, 
	SalesOrderID, ProductID
FROM
	(
		SELECT TOP (@RowsPerPage)
			SalesOrderDetailID, 
			SalesOrderID, ProductID
		FROM
		(
			SELECT TOP ((@PageNumber)*@RowsPerPage)
					SalesOrderDetailID, 
					SalesOrderID, ProductID
			FROM Sales.SalesOrderDetail
				ORDER BY SalesOrderDetailID
		) AS SOD
		ORDER BY SalesOrderID,SalesOrderDetailID DESC
	) AS SOD2
	ORDER BY SalesOrderID,SalesOrderDetailID ASC
GO
-- SQL Server 2005,2008,2008R2
DECLARE @RowsPerPage INT = 10, @PageNumber INT = 6
SELECT 
	SalesOrderDetailID, SalesOrderID, ProductID
FROM 
(
	SELECT 
		SalesOrderDetailID, SalesOrderID, ProductID,
		ROW_NUMBER() OVER (ORDER BY SalesOrderID,SalesOrderDetailID) AS RowNum
	FROM Sales.SalesOrderDetail 
) AS SOD
WHERE 
	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
	AND @RowsPerPage*(@PageNumber)
GO
-- SQL Server 2012,2014,2016
DECLARE @RowsPerPage INT = 10, @PageNumber INT = 6
SELECT 
	SalesOrderDetailID, SalesOrderID, ProductID
FROM Sales.SalesOrderDetail
ORDER BY SalesOrderID,SalesOrderDetailID
	OFFSET (@PageNumber-1)*@RowsPerPage ROWS
	FETCH NEXT @RowsPerPage ROWS ONLY
GO
--------------------------------------------------------------------
USE Northwind
GO
--یکی از بهترین روش ها
--ارسال رکوردهای صفحه مربوطه به همراه تعداد کل رکوردهای منطبق با شرط
;WITH CTE1 AS
(
	SELECT 
		ROW_NUMBER() OVER (ORDER BY O.OrderID) AS Row_NO,
		o.OrderID,o.OrderDate,
		od.ProductID,P.ProductName 
	FROM Orders O
		INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
		LEFT JOIN Products P ON P.ProductID=OD.ProductID
	WHERE 
		DATEPART(YEAR,O.OrderDate)=1998
),
CTE2 AS 
(
	SELECT COUNT(OrderID) AS REC_COUNT  FROM CTE1
)
SELECT CTE1.*,CTE2.* FROM CTE1,CTE2
	WHERE CTE1.Row_NO BETWEEN 6 AND 10
GO
