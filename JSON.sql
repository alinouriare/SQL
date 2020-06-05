--SQL Server در JSON استفاده از 

--JSON
DECLARE @Json AS NVARCHAR(MAX)
SET @Json = 
	(
		SELECT 
			N'علی' AS FirstName, 
			N'نوری' AS LastName,
            33 AS Age, 
			GETDATE() AS DateCreated
            FOR JSON PATH
	)
PRINT @Json

GO
DECLARE @XML AS XML
SET @XML = 
	(
		SELECT 
				N'علی' AS FirstName, 
			N'نوری' AS LastName,
            33 AS Age, 
			GETDATE() AS DateCreated
            FOR XML PATH
	)
SELECT @XML

GO

CREATE TABLE Students 
(
	ID INT IDENTITY(1,1) NOT NULL, 
	FirstName NVARCHAR(255), 
	LastName NVARCHAR(255), 
	Class INT
 )
GO 
 INSERT INTO Students (FirstName, LastName, Class) VALUES
	(N'مسعود',N'نوری',1),
	(N'فرید',N'سعید',1),
	(N'علیرضا',N'نوری',2),
	(N'علی',N'رضایی',2),
	(N'مجید',N'نوری',0),
	(N'محمد',N'مزیدی',3),
	(N'سعید',NULL,3)

GO
SELECT * FROM Students

GO

SELECT * FROM Students
FOR JSON AUTO
--حذف براکت های
SELECT FirstName, LastName, Class FROM Students
	FOR JSON AUTO,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
--Root اضافه کردن گره 
SELECT FirstName, LastName, Class FROM Students
	FOR JSON AUTO,ROOT('Test')



	--------------------------------------------------------------------
--For Path : JSON کنترل کامل روی  خروجی  
GO
--JSON قالب بندی خروجی 
SELECT 
ID,
	FirstName AS 'Info.FirstName', 
	LastName  AS 'Info.LastName', 
	Class 
FROM Students FOR JSON PATH
GO
SELECT 
	FirstName AS 'Info.FirstName', 
	LastName  AS 'Info.LastName', 
	Class 
FROM Students FOR JSON AUTO
GO
--------------------------------------------------------------------
--JSON پردازش یک عبارت 

DECLARE @JSON AS NVARCHAR(max)

SET @JSON= (SELECT

'Ali' AS FirstName,
'Nouri' AS LastName ,
33 AS Age,
GETDATE() AS DATES
FOR JSON PATH
)

SELECT @JSON
SELECT * FROM OPENJSON(@JSON)
SELECT * FROM OPENJSON(@JSON)WITH
(
FirstName  NVARCHAR(50),
LastName  NVARCHAR(50),
Age INT,
DATES DATETIME 
)
GO
DECLARE @JSON AS NVARCHAR(MAX)
SET @JSON = N'[{"ID":1,"FirstName":"مسعود","LastName":"نوری","Class":1},{"ID":2,"FirstName":"فرید","LastName":"نوری","Class":1},{"ID":3,"FirstName":"علیرضا","LastName":"نوری","Class":2},{"ID":4,"FirstName":"علی","LastName":"نوری","Class":2},{"ID":5,"FirstName":"مجید","LastName":"نوری","Class":0},{"ID":6,"FirstName":"محمد","LastName":"مزیدی","Class":3},{"ID":7,"FirstName":"سعید","Class":3}]'
SELECT * FROM OPENJSON(@JSON)WITH
(
ID INT,
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Class INT
)
GO

DECLARE @JSON AS NVARCHAR(MAX)
SET @JSON = N'[{"ID":1,"FirstName":"مسعود","LastName":"نوری","Class":1},{"ID":2,"FirstName":"فرید","LastName":"نوری","Class":1},{"ID":3,"FirstName":"علیرضا","LastName":"نوری","Class":2},{"ID":4,"FirstName":"علی","LastName":"نوری","Class":2},{"ID":5,"FirstName":"مجید","LastName":"نوری","Class":0},{"ID":6,"FirstName":"محمد","LastName":"مزیدی","Class":3},{"ID":7,"FirstName":"سعید","Class":3}]'
SELECT * FROM OPENJSON(@JSON)WITH
(
ID INT,
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Class INT
)WHERE ID=3
GO
--------------------------------------------------------------------
--ISJSON بررسی تابع 
DECLARE @JSON AS NVARCHAR(MAX)
SET @JSON = N'["ID":1,"FirstName":"مسعود","LastName":"نوری","Class":1},{"ID":2,"FirstName":"فرید","LastName":"نوری","Class":1},{"ID":3,"FirstName":"علیرضا","LastName":"نوری","Class":2},{"ID":4,"FirstName":"علی","LastName":"نوری","Class":2},{"ID":5,"FirstName":"مجید","LastName":"نوری","Class":0},{"ID":6,"FirstName":"محمد","LastName":"مزیدی","Class":3},{"ID":7,"FirstName":"سعید","Class":3}]'
SELECT ISJSON(@JSON)
SET @JSON = N'[{"ID":1,"FirstName":"مسعود","LastName":"نوری","Class":1},{"ID":2,"FirstName":"فرید","LastName":"نوری","Class":1},{"ID":3,"FirstName":"علیرضا","LastName":"نوری","Class":2},{"ID":4,"FirstName":"علی","LastName":"نوری","Class":2},{"ID":5,"FirstName":"مجید","LastName":"نوری","Class":0},{"ID":6,"FirstName":"محمد","LastName":"مزیدی","Class":3},{"ID":7,"FirstName":"سعید","Class":3}]'
SELECT ISJSON(@JSON)
GO
--------------------------------------------------------------------


--------------------------------------------------------------------
--JSON Path
/*
Using :
	OPENJSON 
	JSON_VALUE 
	JSON_QUERY 
*/
 --lax or strict
DECLARE @JSON AS NVARCHAR(MAX)=
N'
{ "employee":
  [
    { "firstname": "Masoud", "lastname": "Nouri" },
    { "firstname": "Farid", "lastname": null, "active": true }
  ]
}
'
SELECT value FROM OPENJSON(@json, 'lax $')
SELECT value FROM OPENJSON(@json, 'lax $.employee')
GO
--------------------------------------------------------------------
--JSON_VALUE بررسی تابع 
DECLARE @JSON AS NVARCHAR(MAX)=
N'
{ "employee":
  [
    { "firstname": "Masoud", "lastname": "Nouri" },
    { "firstname": "Farid", "lastname": null, "active": true }
  ]
}
'
SELECT JSON_VALUE(@JSON,'lax $.employee[0].firstname') ,JSON_VALUE(@JSON,'lax $.employee[0].lastname')
SELECT JSON_VALUE(@JSON,'lax $.employee[1].firstname') ,JSON_VALUE(@JSON,'lax $.employee[1].lastname')
GO
--------------------------------------------------------------------


--------------------------------------------------------------------
--JSON سناریو 1 : ایجاد یک جدول با پشتیبانی از
DROP TABLE IF EXISTS SalesOrderRecord
GO
CREATE TABLE SalesOrderRecord 
(    
	Id INT PRIMARY KEY IDENTITY,
	OrderNumber NVARCHAR(25) NOT NULL,    
	OrderDate DATETIME NOT NULL,
   JSalesOrderDetails NVARCHAR(4000),         
	Quantity ASCAST(JSON_VALUE(JSalesOrderDetails, '$.Order.Qty') AS INT),
	Price AS CAST(JSON_VALUE(JSalesOrderDetails, '$.Order.Price') AS INT),
	CONSTRAINT SalesOrderDetails_IS_JSON CHECK(ISJSON(JSalesOrderDetails)>0)    
)
GO
CREATE INDEX IX_JSON ON SalesOrderRecord(Quantity)    
	INCLUDE (Price)
GO
--------------------------------------------------------------------
--به یک پروسیجر JSON سناریو 2 : پاس دادن مقادیر 
--Passing arrays to T-SQL procedures 
--نمایش تصویر لیست باکس
GO
DROP PROCEDURE IF EXISTS usp_GetStudents
GO
CREATE PROCEDURE usp_GetStudents
(
	@StudentID NVARCHAR(200)
)
AS
	SELECT * FROM Students 
		WHERE ID IN (SELECT CAST(VALUE AS INT) FROM OPENJSON(@StudentID)) 
GO
--نحوه استفاده از پروسیجر
EXEC usp_GetStudents '[1,3,5]'
GO

