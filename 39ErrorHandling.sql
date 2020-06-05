begin try
select 1/0
end try
begin catch
print 'error'
end catch

go

CREATE TABLE Err_Handling
(
	F1 INT PRIMARY KEY,
	F2 NVARCHAR(1)
)
GO
INSERT INTO Err_Handling VALUES (1,'A')
INSERT INTO Err_Handling VALUES (2,'B')
INSERT INTO Err_Handling VALUES (3,'C')
GO
SELECT * FROM Err_Handling 
GO
INSERT INTO Err_Handling VALUES (2,'B') --يك درج تكراري رخ مي دهد

go
declare @ERR int
INSERT INTO Err_Handling VALUES (2,'B')
set @ERR=@@ERROR
IF @ERR>0 
BEGIN
	PRINT 'ERROR NO:'+CAST(@@ERROR AS NVARCHAR(100))
	PRINT 'ERROR NO:'+CAST(@ERR AS NVARCHAR(100))
	PRINT 'درج اطلاعات لغو شد'
END 
GO
--SQL server2005,2008 در 
--دستور جديدي براي اينكار وجود دارد
/*
BEGIN TRY

    T-SQL Statement

END TRY

BEGIN CATCH

    T-SQL Statement

END CATCH
*/
--استخراج اطلاعات بيشتري در مورد خطا
BEGIN TRY
    SELECT 1/0; -- Generate a divide-by-zero error.
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber, --شماره خطا
        ERROR_SEVERITY() AS ErrorSeverity,--درجه اهميت خطا را مشخص مي كند
        ERROR_STATE() AS ErrorState,--اطلاعات دقيق تري در خصوص سطح خطا ارائه مي كند
        ERROR_PROCEDURE() AS ErrorProcedure, --ي كه خطا در آن رخ داده را مشخص مي كندSPنام 
        ERROR_LINE() AS ErrorLine,--شماره خطي را كه خطا در آن رخ داده را مشخص مي كند
        ERROR_MESSAGE() AS ErrorMessage;--متن خطا را مشخص مي كند
END CATCH;
GO



--------------------------------------------------------------------
CREATE TABLE [dbo].[ErrorHandling]
(
	[ErrorHandlingID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Error_Number]    INT NOT NULL,
	[Error_Message]   NVARCHAR(4000) NULL,
	[Error_Severity]  SMALLINT NOT NULL,
	[Error_State]     SMALLINT NOT NULL DEFAULT ((1)),
	[Error_Procedure] NVARCHAR(200) COLLATE Latin1_General_BIN NOT NULL,
	[Error_Line] INT NOT NULL DEFAULT ((0)),
	[UserName] NVARCHAR(128) NOT NULL DEFAULT (''),
	[HostName] VARCHAR (128) NOT NULL DEFAULT (''),
	[Time_Stamp] DATETIME NOT NULL,
)
GO
--ايجاد پروسيجر
CREATE procedure uspErrorHandling 
AS
-- Declaration statements
DECLARE @Error_Number int
DECLARE @Error_Message varchar(4000)
DECLARE @Error_Severity int
DECLARE @Error_State int
DECLARE @Error_Procedure varchar(200)
DECLARE @Error_Line int
DECLARE @UserName varchar(200)
DECLARE @HostName varchar(200)
DECLARE @Time_Stamp datetime
-- Initialize variables
SELECT @Error_Number = isnull(error_number(),0),
@Error_Message = isnull(error_message(),'NULL Message'),
@Error_Severity = isnull(error_severity(),0),
@Error_State = isnull(error_state(),1),
@Error_Line = isnull(error_line(), 0),
@Error_Procedure = isnull(error_procedure(),''),
@UserName = SUSER_SNAME(),--لاگين كاربر را به اس كيو ال مشخص مي كند
@HostName = HOST_NAME(),--نام كامپيوتر كاربر را مشخصص مي كند
@Time_Stamp = GETDATE();
-- Insert into the dbo.ErrorHandling table
INSERT INTO ErrorHandling ([Error_Number], [Error_Message], [Error_Severity], [Error_State], [Error_Line],
[Error_Procedure], [UserName], [HostName], [Time_Stamp])
SELECT @Error_Number, @Error_Message, @Error_Severity, @Error_State, @Error_Line,
@Error_Procedure, @UserName, @HostName, @Time_Stamp
GO
--تست روال
BEGIN TRY
    SELECT 1/0
END TRY
BEGIN CATCH
    EXEC uspErrorHandling 
END CATCH
GO
--استخراج اطلاعات از جدول خطاها
SELECT * FROM ErrorHandling;
--------------------------------------------------------------------
--THROW  بررسی دستور 
GO
/*
THROW [ { error_number | @local_variable },
        { message | @local_variable },
        { state | @local_variable } ] 
[ ; ]
*/
GO
/*
begin try
-- The code where error has occurred.
end try
begin catch
-- throw error to the client
Throw;
end catch
*/
BEGIN TRY
  SELECT 'Using Throw'
  SELECT 1 / 0 
END TRY
BEGIN CATCH
  --Throw error
  THROW
END CATCH
GO
--*********************
USE tempdb;
GO
CREATE TABLE dbo.TestRethrow
(    ID INT PRIMARY KEY
);
BEGIN TRY
    INSERT dbo.TestRethrow(ID) VALUES(1);
--  Force error 2627, Violation of PRIMARY KEY constraint to be raised.
    INSERT dbo.TestRethrow(ID) VALUES(1);
END TRY
BEGIN CATCH

    PRINT 'In catch block.';
    THROW;
END CATCH;