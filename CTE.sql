USE AdventureWorks2014
GO

WITH CTE AS(
SELECT H.SalesOrderID,H.CustomerID,H.OrderDate,H.SubTotal
FROM Sales.SalesOrderHeader H
)
SELECT * FROM CTE

GO
;WITH CTE1 (A1,A2,A3,A4)AS
(
SELECT H.SalesOrderID,H.CustomerID,H.OrderDate,H.SubTotal
FROM Sales.SalesOrderHeader H
)
SELECT * FROM CTE1

GO


USE tempdb



SELECT H.SalesOrderID,H.CustomerID,H.OrderDate,H.SubTotal
INTO SALESHEADER
FROM AdventureWorks2014.Sales.SalesOrderHeader H

GO

SELECT * FROM SALESHEADER

GO
--بدست آوردن آخرین سفارش هر مشتری
;WITH CTE AS
(

SELECT ROW_NUMBER() OVER (PARTITION BY H.CustomerID ORDER BY H.OrderDate DESC) AS ROW_NU
,H.CustomerID,H.SalesOrderID,H.OrderDate,H.SubTotal
FROM SALESHEADER H
)
SELECT * FROM CTE  A
WHERE A.ROW_NU=1

GO
--به روز رسانی قیمت کل آخرین سفارش هر مشتری
--Update و استفاده از آن در عملیاتCTE ایجاد 
;WITH CTE AS
(

SELECT ROW_NUMBER() OVER (PARTITION BY H.CustomerID ORDER BY H.OrderDate DESC) AS ROW_NU
,H.CustomerID,H.SalesOrderID,H.OrderDate,H.SubTotal
FROM SALESHEADER H
)
UPDATE CTE
SET SubTotal =+1
WHERE ROW_NU=1

GO
USE AdventureWorks2014
GO
SELECT A.CustomerID,CA.CustomerID,CA.OrderDate,CA.SalesOrderID,CA.SubTotal FROM Sales.Customer  A
CROSS APPLY
(
SELECT
DISTINCT TOP 1
H.CustomerID,
H.SalesOrderID,H.OrderDate,H.SubTotal

FROM Sales.SalesOrderHeader H
WHERE H.CustomerID=A.CustomerID
ORDER BY H.OrderDate DESC
)CA
 
 GO
 ;WITH CTE1 AS
(

SELECT ROW_NUMBER() OVER (PARTITION BY H.CustomerID ORDER BY H.OrderDate DESC) AS ROW_NU
,H.CustomerID,H.SalesOrderID,H.OrderDate,H.SubTotal
FROM SALESHEADER H
)
DELETE FROM  CTE1
WHERE ROW_NU=1

GO

;WITH CTEEurope AS(

SELECT C.CustomerID FROM Sales.Customer C
JOIN Sales.SalesTerritory S
ON C.TerritoryID=S.TerritoryID
WHERE S.[Group]='Europe'
),CTEOrder AS
(

SELECT H.CustomerID,H.SalesOrderID,H.SubTotal,H.OrderDate FROM Sales.SalesOrderHeader H
)
SELECT * FROM CTEEurope A
JOIN CTEOrder B
ON A.CustomerID=B.CustomerID
ORDER BY A.CustomerID
-----------

--1...1000 تولید اعداد
;WITH e1(n) AS
(
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
), -- 10
e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b), -- 10*10
e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2) -- 10*100
  SELECT n = ROW_NUMBER() OVER (ORDER BY n) FROM e3 ORDER BY n;
  ------------

  USE Northwind

  SELECT E.FirstName,E.LastName,E.EmployeeID
  ,E.ReportsTo
  FROM Employees E

  GO
   SELECT E.FirstName,E.LastName,E.EmployeeID
  ,E.ReportsTo,
  (SELECT ES.FirstName+ ' ' + ES.LastName   FROM Employees ES
  WHERE ES.EmployeeID=E.ReportsTo) AS MAN

  FROM Employees E

  GO
  ;WITH EM AS
  (
  SELECT E.EmployeeID,E.FirstName,E.LastName,E.ReportsTo
  FROM Employees E
  ),MAN AS
  (
  SELECT EM.FirstName,EM.LastName,EM.ReportsTo FROM Employees EM
  )
  SELECT * FROM
  EM A JOIN EM AA
  ON A.EmployeeID=AA.ReportsTo


  --------------------------------------------------------------------
--بازگشتی CTE ایجاد یک
/*
WITH CTE_Name AS
(
   Query1 (Anchor Member : تولید نتیجه نهایی)
   UNION ALL
   Query2 (Recursive Member : تولید سطوح بعدی درخت)
)
--دو کوئری وجود دارد که باید با دستورات زیر به هم متصل شودCTE در بدنه
UNION
UNION ALL
INTERSECT
EXCEPT
--Recursive Member 
اشاره کند تا بتواند رکوردهای بعدی را تشخیص دهدCTE باید به 
شرایط کافی برای پایان حلقه پیمایش را داشته باشد
*/
--------------------------------


--استخراج لیست کارمندان + نام مدیر + شماره سطح درخت

;WITH CTE_R AS
(
SELECT EmployeeID,FirstName,LastName,ReportsTo
, 1 AS EMPLOYEELEVEL FROM Employees 
WHERE ReportsTo IS NULL

UNION ALL
SELECT E.EmployeeID
,E.FirstName,E.LastName,E.ReportsTo,CTE_R.EMPLOYEELEVEL+1
FROM Employees E
JOIN CTE_R 
ON E.ReportsTo=CTE_R.EmployeeID
)
SELECT * FROM CTE_R
ORDER BY EMPLOYEELEVEL,ReportsTo


;WITH CTE_Recursive AS
(
	--استخراج ریشه
	SELECT 
		EmployeeID,FirstName,
		LastName,ReportsTo,1 AS EmployeeLevel
	FROM Employees
	WHERE ReportsTo IS NULL

	UNION ALL
	--استخراج کارمندان زیر دست هر کارمند قبلی
	SELECT 
		E.EmployeeID,E.FirstName,
		E.LastName,E.ReportsTo,
		CTE_Recursive.EmployeeLevel + 1 
	FROM Employees E
	INNER JOIN CTE_Recursive
	ON E.ReportsTo =CTE_Recursive.EmployeeID
)
SELECT 
	* 
FROM CTE_Recursive
ORDER BY EmployeeLevel,ReportsTo
GO
------------

;WITH CTE_MAN AS(
SELECT EmployeeID,ReportsTo,
FirstName,LastName,1 AS LEVELS
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL

SELECT E.EmployeeID,E.ReportsTo,E.FirstName,E.LastName
,CTE_MAN.LEVELS+1
FROM Employees E
JOIN CTE_MAN ON E.ReportsTo=CTE_MAN.EmployeeID
),CTE_RES AS
(

SELECT *,
DENSE_RANK() OVER ( ORDER BY LEVELS DESC) AS RNK
FROM CTE_MAN
)
SELECT * FROM CTE_RES
WHERE CTE_RES.RNK=1



SELECT E.EmployeeID,E.FirstName,E.ReportsTo,E.Region
,DENSE_RANK() OVER (  ORDER BY E.ReportsTo DESC)AS EWW
FROM Employees E


--------------------------------
--کارمندانی که دارای فرزند نیستند
;WITH CTE_Recursive AS
(
	--استخراج ریشه
	SELECT 
		EmployeeID,FirstName,
		LastName,ReportsTo,1 AS EmployeeLevel
	FROM Employees
	WHERE ReportsTo IS NULL

	UNION ALL
	--استخراج کارمندان زیر دست هر کارمند قبلی
	SELECT 
		E.EmployeeID,E.FirstName,
		E.LastName,E.ReportsTo,
		CTE_Recursive.EmployeeLevel + 1 
	FROM Employees E
	INNER JOIN CTE_Recursive
	ON E.ReportsTo =CTE_Recursive.EmployeeID
)
SELECT 
	* 
FROM CTE_Recursive
WHERE NOT EXISTS(SELECT * FROM Employees WHERE ReportsTo=CTE_Recursive.EmployeeID)
GO
--------------------------------
--استخراج زیر دستان کارمند شماره 5
;WITH CTE_Recursive AS
(
	--استخراج ریشه
	SELECT 
		EmployeeID,FirstName,
		LastName,ReportsTo,1 AS EmployeeLevel
	FROM Employees
	WHERE ReportsTo =5

	UNION ALL
	--استخراج کارمندان زیر دست هر کارمند قبلی
	SELECT 
		E.EmployeeID,E.FirstName,
		E.LastName,E.ReportsTo,
		CTE_Recursive.EmployeeLevel + 1 
	FROM Employees E
	INNER JOIN CTE_Recursive
	ON E.ReportsTo =CTE_Recursive.EmployeeID
)
SELECT 
	* 
FROM CTE_Recursive
ORDER BY EmployeeLevel,ReportsTo
GO
------------------------------------