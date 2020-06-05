
CREATE DATABASE In_Memory ON PRIMARY(
NAME=In_Memory,FILENAME='C:\dump\In_Memory.mdf',
SIZE=5120KB,FILEGROWTH=1024KB
)log on(
NAME=In_Memory_log,FILENAME='C:\dump\In_Memory_log.ldf',
SIZE=1024KB,FILEGROWTH=10%
)

--MEMORY_OPTIMIZED_DATA اضافه شدن فایل گروه از نوع 
ALTER DATABASE In_Memory ADD FILEGROUP MemFG  CONTAINS MEMORY_OPTIMIZED_DATA  

GO

ALTER DATABASE In_Memory ADD FILE
(
NAME=OPTIMIZE,FILENAME='C:\dump\OPTIMIZE'
)TO FILEGROUP MemFG

GO
USE In_Memory
GO
SELECT name,type_desc,physical_name FROM sys.database_files

--Memory Optimized Table  ایجاد یک جدول از نوع
--داده های مربوط به جدول در دیسک ثبت می گردد
--در صورت ذخیره محتوای جدول در دیسک باید حتما کلید اصلی موجود باشد

CREATE TABLE MemOptTable1(
  ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
  FullName NVARCHAR(200) NOT NULL,
  DateAdded DATETIME NOT NULL

) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)--OR SCHEMA ONLY STROER DISK STRACTURE
GO
--Memory Optimized Table  مشاهده لیست جداول از نوع
SELECT * FROM sys.tables
WHERE is_memory_optimized=1

--Memory Optimized Table  ایجاد یک جدول از نوع
--داده های مربوط به جدول در دیسک ثبت نمی گردد

CREATE TABLE MemOptTable2(
ID INT NOT NULL PRIMARY KEY  NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
  FullName NVARCHAR(200) NOT NULL,
  DateAdded DATETIME NOT NULL
)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_ONLY)
GO

--------------------------------------------------------------------
--ایجاد شده به ازای جدول DLL مشاهده 
SELECT OBJECT_ID('MemOptTable1')

SELECT OBJECT_ID('MemOptTable2')


SELECT 
	name,description 
FROM sys.dm_os_loaded_modules
WHERE name LIKE '%XTP%'

--بررسی دیتا فایل و دلتا فایل ها + ظرفیت هر کدام از آنها
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Memory Optimized Table در Lock بررسی 
GO
--Disk Based  انجام عملیات در یک جدول از نوع
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('DiskTable')>0
	DROP TABLE DiskTable
GO
--Disk Based  ایجاد یک جدول از نوع
CREATE TABLE DiskTable
(
    ID INT NOT NULL PRIMARY KEY ,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) 
GO

BEGIN TRANSACTION 
INSERT INTO DiskTable VALUES (1,'ALINOURI',GETDATE())
--مشاهده لاک های مربوط به جدول
SELECT LO.request_session_id,LO.resource_database_id
,LO.resource_associated_entity_id,LO.resource_type,LO.resource_description,
LO.request_mode,LO.request_status
FROM sys.dm_tran_locks LO
WHERE LO.request_session_id=@@SPID


ROLLBACK
GO


SELECT * FROM SYS.dm_os_latch_stats


--------------------------------------------------------------------
--Memory Optimized Table  انجام عملیات در یک جدول از نوع


CREATE TABLE MemOptTable(
   ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH(BUCKET_COUNT=10000),

    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_AND_DATA)
GO
BEGIN TRANSACTION

INSERT INTO MemOptTable VALUES (1,'ALINOURI',GETDATE())

SELECT * FROM SYS.dm_tran_locks
WHERE request_session_id=@@SPID
ROLLBACK

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Hash Index بررسی

CREATE TABLE MemOptTable(
ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=10000),
  FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_AND_DATA)

GO

INSERT INTO MemOptTable(FullName,DateAdded) VALUES('ALINOURI',GETDATE())
GO 5000

SELECT * FROM MemOptTable

SELECT COUNT(ID) FROM MemOptTable

SELECT * FROM MemOptTable
WHERE ID=123


---- BUCKET_COUNT HASH INDEX LOWWWWW BETWEEN
SELECT * FROM MemOptTable
WHERE ID BETWEEN 123 AND 200
---------2 INDEX

CREATE TABLE MemOptTable2(
ID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED HASH WITH(BUCKET_COUNT=1000),
NatinoalCod INT INDEX IX NONCLUSTERED HASH WITH (BUCKET_COUNT=1000),
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_AND_DATA)
GO

--Disk Based مقایسه هش ایندکس با ایندکس کلاستر جداول 

CREATE TABLE DiskTable
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY ,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL
) 
GO
INSERT INTO DiskTable(FullName,DateAdded)
	VALUES (N'FullName',GETDATE())
GO 397


--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
SELECT * FROM MemOptTable
	WHERE ID=123
GO
SELECT * FROM DiskTable
	WHERE ID=123

-----------Memory Optimized برای جداول NonClustered Index بررسی 

CREATE TABLE MemOptTable
(
ID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=1000),
 FullName NVARCHAR(200) NOT NULL, 
 DateAdded DATETIME NOT NULL INDEX IX NONCLUSTERED 

)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_AND_DATA)

--درج تعدادی رکورد در بانک اطلاعاتی
INSERT INTO MemOptTable(FullName,DateAdded)
	VALUES ('FullName',GETDATE())
GO 100
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(ID),* FROM MemOptTable
GO
--مشاهده پلن اجرایی کوئری
--Show Estimate Execution Plan & Actual Execution Plan
--Bookmark Lookup فاقد
SELECT * FROM MemOptTable
	WHERE DateAdded =GETDATE()
GO
SELECT * FROM MemOptTable
	WHERE DateAdded BETWEEN '2020-05-29 16:39:18.317' AND '2020-05-29 16:39:22.170'
GO


--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--Memory Optimized Table بررسی وضعیت تخصیص حافظه به جداول 
SELECT 
	OBJECT_NAME(object_id) ObjectName,
    Object_Id,
    SUM( memory_allocated_for_indexes_kb + memory_allocated_for_table_kb) AS MemoryAllocated_Object_In_KB, 
    SUM( memory_used_by_indexes_kb + memory_used_by_table_kb) AS MemoryUsed_Object_In_KB 
FROM sys.dm_db_xtp_table_memory_stats
WHERE object_id>0
GROUP by object_id
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------

--Native Compiled Stored Procedureآشنایی با 

CREATE TABLE DiskTable(
   ID INT NOT NULL PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL

)

GO

CREATE PROCEDURE usp_LoadDiskTable (@maxRows INT, @FullName NVARCHAR(200))
AS BEGIN
SET NOCOUNT ON
DECLARE @I INT=1
WHILE @I <=@maxRows
BEGIN
INSERT INTO DiskTable VALUES(@I,@FullName,GETDATE())
SET @I=@I+1
END
END

GO

CREATE TABLE MemOptTable(
ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT=1000),
  FullName NVARCHAR(200) NOT NULL, 
    DateAdded DATETIME NOT NULL

)WITH (MEMORY_OPTIMIZED=ON,DURABILITY=SCHEMA_AND_DATA)

GO

CREATE PROCEDURE usp_LoadMemOptTable (@maxRows INT, @FullName NVARCHAR(200))
WITH 
NATIVE_COMPILATION,
SCHEMABINDING,
EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT ,LANGUAGE='us_english')
DECLARE @I INT=1
WHILE @I <=@maxRows
 BEGIN
        INSERT INTO dbo.MemOptTable VALUES(@i, @FullName, GETDATE())
        SET @i = @i+1
    END
END

GO

--در حالت های مختلف Disk Table تست
GO
--Disk Table (without SP) درج دیتا در جدول از نوع 
SET NOCOUNT ON
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @TotalTime INT
DECLARE @i INT = 1
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)

WHILE @i <= @MaxRows
BEGIN
    INSERT INTO DiskTable VALUES(@i, @FullName, GETDATE())
    SET @i = @i+1
END
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Disk Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (without SP)'
GO
--بررسی تعداد رکوردهای درج شده
SP_SPACEUSED 'DiskTable'
/*
Disk Table Load (without SP) :8473 ms
*/
GO

--Disk Table (with simple SP) درج دیتا در جدول از نوع 
TRUNCATE TABLE DiskTable
GO
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
DECLARE @TotalTime INT
EXEC usp_LoadDiskTable @maxRows, @FullName
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Disk Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (with simple SP)'
GO
--بررسی تعداد رکوردهای درج شده
SP_SPACEUSED 'DiskTable'
/*
Disk Table Load (with SP) :4040 ms
*/
--------------------------------------------------------------------
--در حالت های مختلف Memory-Optimized Table تست
GO
--Memory Optimized Table (without SP) درج دیتا در جدول از نوع 
SET NOCOUNT ON
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @TotalTime INT
DECLARE @i INT = 1
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
 
WHILE @i <= @maxRows
BEGIN
    INSERT INTO MemOptTable VALUES(@i, @FullName, GETDATE())
    SET @i = @i+1
END
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Memory Optimized Table  Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (without SP)'
GO
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(*) FROM MemOptTable
GO 
/*
Memory Optimized Table Load (without SP) :3990 ms
*/
GO 
--Memory Optimized Table (with Native Compiled SP) درج دیتا در جدول از نوع 
DELETE FROM MemOptTable
GO
DECLARE @StartTime DATETIME = GETDATE()
DECLARE @MaxRows INT = 10000
DECLARE @FullName VARCHAR(200)= REPLICATE('A',200)
DECLARE @TotalTime INT
EXEC usp_LoadMemOptTable @maxRows, @FullName
SET @TotalTime = DATEDIFF(ms,@StartTime,GETDATE())
SELECT 'Memory Optimized Table Load: ' + CAST(@TotalTime AS VARCHAR) + ' ms (with Native Compiled SP)'
GO
--بررسی تعداد رکوردهای درج شده
SELECT COUNT(*) FROM MemOptTable
GO 
/*
Memory Optimized Table  Load (without SP) :450 ms
*/
--------------------------------------------------------------------
/*
Disk Table Load (without SP) : 8473 ms
Disk Table Load (with SP) : 4040 ms
Memory Optimized Table  Load (without SP) : 3990 ms
Memory Optimized Table  (without SP) : 450 ms
*/
--بررسی کد کامپایل شده
SELECT OBJECT_ID('DBO.usp_LoadMemOptTable')
GO
SELECT name, description FROM sys.dm_os_loaded_modules
	WHERE name like '%xtp_p_%'

--------------------------------------------------------------------
--مربوط به آن حذف می شودDLL اتوماتیک SP هنگام حذف 
--ها نمی باشدDLL لزومی به تهیه نسخه پشتیبان از
--------------------------------------------------------------------
--------------------------------------------------------------------
--SQL Server 2016  بررسی برهی از تغییرات 
USE master
GO
--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('SQL2016_Demo')>0
BEGIN
	ALTER DATABASE SQL2016_Demo SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE SQL2016_Demo
END
GO

--------------------------------------------------------------------
--ایجاد بانک اطلاعاتی
CREATE DATABASE SQL2016_Demo
 ON  PRIMARY
( 
    NAME = N'SQL2016_Demo', 
    FILENAME = N'E:\Dump\SQL2016_Demo.mdf', 
    SIZE = 5120KB, 
    FILEGROWTH = 1024KB 
 )
 LOG ON 
 ( 
    NAME = N'SQL2016_Demo_log', 
    FILENAME = N'E:\Dump\SQL2016_Demo_log.ldf', 
    SIZE = 1024KB, 
    FILEGROWTH = 10%
 )
GO
--MEMORY_OPTIMIZED_DATA اضافه شدن فایل گروه از نوع 
ALTER DATABASE SQL2016_Demo 
    ADD FILEGROUP MemFG CONTAINS MEMORY_OPTIMIZED_DATA 
GO
--اضافه کردن فایل به فایل گروه مورد نظر
ALTER DATABASE SQL2016_Demo ADD FILE
	( 
		NAME = MemFG_File1,
		FILENAME = N'E:\Dump\MemFG_File1'--مسیر مورد نظر بررسی شود
	) 
TO FILEGROUP MemFG
GO
--------------------------------------------------------------------
USE SQL2016_Demo
GO
--بررسی جهت وجود جدول
IF OBJECT_ID('MemOptTable1')>0
	DROP TABLE MemOptTable1
GO
CREATE TABLE MemOptTable1
(
    ID INT NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 10000),
    FullName NVARCHAR(200) COLLATE PERSIAN_100_CI_AI NOT NULL, 
    DateAdded DATETIME  NULL,
	Comments NVARCHAR(MAX),
	Picture VARBINARY(MAX),
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO
--اضافه شدن فیلد جدید
ALTER TABLE MemOptTable1 ADD AddressInfo NVARCHAR(100)
GO
--ساخت ایندکس
ALTER TABLE MemOptTable1 ADD INDEX IX_DateAdded(DateAdded) 
GO
SP_HELPINDEX MemOptTable1
GO
--بازسازی ایندکس برای دستکاری پارامترها
ALTER TABLE MemOptTable1 ALTER INDEX PK__MemOptTa__3214EC262F8C69BC
	REBUILD WITH (BUCKET_COUNT=20000)
GO
--------------------------------------------------------------------
-- Native Compiled Stored Procedure از نوعSP ایجاد یک
CREATE PROCEDURE usp_LoadMemOptTable (@maxRows INT, @FullName NVARCHAR(200))
WITH
    NATIVE_COMPILATION, 
    SCHEMABINDING, 
    EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE='us_english')
    DECLARE @i INT = 1
    WHILE @i <= @maxRows
    BEGIN
        INSERT INTO dbo.MemOptTable1(FullName,DateAdded) 
			VALUES(@FullName, GETDATE())
        SET @i = @i+1
    END
END
GO
--قابلیت جدید
ALTER PROCEDURE usp_LoadMemOptTable (@maxRows INT, @FullName NVARCHAR(200))
WITH
    NATIVE_COMPILATION, 
    SCHEMABINDING, 
    EXECUTE AS OWNER
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE='us_english')
    DECLARE @i INT = 1
    WHILE @i <= @maxRows
    BEGIN
        INSERT INTO dbo.MemOptTable1(FullName,DateAdded) 
			VALUES(@FullName, GETDATE())
        SET @i = @i+1
    END
END
GO

