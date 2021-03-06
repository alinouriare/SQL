
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Function [FnGeneral].[UDF_Gregorian_To_Persian] (@date datetime)
Returns nvarchar(50)
as
Begin
    Declare @depoch as bigint
    Declare @cycle  as bigint
    Declare @cyear  as bigint
    Declare @ycycle as bigint
    Declare @aux1 as bigint
    Declare @aux2 as bigint
    Declare @yday as bigint
    Declare @Jofst  as Numeric(18,2)
    Declare @jdn bigint
 
    Declare @iYear   As Integer
    Declare @iMonth  As Integer
    Declare @iDay    As Integer
 set  @date=(cast(cast(@date as date)as varchar(20)))
    Set @Jofst=2415020.5
    Set @jdn=Round(Cast(@date as int)+ @Jofst,0)
 
    Set @depoch = @jdn - [FnGeneral].[UDF_Persian_To_Julian](475, 1, 1) 
    Set @cycle = Cast(@depoch / 1029983 as int) 
    Set @cyear = @depoch%1029983 
 
    If @cyear = 1029982
       Begin
         Set @ycycle = 2820 
       End
    Else
       Begin
        Set @aux1 = Cast(@cyear / 366 as int) 
        Set @aux2 = @cyear%366 
        Set @ycycle = Cast(((2134 * @aux1) + (2816 * @aux2) + 2815) / 1028522 as int) + @aux1 + 1 
      End
 
    Set @iYear = @ycycle + (2820 * @cycle) + 474 
 
    If @iYear <= 0
      Begin 
        Set @iYear = @iYear - 1 
      End
    Set @yday = (@jdn - [FnGeneral].[UDF_Persian_To_Julian](@iYear, 1, 1)) + 1 
    If @yday <= 186 
       Begin
         Set @iMonth = CEILING(Convert(Numeric(18,4),@yday) / 31) 
       End
    Else
       Begin
          Set @iMonth = CEILING((Convert(Numeric(18,4),@yday) - 6) / 30)  
       End
       Set @iDay = (@jdn - [FnGeneral].[UDF_Persian_To_Julian](@iYear, @iMonth, 1)) + 1 
 
      Return format(CAST(@iYear as INT),'0000')+ '/' +format(CAST(@iMonth as INT),'00') +'/' +format(cast(@iDay as INT),'00') 
End
 
