sp_configure 'clr enabled',1
sp_configure 'clr strict security',0
reconfigure

go
CREATE ASSEMBLY PersianDates FROM 'C:\dump\PersianDate.dll'
WITH PERMISSION_SET=SAFE
go

SELECT * FROM sys.assembly_files
GO

CREATE FUNCTION dbo.GetPersian(@pDate datetime null)
RETURNS NVARCHAR(10)
AS
EXTERNAL NAME PersianDates.UserDefinedFunctions.PersianDate
go

SELECT dbo.GetPersian(GETDATE())

GO

