CREATE DATABASE TEST
GO
USE TEST
GO
--non cluster on heap
CREATE TABLE HeapTable(

ID CHAR(900),
FirstName CHAR(3000),
LastName CHAR(3000)
)
GO
CREATE NONCLUSTERED INDEX NON_INDEX ON HeapTable(ID)
GO
SP_HELPINDEX 'HeapTable'
GO



INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (1,'Masoud','Nouri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (5,'Alireza','Nouri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (3,'Ali','Nouri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (4,'Majid','Nouri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (2,'Farid','Nouri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (10,'Ahmad','Ghafari')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (8,'Alireza','Nasiri')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (9,'Khadijeh','Afrooznia')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (7,'Mina','Afrooznia')
INSERT INTO HeapTable(ID,FirstName,LastName) VALUES (6,'Mohammad','Noroozi')
GO
SP_SPACEUSED 'HeapTable'
GO

DBCC IND('TEST','HeapTable',-1) ;

DBCC TRACEON(256);
DBCC PAGE('TEST',1,257,0);

SELECT S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count FROM 
sys.dm_db_index_physical_stats(DB_ID('TEST')
,OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S

GO

SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID],
	* 
FROM HeapTable

GO
------non cluster on cluster
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName CHAR(3000),
	LastName CHAR(3000),
	StartYear  CHAR(900)
)
go

CREATE CLUSTERED INDEX IX_CLUSTER ON ClusteredTable(ID)
CREATE NONCLUSTERED INDEX IX_NONCLUSTER ON ClusteredTable(StartYear)

SP_SPACEUSED 'ClusteredTable'

SELECT * FROM sys.indexes
WHERE object_id=OBJECT_ID('ClusteredTable')
GO
DBCC IND ('TEST','ClusteredTable',1) WITH NO_INFOMSGS;
GO
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('TEST'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S


			--درج تعدادی رکورد تستی
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (1,'Masoud','Nouri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (5,'Alireza','Nouri',1393)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (3,'Ali','Nouri',1390)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (4,'Majid','Nouri',1380)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (2,'Farid','Nouri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (10,'Ahmad','Ghafari',1379)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (8,'Alireza','Nasiri',1378)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (9,'Khadijeh','Afrooznia',1384)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (7,'Mina','Afrooznia',1385)
INSERT INTO ClusteredTable(ID,FirstName,LastName,StartYear) VALUES (6,'Mohammad','Noroozi',1383)
GO
--بررسی حجم جدول
SP_SPACEUSED ClusteredTable
GO
--بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
--در یک فضای دیگر ایجاد شده استNonClustered ایندکس
SELECT 
	S.index_id,S.index_type_desc,S.alloc_unit_type_desc,
	S.index_depth,S.index_level,S.page_count ,S.record_count
	FROM 
		sys.dm_db_index_physical_stats
			(DB_ID('TEST'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED') S
GO

--مشاهده درون ایندکس
--به انواع صفحات موجود در ایندکس توجه کنید
--به ترتیب صفحات توجه کنید
DBCC IND('TEST','ClusteredTable',-1) WITH NO_INFOMSGS;--همه ركوردها توجه iam_chanin_type به فيلد 
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
----------lookup rid

SELECT * INTO HeapTable FROM AdventureWorks2014.Sales.SalesOrderDetail

GO

CREATE nonCLUSTERED INDEX IX_Nonclustered on HeapTable
(ProductID,OrderQty,SpecialOfferID)

go

DBCC IND ('TEST','HeapTable',1)
GO

SELECT S.index_id,S.index_depth,S.index_type_desc
,s.page_count,s.record_count,s.alloc_unit_type_desc
FROM

sys.dm_db_index_physical_stats(DB_ID('TEST')
,OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED') S

go
SET STATISTICS IO ON
---plan
SELECT
SalesOrderID,SalesOrderDetailID,
ProductID,OrderQty,SpecialOfferID
FROM HeapTable 
WHERE ProductID=789

SELECT SalesOrderID,SalesOrderDetailID
,ProductID,OrderQty,SpecialOfferID
FROM HeapTable 
WHERE OrderQty=1


SELECT 
ProductID,OrderQty,SpecialOfferID
FROM HeapTable 
WHERE OrderQty=1
go
------lookup key
SELECT * INTO ClusteredTbale FROM AdventureWorks2014.Sales.SalesOrderDetail

create clustered index ix_clustered on ClusteredTbale(SalesOrderID)
create nonclustered index ix_nonclustered on ClusteredTbale(ProductID,OrderQty,SpecialOfferID)

go
SP_HELPINDEX 'ClusteredTbale'

SELECT s.index_id,s.index_depth,index_type_desc
,s.alloc_unit_type_desc,s.page_count,s.record_count FROM sys.dm_db_index_physical_stats
(DB_ID('TEST'),OBJECT_ID('ClusteredTbale')
,null,null,'DETAILED') s

SELECT
SalesOrderID,SalesOrderDetailID,
ProductID,OrderQty,SpecialOfferID
FROM ClusteredTbale 
WHERE ProductID=789
go
SELECT
SalesOrderID
--,SalesOrderDetailID
,ProductID,OrderQty,SpecialOfferID
FROM ClusteredTbale 
WHERE ProductID=789
go

----lookup key and rid
--plan

set statistics io on
SELECT
SalesOrderID,SalesOrderDetailID,
ProductID,OrderQty,SpecialOfferID
FROM ClusteredTbale 
WHERE ProductID=789


SELECT
SalesOrderID,SalesOrderDetailID,
ProductID,OrderQty,SpecialOfferID
FROM HeapTable 
WHERE ProductID=789

-------cover index


SELECT * INTO HEAPCOVER FROM AdventureWorks2014.Sales.SalesOrderDetail
---PLAN
CREATE NONCLUSTERED INDEX IX_NONCUSTERED ON HEAPCOVER(ProductID,OrderQty,SpecialOfferID)
GO
SELECT SalesOrderID,SalesOrderDetailID,ProductID,OrderQty,
SpecialOfferID
FROM HEAPCOVER
WITH (INDEX(IX_NONCUSTERED))
WHERE ProductID=789 
GO

CREATE NONCLUSTERED INDEX IX_NONCUSTERED2 ON 
HEAPCOVER(ProductID,OrderQty,SpecialOfferID)
INCLUDE(SalesOrderID,SalesOrderDetailID)


SELECT SalesOrderID,SalesOrderDetailID,ProductID,OrderQty,
SpecialOfferID
FROM HEAPCOVER
WITH (INDEX(IX_NONCUSTERED))
WHERE ProductID=789 


SELECT SalesOrderID,SalesOrderDetailID,ProductID,OrderQty,
SpecialOfferID
FROM HEAPCOVER
WITH (INDEX(IX_NONCUSTERED2))
WHERE ProductID=789 
GO

SELECT S.hobt_id,S.alloc_unit_type_desc,S.index_type_desc
,S.page_count,S.record_count,S.index_depth FROM

sys.dm_db_index_physical_stats(DB_ID('TEST'),
OBJECT_ID('HEAPCOVER'),NULL,NULL,'DETAILED') S


SP_HELPINDEX 'HEAPCOVER'

SELECT * FROM sys.indexes
WHERE object_id=OBJECT_ID('HEAPCOVER')

DBCC IND('TEST','HEAPCOVER',1)

SP_SPACEUSED 'HEAPCOVER'
-------

SELECT * INTO CLUSTEREDCOVER FROM AdventureWorks2014.Sales.SalesOrderDetail


GO

CREATE CLUSTERED INDEX IS_CUSTERDE ON CLUSTEREDCOVER(SalesOrderID)

CREATE NONCLUSTERED INDEX IS_NONCUSTERDE ON CLUSTEREDCOVER(ProductID,OrderQty,SpecialOfferID)
---IS_CUSTERDE  IS SalesOrderID
CREATE NONCLUSTERED INDEX IS_NONCUSTERDE2 ON CLUSTEREDCOVER(ProductID,OrderQty,SpecialOfferID)
INCLUDE (SalesOrderDetailID)




GO


SELECT SalesOrderID,SalesOrderDetailID
,ProductID,OrderQty,SpecialOfferID

FROM CLUSTEREDCOVER WITH (INDEX(IS_NONCUSTERDE))
WHERE ProductID=789
GO


SELECT SalesOrderID,SalesOrderDetailID
,ProductID,OrderQty,SpecialOfferID
FROM CLUSTEREDCOVER WITH (INDEX(IS_NONCUSTERDE2))
WHERE ProductID=789

SELECT S.hobt_id,S.alloc_unit_type_desc,S.index_type_desc
,S.page_count,S.record_count,S.index_depth

FROM

sys.dm_db_index_physical_stats(DB_ID('TEST'),
OBJECT_ID('CLUSTEREDCOVER'),NULL,NULL,'DETAILED') S

--------ALTER INDEX

CREATE NONCLUSTERED INDEX IX_NonClustered02 
	ON CLUSTEREDCOVER(ProductID,OrderQty,SpecialOfferID)
		INCLUDE(SalesOrderDetailID) WITH (drop_existing=on)

		GO

		------------
----------Filtered Index
--اعمال شرط
--حجم اندکس کم و سرعت بالا

SELECT * INTO FILTERS FROM AdventureWorks2014.Sales.SalesOrderHeader
GO

CREATE CLUSTERED INDEX IX_Clustered  ON FILTERS(SalesOrderID)
GO

CREATE NONCLUSTERED INDEX IX_NONClustered ON FILTERS(OrderDate,CustomerID, AccountNumber)
WITH(DROP_EXISTING=ON)
GO
 DROP INDEX IX_NONClusteredFILTER ON FILTERS
 GO
CREATE NONCLUSTERED INDEX IX_NONClusteredFILTER ON FILTERS(CustomerID, AccountNumber, OrderDate)
  WHERE OrderDate>='2010-01-01' AND OrderDate <='2011-12-01'
GO
SELECT S.index_id,S.index_type_desc,S.index_depth,S.page_count,S.record_count
,S.avg_fragment_size_in_pages,S.avg_fragmentation_in_percent,S.fragment_count
FROM sys.dm_db_index_physical_stats
(DB_ID('TEST'),OBJECT_ID('FILTERS'),NULL,NULL,'DETAILED') S

GO
--PLAN
SELECT CustomerID, AccountNumber, OrderDate FROM FILTERS
WITH (INDEX (IX_NONClustered))
WHERE OrderDate BETWEEN '2011-01-01' AND '2011-12-01'
GO
SELECT CustomerID, AccountNumber, OrderDate FROM FILTERS
WITH (INDEX (IX_NONClusteredFILTER))
WHERE OrderDate BETWEEN '2011-01-01' AND '2011-12-01'

GO

-------------

CREATE TABLE Students
(
	ID INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(50),
	Family NVARCHAR(50),
	NationalCode NVARCHAR(20)
)
GO
SP_HELP Students

GO

INSERT Students(Name, Family, NationalCode) VALUES
    (N'مسعود', N'نوری', '111-111-111-111'),
    (N'فريد', N'نوری', NULL),
    (N'مجيد', N'نوری', '222-222-222-222'),
    (N'علي', N'نوری', '333-333-333-333'),
    (N'عليرضا', N'نصيري', NULL),
    (N'حامد', N'اكبر مقدم', '444-444-444-444'),
    (N'بهروز', N'اكبري', ''),
    (N'صادق', N'نوري', ''),
    (N'محمد', N'صباغي', NULL)
GO
SELECT * FROM Students

GO
--------EROR NULL AND BLUNK
CREATE UNIQUE NONCLUSTERED INDEX IX1 ON Students(NationalCode)
GO
CREATE UNIQUE NONCLUSTERED INDEX IX1 ON Students(NationalCode)
WHERE (NationalCode <> '' AND NationalCode IS NOT NULL)
GO
SELECT * FROM sys.indexes WHERE name='IX1'
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'كريم', N'صادقي' , NULL)
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'علي', N'شادي' , '')
GO
-- This Will Be Inserted
INSERT Students(Name, Family, NationalCode)
    VALUES (N'محمد', N'اصغري' , '')
GO
-- This Will Be Prevented Because of Duplicate CCNO
INSERT Students(Name, Family, NationalCode)
    VALUES (N'ناصر', N'رادمنش' , '222-222-222-222')