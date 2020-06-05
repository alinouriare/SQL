USE AdventureWorks2014
GO
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID=(SELECT MAX(SalesOrderID) FROM Sales.SalesOrderHeader)

GO

SELECT TerritoryID FROM Sales.SalesOrderHeader

SELECT * FROM Sales.SalesTerritory

SELECT *FROM Sales.SalesOrderHeader
WHERE TerritoryID=(SELECT TerritoryID FROM Sales.SalesTerritory WHERE [Group]='Europe')
GO
SET STATISTICS IO ON
SELECT *FROM Sales.SalesOrderHeader
WHERE TerritoryID IN (SELECT TerritoryID FROM Sales.SalesTerritory WHERE [Group]='Europe')
GO

SELECT * FROM Sales.SalesOrderHeader H 
JOIN Sales.SalesTerritory T
ON H.TerritoryID=T.TerritoryID
WHERE T.[Group]='Europe'
GO
--مشخصات کالاهایی که رنگ آنها مشکی بوده و بالای پنج عدد از آن سفارش داریم
SELECT * FROM Production.Product
WHERE ProductID IN( SELECT ProductID FROM 
Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(SalesOrderID) >5)
AND Color='Black'
go
--Correlated Sub Queries

--نام دارد Drived Table این حالت 
--استفاده می کنیم CTE در برخی موارد به جای این حالت از

SELECT * FROM(
SELECT * FROM Sales.SalesOrderHeader
)P
GO
--از هر محصول چه تعداد فروش رفته است
--Correlated Sub Queriesیک مدل از 

SELECT P.Name,P.ProductID,
(SELECT COUNT(SalesOrderDetailID) FROM
Sales.SalesOrderDetail OP
WHERE OP.ProductID=P.ProductID) AS COUNTS
FROM Production.Product P
go
USE TESTDB
--ایجاد جدول تستی
CREATE TABLE RunTotalTestData 
(
   ID    INT IDENTITY(1,1) PRIMARY KEY,
   Value INT
)
GO
--درج تعدادی رکورد تستی در جدول
INSERT INTO RunTotalTestData (value) VALUES (1)
INSERT INTO RunTotalTestData (value) VALUES (2)
INSERT INTO RunTotalTestData (value) VALUES (4)
INSERT INTO RunTotalTestData (value) VALUES (7)
INSERT INTO RunTotalTestData (value) VALUES (9)
INSERT INTO RunTotalTestData (value) VALUES (12)
INSERT INTO RunTotalTestData (value) VALUES (13)
INSERT INTO RunTotalTestData (value) VALUES (16)
INSERT INTO RunTotalTestData (value) VALUES (22)
INSERT INTO RunTotalTestData (value) VALUES (42)
INSERT INTO RunTotalTestData (value) VALUES (57)
INSERT INTO RunTotalTestData (value) VALUES (58)
INSERT INTO RunTotalTestData (value) VALUES (59)
INSERT INTO RunTotalTestData (value) VALUES (60)
GO
--مشاهده رکوردهای درج شده
SELECT * FROM RunTotalTestData

GO

SELECT A.ID,A.Value
,(SELECT SUM(B.Value) FROM RunTotalTestData B
WHERE B.ID <=A.ID)
FROM RunTotalTestData A
ORDER BY A.ID
GO

--Over با استفاده از Running Total پیاده سازی 

SELECT R.ID,R.Value
,SUM(R.Value) OVER (ORDER BY R.ID)
FROM RunTotalTestData R
ORDER BY R.ID

SET STATISTICS IO ON

--بررسی جهت وجود جدول
IF OBJECT_ID('TestMandeh')>0
	DROP TABLE TestMandeh
GO
--ایجاد جدول
CREATE TABLE TestMandeh
(
	Radif INT PRIMARY KEY,
	Bedehkar MONEY,
	Bestankar MONEY,
)
GO
--درج تعدادی رکورد تستی
INSERT TestMandeh VALUES(1, 1000,0) 
INSERT TestMandeh VALUES(2, 0,1000)
INSERT TestMandeh VALUES(3, 0, 2000)
INSERT TestMandeh VALUES(4, 0, 2000)
INSERT TestMandeh VALUES(5, 0, 2000)
INSERT TestMandeh VALUES(6, 0, 2000)
INSERT TestMandeh VALUES(7, 0, 2000)
INSERT TestMandeh VALUES(8, 100000,0)
GO
--مشاهده کلیه رکوردهای جدول
SELECT * FROM TestMandeh
--Correlated Sub Queries محاسبه مانده با استفاده از 
SELECT Radif,Bedehkar, Bestankar,(SELECT SUM(-1*BEDEHKAR+BESTANKAR) AS MANDEH
FROM TestMandeh M
WHERE M.Radif <=T.Radif) FROM TestMandeh T
GO
--Over محاسبه مانده با استفاده از 
SELECT 
	Radif,Bedehkar, Bestankar,
	SUM(-1*BEDEHKAR+BESTANKAR) OVER (ORDER BY Radif) AS Mandeh
	FROM TestMandeh T1
	GO
	--EXIST
--وجود يك سطر خاص بررسي مي شود و تنها در صورت وجود اين سطر خاص كوئري اجرا مي شود
GO
USE AdventureWorks2014
GO
--مشترياني كه داراي سفارش بوده اند
SELECT C.CustomerID,C.AccountNumber,
P.MiddleName,P.BusinessEntityID
FROM Sales.Customer C
JOIN Person.Person P
ON C.PersonID=P.BusinessEntityID
WHERE EXISTS(SELECT CustomerID FROM Sales.SalesOrderHeader OH
WHERE OH.CustomerID=C.CustomerID
)
--مشترياني كه داراي سفارش نمي باشند
SELECT 
	C.CustomerID,C.AccountNumber,
	P.BusinessEntityID,P.FirstName,P.LastName 
FROM Sales.Customer C
INNER JOIN Person.Person P ON C.PersonID=P.BusinessEntityID
WHERE 
	NOT EXISTS (SELECT * FROM Sales.SalesOrderHeader OH WHERE OH.CustomerID=C.CustomerID)
GO




use NikAmoozShop

SELECT   pp.EmployeeID,CONCAT( pp.FirstName,pp.LastName) AS FULLNAME
,pp.EmployeeGroupTitle AS MANGE,
(select CONCAT( w.FirstName,w.LastName) from HumanResources.Employee w
where pp.ManagerID=w.EmployeeID
) as namemodir
from
(select E.*,g.EmployeeGroupTitle as EmployeeGroupTitle 
 FROM HumanResources.EmployeeGroup G
JOIN HumanResources.Employee E
ON G.EmployeeGroupCode=E.EmployeeGroupCode ) pp
