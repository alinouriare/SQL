use master
go
if db_id('tset')>0
 begin 
 alter database test set single_user with rollback immediate 
 drop database test
 end

 go
 create database test on(
 name=datafile1,filename='c:\dump\datafile1.mdf',
 size=100mb,maxsize=unlimited,filegrowth=10%
 ) log on(
 name=testlog,filename='c:\dump\test.log',
 size=200mb,maxsize=unlimited,filegrowth=1024mb
 
 
 )
 use test
 go
 sp_helpfile
 go
 sp_helpfilegroup
 go
 select * from sys.filegroups
 go

 alter database test add filegroup FG1

 go

 go
 alter database test add file(
 
 name=datafile2,filename='c:\dump\datafile2.ndf'
 )to filegroup FG1
 go
 alter database test add file (
name=datafile3,filename='c:\dump\datafile3.ndf'
)to filegroup FG1
 go
 sp_helpfile
 go
alter database test add filegroup FG2
 
go

alter database test add file (
name=datafile4,filename='c:\dump\datafile4.ndf'
)to filegroup FG2

go
create table Customer2(
CustomerId int identity,
FirstName char(4000),
LastName Char(3000)
)on FG2

go
sp_help Customer
go



alter database test modify filegroup [PRIMARY] Default

go
use test
go
alter database test set single_user with rollback immediate
go
alter database test modify filegroup FG2 readwrite
go
alter database test modify filegroup FG2 read_only
go
alter database test set multi_user
go

go
insert into Customer(FirstName,LastName)values('a','b')
go
CREATE DATABASE Test01
	ON 
	PRIMARY
	(
		NAME=DataFile1,FILENAME='C:\Dump\DataFile1.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	),
	FILEGROUP FG1
	(
		NAME=DataFile2,FILENAME='C:\Dump\DataFile2.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	),
	(
		NAME=DataFile3,FILENAME='C:\Dump\DataFile3.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	),
	FILEGROUP FG2
	(
		NAME=DataFile4,FILENAME='C:\Dump\DataFile4.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%		
	)
	LOG ON
	(
		NAME=LogFile1,FILENAME='C:\Dump\LogFile1.LDF',
		SIZE=200MB,MAXSIZE=5GB,FILEGROWTH=1024MB
	)
GO
-----------BestPrcatices

--حذف بانک اطلاعاتی
IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
CREATE DATABASE Test01
	ON PRIMARY
	(
		NAME=Test01_Primary,FILENAME='C:\Dump\Test01_Primary.mdf',
		SIZE=100MB,MAXSIZE=UNLIMITED,FILEGROWTH=10%
	)
	LOG ON
	(
		NAME=LogFile1,FILENAME='C:\Dump\LogFile1.LDF',
		SIZE=200MB,MAXSIZE=5GB,FILEGROWTH=1024MB
	)
GO
--ایجاد فایل گروه های مربوط به بانک اطلاعاتی
ALTER DATABASE Test01 ADD FILEGROUP Data_FG
ALTER DATABASE Test01 ADD FILEGROUP Index_FG 
ALTER DATABASE Test01 ADD FILEGROUP BLOB_FG 
GO
--ایجاد دیتا فایل های مربوط به هر فایل گروه
ALTER DATABASE Test01 ADD FILE
	(
		NAME=Test01_Data,FILENAME='C:\Dump\Test01_Data.ndf'
	) TO FILEGROUP Data_FG
 GO
ALTER DATABASE Test01 ADD FILE
	(
		NAME=Test01_Index,FILENAME='C:\Dump\Test01_Index.ndf'
	) TO FILEGROUP Index_FG
GO
ALTER DATABASE Test01 ADD FILE
	(
		NAME=Test01_BLOB,FILENAME='C:\Dump\Test01_BLOB.ndf'
	) TO FILEGROUP BLOB_FG
 GO
 use Test01
 go
--مشاهده لیست فایل های بانک اطلاعاتی
SP_HELPFILE
GO
--مشاهده لیست فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM sys.filegroups
GO
--تعیین فایل گروه پیش فرض
ALTER DATABASE Test01 MODIFY FILEGROUP Data_FG DEFAULT
GO
