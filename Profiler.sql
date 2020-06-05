--مشاهده پلن اجرايي يك كوري
--Please HighLight This Query And Press Ctrl+L
USE Northwind
GO
SELECT Customers.CustomerID,Customers.CompanyName,COUNT(Orders.OrderID) AS ORDER_COUNT FROM Customers 
	INNER JOIN Orders 
		ON Customers.CustomerID=Orders.CustomerID 
			GROUP BY Customers.CustomerID,Customers.CompanyName
GO	

 USE Northwind
                GO
                CREATE PROCEDURE usp_GetOrders
                (
	                @OrderID INT
                )
                AS
	                SELECT * FROM Orders
		                WHERE OrderID=@OrderID


go

USE Northwind
GO
CREATE PROCEDURE ShowMsg
	 (@FirstName  NvarChar(20),
		@LastName  NvarChar(20))
AS	
	DECLARE @Ucase_FirstName AS NVARCHAR(20)
	DECLARE @UCase_LastName  AS NVARCHAR(20)
	DECLARE @ResultString  AS NVARCHAR(100)
	
	SET @Ucase_FirstName=UPPER(@FirstName)
	SET @UCase_LastName=UPPER(@LastName)
	SET @ResultString ='Hello ' + @Ucase_FirstName + ' ' + @UCase_LastName  
	
	SELECT @ResultString
Go

-----------------تعرف جاب برای اسم فایل
select 'c:\dump\profiler\'+replace( convert(nvarchar(19),getdate(),121),':','')

ShowMsg 'ali','nouri'

GO

---- PROFILER GREATER THEN OR EQUAL 2000 MS=>2S

SELECT Customers.CustomerID,Customers.CompanyName,COUNT(Orders.OrderID) AS ORDER_COUNT FROM Customers 
	INNER JOIN Orders 
		ON Customers.CustomerID=Orders.CustomerID 
			GROUP BY Customers.CustomerID,Customers.CompanyName
		WAITFOR DELAY '00:00:03'

		--------------------------------------------------------------------
--Server Side Trace ساخت بعد
SELECT * FROM sys.traces
GO
--نمایش محتوا فایل ساخته شده
SELECT * FROM sys.fn_trace_gettable('C:\dump\1399.trc',default)
go

SELECT TextData,(Duration/1000000.0) as Duration,Reads,Writes,HostName FROM sys.fn_trace_gettable('C:\dump\1399.trc',default)
order by Duration desc
GO
SP_CONFIGURE 'default trace enabled'


sp_trace_setstatus   2 ,  0



GO
--Trace تنظیم وضعیت 
/*
sp_trace_setstatus [ @traceid = ] trace_id , [ @status = ] status  
0	Stops the specified trace.
1	Starts the specified trace.
2	Closes the specified trace and deletes its definition from the server.
https://msdn.microsoft.com/en-us/library/ms176034.aspx
*/
GO
--------------------------------------------------------------------
--از بین می رود Trace با قطع شدن برق
--Trace اجرای اتوماتیک 
/*
sp_procoption [ @ProcName = ] 'procedure'   
    , [ @OptionName = ] 'option'   
    , [ @OptionValue = ] 'value'   

Arguments
[ @ProcName = ] 'procedure'
Is the name of the procedure for which to set an option. procedure is nvarchar(776), with no default.

[ @OptionName = ] 'option'
Is the name of the option to set. The only value for option is startup.

[ @OptionValue = ] 'value'
Is whether to set the option on (true or on) or off (false or off). value is varchar(12), with no default.
*/
EXEC sp_procoption @ProcName='ups_Trace',@OptionName='startup',@OptionValue='off'
GO
--With Job
sp_configure 'show advanced options',1
reconfigure
sp_configure 'scan for startup procs' , 0
reconfigure


SELECT name,create_date,modify_date
FROM sys.procedures
WHERE OBJECTPROPERTY(OBJECT_ID, 'ExecIsStartup') = 1
GO
SELECT name,create_date,modify_date
FROM sys.procedures
WHERE is_auto_executed = 1






---------------------create file export profiler change


use master
go
alter proc usp_run
as
-- Create a Queue

declare @x nvarchar(50)
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5 
set @x='c:\dump\'+replace( convert(nvarchar(19),getdate(),121),':','')
-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, @x, @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 28, @on
exec sp_trace_setevent @TraceID, 45, 35, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 35, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

set @bigintfilter = 20000000
exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

exec sp_trace_setfilter @TraceID, 35, 0, 6, N'Northwind'
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
---any run create file
exec usp_run

--With Job
sp_configure 'show advanced options',1
reconfigure
sp_configure 'scan for startup procs' , 0
reconfigure


--- proc in mastre
EXEC sp_procoption @ProcName='usp_run',@OptionName='startup',@OptionValue='off'


SELECT name,create_date,modify_date
FROM sys.procedures
WHERE OBJECTPROPERTY(OBJECT_ID, 'ExecIsStartup') = 1
GO
SELECT name,create_date,modify_date
FROM sys.procedures
WHERE is_auto_executed = 1
