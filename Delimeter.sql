USE tempdb
GO
--SQL Server 2016
SELECT * FROM STRING_SPLIT('Masoud,Farid,AliReza',',')
GO
--------------------------------------------------------------------
DROP FUNCTION IF EXISTS dbo.StringSplit
GO
CREATE FUNCTION dbo.StringSplit
(
    @String  VARCHAR(MAX), @Separator CHAR(1)
)
RETURNS @RESULT TABLE(Value VARCHAR(MAX))
AS
BEGIN     
	DECLARE @SeparatorPosition INT = CHARINDEX(@Separator, @String ),
	@Value VARCHAR(MAX), @StartPosition INT = 1
 
	IF @SeparatorPosition = 0  
	BEGIN
		INSERT INTO @RESULT VALUES(@String)
		RETURN
	END
	SET @String = @String + @Separator
	WHILE @SeparatorPosition > 0
	BEGIN
		SET @Value = SUBSTRING(@String , @StartPosition, @SeparatorPosition- @StartPosition)
		IF( @Value <> ''  ) 
			INSERT INTO @RESULT VALUES(@Value)
		SET @StartPosition = @SeparatorPosition + 1
		SET @SeparatorPosition = CHARINDEX(@Separator, @String , @StartPosition)
	END    
	RETURN
END
GO
SELECT * FROM DBO.StringSplit('Masoud,Farid,AliReza',',')
GO
--------------------------------------------------------------------
DROP FUNCTION IF EXISTS dbo.StringSplitXML
GO
CREATE FUNCTION dbo.StringSplitXML
(
    @String  VARCHAR(MAX), @Separator CHAR(1)
)
RETURNS @RESULT TABLE(Value VARCHAR(MAX))
AS
BEGIN    
	DECLARE @XML XML
	SET @XML = CAST(('<i>' + REPLACE(@String, @Separator, '</i><i>') + '</i>')AS XML)
	INSERT INTO @RESULT
		SELECT t.i.value('.', 'VARCHAR(MAX)') FROM @XML.nodes('i') AS t(i)
			WHERE t.i.value('.', 'VARCHAR(MAX)') <> ''
	RETURN
END
GO
SELECT * FROM dbo.StringSplitXML('Masoud,Farid,AliReza',',')
GO
--------------------------------------------------------------------
--مقایسه
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO
SELECT * FROM STRING_SPLIT('Masoud,Farid,AliReza',',')
GO
SELECT * FROM DBO.StringSplit('Masoud,Farid,AliReza',',')
GO
SELECT * FROM dbo.StringSplitXML('Masoud,Farid,AliReza',',')
GO