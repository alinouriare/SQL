CREATE FUNCTION AB(@F NVARCHAR(20)='Ali',@L NVARCHAR(20)='Nouri')
RETURNS CHAR(4)
AS
BEGIN
	DECLARE @X CHAR(4)
	SET @X=LEFT(@F,1)+'.'+LEFT(@L,1)
	RETURN @X
END
GO

SELECT dbo.AB('REZA','ASAD')
SELECT DBO.AB(DEFAULT,DEFAULT)
GO

SELECT EmployeeID,FirstName,LastName,dbo.AB(FirstName,LastName) AS NIKNAME FROM Employees

GO

-----INLINE TABLE VLAUE

CREATE VIEW VIEW1
AS SELECT C.CompanyName,O.OrderDate,O.OrderID,C.Country FROM Customers C
JOIN Orders O 
ON C.CustomerID=O.CustomerID
GO

SELECT * FROM VIEW1 WHERE Country='UK'

GO

CREATE FUNCTION FN2(@X NVARCHAR(100))
 RETURNS TABLE
 AS
 RETURN 
 SELECT C.CompanyName,O.OrderDate,O.OrderID,C.Country FROM Customers C
JOIN Orders O 
ON C.CustomerID=O.CustomerID WHERE Country=@X
GO

SELECT * FROM FN2('UK')
GO

SELECT * FROM FN2('UK') JOIN [Order Details] OD
ON FN2.OrderID=OD.OrderID

GO
------MULTI STATMENT TABLE VALUE
CREATE FUNCTION FN3()
RETURNS @X TABLE (C1 INT,C2 NVARCHAR(20))
AS 
BEGIN

 INSERT INTO @X VALUES(1,'AA'),(2,'BB')
 RETURN
END

GO

SELECT * FROM FN3()

GO


--------------------------------------------------------------------
--Âœ› ÿ—«ÕÌ ê“«—‘Ì »Â ‘ﬂ· “Ì— „Ì »«‘œ
/*
COMPANY				ORDER COUNT			NEWEST ORDER
Romero y tomillo		5			    Apr  9 1998 12:00AM
ORDER_ID			ORDER DATE			EMPLOYEE_ID
10281			   	Aug 14 1996 12:00AM		4
10282				Aug 15 1996 12:00AM		4
10306				Sep 16 1996 12:00AM		1
10917				Mar  2 1998 12:00AM		4
11013				Apr  9 1998 12:00AM		2
----------			----------			----------
*/
GO

CREATE FUNCTION GetSummary(@CID CHAR(5))
RETURNS @MyTable TABLE(
Col1 VARCHAR(200),
Col2 VARCHAR(200),
Col3 VARCHAR(200)
)
AS
BEGIN 
IF NOT EXISTS (SELECT * FROM Customers WHERE CustomerID=@CID) RETURN

INSERT INTO @MyTable VALUES('COMPANY','ORDER COUNT','NEWEST ORDER') 

	DECLARE @Company VARCHAR(200)
	DECLARE @OCount INT
	DECLARE @NewOrder DATETIME

SET @Company=(SELECT CompanyName FROM Customers WHERE CustomerID=@CID)


SET @OCount=(SELECT COUNT(OrderID) FROM Orders WHERE CustomerID=@CID)

SET @NewOrder=(SELECT MAX(OrderDate) FROM Orders WHERE CustomerID=@CID)

INSERT INTO @MyTable VALUES(@Company,@OCount,@NewOrder) 

INSERT INTO @MyTable VALUES('ORDER_ID','ORDER DATE','EMPLOYEE_ID')

INSERT INTO @MyTable SELECT OrderID,OrderDate,EmployeeID FROM Orders WHERE CustomerID=@CID


	INSERT @MyTable VALUES
	('----------','----------','----------')
	RETURN

	END


GO
SELECT * FROM DBO.GetSummary('VINET')
UNION ALL
SELECT * FROM DBO.GetSummary('ALFKI')
GO

SELECT C.CompanyName,TEMP.* FROM Customers C
CROSS APPLY GetSummary(C.CustomerID) TEMP
WHERE C.Country='spain'

SELECT C.CompanyName,TEMP.* FROM Customers C
OUTER APPLY GetSummary(C.CustomerID) TEMP
WHERE C.Country='spain'