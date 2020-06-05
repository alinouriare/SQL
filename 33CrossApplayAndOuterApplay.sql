USE AdventureWorks2014
GO

SELECT RTRIM(P.FirstName) + ' '+LTRIM(P.LastName) AS FULLNAME,D.City
FROM Person.Person AS P
JOIN HumanResources.Employee AS E
ON P.BusinessEntityID=E.BusinessEntityID
JOIN 
(
SELECT BEA.BusinessEntityID,A.City FROM Person.[Address] AS A
JOIN Person.BusinessEntityAddress AS BEA
ON A.AddressID=BEA.AddressID
) AS D
ON P.BusinessEntityID=D.BusinessEntityID
ORDER BY P.LastName,P.FirstName
-----

SET STATISTICS IO ON

SELECT H.SalesOrderID,H.OrderDate
,
(SELECT MAX(D.UnitPrice) FROM Sales.SalesOrderDetail D
WHERE D.SalesOrderID=H.SalesOrderID
) AS OP

FROM Sales.SalesOrderHeader H



SELECT H.SalesOrderID,H.OrderDate,
MAX(D.UnitPrice) 

FROM Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID=D.SalesOrderID
GROUP BY H.SalesOrderID,H.OrderDate

GO

SELECT H.SalesOrderID,H.OrderDate,CR.MAXUNIT
FROM Sales.SalesOrderHeader H
CROSS APPLY 
(
SELECT MAX(D.UnitPrice) AS MAXUNIT FROM Sales.SalesOrderDetail D
WHERE D.SalesOrderID=H.SalesOrderID
)AS CR
go


SELECT H.SalesOrderID,H.OrderDate,CR.MAXUNIT
FROM Sales.SalesOrderHeader H
outer APPLY 
(
SELECT MAX(D.UnitPrice) AS MAXUNIT FROM Sales.SalesOrderDetail D
WHERE D.SalesOrderID=H.SalesOrderID
)AS CR
--where CR.MAXUNIT>50
use master
GO
USE master 
GO 
SELECT 
	DB_NAME(database_id) AS [Database], [text] AS [Query]  
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) st 
WHERE 
	session_Id > 50           -- Consider spids for users only, no system spids. 
	AND session_Id NOT IN (@@SPID)  -- Don't include request from current spid.
GO
