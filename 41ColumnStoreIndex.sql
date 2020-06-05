CREATE TABLE Employees
(
	Code INT IDENTITY  PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(80),
	HireDate SMALLDATETIME,
	City NVARCHAR(20)
)
GO

SP_HELPINDEX 'Employees'

GO

INSERT INTO Employees (FirstName,LastName,HireDate,City) VALUES 
	(N'علی',N'نوری','2000-01-01',N'میانه'),
	(N'فرید',N'سعیدی','2003-01-01',N'میانه'),
	(N'احمد',N'غفاری','2003-01-01',N'میانه'),
	(N'خدیجه',N'افروزنیا','2000-01-01',N'تهران'),
	(N'مجید',N'طاهری','2005-01-01',N'تهران')

GO

SELECT * FROM Employees
GO

INSERT INTO Employees (FirstName,LastName,HireDate,City) 
	SELECT FirstName,LastName,HireDate,City FROM Employees
GO 20

DBCC IND('XMLTEST','Employees',1)

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID('XMLTEST'),OBJECT_ID('Employees'),

NULL,NULL,'detailed') 

GO
---تعداد رکورد
SP_SPACEUSED 'Employees'
--------------------------------------------------------
--NONCLUSTERED INDEX OVER CLUSTERED INDEX

CREATE NONCLUSTERED INDEX IX_X ON Employees(FirstName,LastName,HireDate)


--NONCLUSTERED COLUMNSTORE INDEX OVER CLUSTERED INDEX

CREATE NONCLUSTERED COLUMNSTORE INDEX CO_X ON Employees(FirstName,LastName,HireDate)

GO
SP_SPACEUSED 'Employees'
SP_HELPINDEX 'Employees'
--نمی باشذ Read-Only به صورت Columnstore Index در نسخه 2016 دیگر 
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('XMLTEST'),OBJECT_ID('Employees'),NULL,NULL,'DETAILED') S

			GO

			SELECT 
	OBJECT_SCHEMA_NAME(i.OBJECT_ID) SchemaName,
	OBJECT_NAME(i.OBJECT_ID ) TableName
	,i.type_desc,i.name IndexName,
	SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE i.OBJECT_ID=OBJECT_ID('Employees')  
GROUP BY i.OBJECT_ID, i.name,i.type_desc

go

 --------------------------------------------------------
--اگر کوئری شامل فیلدهای مورد استفاده در کالمن استور ایندکس باشد
--Show Execution Plan
SELECT Code,FirstName,LastName FROM Employees

--Show Execution Plan
SELECT Code,FirstName,LastName FROM Employees
	OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
--SELECT Code,FirstName,LastName FROM Employees WITH(INDEX(IX_X))



----
SELECT Code,FirstName,LastName FROM Employees WHERE LastName=N'نوری'
GO
SELECT Code,FirstName,LastName FROM Employees WHERE  LastName=N'نوری'
	OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX) 
GO
--Show Execution Plan
SELECT Code,FirstName,LastName FROM Employees
	OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
--SELECT Code,FirstName,LastName FROM Employees WITH(INDEX(IX_NC))
GO



SET STATISTICS IO ON

SET STATISTICS TIME ON
------------
----COLUMNSTORE
SELECT  Code,FirstName,LastName FROM Employees WITH (INDEX(CO_X))
WHERE FirstName=N'علی'
-------NON
SELECT  Code,FirstName,LastName FROM Employees WITH (INDEX(IX_X))
WHERE FirstName=N'علی'


SELECT  Code,FirstName,LastName FROM Employees WITH (INDEX(CO_X))
WHERE Code BETWEEN 1 AND 1000
-------NON
SELECT  Code,FirstName,LastName FROM Employees WITH (INDEX(IX_X))
WHERE Code BETWEEN 1 AND 1000
--------------------TOTAL FIELD COLUMNSTORD

SELECT * INTO EM3 FROM Employees

SELECT * INTO EM2 FROM Employees
GO

SELECT * FROM sys.indexes
WHERE object_id=OBJECT_ID('EM3')
-- CLUSTERED COLUMNSTORE INDEX ایجاد یک 
CREATE CLUSTERED COLUMNSTORE INDEX AA_X ON EM3

CREATE UNIQUE CLUSTERED  INDEX AA_B ON EM2(CODE)
---
SELECT * FROM sys.indexes
WHERE object_id=OBJECT_ID('EM2')

SP_SPACEUSED 'EM2'
GO
SP_SPACEUSED 'EM3'

------PLAN
SET STATISTICS IO ON
SET STATISTICS TIME ON
DBCC DROPCLEANBUFFERS
CHECKPOINT
SELECT COUNT(Code),FirstName FROM EM3
GROUP BY FirstName
-------
SELECT COUNT(Code),FirstName FROM EM2
GROUP BY FirstName
-------------------AGRAGATION ON COLUMN OK
-------------------OPTIMIZ MEMORY COLUMN ON DISK
