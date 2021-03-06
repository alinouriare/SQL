
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [FnGeneral].[PersianToEn](@Date nchar(10))
RETURNS nvarchar(10)
AS
Begin
 
Declare @PERSIAN_EPOCH  as int
Declare @epbase as bigint
Declare @epyear as bigint
Declare @mdays as bigint
Declare @Jofst  as Numeric(18,2)
Declare @jdn bigint
Declare @iYear int =cast(substring(@Date,1,4)as  int)
Declare @iMonth int =cast(substring(@Date,6,2)as  int)
Declare @iDay int =cast(substring(@Date,9,2)as  int)
     
Set @PERSIAN_EPOCH=1948321
Set @Jofst=2415020.5
--IF  [FnGeneral].[IsDateValid](1,@iYear,@iMonth,@iDay)<>1 
--RETURN  'Error Date'
If @iYear>=0 
    Begin
        Set @epbase=@iyear-474 
    End
Else
    Begin
        Set @epbase = @iYear - 473 
    End
    set @epyear=474 + (@epbase%2820) 
If @iMonth<=7
    Begin
        Set @mdays=(Convert(bigint,(@iMonth) - 1) * 31)
    End
Else
    Begin
        Set @mdays=(Convert(bigint,(@iMonth) - 1) * 30+6)
    End
    Set @jdn =Convert(int,@iday) + @mdays+ Cast(((@epyear * 682) - 110) / 2816 as int)  + (@epyear - 1) * 365 + Cast(@epbase / 2820 as int) * 1029983 + (@PERSIAN_EPOCH - 1) 
  
    RETURN  Convert(nvarchar(11),Convert(datetime,(@jdn- @Jofst),131),120)
   
End



