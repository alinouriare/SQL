CREATE TABLE Product(
Id int,
ProductName nvarchar(100),
Price MONEY
)
GO
checkpoint
go
select * from fn_dblog(null,null)
go
INSERT INTO Product
  VALUES  (1, 'Monitor 17 Inches', 112000),
    (2, 'Keyboard 101 Keys', 20000),
    (3, 'Optical Mouse', 7000),
    (4, 'DVD-ROM', 30000)
	GO
SELECT * FROM Product

GO


CREATE TABLE AA1(
CODE INT IDENTITY,
FNAME NVARCHAR(100),
LNAME NVARCHAR(100),
BRITHDAY DATETIME
)
INSERT INTO AA1
SELECT FirstName,LastName,BirthDate FROM Northwind.dbo.Employees
GO
SELECT * FROM AA1
GO

CREATE PROC GETCOUNTRY (
@COUNTY NVARCHAR(100)
)
AS
SELECT FirstName,LastName,BirthDate FROM Northwind.dbo.Employees
where Country=@COUNTY
go
exec GETCOUNTRY 'usa'
exec GETCOUNTRY 'uk'

insert into AA1
exec GETCOUNTRY 'usa'

go
USE Northwind

SELECT * INTO A FROM Orders --NO INDEX NO CONSTRAINT IN A
GO
SELECT * FROM A 
GO

SP_HELP A
GO

SELECT ShipName INTO A2 FROM Orders

GO

SELECT * FROM A2
GO

SELECT * INTO A3 FROM Orders
WHERE 1=2

GO
SELECT * FROM A3

DROP TABLE A2

DROP TABLE A3

DROP TABLE A

SELECT FirstName COLLATE Persian_100_CI_AI as FirstName,
LastName
INTO A3 FROM Employees
WHERE 1=2

sp_help 'A3'
-----------------------------------------------------------------------------
USE tempdb
GO
--Select «ÌÃ«œ ”ÿ—Â« Ê ” Ê‰ Â«Ì „Ê—œ ‰Ÿ— »« «” ›«œÂ «“ œ” Ê—
SELECT * FROM
  (
	VALUES
     (1, 'Cust 1', '(111) 111-1111', 'address 1'),
     (2, 'Cust 2', '(222) 222-2222', 'address 2'),
     (3, 'Cust 3', '(333) 333-3333', 'address 3'),
     (4, 'Cust 4', '(444) 444-4444', 'address 4'),
     (5, 'Cust 5', '(555) 555-5555', 'address 5')
  ) AS C(CustID, CompanyName, Phone, [Address])
GO
--¬‘‰«ÌÌ »«  «»⁄ “Ì—
SELECT OBJECT_ID('Customers', 'U')
GO
IF OBJECT_ID('Customers', 'U') IS NOT NULL 
BEGIN
	DROP TABLE Customers;
END
GO
CREATE TABLE Customers
(
  CustID      INT         NOT NULL,
  CompanyName VARCHAR(25) NOT NULL,
  Phone       VARCHAR(20) NOT NULL,
  [Address]     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(CustID)
)
GO
--œ—Ã œ«œÂ Â« œ— Ìﬂ ÃœÊ·
INSERT INTO Customers(CustID, CompanyName, Phone, [Address])
SELECT * FROM
  (
	VALUES
     (1, 'Cust 1', '(111) 111-1111', 'address 1'),
     (2, 'Cust 2', '(222) 222-2222', 'address 2'),
     (3, 'Cust 3', '(333) 333-3333', 'address 3'),
     (4, 'Cust 4', '(444) 444-4444', 'address 4'),
     (5, 'Cust 5', '(555) 555-5555', 'address 5')
  ) AS C(CustID, CompanyName, Phone, [Address])
GO
--„‘«ÂœÂ «ÿ·«⁄«  ÃœÊ·
SELECT * FROM Customers
GO
--------------------------------------------------------------------------------------------

--INSERT with OUTPUT
-- œ— œ” —” „Ì »«‘‰œinserted ›Ì·œÂ«Ì „Ê—œ ‰Ì«“ ‘„« œ— Ìﬂ ÃœÊ· »Â ‰«„ 
INSERT INTO Customers(CustID, CompanyName, Phone, [Address])
	OUTPUT inserted.*	
VALUES (6, 'Cust 6', '(666) 666-6666', 'address 6')
GO
--œ” “”Ì »Â œÊ ›Ì·œ «“ —ﬂÊ—œ œ—Ã ‘œÂ
INSERT INTO Customers(CustID, CompanyName, Phone, [Address])
	OUTPUT inserted.CustID,	inserted.CompanyName
VALUES (7, 'Cust 7', '(777) 777-7777', 'address 7')
GO
drop table #MyTableVar
-- ⁄—Ì› Ìﬂ „ €ÌÌ— «“ ‰Ê⁄ ÃœÊ·
create  TABLE #MyTableVar (CustID INT,CompanyName VARCHAR(25))
--@MyTableVarÊ „ €ÌÌ—Customersœ—Ã —ﬂÊ—œ œ— ÃœÊ· 
INSERT INTO Customers(CustID, CompanyName, Phone, [Address])
	OUTPUT inserted.CustID,	inserted.CompanyName INTO #MyTableVar
VALUES (9, 'Cust 8', '(888) 888-8888', 'address 8')
--@MyTableVarÊ«ﬂ‘Ì œ«œÂ «“ „ €ÌÌ— ÃœÊ·Ì
SELECT * FROM #MyTableVar
GO
select * from Customers