
--------------------------------------------------------------------
USE master
GO
--AdventureWorks2014 بازیابی بانک اطلاعاتی 

--بررسی جهت وجود بانک اطلاعاتی
IF DB_ID('AdventureWorks2014')>0
BEGIN
	ALTER DATABASE AdventureWorks2014 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE AdventureWorks2014
END
GO
RESTORE DATABASE AdventureWorks2014 FROM DISK=N'E:\SQLServerForDevelopers\Session04\Section03\AdventureWorks2014.bak' WITH
	MOVE 'AdventureWorks2014_Data' TO 'E:\Database\AdventureWorks2014_Data.mdf',
	MOVE 'AdventureWorks2014_Log' TO 'E:\Database\AdventureWorks2014_Log.ldf',
	STATS=1,REPLACE
GO
