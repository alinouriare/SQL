 ---Config SQL Server 2019 Configuration Manager
 ----config instance
 sp_configure 'show advanced options'
 go
 sp_configure 'filestream access level'
 reconfigure
 go

 CREATE DATABASE Test01 ON PRIMARY(
 NAME=Test01,FILENAME='C:\dump\Test01.mdf'
 
 ),FILEGROUP FG_FileStream CONTAINS FILESTREAM
 (
 NAME=Test01_FSG,FILENAME='C:\dump\Test01_FSG'
 
 )LOG ON
 (
  NAME=Test01_lOG,FILENAME='C:\dump\Test01_lOG.ldf'
 )
 go
 use Test01
 go
 sp_helpfile 
 go
 select * from sys.database_files
 go
 sp_helpfilegroup
 go
 select * from sys.filegroups
 go

 ---add file goup exists database

 CREATE DATABASE Test02 ON PRIMARY 
 (
 NAME =Test02,FILENAME='C:\dump\Test02.mdf'
 )log on
 (
  NAME =Test02_log,FILENAME='C:\dump\Test02_log.ldf'
 )
 go

 ALTER DATABASE Test02 ADD FILEGROUP FG_FileGroup CONTAINS FILESTREAM 
 GO
 ALTER DATABASE Test02 ADD FILE
 (
 NAME=Test02_FSG,FILENAME='C:\dump\Test02_FSG'
 )TO FILEGROUP FG_FileGroup

 go
 SP_HELPFILE
 GO
 SP_HELPFILEGROUP 

 GO

 ----------CREATE TABLE

 CREATE TABLE TestTbale
 (
 ID INT PRIMARY KEY IDENTITY,
 FileID UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWID()) ,
 Title NVARCHAR(255) NOT NULL ,
 Pic VARBINARY(MAX) FILESTREAM NULL 
 
 )ON [PRIMARY] FILESTREAM_ON FG_FileStream
 GO
 SP_HELP 'TestTbale'

 SP_HELPINDEX 'TestTbale'

 GO 
 --------ADD FILE STREAM EXISTS TABLE
 USE Test02
 GO

 CREATE TABLE TestTable2
 (
 ID INT PRIMARY KEY IDENTITY,
 FULLNAME NVARCHAR(255) NULL
 )
 GO

 ALTER TABLE TestTable2 SET (FILESTREAM_ON=FG_FileGroup)

 GO
 -------2FILED GUID AND VARBINARY BOTH ADD
 ALTER TABLE TestTable2 ADD
 FileId UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWID()),
 --Title NVARCHAR(255) NULL,
 Pic VARBINARY(MAX) FILESTREAM NULL

 GO



 INSERT INTO [dbo].[TestTbale](Title,PIC) 
 VALUES('ALINOURI',CAST(REPLICATE( 'ALINOURI*',10) AS varbinary(MAX)))

 GO

 SELECT *,pic.PathName() FROM [dbo].[TestTbale]

  SELECT *,CAST (PIC AS varchar(MAX)) AS A  FROM [dbo].[TestTbale]
  GO
INSERT INTO [dbo].[TestTbale](Title,PIC)
 SELECT 'PEROFRMANCE',BulkColumn from
openrowset(bulk 'c:\dump\1.jpg',single_blob) as tmp


 SELECT *,pic.PathName() FROM [dbo].[TestTbale]

  SELECT *,CAST (PIC AS varchar(MAX)) AS A  FROM [dbo].[TestTbale]

 