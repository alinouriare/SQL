CREATE DATABASE TEST
GO
USE TEST
GO

CREATE TABLE Customers(
CustomerId INT NOT NULL,
CustomerName char(100) not null,
CustomerAddress char(100) not null,
Comment char(180) not null,
value int not null

)
go

alter table Customers add constraint pk_Key primary key (CustomerId)

create unique nonclustered index ix_non  on Customers(value)


go

declare @cntr int=1
while (@cntr <=8000)
begin 
insert into Customers values(
@cntr,
'CustomerName'+CAST(@cntr as char),
'CustomerAddress'+CAST(@cntr as char),
'Comment'+CAST(@cntr as char),
@cntr
)
set @cntr+=1
end

sp_spaceused 'Customers'
go

create procedure usp_GetAllCustomers
as
begin

select CustomerId,CustomerName,CustomerAddress,Comment from Customers 
end
go

sp_helptext 'usp_GetAllCustomers' 

go

select * from sys.syscomments
go
select OBJECT_DEFINITION(OBJECT_ID('usp_GetAllCustomers'))

go

exec usp_GetAllCustomers

usp_GetAllCustomers

go
alter procedure usp_GetAllCustomers
as begin
select top 100 CustomerId,CustomerName,CustomerAddress,Comment,value from Customers 
end


declare @test table(

CustomerId INT NOT NULL,
CustomerName char(100) not null,
CustomerAddress char(100) not null,
Comment char(180) not null,
value int not null
)



insert into @test exec usp_GetAllCustomers

go

CREATE PROCEDURE usp_getbyid( @customerid int)
as begin
select CustomerId,CustomerName,CustomerAddress,CustomerAddress from Customers
where CustomerId=@customerid
end

usp_getbyid '10'
 

 exec  usp_getbyid @customerid=20
go

CREATE PROCEDURE usp_insert(@Customerid int,@CustomerName char(100),
@CustomerAddress char(100),@Comment char(180),@value int
)
as
begin
insert into Customers values(@Customerid,@CustomerName,@CustomerAddress,@Comment
,@value)
end

usp_insert '8000001','ali','ttt','rrr',8000001
go

usp_insert @Customerid='8000002',@CustomerName='ali',@CustomerAddress='ttt',@Comment='rrr',@value=8000002
go

usp_getbyid '8000002'

select * from sys.syscomments
go
select OBJECT_NAME(id),* from sys.syscomments
where text like '%customer%'
go
------------output


select * from INFORMATION_SCHEMA.ROUTINES
CREATE PROCEDURE usp_EXISTPROC
(
@customerid int,
@existcuromer bit output
)
as

begin 
 if exists(select * from Customers
where CustomerId=@customerid)
 set @existcuromer=1
 else
 set @existcuromer=0


end

go

declare @bit bit
exec usp_EXISTPROC @customerid=1,@existcuromer=@bit output
select @bit

go

create procedure fullname(

@firstanme nvarchar(100),
@lastname nvarchar(100),
@fullname nvarchar(200) output
)
as
begin

set @fullname= concat(@firstanme,'' ,@lastname)
end
declare @fl nvarchar(200)
exec fullname N'علی',N'نوری',@fullname=@fl output
select @fl
go

------------encryption
go

alter procedure usp_GetAllCustomers
with encryption
as begin
select top 100 CustomerId,CustomerName,CustomerAddress,Comment,value from Customers 
end


select OBJECT_NAME(id),* from sys.syscomments

-----------
-------plan view
select CustomerId,CustomerAddress,CustomerName,Comment,value from Customers
where value <1063
go
create unique nonclustered index ix_non2  on Customers(value)
include(CustomerName,CustomerAddress,Comment)
--with(drop_existing=on)


select CustomerId,CustomerAddress,CustomerName,Comment,value from Customers
where value <1063


go

select CustomerId,CustomerAddress,CustomerName,Comment,value from Customers
with (index(ix_non))
where value <106

go

exec usp_getbyid 123

----plan cache
--پاک کردن کوئری هایی که در پلن آنها در کش ذخیره شده است
DBCC FREEPROCCACHE

select * from sys.dm_exec_cached_plans
go
select * from sys.dm_exec_sql_text(0x0500FF7FEC5CE6D85001B125E801000001000000000000000000000000000000000000000000000000000000)
go

select t.text,p.bucketid,p.size_in_bytes,p.usecounts from sys.dm_exec_cached_plans p
cross apply sys.dm_exec_sql_text(p.plan_handle) t

go

select t.text,p.bucketid,p.size_in_bytes,p.usecounts,pp.query_plan from 
sys.dm_exec_cached_plans p
cross apply sys.dm_exec_sql_text(p.plan_handle) t
cross apply sys.dm_exec_query_plan(p.plan_handle) pp

go
-----------check use proc use az plna befor not select any plan create
dbcc freeproccache
[usp_getbyid] 123
go
[usp_getbyid] 124
go
[usp_getbyid] 130

select CustomerAddress,Comment,CustomerId,CustomerName from Customers

where CustomerId=123

select CustomerAddress,Comment,CustomerId,CustomerName from Customers

where CustomerId=124

select CustomerAddress,Comment,CustomerId,CustomerName from Customers

where CustomerId=130


select p.size_in_bytes,s.text,pp.query_plan from sys.dm_exec_cached_plans p
cross apply sys.dm_exec_sql_text(p.plan_handle) s
cross apply sys.dm_exec_query_plan(p.plan_handle) pp

go


-------with Result
use AdventureWorks2014
go
CREATE PROCEDURE dbo.INFOORDR(@orderid int)
as
begin
select SalesOrderID,OrderDate,CurrencyRateID,TotalDue from Sales.SalesOrderHeader 
where SalesOrderID=@orderid
select SalesOrderID,SalesOrderDetailID,OrderQty from Sales.SalesOrderDetail
where SalesOrderID=@orderid

end
go

exec dbo.INFOORDR 43671
go

exec dbo.INFOORDR 43671
with result sets
(
([شماره سفارش] int not null
,[تاریخ] datetime not null,
[rate] int null,[total] int not null),
(

[شماره سفارش] int not null
,[detail] int not null,
[qty] int null
)

)



---------TVP
--table value parameter
---table parameter input


CREATE TABLE [Order](

OrderId int identity primary key,
CustomerId int,
OrderDate datetime not null

)
go

Create table OrderDetail(
Id int identity primary key,
OrderId int foreign key references [Order](OrderId),
ProductId int not null,
Quantity int not null,
Price money not null 

)

go
create type OrderUdt as table
(

CustomerId int not null,
OrderDate datetime not null
)
go

create type OrderDetailUdt as table(


ProductId int not null,
Quantity int not null,
Price money not null 
)
go


Create Procedure OrderInsert(
@OrderHeader as OrderUdt readonly,
@OrderDetails as OrderDetailUdt readonly

)
as 
begin
     begin try
        begin transaction
		   declare @OrderId int
		    insert into [Order](CustomerId,OrderDate)
			select * from @OrderHeader

			set @OrderId=scope_identity();

			insert into OrderDetail(OrderId,ProductId,Quantity,Price)
			select @OrderId,ProductId,Quantity,Price from @OrderDetails
        commit transaction
		end try
	begin catch
	rollback tran
	end catch
	end
	go

	declare @O_H as OrderUdt;
declare @O_D as OrderDetailUdt;
insert into @O_H values(1,getdate())
insert into @O_D values(100,2,10000)
insert into @O_D values(101,20,5000)
insert into @O_D values(102,7,66)
insert into @O_D values(103,10,9855)


exec OrderInsert @O_H,@O_D;
go
SELECT * FROM [Order]
SELECT * FROM [OrderDetail]


--درج داده از طريق سي شارپ
--همانند ساختار نوع داده جدولي دو ديتا تيبل ايجاد شود
/*
var headers = new DataTable();
headers.Columns.Add("CustomerId", typeof(int));
headers.Columns.Add("OrderDate", typeof(DateTime));

var details = new DataTable();
details.Columns.Add("ProductId", typeof(int));
details.Columns.Add("Quantity", typeof(decimal));
details.Columns.Add("Price", typeof(int));

headers.Rows.Add(new object[] { 1, DateTime.Today });

details.Rows.Add(new object[] { 100,2,100000 });
details.Rows.Add(new object[] { 101,20,300000 });
details.Rows.Add(new object[] { 102,7,20000 });
details.Rows.Add(new object[] { 103,10,40000 });



using (var conn = new SqlConnection("Data Source=.;Initial Catalog=MyDb;Integrated Security=True;"))
{
  conn.Open();
  using (var cmd = new SqlCommand("InsertOrders", conn))
  {
    cmd.CommandType = CommandType.StoredProcedure;

    var headersParam = cmd.Parameters.AddWithValue("@OrderHeaders", headers);
    var detailsParam = cmd.Parameters.AddWithValue("@OrderDetails", details);

    headersParam.SqlDbType = SqlDbType.Structured;
    detailsParam.SqlDbType = SqlDbType.Structured;

    cmd.ExecuteNonQuery();
  }
  conn.Close();
}
*/
---------------ParameterSniffing
use AdventureWorks2014
go

alter PROCEDURE usp_GetSalesOderHeader0(
@SalesOrderId int , @OrderDate datetime
)
as
select * from Sales.SalesOrderHeader
where (SalesOrderID=@SalesOrderId or @SalesOrderId is null)
and (OrderDate=@OrderDate or @OrderDate is null)
go

----show actual plan

--declare @orderdate datetime='2011-05-31 00:00:00.000'
--declare @SalesOrderId int=43671

select * from Sales.SalesOrderHeader
where (SalesOrderID=43671 or 43671 is null)
and (OrderDate='2011-05-31 00:00:00.000' or '2011-05-31 00:00:00.000' is null)


go
--declare @orderdate datetime='2011-05-31 00:00:00.000'
--declare @SalesOrderId int = null

select * from Sales.SalesOrderHeader
where (SalesOrderID=null or null is null)
and (OrderDate='2011-05-31 00:00:00.000' or '2011-05-31 00:00:00.000' is null)


select * from Sales.SalesOrderHeader
where (SalesOrderID=43671 or 43671 is null)
and (OrderDate=null or null is null)


select * from Sales.SalesOrderHeader
where (SalesOrderID=null or null is null)
and (OrderDate=null or null is null)

---sp one create plan onther use as plan
exec usp_GetSalesOderHeader0  43671,null
go
exec usp_GetSalesOderHeader0  null,'2011-05-31 00:00:00.000'
go
exec usp_GetSalesOderHeader0  null,null
go
---هرکدام یک پلن دارن

select p.usecounts,p.objtype,q.query_plan,h.text from sys.dm_exec_cached_plans p
cross apply sys.dm_exec_query_plan(p.plan_handle) q
cross apply sys.dm_exec_sql_text(p.plan_handle) h

go

---------slove
create PROCEDURE usp_GetSalesOrderHeader1 (@SalesOrderID INT,
@OrderDate DATETIME)
AS
	DECLARE @cmd NVARCHAR(1000)
	SET @cmd=N'SELECT * FROM Sales.SalesOrderHeader WHERE 1=1 '

	IF @SalesOrderID IS NOT NULL
		SET @cmd+=' AND SalesOrderID=@SalesOrderID'

	IF @OrderDate IS NOT NULL
		SET @cmd+=' AND OrderDate=@OrderDate'
	
	EXEC sp_executesql @cmd
		,N'@SalesOrderID INT,@OrderDate DATETIME', 
		@SalesOrderID,@OrderDate
GO
exec usp_GetSalesOderHeader0  43671,null
go
exec usp_GetSalesOderHeader0  null,'2011-05-31 00:00:00.000'
go
exec usp_GetSalesOderHeader0  null,null

go
exec usp_GetSalesOderHeader0  43671,null
exec usp_GetSalesOrderHeader1  43671,null
go
exec usp_GetSalesOrderHeader1  43671,'2011-05-31 00:00:00.000'
go
exec usp_GetSalesOrderHeader1  null,null