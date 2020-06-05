CREATE TABLE Orders
(
	OrderID INT PRIMARY KEY,
	Country NVARCHAR(20),
	OrderDate INT,
	EmpName NVARCHAR(20)
)
GO
--SQL Server 2008
--در اين مثال اگر يكي از سطرها درج نشود كل عمليات درج لغو مي گردد
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
UPDATE Orders 
SET Country='USA'
GO

UPDATE Orders
SET Country='IRAN',EmpName='ALI',OrderDate='2020'
WHERE OrderID=6

USE Northwind

SELECT OD.Discount FROM Orders  O
JOIN Customers C
ON O.CustomerID=C.CustomerID
JOIN [Order Details] OD
ON O.OrderID=O.OrderID
WHERE C.Country='UK'


UPDATE OD SET OD.Discount=2.5
 FROM [Order Details]
OD JOIN
Orders O ON OD.OrderID=O.OrderID
JOIN Customers C
ON O.CustomerID=C.CustomerID
WHERE C.Country='UK'

SELECT * FROM [Order Details]
OD JOIN
Orders O ON OD.OrderID=O.OrderID
JOIN Customers C
ON O.CustomerID=C.CustomerID
WHERE C.Country='UK'


SELECT OD.Discount FROM [Order Details] OD
WHERE OD.OrderID IN(

SELECT OrderID FROM Orders O
  WHERE CustomerID IN(
  SELECT CustomerID FROM Customers C
  WHERE C.CustomerID=O.CustomerID
  )
)
GO
USE TESTDB
GO
UPDATE Orders SET Country='IRan'
OUTPUT deleted.* ,inserted.* 
WHERE OrderID=5
SELECT * FROM Orders
GO
UPDATE Orders SET EmpName=EmpName+'NEW'
OUTPUT inserted.OrderID AS ID
,inserted.EmpName AS NEW
,deleted.Country AS OLD
WHERE Country='USA'
GO

CREATE DATABASE TESTLOG
GO

CREATE TABLE TESTLOG(
ID INT PRIMARY KEY,
FULLNAME NVARCHAR(200)
)
USE TESTLOG
GO
INSERT INTO [dbo].[TESTLOG] VALUES
(1,N'مسعود نوری'),
	(2,N'فرید نوری'),
	(3,N'مجید نوری'),
	(4,N'علی نوری'),
	(5,N'علیرضا نوری')

	GO

	SELECT * FROM [dbo].[TESTLOG]

	GO

	BACKUP DATABASE [TESTLOG] TO DISK='C:\DUMP\B.BAK'
	WITH FORMAT
	GO
	--های مربوط به بانک اطلاعاتیVLF مشاهده 
DBCC LOGINFO()
GO
CHECKPOINT
GO
SELECT * FROM fn_dblog(NULL,NULL)
GO
UPDATE [dbo].[TESTLOG] SET FULLNAME=N'سید مرادی'
WHERE ID=1
GO
SELECT * FROM fn_dblog(NULL,NULL)

BEGIN TRANSACTION
UPDATE [dbo].[TESTLOG] SET FULLNAME=N'سید مرادی S'
WHERE ID IN (1,2)
GO
ROLLBACK TRANSACTION
GO
SELECT * FROM fn_dblog(NULL,NULL)