CREATE DATABASE DEMOBulkInsert
GO
CREATE TABLE Students(
SudentId nvarchar(50) primary key,
FirstName nvarchar(100),
LastName nvarchar(100),
City nvarchar(100)
)
GO
use DEMOBulkInsert
--import c
SELECT * FROM fn_helpcollations() WHERE name LIKE '%1256%'
GO
--import ssis and import csv
bulk insert dbo.students
from 'c:\dump\Students.txt'
with(
keepidentity,
firstrow=1,
fieldterminator=',',
rowterminator='\n'


)go
sp_spaceused Students
go
select * from Students
go
truncate table Students
go
GO
SELECT 
	Test.* 
FROM OPENROWSET( BULK  'C:\Dump\Students.txt',SINGLE_CLOB) AS Test
GO
/*
--نحوه ایجاد فرمت فایل
--bcp BulkDemo.dbo.Students format nul -SMASUD_TAHERI\SQLSERVER2014 -T -F1 -c -t -r -x -f C:\Dump\Students.Xml
*/
SP_HELP Students
GO
INSERT INTO Students WITH (KEEPIDENTITY)(StudentID,FirstName,LastName,City)
    SELECT *
      FROM  OPENROWSET(BULK   'C:\Dump\Students.txt',
      FORMATFILE= 'C:\Dump\Students.Xml'     
      ) as Test ;
GO
--بررسی حجم جدول
SP_SPACEUSED Students
GO
--نمایش رکوردهای درج شده در جدول
SELECT * FROM Students