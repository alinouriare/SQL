CREATE DATABASE Test_SSSB
GO
USE Test_SSSB
GO
CREATE TABLE EmployeeInfo(
EmployeeID INT PRIMARY KEY,
	FirstNamre NVARCHAR(100),
	LastName NVARCHAR(100)

)

GO
--این پروسیجر بعد از درج رکورد در جدول اجرا می شود


CREATE PROCEDURE usp_ProcessAfterInsertRecord(@EmployeeID INT)
AS
	IF @EmployeeID<1000
		WAITFOR DELAY '00:00:05'
	ELSE IF @EmployeeID BETWEEN 1000 AND 1999 
		WAITFOR DELAY '00:00:10'		
	ELSE IF @EmployeeID BETWEEN 2000 AND 2999
		WAITFOR DELAY '00:00:15'		
GO
--تست پروسیجر
EXEC usp_ProcessAfterInsertRecord 852
GO
EXEC usp_ProcessAfterInsertRecord 1852
GO
EXEC usp_ProcessAfterInsertRecord 2852
GO
--ایجاد یک تریگر به ازای جدول

CREATE TRIGGER trg_Insert_EmployeeInfo 
ON EmployeeInfo AFTER INSERT
AS
DECLARE  @Inserted_EmployeeID INT
SELECT @Inserted_EmployeeID=EmployeeID FROM EmployeeInfo
EXEC usp_ProcessAfterInsertRecord @Inserted_EmployeeID
GO

GO
--درج رکورد تستی در جدول
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES 
	(2034,N'علی',N'نوری')
GO 
--دیگر کنترل شودSession در یک 
SELECT * FROM EmployeeInfo
GO
--مشاهده می شود با اعمال تریگر به ازای جدول درج رکورد چندین 
--ثانیه طول می کشد
GO
--------------------------------------------------------------------
--بر روی بانک اطلاعاتیSSSB فعال سازی قابلیت 

ALTER DATABASE Test_SSSB SET ENABLE_BROKER
GO
--------------------------------------------------------------------
--Message Types ایجاد 
CREATE MESSAGE TYPE RequestMessage
VALIDATION=WELL_FORMED_XML
GO
CREATE MESSAGE TYPE ReplyMessage
VALIDATION=WELL_FORMED_XML
GO

-------------------------------------------------------------------- 
--Contract ایجاد 

CREATE CONTRACT SampleContract
(
RequestMessage SENT BY INITIATOR,
ReplyMessage  SENT BY TARGET

)

--------------------------------------------------------------------
--می باشدTarget و یک Initiator ایجاد ارتباط بین یک 
-- می تواند در دیتابیس های جداگانه و حتی ماشین های جداگانه ای باشند Initiator&Target
--------------------------------------------------------------------
GO
--و سرویس وابسته Initiator Queue ایجاد 
CREATE QUEUE InitiatorQueue

GO

--می کندRoute (صف) Queue را به یک Message سرویس یک 
CREATE SERVICE InitiatorService 
    ON QUEUE InitiatorQueue

	--و سرویس وابسته Target Queue ایجاد 
CREATE QUEUE TargetQueue
GO
--می کندRoute (صف) Queue را به یک Message سرویس یک 
CREATE SERVICE TargetService 
    ON QUEUE TargetQueue(SampleContract)
GO

--------------------------------------------------------------------
--Message ایجاد یک پروسیجر برای ارسال

CREATE PROCEDURE SendBrokerMessage 
	@FromService SYSNAME,
	@ToService   SYSNAME,
	@Contract    SYSNAME,
	@MessageType SYSNAME,
	@MessageBody XML
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MsgXML XML;
 
	DECLARE @conversation_handle UNIQUEIDENTIFIER;
	BEGIN TRANSACTION;
		BEGIN DIALOG CONVERSATION @conversation_handle
			FROM SERVICE @FromService
			TO SERVICE @ToService
			ON CONTRACT @Contract
			WITH ENCRYPTION = OFF;
		--Conversation به Message ارسال
		SEND ON CONVERSATION @conversation_handle
			MESSAGE TYPE @MessageType(@MessageBody)
	COMMIT TRANSACTION;
END
GO
--Message و ارسال Conversation شروع
EXEC SendBrokerMessage
	@FromService =N'InitiatorService',
	@ToService   =N'TargetService',
	@Contract    =N'SampleContract',
	@MessageType =N'RequestMessage',
	@MessageBody =N'<EmployeeInfo><EmployeeID>123</EmployeeID></EmployeeInfo>'
GO
--------------------------------------------------------------------
--TargetQueue های موجود در Message مشاهده 
SELECT * FROM InitiatorQueue
SELECT * FROM TargetQueue
GO
--XML موجود در صف به یک متنMessage تبدیل 
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue
GO
--Queue خواندن مسچ ها از
RECEIVE TOP(1) * FROM TargetQueue
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
--TargetQueue ایجاد یک پروسیجر برای پردازش مسج های موجود در 
IF OBJECT_ID('usp_TargetQueueProcess')>0
	DROP PROCEDURE usp_TargetQueueProcess
GO
CREATE PROCEDURE usp_TargetQueueProcess
AS
	DECLARE @Conversation_Handle UNIQUEIDENTIFIER;
	DECLARE @Message_Body XML;
	DECLARE @Message_Type_Name sysname;

	WHILE (1=1)
	BEGIN
		BEGIN TRANSACTION
		WAITFOR
		( 
			--Queue از Message خواندن 		
			RECEIVE TOP(1)
			@Conversation_Handle = conversation_handle,
			@Message_Body = message_body,
			@Message_Type_Name = message_type_name
			FROM TargetQueue
		),  TIMEOUT 5000;
		--وجود نداشت Queue در صورتیکه رکوردی در 
		IF (@@ROWCOUNT = 0)
		BEGIN
		  ROLLBACK TRANSACTION
		  BREAK
		END
		
		--باشد RequestMessage آن Message وجود داشت و نوع Queue چنانچه رکوردی در
		IF @Message_Type_Name =N'RequestMessage'
		BEGIN
			--انجام شود در این قسمت نوشته می شودAsyn هر کاری که قرار است به صورت
			DECLARE @EmployeeID_FromTargetQueue INT=@Message_Body.value('(EmployeeInfo/EmployeeID)[1]', 'INT');
			
			--کار مورد نظر شما
			EXEC usp_ProcessAfterInsertRecord  @EmployeeID_FromTargetQueue;

			--Initiator به Response Message ارسال 
			DECLARE @ReplyMsg XML
		    SELECT @ReplyMsg =@Message_Body;
			SEND ON CONVERSATION @Conversation_Handle
				MESSAGE TYPE ReplyMessage(@ReplyMsg)
			
			END CONVERSATION @Conversation_Handle;
		END
		
		ELSE IF @Message_Type_Name =N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
		BEGIN
		   END CONVERSATION @Conversation_Handle;
		END
		--در صورتیکه با خطا مواجه شویم
		ELSE IF @Message_Type_Name =N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
		BEGIN
			--می توان خطاهای رخ داده را لاگ کرد
			END CONVERSATION @Conversation_Handle;
		END
		COMMIT TRANSACTION
  END
GO

--------------------------------------------------------------------
--InitiatorQueue موجود در Response Message ایجاد یک پروسیجر برای پردازش 
IF OBJECT_ID('usp_InitiatorQueueProcess')>0
	DROP PROCEDURE usp_InitiatorQueueProcess
GO
CREATE PROCEDURE usp_InitiatorQueueProcess
AS
	DECLARE @Conversation_Handle UNIQUEIDENTIFIER;
	DECLARE @Message_Body XML;
	DECLARE @Message_Type_Name sysname;

	WHILE (1=1)
	BEGIN
		BEGIN TRANSACTION
		WAITFOR
		( 
			--Queue از Message خواندن 		
			RECEIVE TOP(1)
			@Conversation_Handle = conversation_handle,
			@Message_Body = message_body,
			@Message_Type_Name = message_type_name
			FROM InitiatorQueue
		),  TIMEOUT 5000;
		--وجود نداشت Queue در صورتیکه رکوردی در 
		IF (@@ROWCOUNT = 0)
		BEGIN
		  ROLLBACK TRANSACTION
		  BREAK
		END
		
		--باشد ReplyMessage آن Message وجود داشت و نوع Queue چنانچه رکوردی در
		IF @Message_Type_Name =N'ReplyMessage'
		BEGIN
			--انجام شود در این قسمت نوشته می شودAsyn هر کاری که قرار است به صورت
			DECLARE @EmployeeID_FromTargetQueue INT=@Message_Body.value('(EmployeeInfo/EmployeeID)[1]', 'INT');
			
			--کار مورد نظر شما

			END CONVERSATION @Conversation_Handle;
		END
		--اگر مسجی در صف وجود نداشته باشد
		ELSE IF @Message_Type_Name =N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
		BEGIN
		   END CONVERSATION @Conversation_Handle;
		END
		--در صورتیکه با خطا مواجه شویم
		ELSE IF @Message_Type_Name =N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
		BEGIN
			--می توان خطاهای رخ داده را لاگ کرد
			END CONVERSATION @Conversation_Handle;
		END
		COMMIT TRANSACTION
  END
GO

--Message و ارسال Conversation شروع
EXEC SendBrokerMessage
	@FromService =N'InitiatorService',
	@ToService   =N'TargetService',
	@Contract    =N'SampleContract',
	@MessageType =N'RequestMessage',
	@MessageBody =N'<EmployeeInfo><EmployeeID>123</EmployeeID></EmployeeInfo>'
GO
--XML موجود در صف به یک متنMessage تبدیل 
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM InitiatorQueue
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue
GO
--TargetQueue پردازش
EXECUTE dbo.usp_TargetQueueProcess;
GO
--XML موجود در صف به یک متنMessage تبدیل 
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM InitiatorQueue
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue
GO
--InitiatorQueue پردازش
EXECUTE dbo.usp_InitiatorQueueProcess;
GO
--XML موجود در صف به یک متنMessage تبدیل 
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM InitiatorQueue
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue
GO
--------------------------------------------------------------------
--پردازش اتوماتیک صف ها

--TargetQueue و تخصیص پروسیجر مربوط به پردازش  Queue ویرایش 
ALTER QUEUE TargetQueue WITH ACTIVATION
( 
	STATUS = ON,
	PROCEDURE_NAME = usp_TargetQueueProcess,
	MAX_QUEUE_READERS = 10,
	EXECUTE AS SELF
)
GO
--InitiatorQueue و تخصیص پروسیجر مربوط به پردازش  Queue ویرایش 
ALTER QUEUE InitiatorQueue WITH ACTIVATION
( 
	STATUS = ON,
	PROCEDURE_NAME = usp_InitiatorQueueProcess,
	MAX_QUEUE_READERS = 10,
	EXECUTE AS SELF
)
GO
--------------------------------------------------------------------
--Message و ارسال Conversation شروع
EXEC SendBrokerMessage
	@FromService =N'InitiatorService',
	@ToService   =N'TargetService',
	@Contract    =N'SampleContract',
	@MessageType =N'RequestMessage',
	@MessageBody =N'<EmployeeInfo><EmployeeID>123</EmployeeID></EmployeeInfo>'
GO 100
--XML موجود در صف به یک متنMessage تبدیل 
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM InitiatorQueue WITH(NOLOCK)
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue  WITH(NOLOCK)
GO 
--------------------------------------------------------------------
USE Test_SSSB
GO
--Async Trigger پیاده سازی 
IF OBJECT_ID('EmployeeInfo')>0
	DROP TABLE EmployeeInfo
GO
CREATE TABLE EmployeeInfo
(
	EmployeeID INT PRIMARY KEY,
	FirstNamre NVARCHAR(100),
	LastName NVARCHAR(100)
)
GO
--ایجاد یک تریگر به ازای جدول
CREATE TRIGGER trg_Insert_EmployeeInfo 
	ON EmployeeInfo AFTER INSERT 
AS
	DECLARE @Msg XML;
	--'<EmployeeInfo><EmployeeID>123</EmployeeID></EmployeeInfo>'
	SET @Msg=(SELECT EmployeeID FROM inserted FOR XML PATH(''),ROOT('EmployeeInfo'))
	--ارسال رکورد به صف 
	EXEC SendBrokerMessage
		@FromService =N'InitiatorService',
		@ToService   =N'TargetService',
		@Contract    =N'SampleContract',
		@MessageType =N'RequestMessage',
		@MessageBody =@Msg
GO
--درج رکورد تستی در جدول
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (7234,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (1235,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (1236,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (1237,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (2234,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (3234,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (4234,N'مسعود',N'طاهری')
INSERT INTO EmployeeInfo (EmployeeID,FirstNamre,LastName) VALUES (5234,N'مسعود',N'طاهری')
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM InitiatorQueue WITH(NOLOCK)
GO
SELECT 
	conversation_group_id,
	CAST(message_body AS XML) 
FROM TargetQueue  WITH(NOLOCK)
GO 
--------------------------------------------------------------------