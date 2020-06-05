USE tempdb
GO
IF ( Object_id('UsingTable') > 0 )
  DROP TABLE UsingTable
GO
CREATE TABLE UsingTable
  (
     RefId INT ,
     name  VARCHAR(100)
  )
GO
IF ( Object_id('TargetTable') > 0 )
  DROP TABLE TargetTable
GO
CREATE TABLE TargetTable
  (
     ChildId INT,
     val     VARCHAR(100)
  )
GO
-- Inserting records in both tables
INSERT INTO UsingTable(RefId,name)
VALUES      (1,'S-1'),
            (2,'S-2'),
            (3,'S-3'),
            (4,'S-4'),
            (5,'S-555'),
            (7,'S-7')

GO
INSERT INTO TargetTable(ChildId,val)
VALUES      (1,'S-1'),
            (2,'S-2'),
            (3,'S-3'),
            (5,'S-5'),
            (6,'S-6') 
GO
SELECT * FROM UsingTable
SELECT * FROM TargetTable

BEGIN TRANSACTION
MERGE TargetTable AS TARGET_Table
USING UsingTable AS SOURCE_Table
ON (SOURCE_Table.RefId = TARGET_Table.ChildId)
WHEN MATCHED THEN
DELETE;
GO
SELECT * FROM UsingTable
SELECT * FROM TargetTable
GO
ROLLBACK TRAN

GO

BEGIN TRAN
GO
MERGE TargetTable AS TARGET_Table
USING UsingTable AS SOURCE_Table
ON (SOURCE_Table.RefId = TARGET_Table.ChildId)
WHEN  NOT MATCHED BY SOURCE THEN--«“ ÃœÊ·  «—ê  —ﬂÊ—œÂ«Ì „‘«»Â ÃœÊ· ”Ê—” ‰Ì” ‰œ —« Õ–› „Ì ﬂ‰œ
	DELETE;
GO	
SELECT * FROM UsingTable
SELECT * FROM TargetTable
GO
ROLLBACK TRAN

GO

BEGIN TRAN
GO
MERGE TargetTable AS TARGET_Table
USING UsingTable AS SOURCE_Table
ON (SOURCE_Table.RefId = TARGET_Table.ChildId)
WHEN  NOT MATCHED BY TARGET THEN--œ— ÃœÊ·  «—ê  —ﬂÊ—œÂ«Ì ﬂÂ œ— ÃœÊ· ”Ê—” Â” ‰œ Ê œ—  «—ê  ‰Ì” ‰œ —«œ—Ã „Ì ﬂ‰œ
	INSERT (childId,val) VALUES (SOURCE_Table.RefId,SOURCE_Table.NAME) ;
GO	
SELECT * FROM UsingTable
SELECT * FROM TargetTable
GO
ROLLBACK TRAN
--------------------------------------------------------------------ALL
BEGIN TRAN
GO
MERGE TargetTable AS TARGET_Table
USING UsingTable AS SOURCE_Table
ON (SOURCE_Table.RefId = TARGET_Table.ChildId)
WHEN MATCHED AND SOURCE_Table.NAME<>TARGET_Table.VAL THEN 
	UPDATE SET TARGET_Table.VAL=SOURCE_Table.NAME 
WHEN  NOT MATCHED BY SOURCE THEN
	DELETE
WHEN  NOT MATCHED BY TARGET THEN
	INSERT (childId,val)
		 VALUES (SOURCE_Table.RefId,SOURCE_Table.NAME) ;
GO	
SELECT * FROM UsingTable
SELECT * FROM TargetTable
GO
ROLLBACK TRAN
GO