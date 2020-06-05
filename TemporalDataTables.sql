--Temporal Table (Temporal Data Table)
/*
جدول زمانی
هدف نگهداری اطلاعات مربوط به مقدار یک رکورد در هر نقطه از زمان
با اینکار مقادیری که در حال حاظر در جدول اصلی وجود ندارد قابل دسترس می باشد
GO
و اعتبار رکورد را نمایش می دهدDateTime2 اضافه شدن دو فیلد به جدول اصلی است که از نوع 
یعنی رکورد از این تاریخ تا این تاریخ معتبر بوده
*/

CREATE DATABASE TemporalTestDB
USE TemporalTestDB
GO

CREATE TABLE Department
(
	DepartmentID INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED, 
    DepartmentName NVARCHAR(50) NOT NULL, 
    ManagerName NVARCHAR(50) NULL, 
	StartDate DATETIME2(0) GENERATED ALWAYS AS ROW START NOT NULL,
	EndDate DATETIME2(0) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
)
WITH ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.DepartmentHistory ) )
--WITH ( SYSTEM_VERSIONING = ON )


--Temporal استخراج اطلاعاتی درباره جداول
SELECT 
	object_id, temporal_type, temporal_type_desc, 
	history_table_id, name 
FROM SYS.TABLES 
WHERE object_id = OBJECT_ID('dbo.Department', 'U')
GO
SELECT 
	object_id, temporal_type, temporal_type_desc, 
	history_table_id, name 
FROM SYS.TABLES 
WHERE 
	object_id = 
		( 
			SELECT 
				history_table_id 
			FROM SYS.TABLES 
			WHERE 
				object_id = OBJECT_ID('dbo.Department', 'U')
		)
GO


--درج دیتا در جدول اصلی
INSERT Department (DepartmentName,ManagerName) VALUES 
	('D1','Alireza Nouri'),
	('D2','Masoud Nouri'),
	('D3','Farid Nouri')
GO
SELECT * FROM Department
SELECT * FROM DepartmentHistory
GO
UPDATE Department SET ManagerName+='*' WHERE DepartmentID=1
GO
UPDATE Department SET ManagerName+='*' WHERE DepartmentID=2
GO
SELECT * FROM Department
SELECT * FROM DepartmentHistory
GO
--Show Plan
UPDATE Department SET ManagerName+='-' WHERE DepartmentID=1
GO
UPDATE Department SET ManagerName+='-' WHERE DepartmentID=2
GO
SELECT * FROM Department
SELECT * FROM DepartmentHistory
GO
DELETE FROM Department WHERE DepartmentID=1
GO
SELECT * FROM Department
SELECT * FROM DepartmentHistory
GO
--------------------------------------------------------------------
--فرض کنید جدول از قبل وجود دارد
IF OBJECT_ID('Department ')>0
BEGIN
	ALTER TABLE Department SET ( SYSTEM_VERSIONING = OFF )
	DROP TABLE DepartmentHistory
	DROP TABLE Department 
END
GO
CREATE TABLE Department
(
	DepartmentID INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED, 
    DepartmentName NVARCHAR(50) NOT NULL, 
    ManagerName NVARCHAR(50) NULL
)
GO
--Temporal ایجاد حالت 
ALTER TABLE Department ADD
	StartDate DATETIME2(0) GENERATED ALWAYS AS ROW START NOT NULL,
	EndDate DATETIME2(0) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
GO
ALTER TABLE Department SET
	( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.DepartmentHistory ) )
GO
--Temporal استخراج اطلاعاتی درباره جداول
SELECT 
	object_id, temporal_type, temporal_type_desc, 
	history_table_id, name 
FROM SYS.TABLES 
WHERE object_id = OBJECT_ID('dbo.Department', 'U')
GO
SELECT 
	object_id, temporal_type, temporal_type_desc, 
	history_table_id, name 
FROM SYS.TABLES 
WHERE 
	object_id = 
		( 
			SELECT 
				history_table_id 
			FROM SYS.TABLES 
			WHERE 
				object_id = OBJECT_ID('dbo.Department', 'U')
		)
GO


/*
 Limitation of Temporal Tables:

1. Temporal querying over Linked Server is not supported.

2. History table cannot have constraints (PK, FK, Table or Column constraints).

3. INSERT and UPDATE statements cannot reference the SYSTEM_TIME period columns.

4. TRUNCATE TABLE is not supported while SYSTEM_VERSIONING is ON

5. Direct modification of the data in a history table is not permitted.

6. INSTEAD OF triggers are not permitted on either the tables.

7. Usage of Replication technologies is limited.
*/