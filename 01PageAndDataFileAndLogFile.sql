use master
go
if DB_ID('PageAnatomy')>0
  drop database PageAnatomy
go

create database PageAnatomy
go

use PageAnatomy

go
 sp_helpfile

 select * from sys.database_files

 if OBJECT_ID('Test_Table')>0
    drop table Test_Table
	go

	create table Test_Table(
	FirstName char(200),
	LastName char(300),
	Email char(200)
	
	)
	go

	insert into Test_Table(FirstName,LastName,Email)
	values
	('Masoud','Taheri','TestMail@yahoo.com'),
	('Farid','Taheri','Test1@yahoo.com'),
	('Majid','Taheri','Test2@yahoo.com'),
	('Ali','Taheri','Test3@yahoo.com'),
	('AliReza','Taheri','Test4@yahoo.com'),
	('Khadijeh','Afrooz','Test5@yahoo.com')	

	go

	sp_helpindex Test_Table

	select * from sys.indexes
	where OBJECT_ID= OBJECT_ID('Test_Table')

	go


	select OBJECT_NAME(object_id),* from sys.indexes
	where type_desc='HEAP'

	go

	sp_spaceused Test_Table
	go

	select * from Test_Table

	go

	dbcc ind('PageAnatomy','Test_Table',-1) with no_infomsgs;

	go
	select sys.fn_PhysLocFormatter(%%physloc%%) as [Physical RID],
	* from Test_Table;
	go
	dbcc traceon(3604)

	dbcc page('PageAnatomy',1,264,1)with no_infomsgs
	go

	use master

	if DB_ID('Test01')>0
	 drop database Test01
	 go
	 create database Test01
	 go
	 use Test01

	go

	sp_helpfile

	go
	dbcc loginfo
	go
	select * from sys.fn_dblog(null,null)
	go

	alter database Test01 set recovery simple
	go
	checkpoint
	go
		select * from sys.fn_dblog(null,null)
go

create table VLF_Test(
C1 int,
C2 nvarchar(100),
C3 nvarchar(100)
)
go
insert into VLF_Test(C1,c2,c3)
values(2,'ali','nouri')
go

	select database_id,recovery_model,name from sys.databases
	go


	begin transaction
	update [dbo].[VLF_Test]
	set C2='aa',C3='bb'
	where c1=1
	rollback transaction

		
