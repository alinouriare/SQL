USE tempdb
GO
--بررسی جهت حذف جدول
DROP TABLE IF EXISTS Employees
GO
--ایجاد یک جدول جدید
CREATE TABLE Employees
(
	EmpID       INT PRIMARY KEY  NONCLUSTERED,
	EmpName     VARCHAR(20),
	HID         HierarchyID,
	EmpLevel    AS HID.GetLevel() PERSISTED
)
GO
--درج تعدادی رکورد تستی
--به نحوه درج دیتا در جدول دقت کنید
INSERT Employees (EmpID, EmpName, HID) VALUES
    (1, 'David', '/'),
    (2, 'Nancy', '/1/'),
    (3, 'Jason', '/2/'),
    (4, 'Sarah', '/1/1/'),
    (5, 'Peter', '/1/2/'),
    (6, 'Steve', '/1/3/'),
    (7, 'Sandra', '/1/2/1/'),
    (8, 'Bob', '/1/2/2/'),
    (9, 'John', '/2/1/'),
    (10, 'Rita', '/2/1/1/'),
    (11, 'Gabriel', '/2/1/2/'),
    (12, 'Emilia', '/2/1/1/1/'),
    (13, 'Michael', '/2/1/1/2/'),
    (14, 'Bill', '/2/1/1/3/')
GO
--دقت کنید ToString مشاهده رکوردهای موجود در جدول به متد 
--به صورت اسلش بوده و نودهای بعدی از چپ به راست شماره گرفته و آدرس رده بالاتر را دارندRoot
--
SELECT 
	EmpID, EmpName, 
	HID.ToString() AS HID_ToString, 
	HID AS HID, 
	EmpLevel 
FROM Employees

GO
--حرفه ای ترین قابلیت این ویژگی ایجاد ایندکس بر روی آن است
CREATE UNIQUE CLUSTERED INDEX IX_Depth_First ON Employees(HID)
GO
SELECT 
	EmpID, EmpName, 
	HID.ToString() AS HID_ToString, 
	HID AS HID, 
	EmpLevel 
FROM Employees

GO
--ساخت درخت
SELECT 
	EmpID, REPLICATE( ' | ' , EmpLevel)+EmpName, 
	HID.ToString() AS HID  
FROM Employees
ORDER BY 
	HID
GO
--Breadth_First ایجاد ایندکس
CREATE UNIQUE INDEX IX_Breadth_First ON Employees(EmpLevel, HID)
GO
--------------------------------------------------------------------
--بررسی تعدادی از متدهای این نوع دیتا تایپ
/*
GetLevel() : خروجی عددی دارد که موقعیت نود را در گره مشخص می کند
GetAncestor(n) :دارد که رده بالاتر یا جد مربوط به برای یک نود را بر می گرداند Hierarchy خروجی 
GetDescendant(Child1,Child2) :جدید هنگام درج نود جدید استفاده می شود Hierarchy دارد و برای تولید  Hierarchy خروجی 
IsDescendantOf(Node/HID) :فرزند نود مورد نظر می باشد HID خروجی بولین دارد و مشخص می کند که آیا یک  
--
Ancestor : جد
Descendant : اولاد
*/
DECLARE @Michael HierarchyID
DECLARE @John HierarchyID
DECLARE @Nancy HierarchyID

SET @Nancy='/1/'
SET @John='/2/1/'
SET @Michael='/2/1/1/2/'

SELECT 
    @Michael.GetLevel(),
    @Michael.GetAncestor(1).ToString(),   -- Father
    @Michael.GetAncestor(2).ToString(),   -- Grand Father (Returns John's HierarchyID)
    @Nancy.GetDescendant(NULL,NULL).ToString(),   -- Getting First Child
    @Nancy.GetDescendant('/1/1/',NULL).ToString(),-- If the First Child Exists
    @Nancy.GetDescendant('/1/1/','/1/2/').ToString(),-- Between Two Childs
    @Michael.IsDescendantOf(@John)   -- Check If Michael is Child of John
GO
--------------------------------------------------------------------
--بدست آوردن پدر های یک گره
--روش اول
DECLARE @EmpHID HIERARCHYID
SELECT @EmpHID = HID FROM Employees WHERE EmpName= 'Bill'
SELECT 
	EmpID, EmpName, 
	HID.ToString() AS HID_ToString, 
	EmpLevel,
	HID.GetAncestor(1)
FROM Employees
WHERE 
    @EmpHID.IsDescendantOf(HID) = 1
GO
--روش دوم
SELECT 
	M.empid, M.empname
FROM dbo.Employees AS M
INNER JOIN dbo.Employees AS E
	ON E.empid = 14AND E.hid.IsDescendantOf(M.hid) = 1
GO
--------------------------------------------------------------------
--بدست آوردن فرزند های یک گره
SELECT
	 E.empid, E.empname
FROM dbo.Employees AS M
INNER JOIN dbo.Employees AS E
ON M.empid = 2 AND E.hid.GetAncestor(1) = M.hid;
GO
--بدست آوردن گره هایی که فرزند ندارند
SELECT empid, empname
FROM dbo.Employees AS M
WHERE NOT EXISTS
(SELECT * FROM dbo.Employees AS E
WHERE E.hid.GetAncestor(1) = M.hid);
GO

SELECT REPLICATE(' | ', EmpLevel) + empname AS empname, hid.ToString() AS path
FROM dbo.Employees
ORDER BY hid;