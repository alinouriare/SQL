--توابع رشته ای
GO
USE AdventureWorks2014
GO
--Upper بررسی تابع 
--تبدیل حروف کوچک به بزرگ
--UPPER ( character_expression )
SELECT UPPER('alireza') AS Result
GO
SELECT 
	BusinessEntityID,FirstName,UPPER(FirstName) AS FirstName_Upper,
	LastName,UPPER(LastName) AS LastName_Upper
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
-----------
--Lower بررسی تابع 
--تبدیل حروف بزرگ به کوچک
--LOWER ( character_expression )
SELECT LOWER('AliReza') AS Result
GO
SELECT 
	BusinessEntityID,FirstName,LOWER(FirstName) AS FirstName_Upper,
	LastName,LOWER(LastName) AS LastName_Upper
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
--------------------------------------------------------------------
--Right بررسی تابع 
--استخراج زیر رشته از سمت راست
--RIGHT ( character_expression , integer_expression )
SELECT RIGHT('AliReza',4) AS Result
GO
SELECT 
	BusinessEntityID,FirstName,RIGHT(FirstName,4) AS FirstName_Right,
	LastName,RIGHT(LastName,4) AS LastName_Right
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
-----------
--Left بررسی تابع 
--استخراج زیر رشته از سمت جپ
--LEFT ( character_expression , integer_expression )
SELECT LEFT('AliReza',3) AS Result
GO
SELECT 
	BusinessEntityID,FirstName,LEFT(FirstName,4) AS FirstName_Left,
	LastName,LEFT(LastName,4) AS LastName_Left
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
-----------
--SubString بررسی تابع 
--استخراج یک زیر رشته از یک رشته
--SUBSTRING ( expression ,start , length )
SELECT SUBSTRING('AliReza Taheri',4,6) AS Result
GO
SELECT 
	BusinessEntityID,FirstName,SUBSTRING(FirstName,3,2) AS FirstName_Left,
	LastName,SUBSTRING(LastName,3,2) AS LastName_SubString
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
--------------------------------------------------------------------
--Rtrim بررسی تابع 
--حذف فاصله خالی از سمت راست رشته
--RTRIM ( character_expression )
SELECT RTRIM(' AliReza  ') AS Result
GO
SELECT 
	BusinessEntityID,FirstName,RTRIM(FirstName) AS FirstName_Rtrim,
	LastName,RTRIM(LastName) AS LastName_Rtrim
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
-----------
--Ltrim بررسی تابع 
--حذف فاصله خالی از سمت چپ رشته
--LTRIM ( character_expression )
SELECT LTRIM(' AliReza  ') AS Result
GO
SELECT 
	BusinessEntityID,FirstName,LTRIM(FirstName) AS FirstName_Ltrim,
	LastName,LTRIM(LastName) AS LastName_Ltrim
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
-----------
--حذف کلیه فاصله های خالی از سمت چپ و راست یک رشته
SELECT LTRIM(RTRIM(' AliReza  ')) AS Result
GO
SELECT 
	BusinessEntityID,FirstName,RTRIM(LTRIM(FirstName)) AS FirstName_Trim,
	LastName,RTRIM(LTRIM(LastName)) AS LastName_Trim
FROM Person.Person
WHERE BusinessEntityID IN(1,2,501,502)
GO
--------------------------------------------------------------------
--Char بررسی تابع
--CHAR ( integer_expression )
SELECT CHAR(65) AS Result
GO
-----------
--Ascii بررسی تابع
--ASCII ( character_expression )
SELECT ASCII('A') AS Result
GO
--------------------------------------------------------------------
--NChar بررسی تابع
--NCHAR ( integer_expression )
SELECT NCHAR(1576) AS Result
GO
-----------
--Unicode بررسی تابع
--UNICODE ( 'ncharacter_expression' )
SELECT UNICODE(N'ب') AS Result
GO
--------------------------------------------------------------------
--CharIndex بررسی تابع 
--اولین محل وجود یک رشته درون یک رشته دیگر، عدم امکان استفاده از کارکترهای عمومی
--CHARINDEX ( expressionToFind ,expressionToSearch [ , start_location ] )
SELECT CHARINDEX('re','AliReza') AS Result
GO
SELECT 
	BusinessEntityID,FirstName,CHARINDEX('Y',FirstName) AS FirstName_CharIndex,
	LastName,CHARINDEX('M',LastName) AS LastName_CharIndex
FROM Person.Person
GO

USE NikAmoozShop
GO
--درج رکوردهای تستی
INSERT INTO HumanResources.Employee(EmployeeCode,FirstName,LastName,EmployeeGroupCode,ManagerID) VALUES 
	('501','Masoud','Taheri',7,4),
	('502','Farid','Taheri',7,4),
	('503','Hassan','Ahmad',7,4),
	('504',' Hassan',' Ahmadi',7,4),
	('505','Ahmad ','Moradi ',7,4),
	('506','Test','Test*Taheri%',7,4)
GO

--PatIndex بررسی تابع 
--اولین محل وجود یک رشته درون یک رشته دیگر، امکان استفاده از کارکترهای عمومی
--PATINDEX ( '%pattern%' , expression )
SELECT PATINDEX('%za','AliReza') AS Result
GO
SELECT 
	EmployeeCode,FirstName,PATINDEX(N'%د',FirstName) AS FirstName_CharIndex,
	LastName,PATINDEX('%ri',LastName)  AS LastName_CharIndex
FROM HumanResources.Employee
WHERE EmployeeCode IN(1,2,501,502)
GO
--------------------------------------------------------------------
--Concat بررسی تابع
--متصل کردن چند رشته به همدیگر
--CONCAT ( string_value1, string_value2 [, string_valueN ] )
SELECT CONCAT(N'مسعود' , N'نوری', N'علیرضا',N'نوری') AS Result
SELECT CONCAT(N'مسعود' ,' ', N'نوری',' ', N'علیرضا',' ',N'نوری') AS Result
SELECT CONCAT('Hello',' ','SQL!') AS Result
GO
SELECT 
	*,FirstName,LastName,
	(FirstName +' ' + LastName) AS FullName1,
	CONCAT(FirstName,' ',LastName) AS FullName2
FROM Person.Person
WHERE EmployeeCode IN(1,2,501,502)

-----------
--Choose بررسی تابع
--باز گرداندن یکی از آیتم های موجود در لیست
--CHOOSE ( index, val_1, val_2 [, val_n ] )
GO
SELECT CHOOSE(1,N'مرد',N'زن') AS Result
SELECT CHOOSE(3,'Group1','Group2','Group3','Group4') AS Result
SELECT CHOOSE(5,'Group1','Group2','Group3','Group4') AS Result
GO
--------------------------------------------------------------------
--Replcae بررسی تابع 
--پیدا کردن یک رشته و جایگزینی آن با رشته ای دیگر
--REPLACE ( string_expression , string_pattern , string_replacement )
SELECT REPLACE('abcdefghicde','cde','xxx') AS Result
GO
-----------
--Stuff بررسی تابع 
--درج یک رشته داخل یک رشته دیگر
--STUFF ( character_expression , start , length , replaceWith_expression )
SELECT STUFF('abcdef', 2, 3, 'ijklmn') AS Result
GO
--------------------------------------------------------------------
--Reverse بررسی تابع 
--برعکس کردن یک رشته 
--REVERSE ( string_expression )
SELECT REVERSE('AliReza') AS Result
GO
SELECT 
	EmployeeCode,FirstName,REVERSE(FirstName) AS FirstName_Reverse
	,LastName,REVERSE(LastName) AS FirstName_LastName
FROM HumanResources.Employee
WHERE EmployeeCode IN(1,2,501,502)
GO
-----------
--Replicate بررسی تابع 
--تکرار یک رشته به تعداد مشخص
--REPLICATE ( string_expression ,integer_expression ) 
SELECT REPLICATE('AliReza,',3) AS Result
GO
SELECT 
	EmployeeCode, (REPLICATE('0',3) + EmployeeCode) AS EmployeeCode_REPLICATE,
	FirstName,LastName
FROM HumanResources.Employee
WHERE EmployeeCode IN(1,2,501,502)
GO
--------------------------------------------------------------------
--Len بررسی تابع
--استخراج طول یک رشته
--LEN ( string_expression )
SELECT LEN('AliReza') AS Result
GO
SELECT 
	EmployeeCode,FirstName,LEN(FirstName) AS FirstName_Len,
	LastName
FROM HumanResources.Employee
WHERE EmployeeCode IN(1,2,501,502)
GO
-----------
--DataLength بررسی تابع
--استخراج فضای تخصیص داده شده به یک رشته و یا هر نوع فیلدی 
--DATALENGTH ( expression ) 
SELECT DATALENGTH('AliReza') AS Result
SELECT DATALENGTH(N'AliReza') AS Result
GO
SELECT 
	EmployeeCode,FirstName,DATALENGTH(FirstName) AS FirstName_DataLength,
	LastName
FROM HumanResources.Employee
WHERE EmployeeCode IN(1,2,501,502)
GO
--مشاهده فیلدها و... جدول
SP_HELP 'HumanResources.Employee'
GO
--------------------------------------------------------------------
--حذف رکوردهای تستی
DELETE FROM HumanResources.Employee
	WHERE EmployeeCode IN ('501','502','503','504','505','506')
GO