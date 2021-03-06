USE [NEWMLM]
GO
/****** Object:  UserDefinedFunction [FnGeneral].[SplitValueInput]    Script Date: 5/12/2020 3:22:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [FnGeneral].[SplitValueInput]
(
    @i nVARCHAR(max),
	@param nVARCHAR(max)
)
RETURNS nVARCHAR(max)
AS
BEGIN
DECLARE 
    @value nVARCHAR(max)=N'', 
    @Amount   DECIMAL(18,3),
	@compute DECIMAL(18,3),
	@chek bit=0
 
DECLARE cursor_product CURSOR
FOR select 
value  

 from string_split(@param,',')
 where len(value)>0
OPEN cursor_product;
 
FETCH NEXT FROM cursor_product INTO 
    @Amount
 
WHILE @@FETCH_STATUS = 0
    BEGIN
if @chek=1
set
@value=@value+cast(case when CAST(@Amount AS DECIMAL(18,3))=0 then '' else ','+cast(@Amount as nvarchar(30)) end as nvarchar(20))

if @Amount>=CAST(@i AS DECIMAL(18,3)) and @chek=0
begin 
set @i=@Amount-CAST(@i AS DECIMAL(18,3))
set @chek=1
set
@value=@value+--CAST(case when CAST(@i AS DECIMAL(18,3))=0 then '' ELSE
 ','+@i --end AS nvarchar(20))
end 
else if @Amount<@i and @chek=0
begin
set @i=CAST(@i AS DECIMAL(18,3))-@Amount
set @value=@value+',0'
end

        FETCH NEXT FROM cursor_product INTO 
            @Amount
    END;
 
CLOSE cursor_product;
 
DEALLOCATE cursor_product;



return CAST(SUBSTRING(@value,2,len(@value)) AS nVARCHAR(max))

END




