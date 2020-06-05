GO
CREATE TABLE Orders
(
	OrderID INT PRIMARY KEY,
	Country NVARCHAR(20),
	OrderDate INT,
	EmpName NVARCHAR(20)
)
GO
INSERT Orders VALUES
    (1, 'UK', 2007, 'Nancy'),
    (2, 'UK', 2006, 'George'),
    (3, 'USA', 2007, 'Nancy'),
    (4, 'Italy', 2008, 'Steve'),
    (5, 'Brazil', 2007, 'Steve'),
    (6, 'Italy', 2006, 'Nancy'),
    (7, 'USA', 2006, 'Nancy'),
    (8, 'UK', 2006, 'Michael'),
    (9, 'Brazil', 2008, 'George'),
    (10, 'Brazil', 2008, 'George')
GO
SELECT * FROM Orders
GO

DELETE Orders
GO
DELETE FROM Orders
GO
DELETE FROM Orders
WHERE OrderID=10
GO

SELECT * FROM Orders
GO
USE Northwind

DELETE OD
FROM [Order Details] OD
JOIN Orders O ON OD.OrderID=O.OrderID
JOIN Customers C ON O.CustomerID=C.CustomerID
WHERE C.Country='UK'
GO
SELECT * FROM [Order Details] OD
JOIN Orders O ON OD.OrderID=O.OrderID
JOIN Customers C ON O.CustomerID=C.CustomerID
WHERE C.Country='UK'
GO

DELETE FROM Orders
OUTPUT deleted.*
WHERE OrderID=9
GO
-----------

--Truncate بررسی دستور 
GO

USE TESTDB
GO
IF DB_ID('Test_Truncate')>0
	DROP DATABASE Test_Truncate
GO
CREATE DATABASE Test_Truncate
GO
USE Test_Truncate
GO
CREATE TABLE TestTable
(
	F1 INT ,
	F2 NVARCHAR(50) 
)
GO
INSERT INTO TestTable VALUES (1,'A')
INSERT INTO TestTable VALUES (2,'B')
INSERT INTO TestTable VALUES (3,'C')
INSERT INTO TestTable VALUES (4,'D')
INSERT INTO TestTable VALUES (5,'E')
INSERT INTO TestTable VALUES (6,'F')
INSERT INTO TestTable VALUES (7,'G')
INSERT INTO TestTable VALUES (8,'H')
INSERT INTO TestTable VALUES (9,'I')
INSERT INTO TestTable VALUES (10,'J')
GO
SELECT * FROM TestTable
GO
--LOG CHIN START
BACKUP DATABASE Test_Truncate TO DISK='C:\DUMP\TRUNCATE.BAK'
WITH FORMAT

GO
INSERT INTO TestTable VALUES(4,'AA')
SELECT * FROM fn_dblog(NULL,NULL)

DELETE FROM TestTable WHERE F1=4
DBCC LOGINFO()
GO
--LOG TRUANCATE LOW NO RELATION IDENTITYT RESET

DELETE FROM TestTable WHERE F1=4

SELECT * FROM fn_dblog(NULL,NULL)
GO
DELETE FROM TestTable
SELECT * FROM fn_dblog(NULL,NULL)
GO
INSERT INTO TestTable
SELECT * FROM TestTable
GO
SELECT * FROM fn_dblog(NULL,NULL)

GO
--TRUNCATE MIN LOG
TRUNCATE TABLE TestTable
SELECT * FROM fn_dblog(NULL,NULL)
-حذف کلیه رکوردهای یک پارتیشن خاص
--SQL Server 2016
TRUNCATE TABLE PartitionTable1 
	WITH (PARTITIONS (2, 4, 6 TO 8));
GO
--------------------------------------------------------------------
--فرض كنيد يك بانك اطلاعاتي پر از داده هاي تستي دريم جال مي خواهيم اطلاعات آن را پاك كنيم
-- را ريست مي كندIdentity اين اسكريپت كليه داده هاي موجود در بانك اطلاعاتي را حذف و سپس مقادير فيلدهاي
--Constraints & Triggers غير فعال كردن 
--نكته مهمي كه وجود دارد در حذف داده ها تقدم و تاخر داده ها بسيار مهم مي باشد
--دليل اين موضوع به روابط بين جدوال موجود در بانك اطلاعاتي بر مي گردد
USE Northwind
GO
SELECT * FROM Orders
SELECT * FROM [Order Details]
GO
DELETE Orders --آيا امكان حذف اطلاعات جدول پدر وجود دارد
--DELETE [Order Details]
--DELETE Orders
GO
--sp_MSforeachtable بررسي دستور 
EXEC sp_MSforeachtable "print '?'"
EXEC sp_MSforeachtable "sp_spaceused '?'"
EXEC sp_msforeachtable 'sp_spaceused ''?'''
GO
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
EXEC sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'
--حذف كليه ركوردهاي تمامي جداول
exec sp_MSforeachtable 'DELETE ?'
--Constraints & Triggers فعال كردن 
exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'
--Identity ريست كردن مقادير فيلدهاي
exec sp_MSforeachtable 'IF OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1 
	BEGIN DBCC CHECKIDENT (''?'',RESEED,0) END'
GO
------------------------------------------------------------
