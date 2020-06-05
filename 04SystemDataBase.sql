use master
go
sp_helpfile
go
select * from sysdatabases
select * from syscacheobjects
select * from sysconfigures
select * from syslanguages
select * from syslogins
select * from sysmessages

go

use msdb
go
sp_helpfile
go
select * from sysjobs
select * from sysjobhistory
go
select * from backupset 
select * from backupfile
select * from restorehistory

go

use tempdb
go

sp_helpfile

--model بررسی بانک اطلاعاتی
USE model
GO
SP_HELPFILE
GO
CREATE TABLE Students
(
	Code INT PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50)
)
GO
INSERT INTO Students VALUES
	(1,N'علی',N'نوری'),
	(2,N'اسمعیل',N'نوری'),
	(3,N'مجید',N'نوری'),
	(4,N'علی',N'نوری'),
	(5,N'علیرضا',N'نوری')
GO
SELECT * FROM Students
GO
------------------------------
--ایجاد بانک اطلاعاتی جدید
USE master
GO
CREATE DATABASE TestDB
GO
USE TESTDB
GO
SP_HELPFILE
GO
SELECT * FROM Students
--------------------------------------------------------------------
--Resource بررسی بانک اطلاعاتی
USE master
GO
--To determine the version number of the Resource database, use
SELECT SERVERPROPERTY('ResourceVersion');
--To determine when the Resource database was last updated, use:
SELECT SERVERPROPERTY('ResourceLastUpdateDateTime');
GO
--سورس ویو و.... سیستمی داخل این پروسیجر قرار دارد
SELECT OBJECT_DEFINITION(OBJECT_ID('sys.objects')) AS [SQL Definitions];
GO
--D:\Program Files\Microsoft SQL Server\MSSQL12.SQLSERVER2014\MSSQL\Binn\mssqlsystemresource.mdf