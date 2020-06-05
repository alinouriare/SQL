--FileTables
USE master
GO
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO
--ایجاد دایرکتوری محل ذخیره اطلاعات 
EXEC xp_cmdshell 'IF NOT EXIST C:\DemoFileTable MKDIR C:\DemoFileTable';
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DemoFileTable')
BEGIN
	ALTER DATABASE DemoFileTable SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DemoFileTable;
END;


CREATE DATABASE DemoFileTable
WITH FILESTREAM
(
	NON_TRANSACTED_ACCESS = FULL,
	DIRECTORY_NAME = N'DemoFileTable'
)
GO

ALTER DATABASE DemoFileTable ADD FILEGROUP DemoFileTable_FG CONTAINS FILESTREAM
GO
ALTER DATABASE DemoFileTable ADD FILE
(
    NAME= 'DemoFileTable_File',
	FILENAME = 'C:\DUMP\DemoFileTable_File'
)TO FILEGROUP DemoFileTable_FG

GO
USE DemoFileTable
/* Create a FileTable ایجاد جدول*/
CREATE TABLE DemoFileTable AS FILETABLE
WITH
( 
	FILETABLE_DIRECTORY = 'DemoFileTableFiles',
	FILETABLE_COLLATE_FILENAME = database_default
);
GO
Use DemoFileTable;
GO
SELECT * FROM DemoFileTable;

SELECT 
	file_stream.GetFileNamespacePath(),
	* 
FROM DemoFileTable;
GO
SELECT FileTableRootPath('dbo.DemoFileTable') as RootPath

GO

CREATE TABLE TestRelation(
ID INT,
Stream_ID UNIQUEIDENTIFIER,
FirstName NVARCHAR(100),
LastName NVARCHAR(100),
Comment NVARCHAR(100),
CONSTRAINT PK_ID PRIMARY KEY(ID),
CONSTRAINT FG_ID FOREIGN KEY (Stream_ID) REFERENCES DemoFileTable(stream_id)
)
go
INSERT INTO TestRelation(ID,Stream_ID,FirstName,LastName,Comment)
	VALUES (1,'F0767246-78A1-EA11-AA0A-00155DC31F50',N'مسعود',N'نوری',N'کلاس آموزشی')

	GO

	GO
SELECT * FROM TestRelation
GO
SELECT * FROM DemoFileTable;
GO
DELETE FROM DemoFileTable WHERE stream_id='F0767246-78A1-EA11-AA0A-00155DC31F50'
GO
DROP TABLE TestRelation
GO
