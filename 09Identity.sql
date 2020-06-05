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
fathertname nvarchar(100)
  )

  go

  insert into student(firstname,lastname,fathertname)values('ali','nouri','esi')
  go

    insert into student(firstname,lastname,fathertname)values('test','test','test')
	select SCOPE_IDENTITY()
	select @@IDENTITY
	go

	select IDENT_CURRENT('student')

	go

	dbcc checkident (student,reseed,300)
	go

	 insert into student(firstname,lastname,fathertname)values('test','test','test')
	select SCOPE_IDENTITY()
	select @@IDENTITY