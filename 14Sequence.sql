use test
go
if object_id('SequenceTest')>0
drop sequence SequenceTest
go

create sequence SequenceTest as int
start with 1
increment by 1
minvalue 1
maxvalue 30
cycle 
cache
go

select next value for SequenceTest as value

create table C1(

a int,
name varchar(20))

go

insert into C1 values( next value for SequenceTest,'ali' )
insert into C1 values( next value for SequenceTest,'hamid' )
insert into C1 values( next value for SequenceTest,'reza' )
insert into C1 values( next value for SequenceTest,'sadegh' )
go

select * from  C1
go

select next value for SequenceTest
go

select * from sys.sequences

go

if object_id('EventCount')>0
 drop sequence EventCount
 go

 create sequence EventCount
 as int 
 start with 1
 increment by 1;
 go

 if object_id('ProcEvents')>0
  drop table ProcEvent
  go

  create table ProcEvents(
  EventId int primary key clustered
  default (next value for EventCount),
  EventTime  datetime not null  default(getdate()),
  EventCod nvarchar(5),
  EventComment nvarchar(300)
  
  )
  go

  insert into ProcEvents(EventCod,EventComment) values(1,'Event1')
    insert into ProcEvents(EventCod,EventComment) values(2,'Event2')
	go
	select * from ProcEvents
	go

	   insert into ProcEvents(EventId,EventCod,EventComment) values(4,4,'Event4')

	   go

	   select next value for EventCount
	   go
exec sys.sp_sequence_get_range 

sp_helptext sp_sequence_get_range


SP_HELPTEXT sp_sequence_get_range
/*
	@sequence_name      nvarchar(776), --Sequence نام 
	@range_size         bigint, --مقدار ورودی
	@range_first_value  sql_variant output, --مقدار خروجی
	@range_last_value   sql_variant = null output, --مقدار خروجی
	@range_cycle_count  int = null output, --مقدار خروجی
	@sequence_increment sql_variant = null output, --مقدار خروجی
	@sequence_min_value sql_variant = null output, --مقدار خروجی
	@sequence_max_value sql_variant = null output --مقدار خروجی
*/
GO
CREATE SEQUENCE RangeSeq
    AS int 
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 100
    CYCLE
    CACHE 10
GO
DECLARE @range_first_value_output sql_variant 
EXEC sp_sequence_get_range
	@sequence_name = N'RangeSeq'
	, @range_size = 4
	, @range_first_value = @range_first_value_output OUTPUT 
SELECT @range_first_value_output AS FirstNumber 
GO
DECLARE  
	 @FirstSeqNum sql_variant
	, @LastSeqNum sql_variant
	, @CycleCount int
	, @SeqIncr sql_variant
	, @SeqMinVal sql_variant
	, @SeqMaxVal sql_variant 

EXEC sys.sp_sequence_get_range
	  @sequence_name = N'RangeSeq'
	, @range_size = 5
	, @range_first_value = @FirstSeqNum OUTPUT 
	, @range_last_value = @LastSeqNum OUTPUT 
	, @range_cycle_count = @CycleCount OUTPUT
	, @sequence_increment = @SeqIncr OUTPUT
	, @sequence_min_value = @SeqMinVal OUTPUT
	, @sequence_max_value = @SeqMaxVal OUTPUT 

-- The following statement returns the output values
SELECT
  @FirstSeqNum AS FirstVal
, @LastSeqNum AS LastVal
, @CycleCount AS CycleCount
, @SeqIncr AS SeqIncrement
, @SeqMinVal AS MinSeq
, @SeqMaxVal AS MaxSeq 
-------------------------------------
--بررسی سناریو کاربردی و مفید
--شماره مرجع تراکنش بر روی رسیدهای بانکی

GO

/*
SqlCommand cmd = new SqlCommand();
cmd.Connection = conn;
cmd.CommandType = CommandType.StoredProcedure;
cmd.CommandText = "sys.sp_sequence_get_range";
cmd.Parameters.AddWithValue("@sequence_name", "RangeSeq");
cmd.Parameters.AddWithValue("@range_size", 10);

// Specify an output parameter to retreive the first value of the generated range.
SqlParameter firstValueInRange = new SqlParameter("@range_first_value", SqlDbType.Variant);
firstValueInRange.Direction = ParameterDirection.Output;
cmd.Parameters.Add(firstValueInRange);

conn.Open();
cmd.ExecuteNonQuery();

// Output the first value of the generated range.
Console.WriteLine(firstValueInRange.Value);
*/
////////performance

http://www.sqlnotes.info/2011/11/18/sql-server-sequence-internal/
*/
GO
USE tempdb
set nocount on
if object_id('a') is not null
	drop table a

if object_id('seq1') is not null
	drop sequence seq1
GO
create table a (id bigint identity(1,1))
GO

----------------------------------
declare @i int, @d datetime2(3), @j int
select @i = 0, @d = GETDATE()
while @i < 500000
begin
	insert into a default values
	select @i = @i + 1
end
select 'Identity', DATEDIFF(MILLISECOND, @d, getdate()) MILLISECONDs
GO
----------------------------------
create sequence seq1 no cache
go
if object_id('b') is not null
	drop table b
create table b (id bigint default  next value for seq1)
GO
declare @i int, @d datetime2(3), @j bigint
select @i = 0, @d = GETDATE()
while @i < 500000
begin
	insert into b  values (@j)
	select @i = @i + 1
end
select 'Sequence Without Cache', DATEDIFF(MILLISECOND, @d, getdate()) MILLISECONDs
go
drop table b
drop sequence seq1
go
----------------------------------
create sequence seq1 cache
go
if object_id('b') is not null
	drop table b
create table b (id bigint default  next value for seq1)
GO
declare @i int, @d datetime2(3), @j bigint
select @i = 0, @d = GETDATE()
while @i < 500000
begin
	insert into b  values (@j)
	select @i = @i + 1
end
select 'Sequence With Cache 50', DATEDIFF(MILLISECOND, @d, getdate()) MILLISECONDs
go
drop table b
drop sequence seq1
go
----------------------------------
create sequence seq1 cache 500
go
if object_id('b') is not null
	drop table b
create table b (id bigint default  next value for seq1)
GO
declare @i int, @d datetime2(3), @j bigint
select @i = 0, @d = GETDATE()
while @i < 500000
begin
	insert into b  values (@j)
	select @i = @i + 1
end
select 'Sequence With Cache 500', DATEDIFF(MILLISECOND, @d, getdate()) MILLISECONDs
go
drop table b
drop sequence seq1
go
----------------------------------
create sequence seq1 cache 5000
go
if object_id('b') is not null
	drop table b
create table b (id bigint default  next value for seq1)
GO
declare @i int, @d datetime2(3), @j bigint
select @i = 0, @d = GETDATE()
while @i < 500000
begin
	insert into b  values (@j)
	select @i = @i + 1
end
select 'Sequence With Cache 5000', DATEDIFF(MILLISECOND, @d, getdate()) MILLISECONDs
go
drop table b
drop sequence seq1
go
