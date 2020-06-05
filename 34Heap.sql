----heap

CREATE TABLE HEAP
(
ID INT,
FIRTNAME CHAR(3000),
LASTNAME CHAR(3000)
)
GO

SP_HELPINDEX 'HEAP'
GO

SELECT OBJECT_NAME(object_id),* FROM sys.indexes
WHERE object_id=OBJECT_ID('HEAP')
GO

SELECT OBJECT_NAME(object_id),* FROM sys.indexes
WHERE type_desc='HEAP'
GO

SELECT id,rows,FirstIAM FROM sys.sysindexes
WHERE id=OBJECT_ID('HEAP')
GO

INSERT INTO HEAP VALUES(1,'ALI','NOURI')


----heap

CREATE TABLE HEAP
(
ID INT,
FIRTNAME CHAR(3000),
LASTNAME CHAR(3000)
)
GO

SP_HELPINDEX 'HEAP'
GO

SELECT OBJECT_NAME(object_id),* FROM sys.indexes
WHERE object_id=OBJECT_ID('HEAP')
GO

SELECT OBJECT_NAME(object_id),* FROM sys.indexes
WHERE type_desc='HEAP'
GO

SELECT id,rows,FirstIAM FROM sys.sysindexes
WHERE id=OBJECT_ID('HEAP')
GO
SET STATISTICS IO ON
SELECT * FROM HEAP
GO
INSERT INTO HEAP VALUES(1,'ALI','NOURI')
INSERT INTO HEAP VALUES(1,'AA','AA')
INSERT INTO HEAP VALUES(1,'BB','BB')
INSERT INTO HEAP VALUES(1,'CC','CC')

GO

DBCC IND('DDL_TRIGGER','HEAP',1) with no_infomsgs

DBCC IND('AdventureWorks2014','Sales.SalesOrderHeader',1)

--قرار دارد Page بررسی جهت اینکه هر رکورد داخل کدام 
SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID],
	* 
FROM HEAP
GO

SELECT * FROM HEAP
CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%)  AS FPLC
order by FPLC.file_id, FPLC.page_id, FPLC.slot_id


--Page مشاهده محتوای
DBCC TRACEON(280);
DBCC PAGE('TempDB',1,725,1)WITH NO_INFOMSGS;--به خروجي انتهاي اين جدول توجه كنيد
DBCC PAGE('TempDB',1,78,3)WITH NO_INFOMSGS;

go