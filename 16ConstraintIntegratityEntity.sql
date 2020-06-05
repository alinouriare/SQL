Create table Student(
Id int,
Name nvarchar(30),
Family nvarchar(30),
Constraint PK primary key (Id)
)
go
sp_helpconstraint Student
sp_help Student
select * from sys.key_constraints
select OBJECT_NAME(c.parent_object_id),* from sys.key_constraints c
go

create table Products(
CompanyId int,
ProductId int,
Price decimal,
constraint PK_Product primary key (ProductId,CompanyId)

)

sp_helpconstraint Products

alter table Products drop constraint PK_Product

alter table Products add constraint PK_Product primary key (CompanyId,ProductId)

insert into Products values(1,100,200)
insert into Products values(1,200,200)
insert into Products values(2,100,200)
insert into Products values(1,100,200)

create table tset(
c1 int,
c2 int,
price money
)
go
--not null

alter table tset add  primary key (c1,c2)
go
alter table tset add c3 int not null constraint pk_p primary key(c3)
go
sp_helpconstraint tset
go

create table Prg(
Id int primary key,
Snn int unique,
name nvarchar(30)
)
go

alter table Prg add cod int constraint un_p unique 

go

sp_helpconstraint Prg
go
sp_helpindex Prg

GO