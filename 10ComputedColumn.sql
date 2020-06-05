use master
go
if db_id('test')>0
begin
 alter database test set  single_user with  rollback immediate
 drop database test
 end
 go
 create database test
 go
 use test
 go
 if object_id('student')>0
  drop table student
  go

  create table student(
  id int identity(1,1),
  firstname nvarchar(100),
 lastname nvarchar(100),
 fullname as (firstname +' '+ lastname),
fathertname nvarchar(100)
  )
  go
    create table student2(
  id int identity(1,1),
  firstname nvarchar(100),
 lastname nvarchar(100),
 fullname as (firstname +' '+ lastname) persisted,
fathertname nvarchar(100)
  )

  go

  insert into student(firstname,lastname,fathertname)values('ali','nouri','esi')
  go 100

  go

    insert into student2(firstname,lastname,fathertname)values('ali','nouri','esi')
  go 100

  go

  select * from student
  go

   select * from student2
   go

   sp_spaceused student
   go
   sp_spaceused student2