select * from sys.types

go

declare @x int
select @x
select DATALENGTH(@x)

go

declare @x int =1
select @x
select DATALENGTH(@x)

go

declare @x int
select @x=1 --set @x=1
select DATALENGTH(@x)

go


declare @x bit='TRUE'
select @x
select DATALENGTH(@x)

go

declare @x decimal(8,2)=15289.555
select @x
select DATALENGTH(@x)
go

declare @x smallmoney=258
select @x
select DATALENGTH(@x)
go

declare @x money=258
select @x
select DATALENGTH(@x)
go

declare @c char(4)='ali'
select @c 
select DATALENGTH(@c)
go

declare @c varchar(4)='ali'
select @c 
select DATALENGTH(@c)
go

declare @c nvarchar(4)='ali'
select @c 
select DATALENGTH(@c)
go

declare @c varchar(max)='ali*nouri*arejan'
select @c 
select DATALENGTH(@c)

go

declare @c text='ali*nouri*arejan'
select @c 
select DATALENGTH(@c)

go

declare @c nchar(4)='ali' 
select @c 
select DATALENGTH(@c)
go

declare @c nvarchar(5)=N'علی'
select @c 
select DATALENGTH(@c)

go

create table tb1(
id int identity,
name char(1000),
family char(2000)
)
go

insert into tb1 values(null,null)
go 1000

sp_spaceused tb1

declare @c smalldatetime='2015-01-01 12:20:30'
select @c
select DATALENGTH(@c)

go

declare @c datetime='2015-01-01 12:20:30'
select @c
select DATALENGTH(@c)

go

declare @c date='2015-01-01'
select @c
select DATALENGTH(@c)
go
declare @c time(4)='12:20:30'
select @c
select DATALENGTH(@c)

go

declare @c uniqueidentifier=newid()
select @c
select DATALENGTH(@c)

go

declare @c timespan