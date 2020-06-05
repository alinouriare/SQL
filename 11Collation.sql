IF DB_ID('Test01')>0
BEGIN
	ALTER DATABASE Test01 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Test01
END
GO
CREATE DATABASE Test01
GO
USE Test01
go
alter database Test01 collate Persian_100_CI_AI
go
select * from sys.fn_helpcollations()
where [name] like  '%PERSIAN%'
select @@ROWCOUNT
go

create table TestCollation(
id int,
c1 nvarchar(10) collate SQL_Latin1_General_CP1256_CI_AS,
c2 nvarchar(10) collate Persian_100_CI_AI
)
go
sp_help TestCollation
GO
INSERT INTO TestCollation VALUES (1,N'ا',N'ا')
INSERT INTO TestCollation VALUES (2,N'ب',N'ب')
INSERT INTO TestCollation VALUES (3,N'ت',N'ت')
INSERT INTO TestCollation VALUES (4,N'پ',N'پ')
INSERT INTO TestCollation VALUES (5,N'گ',N'گ')
INSERT INTO TestCollation VALUES (6,N'ك',N'ك')--عربي
INSERT INTO TestCollation VALUES (7,N'ک',N'ک')--فارسي
INSERT INTO TestCollation VALUES (7,N'کـ',N'کـ')--فارسي
INSERT INTO TestCollation VALUES (8,N'ي',N'ي')--عربي
INSERT INTO TestCollation VALUES (9,N'ی',N'ی')--فارسي
INSERT INTO TestCollation VALUES (10,N'چ',N'چ')
INSERT INTO TestCollation VALUES (11,N'ج',N'ج')
INSERT INTO TestCollation VALUES (12,N'خ',N'خ')
INSERT INTO TestCollation VALUES (13,N'ر',N'ر')
INSERT INTO TestCollation VALUES (14,N'ز',N'ز')
INSERT INTO TestCollation VALUES (15,N'ژ',N'ژ')
INSERT INTO TestCollation VALUES (16,N'و',N'و')
INSERT INTO TestCollation VALUES (17,N'ن',N'ن')
GO

select * from TestCollation order by c1
go
select * from TestCollation order by c2

SELECT * FROM TestCollation WHERE C1=N'ی' --Persian
SELECT * FROM TestCollation WHERE C2=N'ی' --Persian


gO
-----------------------------------
 --اسكريپتي براي يك دست سازي ي و ك در تمامي ركوردهاي تمامي جداول ديتابيس جاري  
 -- اسكريپت زير ي و ك فارسي را به عربي تبديل مي‌كند  
 -- در صورت نياز به حالت عكس ، جاي مقادير عددي يونيكد را تعويض نمائيد  

GO
--بررسی ی و ک
SELECT * FROM TestCollation
GO   
USE Test01;  
GO
DECLARE @Table NVARCHAR(MAX),  
        @Col NVARCHAR(MAX)  
   
DECLARE Table_Cursor CURSOR   
 FOR  
    --پيدا كردن تمام فيلدهاي متني تمام جداول ديتابيس جاري  
    SELECT a.name, --table  
           b.name --col  
    FROM   sysobjects a,  
           syscolumns b  
    WHERE  a.id = b.id  
           AND a.xtype = 'u' --User table  
           AND (  
                   b.xtype = 99 --ntext  
                   OR b.xtype = 35 -- text  
                   OR b.xtype = 231 --nvarchar  
                   OR b.xtype = 167 --varchar  
                   OR b.xtype = 175 --char  
                   OR b.xtype = 239 --nchar  
               )  
   
 OPEN Table_Cursor FETCH NEXT FROM  Table_Cursor INTO @Table,@Col  
 WHILE (@@FETCH_STATUS = 0)  
 BEGIN  
    EXEC (  
             'update [' + @Table + '] set [' + @Col +  
             ']= REPLACE(REPLACE(CAST([' + @Col +  
             '] as nvarchar(max)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705)) '  
         )  
     
    FETCH NEXT FROM Table_Cursor INTO @Table,@Col  
 END CLOSE Table_Cursor DEALLOCATE Table_Cursor
 
 
 --IF COLLATION = Persian_100_CI_AI THEN
 --'] as nvarchar(max)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705)) '  
 --------------
 --IF COLLATION = SQL_Latin1_General_CP1256_CI_AS THEN
 --'] as nvarchar(max)) , NCHAR(1740), NCHAR(1610)),NCHAR(1705),NCHAR(1603)) ' 
GO
--بررسی ی و ک
SELECT * FROM TestCollation

go

select sum( DATALENGTH(c1)) from TestCollation


--هاي بانك اطلاعاتي و جداول-Collationيافتن تداخل مابين 
DECLARE @DefaultDBCollation NVARCHAR(1000)  
SET @DefaultDBCollation = CAST(DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS NVARCHAR(1000))  
SELECT 
	sys.tables.name AS TableName , sys.columns.name AS ColumnName ,
	sys.columns.is_nullable , sys.columns.collation_name,@DefaultDBCollation AS DefaultDBCollation
FROM sys.columns
INNER JOIN sys.tables ON sys.columns.object_id=sys.tables.object_id
WHERE 
	sys.columns.collation_name<>@DefaultDBCollation
	AND COLUMNPROPERTY(OBJECT_ID(sys.tables.name),  sys.columns.name, 'IsComputed') = 0
GO
sp_help TestCollation

alter table TestCollation alter column c1 nvarchar(10) collate Persian_100_CI_AI