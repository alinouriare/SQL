CREATE TABLE STUDENT(
CODE INT,
[NAME] NVARCHAR(50),
FAMILY NVARCHAR(50)

)

GO

INSERT INTO STUDENT(CODE,[NAME])
OUTPUT inserted.*
VALUES(1,'ALI')
GO
INSERT INTO STUDENT
OUTPUT inserted.*
VALUES(2,'OMID','KHLEGHI')

GO


UPDATE STUDENT

SET FAMILY='NOURI'
OUTPUT deleted.CODE AS OLD_CO,deleted.[NAME] AS OLD_NAME,
deleted.FAMILY AS OLD_FAMILY
,inserted.FAMILY AS NEW_FAMILY,inserted.CODE AS NEW_COD
WHERE CODE=1
GO

DELETE FROM STUDENT
OUTPUT deleted.*
WHERE CODE=2

GO

CREATE TRIGGER trg_TRIGGER ON STUDENT
AFTER INSERT
as
SELECT * FROM inserted
go

sp_helptrigger 'STUDENT'

select * from sys.triggers

SELECT * FROM sys.trigger_events
GO
SP_HELPTEXT 'trg_TRIGGER'

GO

INSERT INTO STUDENT VALUES (2,'REZA','AKBERI')
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name='trg_TRIGGER')
DROP TRIGGER trg_TRIGGER
GO

CREATE TRIGGER trg_TRIGGER ON STUDENT
AFTER UPDATE, INSERT,DELETE
AS
ROLLBACK TRANSACTION
GO

SELECT * FROM STUDENT

GO

INSERT INTO STUDENT VALUES(3,'ESI','NOURI')
GO
UPDATE STUDENT SET NAME='AA'
WHERE CODE=2

GO
DROP TABLE STUDENT
GO
CREATE TABLE Students(
Code INT PRIMARY KEY ,
[Name] NVARCHAR(50),
Family NVARCHAR(50)

)
go

CREATE TABLE History_Studens(
ID INT IDENTITY,
Code INT,
[NAME] NVARCHAR(50),
FAMILY NVARCHAR(50),
ActionType nvarchar(50),
ActionDate datetime,
primary key nonclustered(ID)

)
go

CREATE CLUSTERED INDEX IX_Clustred on History_Studens(Code,ActionDate)

sp_helpindex 'History_Studens'
go

CREATE TRIGGER trg_Students_Insert ON Students
AFTER INSERT
AS
INSERT INTO History_Studens(Code,
[NAME],
FAMILY ,
ActionType,
ActionDate) SELECT Code,[Name],Family,'Insert',getdate() FROM inserted

go


CREATE TRIGGER trg_Student_Update on Students
AFTER UPDATE
AS

INSERT INTO History_Studens(Code,
[NAME],
FAMILY ,
ActionType,
ActionDate)SELECT Code,[NAME],Family,'Update_OLD_Value',getdate() FROM deleted

INSERT INTO History_Studens(Code,
[NAME],
FAMILY ,
ActionType,
ActionDate)SELECT Code,[NAME],Family,'Update_new_Value',getdate() FROM inserted

go


CREATE TRIGGER trg_Student_Delete on Students
AFTER delete
AS

INSERT INTO History_Studens(Code,
[NAME],
FAMILY ,
ActionType,
ActionDate)SELECT Code,[NAME],Family,'Delete',getdate() FROM deleted
go

insert into Students values(100,'Ali','Nouri')
insert into Students values(101,'reza','khalehgi')
insert into Students values(102,'aa','aa')
insert into Students values(103,'omide','akbari')
go
select * from Students
go
select * from History_Studens
go

update Students
set Family='sss'
where Code=102
go

delete from Students
where Code=102
go
SELECT session_id,host_name,program_name,context_info
FROM sys.dm_exec_sessions
WHERE session_id >=51
GO

DECLARE @CTX varbinary(128)
select @CTX=convert(varbinary(128),'ali nouri')
set context_info @CTX
go

select CONTEXT_INFO()
go
select cast(CONTEXT_INFO() as varchar(200))

---
--Session Context روش جدید برای تنظیم 
GO
DECLARE @ID INT = 123456
DECLARE @FullName NVARCHAR(100)=N'علی نوری'
EXEC sys.sp_set_session_context @key = N'ID', @value = @ID
EXEC sys.sp_set_session_context @key = N'FullName', @value = @FullName
GO
SELECT SESSION_CONTEXT(N'ID'),SESSION_CONTEXT(N'FullName')
GO
use Northwind

select * into customer2 from Customers
go

create trigger trg_customer2 on customer2
after delete
as 
declare @cid nchar(5)

select @cid=CustomerID from deleted

if (select COUNT(OrderID) from Orders where CustomerID=@cid)>=4
 begin 
 print 'this cutomer cannot delete'
 rollback transaction
 end

 go


go
select count(OrderID) from Orders where CustomerID='AROUT'
go
select CustomerID, count(OrderID) from Orders
group by CustomerID
having count(OrderID)>2
go

delete from customer2
where CustomerID='BERGS'

go

create trigger up on customer2
after update
as 
if update(city)
begin
print 'no city update'
rollback transaction
end


update customer2
set City='aa'
where CustomerID='BERGS'

go
CREATE TABLE Sudent_valid(
Id int ,
[Name] nvarchar(50),
Family nvarchar(50)
)

go

CREATE TABLE Sudent_Invalid(
Id int ,
[Name] nvarchar(50),
Family nvarchar(50)
)

go
create trigger Sudent_vlid on Sudent_valid
instead of insert
as
declare @name nvarchar(1)
select @name=LEFT([Name],1) from inserted
if	(@name='A')
insert into Sudent_valid select * from inserted
else
insert into Sudent_Invalid select * from inserted

go


insert into Sudent_valid values(1,'ALi','NOuri')
insert into Sudent_valid values(1,'Reza','NOuri')

go

select * from Sudent_Invalid

select * from Sudent_valid

go

