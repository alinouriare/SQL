use master
go
if db_id('test')>0
begin
alter database test set single_user with rollback immediate
drop database test
end
go


create database test on primary(

name=test_primary,filename='c:\dump\test_primary.mdf',
size=100mb,maxsize=unlimited,filegrowth=10%
)log on(

name=logfile,filename='c:\dump\logefile.ldf',
size=200mb,maxsize=5gb,filegrowth=1024mb
)
go

alter database test add filegroup Data_FG
alter database test add filegroup Blob_FG
alter database test add filegroup Index_FG

go

alter database test add file (
name=test_data,filename='c:\dump\test_data.ndf'
)to filegroup Data_FG
go

alter database test add file (
name=test_Index,filename='c:\dump\test_Index.ndf'

)to filegroup Index_FG
go

alter database test add file (
name=test_blob,filename='c:\dump\test_blob.ndf'

)to filegroup Index_FG
go
use test
go


sp_helpfile
go

sp_helpfilegroup
go

select * from sys.filegroups
go
alter database test modify  filegroup  Data_FG default
go

create table Student(
StudentId int identity(1,1) ,
Cod int sparse,--50% null fixedlength
FirstName nvarchar(100) Collate Persian_100_CI_AI,
LastName nvarchar(100) Collate Persian_100_CI_AI,
FullName as(FirstName +' '+LastName )
)on  Data_FG
go
sp_help Student
go

 alter table Student add StudentAddress nvarchar(800) collate  Persian_100_CI_AI not null 
 go
 alter table Student  drop column   StudentAddress
 go

 alter index  all on Student rebuild
go
go
alter table Student drop column  FullName 
go
alter table Student alter column LastName nvarchar(200) collate Persian_100_CI_AI
go
alter table Student add FullName  as (FirstName + ' ' +Family )  
go
sp_help Student01
go

exec sp_rename 'Student.LastName','Family','Column'
go
exec sp_rename 'Student','Student01'
go

drop table Student01