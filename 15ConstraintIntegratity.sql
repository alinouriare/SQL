CREATE TABLE Students(

StudentId INT,
StudemtName NVARCHAR(100),
BrithDate DATETIME,
Sex nvarchar(6) CHECK(Sex in('Male','Femaile')),
MobilePhone VARCHAR(20) CHECK (MobilePhone LIKE '0912-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Physicy REAL CHECK (Physicy BETWEEN 15 AND 20),
Math REAL CONSTRAINT Math_Check CHECK (Math BETWEEN 15 AND 20),
Enghilsh REAL CHECK (Enghilsh >=10),
[Avg] as ((Physicy+Math+Enghilsh)/3) PERSISTED 
CONSTRAINT Avg_Check CHECK([Avg] BETWEEN 15 AND 20)

)
go
sp_help Students

sp_helpconstraint  Students
go
--OR
CREATE TABLE OtherStudents
(
	StudentId INT ,
	StudentName NVARCHAR(100),
	BirthDate DATETIME ,
	Sex  NVARCHAR(6) ,
	MobilePhone VARCHAR(20),
	Physic  REAL ,
	Math    REAL ,
	English REAL ,
	[Avg]   AS ((Physic+Math+English)/3) PERSISTED 
	CHECK  (MobilePhone LIKE '0912-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CHECK (Sex in ('Male','Female')),
	CONSTRAINT Math_Check CHECK (Math BETWEEN 15 AND 20),
	CHECK (Physic BETWEEN 15 AND 20),
	CHECK (English>=10),
	CONSTRAINT Avg_Check CHECK ([AVG] BETWEEN 15 AND 20)
)
SP_HELP 'Students'
SP_HELPCONSTRAINT 'Students'
SELECT * FROM sys.check_constraints where parent_object_id=object_id('Students')
GO
INSERT INTO Students(StudentId,StudemtName,BrithDate,Sex,MobilePhone,Physicy,Math,Enghilsh) 
	VALUES (8418351,'Navid Bahrami','1985-10-12',N'Male','0912-1234267', 16.25 , 15.75 , 16)

	go
	ALTER TABLE Students ADD Art REAl Check (Art>=10)
	alter table Students add constraint check_id check (StudentId>1000)

	go
	CREATE TABLE TestTable1
(
	Fld01 INT ,
	Fld02 NVARCHAR(10) DEFAULT N'سلام'
)	
GO
--OR

GO


CREATE TABLE TestTable
(
	Code1 INT,
	Code2 INT,
	NAME NVARCHAR(10)
)
GO
INSERT INTO TestTable(Code1,Code2,NAME) VALUES (1,NULL,'ALI')
INSERT INTO TestTable(Code1,Code2,NAME) VALUES (2,3,'REZA')
INSERT INTO TestTable(Code1,Code2,NAME) VALUES (1,4,'AHMAD')
INSERT INTO TestTable(Code1,Code2,NAME) VALUES (1,0,'ALI REZA')
GO
SELECT * FROM TestTable
GO
ALTER TABLE TestTable ADD CHECK (CODE2>0)
GO
ALTER TABLE TestTable WITH NOCHECK ADD CHECK (CODE2>0) 
GO
SP_HELPCONSTRAINT 'TestTable'
SELECT * FROM sys.check_constraints



----
CREATE TABLE TestTable1
(
	Fld01 INT ,
	Fld02 NVARCHAR(10) CONSTRAINT DFlt_Fld02 DEFAULT N'سلام'
)	
GO
SP_HELPCONSTRAINT 'TestTable1'
GO
SELECT * FROM sys.default_constraints 
GO
INSERT INTO TestTable1 (Fld01,Fld02) VALUES (1,N'علی')
INSERT INTO TestTable1 (Fld01) VALUES (2)
INSERT INTO TestTable1 (Fld01) VALUES (3)
GO
SELECT * FROM TestTable1 
GO
alter table TestTable1 add default 0 for Fld01
alter table TestTable1 add constraint Che default 1 for Fld02

go
sp_helpconstraint TestTable1
go
insert into TestTable1 default values
go
select * from TestTable1

go

alter table TestTable1 add [time] datetime default getdate()
