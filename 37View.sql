use Northwind
go
SELECT C.CompanyName,C.CustomerID,COUNT(O.OrderID) AS COUNTERORDER FROM Orders O
JOIN Customers C
ON O.CustomerID=C.CustomerID
GROUP BY C.CustomerID,C.CompanyName
GO
CREATE VIEW V1
AS 
SELECT C.CompanyName,C.CustomerID,COUNT(O.OrderID) AS COUNTERORDER FROM Orders O
JOIN Customers C
ON O.CustomerID=C.CustomerID
GROUP BY C.CustomerID,C.CompanyName

GO

SELECT * FROM V1
GO
SP_HELPTEXT 'V1'

GO

SELECT * FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME='V2'

GO
SELECT * FROM sys.sql_modules
WHERE object_id=OBJECT_ID('V2')

GO

SP_DEPENDS 'V1'
GO
SELECT *,OBJECT_NAME(referenced_major_id) FROM sys.sql_dependencies 
	WHERE object_id=object_id('V1')

	GO

	CREATE VIEW V2
	with encryption
AS 
SELECT C.CompanyName,C.CustomerID,COUNT(O.OrderID) AS COUNTERORDER FROM Orders O
JOIN Customers C
ON O.CustomerID=C.CustomerID
GROUP BY C.CustomerID,C.CompanyName

go

SELECT * FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME='V2'
go

---select * not use view
--With بررسي قسمت
--SchemaBinding  استفاده از 
CREATE VIEW V3
AS
SELECT * FROM Orders --به ستاره دقت شود
GO
SELECT * FROM V3
GO
ALTER TABLE ORDERS ADD F1 DATETIME 
GO
SELECT * FROM V3 --آيا ستون جديد به ويو اضافه شده است
GO
ALTER TABLE Orders DROP COLUMN ShipAddress
GO
SELECT * FROM V3 --آيا ستون جديد از ويو حذف شده است
GO
SELECT * FROM Orders
GO
--همه اين معضلات به خاطره استفاده از ستاره در سورس ويو است
--كنيم Refresh حال اگر بخواهيم درست شود بايد ويو را 
SP_REFRESHVIEW 'V3'
GO
SELECT * FROM V3 --آيا مشكلات قبلي رفع شده است
GO
DROP VIEW V3
GO
--اگر بخواهيم جلوي اين نوع مشكلات را بگيريم بايد چه كرد
--WITH SCHEMABINDING راه حل استفاده از
CREATE VIEW V3
WITH SCHEMABINDING 
AS
SELECT * FROM Orders
GO
--با استفاده از اين حالت ساختار جداول مورد استفاده در ويو به ويوي بايند مي شود
--در اين حالت اگر اقلام جدول تغيير كند اس كيو ال به شما گوش زد مي كند يك ويو از جدول استفاده مي كند
CREATE VIEW V3
WITH SCHEMABINDING 
AS
SELECT 
	O.OrderID,O.CustomerID,
	O.EmployeeID,O.ShipName 
FROM Orders O --نام دو قسمتي
GO
---
CREATE VIEW V3
WITH SCHEMABINDING 
AS
SELECT 
	O.OrderID,O.CustomerID,
	O.EmployeeID,O.ShipName 
FROM DBO.Orders O
GO
SELECT * FROM V3
GO
ALTER TABLE ORDERS DROP COLUMN ShipName--به خطا دقت شود
GO
ALTER TABLE ORDERS ALTER COLUMN ShipName NVARCHAR(200)
GO
--پس از آن رفع مشكل ويو حذف و عمليات تغيير در جدول انجام و مجددا ويو ايجاد گردد
GO


----index view
--علاوه بر کوری دیتا ذخیره میشه دیگه expand نمیشه
---not insert up
--عملیات اکسپند حذف
--ابدیت توسط sql
CREATE VIEW VIEW_INDEX_1 AS
SELECT C.CompanyName,O.CustomerID
,O.OrderDate,OD.ProductID
FROM Customers C
JOIN Orders O 
ON C.CustomerID=O.CustomerID
JOIN [Order Details] OD
ON O.OrderID=OD.OrderID
GO

SELECT * FROM VIEW_INDEX_1

-------

CREATE VIEW VIEW_INDEXS_2 
WITH SCHEMABINDING
AS
SELECT C.CompanyName,O.CustomerID
,O.OrderDate,OD.ProductID,O.OrderID
FROM dbo.Customers C
JOIN dbo.Orders O 
ON C.CustomerID=O.CustomerID
JOIN dbo.[Order Details] OD
ON O.OrderID=OD.OrderID
GO
create unique clustered index ix_2 on VIEW_INDEXS_2(OrderID,ProductID)

go
select * from VIEW_INDEXS_2 with (noexpand)
select * from VIEW_INDEXS_2
select * from VIEW_INDEX_1

update Orders set OrderDate=getdate() where CustomerID='Alfki'
go

select * from VIEW_INDEXS_2 with (noexpand) where CustomerID='Alfki'

-----------Update View
create view U_View
as 
select e.EmployeeID,e.FirstName,e.LastName,e.BirthDate from Employees e

go
select * from U_View

go
update U_View set FirstName+='*'
where EmployeeID=4

select * from Employees

go

insert into U_View values('a','b',null,null)

insert into U_View values('a','b',null)

--WITH CHECK OPTION بررسي  
--الزام مي كند كه عمليات ويرايش فيلدها در محدوده شرط مربوط به ويو باشدWITH CHECK OPTION
create VIEW U_View
AS
SELECT E.EmployeeID,E.FirstName,E.LastName,E.BirthDate 
	FROM Employees E
		WHERE E.LastName LIKE 'd%'
WITH CHECK OPTION
GO
SELECT * FROM U_View
GO
UPDATE U_View SET FirstName+='*' 
	WHERE EmployeeID=4 --چرا ركوردي به روز نشد
GO
SELECT * FROM U_View
GO
UPDATE U_View SET FirstName+='*' 
	WHERE EmployeeID=1
GO
SELECT * FROM U_View
GO
UPDATE U_View SET LastName='Taheri'
	WHERE EmployeeID=9
GO
SELECT * FROM U_View
GO
UPDATE U_View SET LastName='D-Taheri'
	WHERE EmployeeID=9
GO
SELECT * FROM U_View
GO
DELETE FROM U_View WHERE EmployeeID=3
GO
DELETE FROM U_View WHERE EmployeeID=1 --هاي مربوط به جدول فعال شده و از حذف جلوگيري مي كنندConstraintامكان حذف دارد ولي 
GO
INSERT INTO U_View VALUES ('AA','BB',NULL) --امكان درج وجود ندارد 
GO
INSERT INTO U_View VALUES ('AA','D-BB',NULL)
SELECT * FROM U_View
SELECT * FROM Employees
GO

--Partitioned View

USE Northwind
GO
USE master
GO
CREATE DATABASE DB1--ايجاد بانك اطلاعاتي اول در سرور اصفهان
GO
CREATE DATABASE DB2--ايجاد بانك اطلاعاتي دوم در سرور تبريز
GO
CREATE DATABASE DB3--ايجاد بانك اطلاعاتي سوم در سرور تهران
GO
--ساخت جدول پرسنل براي سرور اول با شرط ورود كارمنداني كه داراي كد پرسنلي خاص هستند
CREATE TABLE DB1.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 1 AND 100),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--ساخت جدول پرسنل براي سرور دوم با شرط ورود كارمنداني كه داراي كد پرسنلي خاص هستند
CREATE TABLE DB2.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 101 AND 200),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--ساخت جدول پرسنل براي سرور سوم با شرط ورود كارمنداني كه داراي كد پرسنلي خاص هستند
CREATE TABLE DB3.dbo.Employees 
(
	EmployeeID INT PRIMARY KEY CHECK (EmployeeID BETWEEN 201 AND 300),
	FirtName NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
INSERT INTO DB1.dbo.Employees VALUES (1,N'مسعود',N'نوری')
INSERT INTO DB1.dbo.Employees VALUES (2,N'فريد',N'نوری')
INSERT INTO DB1.dbo.Employees VALUES (3,N'مجيد',N'نوری')
INSERT INTO DB1.dbo.Employees VALUES (4,N'علي',N'نوری')
INSERT INTO DB1.dbo.Employees VALUES (120,N'محسن',N'جعفري')--شرط را چك كنيد
GO
INSERT INTO DB2.dbo.Employees VALUES (120,N'محسن',N'جعفري')
INSERT INTO DB2.dbo.Employees VALUES (121,N'سامان',N'حسيني')
INSERT INTO DB2.dbo.Employees VALUES (122,N'محمد',N'نوري')
INSERT INTO DB2.dbo.Employees VALUES (123,N'بهرام',N'غفاري')
INSERT INTO DB2.dbo.Employees VALUES (250,N'علي',N'بسطامي')--شرط را چك كنيد
GO
INSERT INTO DB3.dbo.Employees VALUES (250,N'علي',N'بسطامي')
INSERT INTO DB3.dbo.Employees VALUES (251,N'نادر',N'بيروني')
INSERT INTO DB3.dbo.Employees VALUES (252,N'كريم',N'مقدادي')
INSERT INTO DB3.dbo.Employees VALUES (253,N'محمد',N'عطايي')
GO
SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
------------
USE DB1
GO
--Partitioned view as defined on Server1
CREATE VIEW View_Employees
AS
SELECT EmployeeID,FirtName,LastName FROM DB1.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB2.dbo.Employees
UNION
SELECT EmployeeID,FirtName,LastName FROM DB3.dbo.Employees
GO
--check view in ssms
GO
SELECT * FROM View_Employees
GO
---استخراج داده  از بانك اطلاعاتي به همراه نام سرور و بانك اطلاعاتي
SELECT * FROM ServerName.Northwind.dbo.Employees
-------ad
USE tempdb
GO
CREATE TABLE [dbo].[Customer](
	[CustID] [int] IDENTITY(1,1) NOT NULL,
	[Custname] [varchar](30) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Invoice](
	[InvID] [int] IDENTITY(1,1) NOT NULL,
	[InvDate] [datetime] NULL,
	[Custid] [int] NULL,
	[amount] [numeric](9, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[InvID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE VIEW [dbo].[vInvCustomer]
WITH SCHEMABINDING
AS
SELECT i.invid, invdate, custname, amount 
	FROM dbo.invoice i
	INNER JOIN dbo.customer c ON i.custid = c.custid
GO

CREATE UNIQUE CLUSTERED INDEX [idx_vInvCustomer_InvID] ON [dbo].[vInvCustomer] 
(
	[invid] ASC
) ON [PRIMARY]
GO


insert into customer (custname,address1,address2) values ('Customer 1','Address 11','Address 21')
insert into customer (custname,address1,address2) values ('Customer 2','Address 12','Address 22')
insert into customer (custname,address1,address2) values ('Customer 3','Address 13','Address 23')
insert into customer (custname,address1,address2) values ('Customer 4','Address 14','Address 24')
insert into customer (custname,address1,address2) values ('Customer 5','Address 15','Address 25')
	
	
insert into invoice (invdate, custid, amount) values (getdate(), 1, 1000)
insert into invoice (invdate, custid, amount) values (getdate(), 2, 2000)
insert into invoice (invdate, custid, amount) values (getdate(), 3, 3000)
insert into invoice (invdate, custid, amount) values (getdate(), 4, 4000)
insert into invoice (invdate, custid, amount) values (getdate(), 5, 5000)



SELECT * FROM [vInvCustomer]
go
----------
--Session 1
 begin tran

                  update invoice set amount = amount + 1 where invid = 1


------------
--Session 2
           begin tran

                   update customer set custname = 'Customer Change1' where custid = 2


---------------------

--هنگام استفاده از ایندکس ویو دقت شود که آیا دستورات تغییر داده ها پروسه ایندکس اسکن را انجام می دهند 
--در صورتیکه این گونه باشد باید با یک ایندکس مفید آنها را تنظیم کرد


           CREATE NONCLUSTERED INDEX [IX_Invoice_CustID] ON [dbo].[Invoice] (

                       [Custid] ASC

               ) ON [PRIMARY]