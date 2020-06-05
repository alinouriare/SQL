use Northwind
go
select (1+4) as 'Number'
go

select 'Name' as "AliNouri"
,Address as 'ad'
from Customers
go

select CustomerID as 'ID',City as '‘Â—' from Customers

DECLARE @MyVar INT=100 
SET @MyVar+=5 -- (Add EQUALS)
SET @MyVar-=5 -- (Subtract EQUALS)
SET @MyVar*=5 -- (Multiply EQUALS)
SET @MyVar/=5 -- (Divide EQUALS)
SET @MyVar%=5 -- (Modulo EQUALS)
SET @MyVar|=5 -- (Bitwise OR EQUALS)
SET @MyVar^=5 -- (Bitwise Exclusive OR EQUALS) 
SET @MyVar&=5 -- (Bitwise AND EQUALS)
*/
USE tempdb
GO
DECLARE @MyVar INT=100
SET @MyVar+=5 -- (Add EQUALS)
SELECT  @MyVar AS 'Add EQUALS'
SET @MyVar-=5 -- (Subtract EQUALS)
SELECT  @MyVar AS 'Subtract EQUALS'
SET @MyVar*=5 -- (Multiply EQUALS)
SELECT  @MyVar AS 'Multiply EQUALS'
SET @MyVar/=5 -- (Divide EQUALS)
SELECT  @MyVar AS 'Divide EQUALS'
SET @MyVar%=5 -- (Modulo EQUALS)
SELECT  @MyVar AS 'Modulo EQUALS'
SET @MyVar|=5 -- (Bitwise OR EQUALS)
SELECT  @MyVar AS 'Bitwise OR EQUALS'
SET @MyVar^=5 -- (Bitwise Exclusive OR EQUALS) 
SELECT  @MyVar AS 'Bitwise Exclusive OR EQUALS'
SET @MyVar&=5 -- (Bitwise AND EQUALS)
SELECT  @MyVar AS 'Bitwise AND EQUALS'
GO