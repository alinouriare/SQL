if db_id('TestDB')>0
   drop database TestDB
   go
create database TestDB on(
name='TestDB1',filename='c:\dump\TestDB1.mdf'
,size=10mb,maxsize=unlimited,filegrowth=10%
),
(
name='TestDB2',filename='c:\dump\TestDB2.ndf'
,size=10mb,maxsize=unlimited,filegrowth=10%
)log on(

name='TestDBlog',filename='c:\dump\TestDB2.ldf'
,size=100mb,maxsize=1gb,filegrowth=1gb
)
go
use TestDB
go
create table TestTable(
id int identity ,
name char(4000),
family char(4000)
)

go
insert  TestTable(name,family)values('ali','nouri')
go 10000

go

sp_helpfile

sp_spaceused TestTable

select * from sys.fn_dblog(null,null)


DBCC SQLPERF(LOGSPACE)
go
DBCC SHRINKFILE (TestDB2, EMPTYFILE);  

alter database TestDB remove file TestDB2

alter database TestDB set single_user with rollback immediate

go
use master
go

alter database  TestDB set offline 
