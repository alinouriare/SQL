use AdventureWorks2014
GO
SELECT EmployeeID,VendorID,COUNT(PurchaseOrderID) AS CO
FROM Purchasing.PurchaseOrderHeader
GROUP BY EmployeeID,VendorID
ORDER BY EmployeeID,VendorID
GO
--Cross Tab نمایش گزارش به صورت 
--روش اول
SELECT 
	VendorID,
	SUM(CASE WHEN EmployeeID=250 THEN 1 ELSE 0 END) AS Emp_250,
	SUM(CASE WHEN EmployeeID=251 THEN 1 ELSE 0 END) AS Emp_251,
	SUM(CASE WHEN EmployeeID=256 THEN 1 ELSE 0 END) AS Emp_256,
	SUM(CASE WHEN EmployeeID=257 THEN 1 ELSE 0 END) AS Emp_257,
	SUM(CASE WHEN EmployeeID=260 THEN 1 ELSE 0 END) AS Emp_260
FROM Purchasing.PurchaseOrderHeader 
WHERE EmployeeID IN (250,251,256,257,260)
GROUP BY VendorID
ORDER BY VendorID
GO
--Cross Tab نمایش گزارش به صورت 
--روش دوم
SELECT DISTINCT VendorID
	,(SELECT Count(EmployeeID)FROM Purchasing.PurchaseOrderHeader P2 WHERE  P2.VendorID=P1.VendorID AND P2.EmployeeID=250) AS Emp_250
	,(SELECT Count(EmployeeID)FROM Purchasing.PurchaseOrderHeader P2 WHERE  P2.VendorID=P1.VendorID AND P2.EmployeeID=251) AS Emp_251
	,(SELECT Count(EmployeeID)FROM Purchasing.PurchaseOrderHeader P2 WHERE  P2.VendorID=P1.VendorID AND P2.EmployeeID=256) AS Emp_256
	,(SELECT Count(EmployeeID)FROM Purchasing.PurchaseOrderHeader P2 WHERE  P2.VendorID=P1.VendorID AND P2.EmployeeID=257) AS Emp_257
	,(SELECT Count(EmployeeID)FROM Purchasing.PurchaseOrderHeader P2 WHERE  P2.VendorID=P1.VendorID AND P2.EmployeeID=260) AS Emp_260
FROM Purchasing.PurchaseOrderHeader P1
GO
--شکل کلی دستور 

--SELECT 
--	Field1,Field2
--From
--	(
--		Table_Source
--	) Table_Alias
--PIVOT 
--	(
--		Aggregate_Function(Value_Column)
--		For Pivot_Column
--		IN()
--	) Pivot_Alias
*/
GO

/*
--Pivot مراحل ایجاد یک 

1-Aggregation Column تنظیم 
انجام شود Aggregation فیلدی که قرار است بر روی آن عملیات 
-----
2-Pivot Column تنظیم 
فیلدی که قرار است عملیات چرخش بر روی آن انجام شود
 نوشته می شودFor این فیلد در جلوی عبارت 
-----
3- تنظیم لیستی که قرار است گزارش بر اساس آن تهیه شود 
نوشته می شود IN این فیلدها در جلوی عبارت 
-----
SELECT * FROM sale
PIVOT
(SUM (amount) FOR quarter
IN ([spring],[summer],[autumn],[winter]))pTabl
*/

GO


SELECT VendorID,
[250] AS EMP_250,
[251] AS EMP_251,
[256] AS EMP_256,
[257] AS EMP_257,
[260] AS EMP_260
FROM
(
SELECT PurchaseOrderID,EmployeeID,VendorID 
FROM Purchasing.PurchaseOrderHeader
)P
PIVOT
(
COUNT(PurchaseOrderID)
FOR EmployeeID IN
([250],[251],[256],[257],[260])

)AS PVT
ORDER BY PVT.VendorID

--چگونه به شكل دايناميك ستون ها را ايجاد نماييم
GO
--به کوئری زیر توجه کنید
DECLARE @X NVARCHAR(MAX)
SET @X=''
SELECT @X=+@X+'['+CAST(EmployeeID AS VARCHAR(50))+'],' FROM  Purchasing.PurchaseOrderHeader GROUP BY EmployeeID
PRINT @X
SET @X =LEFT(@X,LEN(@X)-1) --حذف كاما آخر
PRINT @X
GO
-------------------
--Exec معرفی دستور 
EXEC ('SELECT 1+2')
GO
EXEC('SELECT * FROM  Purchasing.PurchaseOrderHeader')
GO
DECLARE @X NVARCHAR(MAX)
SET @X=''
SELECT @X=@X+CAST(EmployeeID AS VARCHAR(50))+',' FROM  Purchasing.PurchaseOrderHeader GROUP BY EmployeeID
SET @X =LEFT(@X,LEN(@X)-1) --حذف كاما آخر
EXEC('SELECT * FROM  HumanResources.Employee WHERE BusinessEntityID IN (' + @X + ')')
PRINT ('SELECT * FROM  HumanResources.Employee WHERE BusinessEntityID IN (' + @X + ')')
GO
-------------------
DECLARE @X NVARCHAR(MAX)
DECLARE @Cmd NVARCHAR(MAX)
SET @X=''
SELECT @X=+@X+'['+CAST(EmployeeID AS VARCHAR(50))+'],' FROM  Purchasing.PurchaseOrderHeader GROUP BY EmployeeID
SET @X =LEFT(@X,LEN(@X)-1) --حذف كاما آخر
SET @Cmd=
'SELECT 
	*
FROM 
	(
		SELECT 
			PurchaseOrderID, EmployeeID, VendorID
		FROM Purchasing.PurchaseOrderHeader
	) P
PIVOT
	(
		COUNT (PurchaseOrderID)
		FOR EmployeeID 
		IN
		(' 
			+@X+
		')
	) AS PVT
ORDER BY PVT.VendorID'
EXEC (@Cmd)
PRINT @Cmd
GO
--------------------------------------------------------------------
--Unpivot استفاده از  
GO
USE tempdb
GO
IF OBJECT_ID('pvt')>0
	DROP TABLE pvt 
GO
CREATE TABLE pvt 
(
	VendorID int, Emp1 int, Emp2 int,
    Emp3 int, Emp4 int, Emp5 int
)
GO
INSERT INTO pvt VALUES (1,4,3,5,4,4);
INSERT INTO pvt VALUES (2,4,1,5,5,5);
INSERT INTO pvt VALUES (3,4,3,5,4,4);
INSERT INTO pvt VALUES (4,4,2,5,5,4);
INSERT INTO pvt VALUES (5,5,1,5,5,5);
GO
SELECT * FROM pvt
GO
--Unpivot the table.
SELECT 
	VendorID, Employee, Orders
FROM 
	(
		SELECT 
			VendorID, Emp1, Emp2, Emp3, Emp4, Emp5
		FROM pvt
	) p
UNPIVOT
	(
		Orders FOR Employee 
		IN 
		(
			Emp1, Emp2, 
			Emp3, Emp4, Emp5
		)
	)AS unpvt
GO

