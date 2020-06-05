create database Test01
go
use Test01
go
sp_helpfile
sp_helpdb

select *from sys.databases
go
select * from sys.database_files

go


create database Test02 on
(
name=Test02,
filename='c:\dump\test02.mdf',
size=100mb,maxsize=unlimited,filegrowth=10%
)
log on(
name=Test02log,
filename='c:\dump\test02.ldf',
size=500mb,maxsize=1gb,filegrowth=1024mb
)

go

use Test02
go
sp_helpfile
go

create table test_table(
id int identity,
firstname char(4000),
lastname char(3700)
)
go
insert into test_table (firstname,lastname)
values('ali','nouri')
go 15000

go

create database Test03
on (
name=datafile01,filename='c:\01dump\datafile01.mdf',
size=10mb,maxsize=100mb,filegrowth=10%
),
(

name=datafile02,filename='c:\01dump\datafile02.ndf',
size=20mb,maxsize=200mb,filegrowth=10%
),
(
name=datafile03,filename='c:\01dump\datafile03.ndf',
size=30mb,maxsize=300mb,filegrowth=10%
)
log on
(
name=logfile1,filename='c:\01dump\logfile1.ldf',
size=100mb,maxsize=5gb,filegrowth=1024mb
),
(

name=logfile2,filename='c:\01dump\logfile2.ldf',
size=200mb,maxsize=5gb,filegrowth=1024mb
)
go
use Test03
go
sp_helpfile
go

alter database Test03 set single_user with rollback immediate
go
ALTER DATABASE Test02 SET SINGLE_USER WITH ROLLBACK AFTER 5 
go

drop database if exists Test03


CREATE DATABASE AA ON(
NAME='AA',FILENAME='C:\AA.MDF'
)

