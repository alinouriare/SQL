
CREATE TABLE CLUSTERD(
ID INT,FIRSTNAME CHAR(2000),LASTNAME CHAR(2000 )
)
GO
SP_HELPINDEX 'CLUSTERD'

INSERT INTO CLUSTERD VALUES(1,'AA','AA')
INSERT INTO CLUSTERD VALUES(1,'BB','BB')
INSERT INTO CLUSTERD VALUES(1,'CC','CC')
INSERT INTO CLUSTERD VALUES(1,'DD','DD')
INSERT INTO CLUSTERD VALUES(1,'EE','EE')
INSERT INTO CLUSTERD VALUES(1,'RR','RR')
INSERT INTO CLUSTERD VALUES(1,'TT','TT')
GO
SP_SPACEUSED 'CLUSTERD'
GO
SELECT * FROM CLUSTERD
GO

CREATE CLUSTERED INDEX CL_IN ON CLUSTERD(ID)
GO

CREATE TABLE CLUSTRED1(
ID CHAR(1000),

FIRSTNAME CHAR(3000),LASTNAME CHAR(3000 )
)
GO
--ERROR The clustered index key size cannot exceed 900 bytes
CREATE CLUSTERED INDEX IX_A ON CLUSTRED1(ID)

GO
--آدرس گره ریشه در جدول
SELECT * FROM sys.system_internals_allocation_units
GO
SELECT 
	au.allocation_unit_id,o.name AS table_name,
	p.index_id, i.name AS index_name , 
	au.type_desc AS allocation_type, 
	au.data_pages, partition_number
FROM sys.allocation_units AS au
    JOIN sys.partitions AS p ON au.container_id = p.partition_id
    JOIN sys.objects AS o ON p.object_id = o.object_id
    JOIN sys.indexes AS i ON p.index_id = i.index_id AND i.object_id = p.object_id
WHERE o.name = N'tempdb' OR o.name = N'ClusteredTable'
ORDER BY o.name, p.index_id;
GO
SELECT * FROM sys.system_internals_allocation_units A 
	WHERE A.allocation_unit_id=2810250048774930432
GO
--های تخصیص یافته به هر رکوردPage بررسی 
SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID],
	* 
FROM ClusteredTable
GO
--مشاهده درون ایندکس
--به انواع صفحات موجود در ایندکس توجه کنید
--به ترتیب صفحات توجه کنید
DBCC IND('tempdb','ClusteredTable',1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
GO

GO
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('tempdb'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO
--نمایش اطلاعات صفحات به صفحات ایندکس دقت شود
DBCC TRACEON(3604);
DBCC PAGE('tempdb',1,73481,3)WITH NO_INFOMSGS;
GO

/*
BCC IND ( { 'dbname' | dbid }, { 'objname' | objid }, { nonclustered indid | 1 | 0 | -1 | -2 });
nonclustered indid = non-clustered Index ID 
1 = Clustered Index ID 
0 = Displays information in-row data pages and in-row IAM pages (from Heap) 
-1 = Displays information for all pages of all indexes including LOB (Large object binary) pages and row-overflow pages 
-2 = Displays information for all IAM pages

1= data page
2= index page
3 and 4 = text pages
8 = GAM page
9 = SGAM page
10 = IAM page
11 = PFS page
*/
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--بخش دوم

--نحوه استفاده از کلاستر ایندکس برای جستجو
--داشته باشیمIO با توجه به ساختار صفحات باید 3 تا 
-- زیادی داریمIO چرا 
SET STATISTICS IO ON
DECLARE @ID CHAR(900)='9'
SELECT * FROM ClusteredTable WHERE ID=@ID
GO

/*
--های تخصیص یافته به هر رکوردPage بررسی 
SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID],
	* 
FROM ClusteredTable
GO
*/
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--بخش سوم

USE tempdb
GO
--بررسی وجود جداول
IF OBJECT_ID('Orders_ClusteredTable')>0
	DROP TABLE Orders_ClusteredTable
GO
IF OBJECT_ID('Orders_HeapTable')>0
	DROP TABLE Orders_HeapTable
GO
--تهیه کپی از جدول
SELECT * INTO Orders_ClusteredTable FROM Northwind.dbo.Orders
SELECT * INTO Orders_HeapTable FROM Northwind.dbo.Orders
GO
--ایجاد کلاستر ایندکس
CREATE CLUSTERED INDEX IX_CLUSTERED ON Orders_ClusteredTable (ORDERID)
GO
--مقایسه هنگام جستجو و واکشی رکوردها

--IO بررسی وضعیت 
SET STATISTICS IO ON
SELECT * FROM Orders_ClusteredTable
SELECT * FROM Orders_HeapTable
GO
--IO بررسی وضعیت 
--Execution Plan
SELECT * FROM Orders_ClusteredTable WHERE ORDERID=10292
SELECT * FROM Orders_HeapTable WHERE ORDERID=10292
GO

--مقایسه هنگام درج رکورد

--درج رکورد در جدول کلاستر
SET  IDENTITY_INSERT Orders_ClusteredTable ON
GO
INSERT INTO Orders_ClusteredTable
	(
		OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
	)
	SELECT 
		200 AS OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry	
	FROM Orders_ClusteredTable WHERE ORDERID=10292
GO
SET  IDENTITY_INSERT Orders_ClusteredTable OFF
GO
--درج رکورد در جدول هیپ
SET  IDENTITY_INSERT Orders_HeapTable ON
GO
INSERT INTO Orders_HeapTable
	(
		OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry
	)
	SELECT 
		200 AS OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
		ShippedDate, ShipVia, Freight, ShipName, ShipAddress, 
		ShipCity, ShipRegion, ShipPostalCode, ShipCountry		
	FROM Orders_HeapTable WHERE ORDERID=10292
GO
SET  IDENTITY_INSERT Orders_HeapTable OFF
GO
--مشاهده رکوردهای درج شده
SELECT * FROM Orders_ClusteredTable
SELECT * FROM Orders_HeapTable
GO