dbcc memorystatus
go

if db_id('test_db')>0
 drop database test_db
 go
 create database test_db
 go
 use test_db
 go
 sp_helpfile

 go

if OBJECT_ID('test_table')>0
 drop table test_table

 go

 create table test_table
 (
 FirstName char(1000),
  LastName char(1000),
  Email char(1000),
 )
 go

 insert into test_table
 values('ali','nouri','yahoo')
 go 1000

 go

 select * from test_table

 go
 sp_spaceused test_table
 go
 ;WITH src AS
(
	SELECT
		database_id, db_buffer_pages = COUNT_BIG(*)
		FROM sys.dm_os_buffer_descriptors
		GROUP BY database_id
)
SELECT
	[db_name] = CASE [database_id] WHEN 32767
		THEN 'Resource DB'
		ELSE DB_NAME([database_id]) END,
	db_buffer_pages,
	db_buffer_MB = CAST(db_buffer_pages / 128.0 AS DECIMAL(6,2))
FROM src
ORDER BY db_buffer_MB DESC;
GO

go
update [dbo].[test_table] set FirstName='alii'
go
checkpoint

SELECT *
	FROM sys.dm_os_performance_counters
	WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
	AND counter_name LIKE '%Checkpoint pages/sec%'
GO

