
CREATE DATABASE CDC
USE CDC

CREATE TABLE Students
(
	CODE INT PRIMARY KEY,
	NAME NVARCHAR(50),
	FAMILY NVARCHAR(50) 
)
GO

EXEC sys.sp_cdc_enable_db
Go
---بررسی فعتا بودن CDC
SELECT name,is_cdc_enabled FROM sys.databases
GO
--براي جدول فوق CDC فعال سازي قابليت
--ايجاد خودكار جاب و فانكشن به 
EXEC sys.sp_cdc_enable_table
    @Source_Schema = N'dbo',
    @Source_Name   = N'Students',
    @Role_Name     = null,
    @Supports_Net_Changes = 1
GO

--گيريCaptureاستخراج پروسه هاي مربوط به 
--به ستون هايي كه قرار است تغييرات آن ذخيره شود دقت كنيد
EXEC SYS.sp_cdc_help_change_data_capture
GO
------------------------------ساعت 9

INSERT INTO Students VALUES 
	(100,'Ali','Ahmadi'),
	(101,'Masud','Taheri'),
	(102,'Saman','Farzam')

GO
--استخراج سابقه تغييرات
-- Please note that __$operation column indicates 1 for delete, 2 for insert,
-- 3(old Values) & 4(New Values) for update
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Students
    (sys.fn_cdc_get_min_lsn('dbo_Students'), sys.fn_cdc_get_max_lsn(), N'all update old' )
GO

------------------------------ساعت 10
DELETE FROM Students WHERE CODE=100
GO
--استخراج سابقه تغييرات
-- Please note that __$operation column indicates 1 for delete, 2 for insert,
-- 3(old Values) & 4(New Values) for update
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Students
    (sys.fn_cdc_get_min_lsn('dbo_Students'), sys.fn_cdc_get_max_lsn(), N'all update old' )
GO
------------------------------ساعت 11
UPDATE Students SET NAME='Ali',FAMILY='Farzam Tehrani' WHERE CODE=102
GO
--استخراج سابقه تغييرات
-- Please note that __$operation column indicates 1 for delete, 2 for insert,
-- 3(old Values) & 4(New Values) for update
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Students
    (sys.fn_cdc_get_min_lsn('dbo_Students'), sys.fn_cdc_get_max_lsn(), N'all update old' )
GO
---SYSTEM TABLE ADD
GO
/*
--CDC (Syetem Tables) بررسی جداول سیستمی 
cdc.CapturedColumn = لیستی از فیلدهای ضبط شده
cdc.ChangeTable =به ازای آنها فعال است CDC جداولی که 
cdc.ddl_History = CDC های تغییر یافته از زمان فعال شدن DDLتاریخچه ای از همه 
cdc.Index_Columns = CDC ایندکس های به کار رفته در جداول
cdc.lsn_time_mapping = شده است Commit شده با زمانی که تراکنش  Commit های LSN مپینگ بین 
*/
SELECT * FROM Students
GO
--- __$operation 2 insert 3,4 update 1 delete
UPDATE Students SET NAME='Ali',FAMILY='Farzam Nouri' WHERE CODE=102
go
 SELECT p.tran_begin_time,i.* FROM [cdc].[fn_cdc_get_all_changes_dbo_Students] 
(sys.fn_cdc_get_min_lsn('dbo_Students'),sys.fn_cdc_get_max_lsn(),'all update old') i
join [cdc].[lsn_time_mapping] p
on i.__$start_lsn=p.start_lsn
WHERE CODE=102 and i.__$operation=3

go

 SELECT max (p.tran_begin_time) over (order by p.tran_begin_time ),i.NAME FROM [cdc].[fn_cdc_get_all_changes_dbo_Students] 
(sys.fn_cdc_get_min_lsn('dbo_Students'),sys.fn_cdc_get_max_lsn(),'all update old') i
join [cdc].[lsn_time_mapping] p
on i.__$start_lsn=p.start_lsn
WHERE CODE=102 and i.__$operation=3
--بدست آوردن سوابق تغييرات داده ها بر حسب زمان
SELECT GETDATE();
DECLARE @begin_time DATETIME
DECLARE @end_time   DATETIME
DECLARE @begin_lsn	BINARY(10)
DECLARE @end_lsn	BINARY(10)

SET @begin_time = '2010-10-21 08:57:00'
SET @end_time = '2010-10-21 10:30:00' 

SELECT @begin_lsn = sys.fn_cdc_map_time_to_lsn('smallest greater than', @begin_time); 
SELECT @end_lsn = sys.fn_cdc_map_time_to_lsn('largest less than or equal', @end_time); 

SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Students(@begin_lsn, @end_lsn, N'all'); 
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Students(@begin_lsn, @end_lsn, N'all update old'); 
-----------------------------------------------------------------------
--براي جدول  CDC غير فعال كردن قابليت
EXECUTE sys.sp_cdc_disable_table 
    @source_schema = N'dbo', 
    @source_name = N'Students',
    @capture_instance = N'dbo_Students';
GO
--------------------------------
--CDCغير فعال كردن قابليت
--هاJobحذف كليه  
EXEC sys.sp_cdc_disable_db




SELECT 
case 
when i.__$operation=2 then 'Insert'
when i.__$operation=1 then 'Delete'
when i.__$operation=3 then 'Update Old'
when i.__$operation=4 then 'Update New'
end as [Action],t.tran_begin_time as [Time],
CONCAT('Code:',i.CODE,'-','Name:',i.NAME,'-','Family:',i.FAMILY) as [Context],
cast( i.__$update_mask as int)---هر فیلد یک عدد توانی مگیره 2 به توان صفر 2 به توان 1
FROM [cdc].[fn_cdc_get_all_changes_dbo_Students]
(sys.fn_cdc_get_min_lsn('dbo_Students'),sys.fn_cdc_get_max_lsn(),'all update old') i
join cdc.lsn_time_mapping t
on i.__$start_lsn=t.start_lsn

----7 1+2+4 همه تغییر کردن
