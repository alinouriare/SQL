CREATE DATABASE DDL_TRIGGER
GO
USE DDL_TRIGGER
GO
CREATE TRIGGER DDL_TRIGER
ON DATABASE 
FOR ALTER_TABLE,DROP_TABLE
AS
PRINT 'NOT WORK'
ROLLBACK
GO
CREATE TABLE A(ID INT)
GO
ALTER TABLE A  ADD CO INT 
GO
SELECT * FROM sys.trigger_event_types

SELECT * FROM sys.trigger_events

SELECT * FROM sys.triggers
GO
DISABLE TRIGGER DDL_TRIGER ON DATABASE
GO
ENABLE TRIGGER DDL_TRIGER ON DATABASE
GO
ALTER TABLE A ADD N NVARCHAR(10) NOT NULL
GO

CREATE TRIGGER T_ALL ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS 
AS

   PRINT N'شما مجاز نمی توانید اینکار نمی باشید'
   ROLLBACK
GO

;with CTERecursive as
(
select type,type_name,parent_type,
1 as leveles
from
sys.trigger_event_types
where type_name='DDL_DATABASE_LEVEL_EVENTS'
union all

select p.type,p.type_name
,p.parent_type,CTERecursive.leveles+1
from sys.trigger_event_types p 
join CTERecursive
on p.parent_type=CTERecursive.type
)
select * from CTERecursive 
order by leveles,type

go
create trigger tr_all on database
for DDL_DATABASE_LEVEL_EVENTS
as
declare @x xml
set @x =EVENTDATA()
print cast(@x as nvarchar(max))

go

create table aa(
co int,
coo nvarchar(20)
)

drop trigger tr_all on database

go

CREATE TABLE DDL_Log 
(
	PostTime datetime, 
	DB_User nvarchar(100), 
	[Event] nvarchar(100), 
	[TSQL] nvarchar(2000)
)
GO
CREATE TRIGGER SaveCommand ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
DECLARE @DATA XML
SET @DATA= EVENTDATA()
INSERT INTO DDL_Log(PostTime,DB_User,[Event],[TSQL])
 VALUES (GETDATE(),CONVERT(NVARCHAR(100),CURRENT_USER),
	@data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), 
				@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)') )

--Test the trigger
CREATE TABLE TestTable 
(
	F1 INT,
	F2 SMALLDATETIME
)

DROP TABLE TestTable ;
GO
SELECT * FROM ddl_log ;
GO
--حذف تریگر
DROP TRIGGER [DDL_Log] ON DATABASE 
GO
USE tempdb
GO
--بررسی وجود جدول و حذف آن
IF OBJECT_ID('DDL_Log')>0
	DROP TABLE DDL_Log
GO
--DDL ایجاد جدولی جهت لاگ دستورات
CREATE TABLE DDL_Log 
(
	PostTime datetime, 
	DB_User nvarchar(100), 
	[Event] nvarchar(100), 
	[TSQL] nvarchar(2000)
)
GO
SELECT * FROM DDL_Log
GO
--ایجاد تریگر در سطح سرور
USE master
GO
CREATE TRIGGER [DDL_Log] ON ALL SERVER 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	DECLARE @data XML
	DECLARE @DB_Name NVARCHAR(100)
	SET @data = EVENTDATA() 
	INSERT TempDB..ddl_log (PostTime, DB_User,[DB_Name], [Event], [TSQL]) 
		VALUES 
			(
				GETDATE(), 
				CONVERT(nvarchar(100), CURRENT_USER), 
				@data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), 
				@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)') 
			) 
	PRINT (CAST(EVENTDATA() AS NVARCHAR(MAX)))
GO
--Show Object Explorer
GO
USE Northwind
GO
--بررسی جدول و حذف آن
IF OBJECT_ID('Students')>0
	DROP TABLE Students
GO
--ایجاد یک جدول جدید
CREATE TABLE Students
(
	Code Int,
	Name NVARCHAR(50),
	Family NVARCHAR(50)
)
GO
--Insert
INSERT INTO Students(Code,Name) 
	VALUES (1,'Masoud')
GO
SELECT * FROM TempDB..ddl_log 
GO
USE master
--حذف تریگر
DROP TRIGGER [DDL_Log] ON ALL SERVER 
GO


USE Logon_Trigger
GO
--Logon Trigger ایجاد یک
-- Creating audit table
CREATE TABLE LogonAuditing
(
	SessionId int,
	LogonTime datetime,
	HostName varchar(50),
	ProgramName varchar(500),
	LoginName varchar(50),
	ClientHost varchar(50)
)
GO
USE Master
GO
-- Creating DDL trigger for logon
CREATE TRIGGER LogonAuditTrigger
ON ALL SERVER
FOR LOGON
AS
BEGIN
	DECLARE @LogonTriggerData xml,
	@EventTime datetime,
	@LoginName varchar(50),
	@ClientHost varchar(50),
	@LoginType varchar(50),
	@HostName varchar(50),
	@AppName varchar(500)
	SET @LogonTriggerData = eventdata()
	SET @EventTime = @LogonTriggerData.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime')
	SET @LoginName = @LogonTriggerData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(50)')
	SET @ClientHost = @LogonTriggerData.value('(/EVENT_INSTANCE/ClientHost)[1]', 'varchar(50)')
	SET @HostName = HOST_NAME()
	SET @AppName = APP_NAME()--,program_name()
	INSERT INTO Logon_Trigger.dbo.LogonAuditing
	(
		SessionId,
		LogonTime,
		HostName,
		ProgramName,
		LoginName,
		ClientHost
	)
	SELECT
		@@spid,
		@EventTime,
		@HostName,
		@AppName,
		@LoginName,
		@ClientHost
END
GO
SELECT * FROM Logon_Trigger..LogonAuditing
GO
--حذف تریگر
USE master
GO
DROP TRIGGER LogonAuditTrigger ON ALL SERVER
--------------------------------------------------------------------
--SQL SERVER سناریو ورود آی پی های مجاز به 
/*
<EVENT_INSTANCE>
  <EventType>event_type</EventType>
  <PostTime>post_time</PostTime>
  <SPID>spid</SPID>
  <TextData>text_data</TextData>
  <BinaryData>binary_data</BinaryData>
  <DatabaseID>database_id</DatabaseID>
  <NTUserName>nt_user_name</NTUserName>
  <NTDomainName>nt_domain_name</NTDomainName>
  <HostName>host_name</HostName>
  <ClientProcessID>client_process_id</ClientProcessID>
  <ApplicationName>application_name</ApplicationName>
  <LoginName>login_name</LoginName>
  <StartTime>start_time</StartTime>
  <EventSubClass>event_subclass</EventSubClass>
  <Success>success</Success>
  <IntegerData>integer_data</IntegerData>
  <ServerName>server_name</ServerName>
  <DatabaseName>database_name</DatabaseName>
  <LoginSid>login_sid</LoginSid>
  <RequestID>request_id</RequestID>
  <EventSequence>event_sequence</EventSequence>
  <IsSystem>is_system</IsSystem>
  <SessionLoginName>session_login_name</SessionLoginName>
</EVENT_INSTANCE>
*/
--------------------------------------------------------------------
/*
sqlcmd -S MASUD_TAHERI\SQLSERVER2014 -A -d master -q "DROP TRIGGER trg_Logon ON ALL SERVER"+
sqlcmd -S MASUD_TAHERI\SQLSERVER2014 -A -d master -q "Disable Trigger All ON ALL Server"
sql server browser start
*/