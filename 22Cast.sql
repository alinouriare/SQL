DECLARE @A INT=100
DECLARE @B NVARCHAR(20)='ALI'


--SELECT (@A+@B) AS RES

SELECT CAST(@A AS nvarchar) +@B
use AdventureWorks2014

SELECT JobTitle,CAST( BusinessEntityID AS nvarchar) +JobTitle FROM HumanResources.Employee
GO
sp_help 'HumanResources.Employee'
GO
SET STATISTICS IO ON
SELECT * FROM HumanResources.Employee
WHERE CAST(BusinessEntityID AS nvarchar(10))='2'
GO
SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID=2
go

SELECT JobTitle,BusinessEntityID,
CONVERT(NVARCHAR(10),BirthDate,111) FROM HumanResources.Employee
GO
SELECT JobTitle,BusinessEntityID,
CONVERT(NVARCHAR(10),BusinessEntityID)+JobTitle FROM HumanResources.Employee
GO
--Parse بررسی تابع 
--Culture جهت تبدیل یک رشته به نوع خاص با در نظر گرفتن
--PARSE ( string_value AS data_type [ USING culture ] )

-- PARSE String to INT
SELECT PARSE('1000' AS INT) AS 'String to INT'
GO
-- PARSE String to Numeric
SELECT PARSE('1000.06' AS NUMERIC(8,2)) AS 'String to Numeric'
GO
-- PARSE String to DateTime
SELECT PARSE('05-18-2013' as DATETIME) AS 'String to DATETIME'
GO
-- PARSE String to DateTime
SELECT PARSE('2013/05/18' as DATETIME) AS 'String to DATETIME'
GO
-- PARSE string value in the India date format to DateTime 
SELECT PARSE('18-05-2013' as DATETIME using 'en-in') 
 AS 'String in Indian DateTime Format to DATETIME'
GO
-- PARSE string value is in the US currency format to Money 
SELECT PARSE('$2500' as MONEY using 'en-US') 
 AS 'String in US Currency Format to MONEY'
GO
GO

--Try_Cast بررسی تابع 
--می شود Null تبدیل یک نوع داده به نوع داده دیگر ، در صورت عدم تبدیل خروجی
--TRY_CAST ( expression AS data_type [ ( length ) ] )
SELECT CAST('123A' AS INT) AS Result
SELECT TRY_CAST('123A' AS INT) AS Result
SELECT TRY_CAST('123' AS INT) AS Result
GO
--Try_Parse بررسی تابع 
--می شود Null در صورت عدم تبدیل خروجی تابعCulture جهت تبدیل یک رشته به نوع خاص با در نظر گرفتن
--TRY_PARSE ( string_value AS data_type [ USING culture ] )
SELECT PARSE('1000' AS INT) AS 'String to INT'
SELECT PARSE('1000A' AS INT) AS 'String to INT'
SELECT TRY_PARSE('1000A' AS INT) AS 'String to INT'

go


GO
--GetDate بررسی تابع 
--بدست آوردن تاریخ و زمان جاری
--GETDATE ( )
SELECT GETDATE() AS Result
GO
SELECT 
	GETDATE() AS GetDateValue,
	CONVERT(VARCHAR(50),GETDATE(),111) AS GetDateConvert
GO
--------------------------------------------------------------------
--SysDateTime بررسی تابع 
--بدست آوردن تاریخ و زمان جاری
--SYSDATETIME ( )
SELECT SYSDATETIME() AS Result
SELECT GETDATE() AS Result
GO
--------------------------------------------------------------------
--DateAdd بررسی تابع 
--اضافه کردن یک مقدار به تاریخ
--DATEADD (datepart , number , date )
SELECT DATEADD(MONTH, 1, '2014-01-01') AS Result
SELECT DATEADD(MONTH, -1, '2014-03-01') AS Result
GO
--تاریخ تولد یکسال عقب کشیده شود
SELECT 
	EmployeeID,FirstName,
	LastName,BirthDate,DATEADD(YEAR,-1,BirthDate) AS Result
FROM HumanResources.Employee
--------------------------------------------------------------------
--DateDiff بررسی تابع 
--بدست آوردن اختلاف بین دو تاریخ
--DATEDIFF ( datepart , startdate , enddate )
SELECT DATEDIFF(YEAR,'1982-07-24',GETDATE())
SELECT DATEDIFF(DAY,'1982-07-24',GETDATE())
GO
--بدست آوردن سن کارمندان
SELECT 
	EmployeeID,FirstName,
	LastName,BirthDate,DATEDIFF(YEAR,BirthDate,GETDATE()) AS Age
FROM HumanResources.Employee
GO
--------------------------------------------------------------------
--DateName بررسی تابع 
--عنوان یک بخش از تاریخ را استخراج می کند
--DATENAME ( datepart , date )
SELECT 
	DATENAME(YEAR,GETDATE()) AS DateName_YEAR
	,DATENAME(MONTH,GETDATE()) AS DateName_MONTH
	,DATENAME(DAY,GETDATE()) AS DateName_DAY
	,DATENAME(DAYOFYEAR,GETDATE()) AS DateName_DAYOFYEAR
	,DATENAME(WEEKDAY,GETDATE()) AS DateName_WEEKDAY
GO
--------------------------------------------------------------------
--DatePart بررسی تابع 
--استخراج قسمتی از تاریخ
--DATEPART ( datepart , date )
SELECT 
	DATEPART(YEAR,GETDATE()) AS DatePart_YEAR
	,DATEPART(MONTH,GETDATE()) AS DatePart_MONTH
	,DATEPART(DAY,GETDATE()) AS DatePart_DAY
	,DATEPART(DAYOFYEAR,GETDATE()) AS DatePart_DAYOFYEAR
	,DATEPART(WEEKDAY,GETDATE()) AS DatePart_WEEKDAY
GO
--------------------------------------------------------------------
--Day , Mount , Year بررسی تابع 
--استخراج سال ، ماه،روز از تاریخ
--DAY ( date ) * MOUNT ( date ) * YEAR ( date )

SELECT YEAR(GETDATE()) AS [Year], MONTH(GETDATE()) AS [Month], DAY(GETDATE()) AS [Day]
GO
--استخراج سال و ماه تولد کارمندان به تفکیک
SELECT 
	EmployeeID,FirstName,
	LastName,BirthDate,
	YEAR(BirthDate) AS [Year],MONTH(BirthDate) AS [Month]
FROM HumanResources.Employee
GO
--------------------------------------------------------------------
--Format بررسی تابع 
--استخراج قسمتی از تاریخ
--FORMAT ( value, format [, culture ] )
DECLARE @d DATETIME = '10/01/2011';
SELECT FORMAT ( @d, 'd', 'en-US' ) AS 'US English Result'
      ,FORMAT ( @d, 'd', 'en-gb' ) AS 'Great Britain English Result'
      ,FORMAT ( @d, 'd', 'de-de' ) AS 'German Result'
      ,FORMAT ( @d, 'd', 'zh-cn' ) AS 'Simplified Chinese (PRC) Result'; 

SELECT FORMAT ( @d, 'D', 'en-US' ) AS 'US English Result'
      ,FORMAT ( @d, 'D', 'en-gb' ) AS 'Great Britain English Result'
      ,FORMAT ( @d, 'D', 'de-de' ) AS 'German Result'
      ,FORMAT ( @d, 'D', 'zh-cn' ) AS 'Chinese (Simplified PRC) Result'
GO
DECLARE @d DATETIME
SET @d='4/9/2013 4:54:08 PM'
 
SELECT FORMAT(@d, 'dd')--09   
SELECT FORMAT(@d, 'dd-M-yyyy')--09-4-2013
SELECT FORMAT(@d, 'dd MMMM')--09 April
SELECT FORMAT(@d, 'dd MMMM', 'fr-FR')--09 avril 
SELECT FORMAT(@d, 'yyyyMM')--201304
GO
--------------------------------------------------------------------
--DateFormatParts بررسی تابع 
--تبدیل تعدادی از مقادیر به نوع تاریخ و یا زمان
--DATEFROMPARTS ( year, month, day )
--DATETIMEFROMPARTS ( year, month, day, hour, minute, seconds, milliseconds )
--DATETIME2FROMPARTS ( year, month, day, hour, minute, seconds, fractions, precision )
SELECT DATEFROMPARTS(2012, 3, 10) AS RESULT
SELECT TIMEFROMPARTS(12, 10, 32, 0, 0) AS RESULT
SELECT DATETIME2FROMPARTS (2012, 3, 10, 12, 10, 32, 0, 0) AS RESULT
GO
