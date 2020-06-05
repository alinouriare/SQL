CREATE ASSEMBLY PersianSQLFunctions

FROM 'c:\DUMP\PersianSQLFunctions.dll'

GO

CREATE FUNCTION ToPersianDateTime

(

@dt DateTime

)

RETURNS NVARCHAR(19)

AS EXTERNAL NAME  PersianSQLFunctions.UserDefinedFunctions.ToPersianDateTime

GO

CREATE FUNCTION ToPersianDate

(

@dt DateTime

)

RETURNS NVARCHAR(10)

AS EXTERNAL NAME PersianSQLFunctions.UserDefinedFunctions.ToPersianDate


SELECT dbo.ToPersianDate(GETDATE())

GO
----------------------------------
