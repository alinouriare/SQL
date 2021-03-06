CREATE DATABASE IsolationLevelTest
GO
CREATE TABLE TestTable
(
ID int IDENTITY,
Field1 INT NULL,
Field2 INT NULL,
Field3 INT NULL
)
GO
INSERT INTO TestTable (Field1,Field2,Field3) VALUES (1,2,3)
INSERT INTO TestTable (Field1,Field2,Field3) VALUES (1,2,3)
INSERT INTO TestTable (Field1,Field2,Field3) VALUES (1,2,3)
INSERT INTO TestTable (Field1,Field2,Field3) VALUES (1,2,3)

GO

BEGIN TRAN
UPDATE TestTable SET Field1 = 20
WAITFOR DELAY '00:00:20'
ROLLBACK

GO
-------------NEW QUERY 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT * FROM TestTable




SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT * FROM TestTable
WAITFOR DELAY '00:00:10'
SELECT * FROM TestTable
ROLLBACK


----------NEW QUERY
UPDATE TestTable SET Field1 = 7