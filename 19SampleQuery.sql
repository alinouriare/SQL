use Northwind
go
select (1+4) as 'Number'
go

select 'Name' as "AliNouri"
,Address as 'ad'
from Customers
go

select CustomerID as 'ID',City as 'شهر' from Customers

DECLARE @MyVar INT=100 
SET @MyVar+=5 -- (Add EQUALS)
SET @MyVar-=5 -- (Subtract EQUALS)
SET @MyVar*=5 -- (Multiply EQUALS)
SET @MyVar/=5 -- (Divide EQUALS)
SET @MyVar%=5 -- (Modulo EQUALS)
SET @MyVar|=5 -- (Bitwise OR EQUALS)
SET @MyVar^=5 -- (Bitwise Exclusive OR EQUALS) 
SET @MyVar&=5 -- (Bitwise AND EQUALS)
*/
USE tempdb
GO
DECLARE @MyVar INT=100
SET @MyVar+=5 -- (Add EQUALS)
SELECT  @MyVar AS 'Add EQUALS'
SET @MyVar-=5 -- (Subtract EQUALS)
SELECT  @MyVar AS 'Subtract EQUALS'
SET @MyVar*=5 -- (Multiply EQUALS)
SELECT  @MyVar AS 'Multiply EQUALS'
SET @MyVar/=5 -- (Divide EQUALS)
SELECT  @MyVar AS 'Divide EQUALS'
SET @MyVar%=5 -- (Modulo EQUALS)
SELECT  @MyVar AS 'Modulo EQUALS'
SET @MyVar|=5 -- (Bitwise OR EQUALS)
SELECT  @MyVar AS 'Bitwise OR EQUALS'
SET @MyVar^=5 -- (Bitwise Exclusive OR EQUALS) 
SELECT  @MyVar AS 'Bitwise Exclusive OR EQUALS'
SET @MyVar&=5 -- (Bitwise AND EQUALS)
SELECT  @MyVar AS 'Bitwise AND EQUALS'
GO

use AdventureWorks2014
go
set statistics io on
go
select * from Sales.SalesOrderHeader
go
select top(3)* from Sales.SalesOrderDetail
go
--نمایش 50 رکورد آخر
declare @a int=50
select top(@a)*from HumanResources.Employee order by 1 desc
go
sp_spaceused 'Sales.SalesOrderDetail'
go

select top 10 percent * from Sales.SalesOrderDetail
-----
select newid() as id
go
-- تصادفی رکورد
select top(5) NEWID(),SalesPersonID,SalesOrderID,SubTotal
from Sales.SalesOrderHeader
order by NEWID()

go
---شرط روی مقادیر عددی
go
set statistics io on
go
select CustomerID,SalesOrderID,OrderDate
from Sales.SalesOrderHeader
where CustomerID=11000
go
---شرط روی مقادیر تاریخ

select CustomerID,SalesOrderID from Sales.SalesOrderHeader
where OrderDate='2011-07-02'
go
select CustomerID,SalesOrderID,OrderDate from Sales.SalesOrderHeader
where OrderDate between '2011-07-02' and '2012-10-02'
go
select BusinessEntityID,JobTitle from HumanResources.Employee
where JobTitle not between 'C' and 'E'

----------
--Filtering on Date and Time
USE tempdb
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('DateTimeExample')>0
	DROP TABLE DateTimeExample
GO
--ایجاد جدول تستی
CREATE TABLE DateTimeExample
(
	ID INT NOT NULL IDENTITY PRIMARY KEY,
	MyDate DATETIME NOT NULL,
	MyValue NVARCHAR(25) NOT NULL
)
GO
--درج رکوردهای تستی در جدول
INSERT INTO DateTimeExample (MyDate,MyValue) VALUES ('2014-01-02 10:30',N'مسعود نوری')
INSERT INTO DateTimeExample (MyDate,MyValue) VALUES ('2014-01-03 13:00:02',N'فرید نوری')
INSERT INTO DateTimeExample (MyDate,MyValue) VALUES ('2014-01-03 13:10',N'مجید نوری')
INSERT INTO DateTimeExample (MyDate,MyValue) VALUES ('2014-01-03 17:35',N'علی نوری')
INSERT INTO DateTimeExample (MyDate,MyValue) VALUES ('2014-01-03 23:35:59',N'علیرضا نوری')
GO
select * from DateTimeExample
go
select * from DateTimeExample
where MyDate='2014-01-03'
go
select ID,MyDate from DateTimeExample
where CAST(MyDate as date)='2014-01-03' 
go
select ID,MyDate from DateTimeExample
where MyDate >= '2014-01-03'
and MyDate< '2014-01-04'
go
--select ID,MyDate from DateTimeExample
--where MyDate between '2014-01-03 00:00:00'
--and '2014-01-03 24:59:59'
go
---------
use AdventureWorks2014
go
set statistics io on
go
select FirstName,LastName,MiddleName from Person.Person
where FirstName='Ken' and LastName in ('Myer','Meyer')
go

select * from Sales.SalesTerritoryHistory
where TerritoryID not in(2,3)
go
select * from Person.Person
where MiddleName is not null and AdditionalContactInfo is not null
go
--Like استفاده از
USE tempdb
GO
IF OBJECT_ID('Employee')>0
	DROP TABLE Employee
GO
CREATE TABLE Employee
(
	EmployeeID int IDENTITY(10,2) ,
	EmployeeCode nvarchar(10) ,
	FirstName nvarchar(100),
	LastName nvarchar(100) ,
)
GO
--درج رکوردهای تستی
INSERT INTO Employee(EmployeeCode,FirstName,LastName) VALUES 
	('501','Masoud','Taheri'),
	('502','Farid','Taheri'),
	('503','Hassan','Ahmad'),
	('504','Hassan','Ahmadi'),
	('505','Ahmad','Moradi'),
	('506','Test','Test*Taheri%'),
	('507',N'احمد',N'مرادی'),
	('508',N'حمید',N'نوری'),
	('509',N'مسعود',N'طاهری'),
	('510',N'حسن',N'حمیدی'),
	('511',N'حسن',N'احمدی'),
	('512',N'ناصر',N'محمدی'),
	('513',N'علیرضا',N'نصیری'),
	('514',N'صادق',N'محمد احمدی'),
	('515',N'حسن',N'نورزاده')
GO
--نمایش کلیه رکوردها به کاربر
SELECT * FROM Employee
GO
------------------------------
--شروع نام خانوادگی با * مقادیر فارسی
SELECT * FROM Employee
	WHERE LastName LIKE N'اح%'
GO
--شروع نام خانوادگی با * مقادیر انگلیسی
SELECT * FROM Employee
	WHERE LastName LIKE N'AH%'
GO
------------------------------
--نام خانوادگی ختم شود به * مقادیر فارسی
SELECT * FROM Employee
	WHERE LastName LIKE N'%دی'
GO
--نام خانوادگی ختم شود به * مقادیر انگلیسی
SELECT * FROM Employee
	WHERE LastName LIKE N'%DI'
GO
------------------------------
--در هر کجای نام خانوادگی رشته.... وجود داشته باشد * مقادیر فارسی
SELECT * FROM Employee
	WHERE LastName LIKE N'%حم%'
GO
--در هر کجای نام خانوادگی رشته.... وجود داشته باشد * مقادیر انگلیسی
SELECT * FROM Employee
	WHERE LastName LIKE N'%Hm%'
GO
------------------------------
--رکوردهایی که نام آنها با الف شروع شده و چهار حرفی هستند * مقادیر فارسی
SELECT * FROM Employee
	WHERE FirstName LIKE N'ا___'
GO
--رکوردهایی که نام آنها با الف شروع شده و پنج حرفی هستند * مقادیر انگلیسی
SELECT * FROM Employee
	WHERE FirstName LIKE N'A____'
GO
------------------------------
--Like صرف نظر کردن از علامت % در هنگام استفاده از
SELECT * FROM Employee
	WHERE LastName LIKE N'%Taheri%'
GO
--در فیلد نامTaheri% به دنبال رشته 
SELECT * FROM Employee
	WHERE LastName LIKE N'%TAHERI%%%'
GO
--اس کیو ال را آگاه می کنیم که از علامت % صرف نظر کند ESCAPE با استفاده از 
SELECT * FROM Employee
	WHERE LastName LIKE N'%Taheri\%%' ESCAPE '\'
GO
------------------------------
--Not Like استفاده از

--رکوردهای که نام خانوادگی آنها دی را ندارد
SELECT * FROM Employee
	WHERE LastName NOT LIKE N'%دی%'
GO




 
 ---------
 sp_helpindex 'Production.Product'
 go
 select productid,[name],color,productnumber from Production.Product
 go
 select productid,[name],color,productnumber from Production.Product
 order by color
 go

 select distinct firstname,lastname from person.person
 go

  select distinct FirstName,LastName from person.person
  order by FirstName
  go
