--Attribute Centric بررسی  
DECLARE @X XML='<Person FirstName="Ali" LastName="Nouri" />'

SELECT @X

--Element Centric بررسی 
DECLARE @X XML ='
<Person>
<FirstName>Ali</FirstName>
<LastName>Nouri</LastName>
</Person>
'
SELECT @X

GO

--است XML Parser یک  SSMS محیط 
DECLARE @X XML='
<PersonInfo>
<Person FirstName="Ali" LastName="Nouri" />
<Person FirstName="reza" LastName="Nouri" />
<Person FirstName="hasan" LastName="Nouri" />
</PersonInfo>
'

SELECT @X
GO
CREATE DATABASE XMLTEST
GO
USE XMLTEST
GO

CREATE TABLE XML_Test
(
ID INT PRIMARY KEY,
XML_Data XML
)
GO

INSERT INTO XML_Test VALUES(1,
'
<PersonInfo>
<Person FirstName="Ali" LastName="Nouri" />
<Person FirstName="reza" LastName="Nouri" />
<Person FirstName="hasan" LastName="Nouri" />
</PersonInfo>
'
)


INSERT INTO XML_Test VALUES(2,
'
<PersonInfo>
<Person FirstName="AMIR" LastName="Nouri" />
<Person FirstName="REZA" LastName="AKABRI" />
<Person FirstName="HASAN" LastName="BEGI" />
</PersonInfo>
'
)
GO

INSERT INTO XML_Test VALUES(4,
'

<Person FirstName="AA" LastName="AA" />

'
)
GO

INSERT INTO XML_Test VALUES(3,
NULL
)

SELECT * FROM XML_Test
GO

--------------------------------------------------------------------
--XML محدودیت های فیلدهای 
--Null امکان مقایسه مستقیم وجود ندارد مگر با 
SELECT * FROM XML_Test
	WHERE XML_Data='<Person FirstName="Ahmad" LastName="Ghafari" />'
GO
SELECT * FROM XML_Test
	WHERE cast (XML_Data as nvarchar(max))=N'<Person FirstName="Ahmad" LastName="Ghafari" />'
GO
SELECT * FROM XML_Test
	WHERE XML_Data IS NULL
GO
---------------------------
--بر روی این فیلدها پشتیبانی نمی شودGroup By,Order By 
SELECT * FROM XML_Test
	ORDER BY XML_Data
---------------------------
--Unique Index عدم انتخاب به عنوان فیلد کلید و همچنین فیلد برای   
CREATE UNIQUE INDEX IX_XML ON XML_Test(XML_Data)
CREATE INDEX IX_XML ON XML_Test(XML_Data)
GO
---------------------------
--Collationعدم تنظیم 
USE tempdb
GO
IF OBJECT_ID('XML_Test')>0
	DROP TABLE XML_Test
GO
CREATE TABLE XML_Test
(
	ID INT PRIMARY KEY,
	TestChar NVARCHAR(100) COLLATE PERSIAN_100_CI_AI,
	XML_Data XML COLLATE PERSIAN_100_CI_AI
)
GO
--------------------------------------------------------------------
CREATE XML SCHEMA COLLECTION Employee_Schema as
'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Employee" >
   <xsd:complexType>
     <xsd:sequence> 
        <xsd:element name="FirstName" type="xsd:string" /> 
        <xsd:element name="LastName" type="xsd:string" />
     </xsd:sequence>
        <xsd:attribute name="EmployeeID" type="xsd:integer" />
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'
go

SELECT * FROM sys.xml_schema_collections
SELECT * FROM sys.xml_schema_elements

CREATE TABLE Employee_Test
(
ID INT PRIMARY KEY,
XML_Data XML (DOCUMENT Employee_Schema)
)
GO

--درج دیتا در جدول
INSERT Employee_Test(ID,XML_Data) VALUES
	(	
		1,
		'<Employee EmployeeID="1">
			<FirstName>Ali</FirstName>
			<LastName>Nouri</LastName>
		</Employee>'
	)
GO
INSERT Employee_Test(ID,XML_Data) VALUES
	(	
		2,
		'<Employee EmployeeID="2">
			<FirstName>ali</FirstName>
			<LastName>nouri</LastName>
		</Employee>'
	)
GO
SELECT * FROM Employee_Test
GO
--درج مقداری مخالف با اسکیما
GO
INSERT Employee_Test(ID,XML_Data) VALUES
	(	
		3,
		'<Employee EmployeeID="3A">
			<FirstName>aa</FirstName>
			<LastName>aa</LastName>
		</Employee>'
	)
GO
INSERT Employee_Test(ID,XML_Data) VALUES
	(	
		3,
		'<Employee EmployeeID="3">
			<FirstName>ss</FirstName>
		</Employee>'
	)
GO
INSERT Employee_Test(ID,XML_Data) VALUES
	(	
		3,
		'<Employee>
			<EmployeeID>"3"</EmployeeID>
			<FirstName>ali</FirstName>
			<LastName>nouri</LastName>
		</Employee>'
	)
GO
--مشاهده رکوردهای موجود در جدول
SELECT * FROM Employee_Test
GO

--نحوه استفاده از اسکیما در متغییرها

DECLARE @X XML (Document Employee_Schema )
SET @X='<Employee EmployeeID="1">
			<FirstName>QQ</FirstName>
			<LastName>QQ</LastName>
		</Employee>'
		SELECT @X
		----------

		DECLARE @X XML (Document Employee_Schema )
SET @X='<Employee EmployeeID="1">
			<FirstName>QQ</FirstName>
		</Employee>'
		SELECT @X

GO

 ---------------------------
--حذف اسکیما
IF EXISTS(SELECT TOP 1 * FROM SYS.XML_SCHEMA_COLLECTIONS WHERE name='Employee_Schema')
BEGIN
	DROP TABLE Test_Employees
	DROP XML SCHEMA COLLECTION Employee_Schema
END
GO
--------------------------------------------------------------------
--های درباره اسکیماDMV  
--XSD بدست آوردن اطلاعاتی درباره
SELECT * FROM sys.xml_schema_collections
SELECT * FROM sys.xml_schema_namespaces
SELECT * FROM sys.xml_schema_elements
SELECT * FROM sys.xml_schema_attributes
SELECT * FROM sys.xml_schema_types
SELECT * FROM sys.column_xml_schema_collection_usages
SELECT * FROM sys.parameter_xml_schema_collection_usages
--------------------------------------------------------------------
--XML بارگذاری دیتاها از فایل 
SELECT * FROM OPENROWSET
(BULK 'C:\dump\BulkLoad.xml',SINGLE_CLOB) AS S

GO
DECLARE @X XML

SELECT @X=BulkColumn FROM OPENROWSET
(BULK 'C:\dump\BulkLoad.xml',SINGLE_CLOB) AS X 

SELECT @X
GO

CREATE TABLE Test_Employee(
ID INT IDENTITY PRIMARY KEY,
XML_Data XML

)
GO

INSERT INTO Test_Employee (XML_Data)
SELECT BulkColumn FROM OPENROWSET
(BULK 'C:\dump\BulkLoad.xml',SINGLE_CLOB) AS X
GO

SELECT * FROM Test_Employee
GO

--XML هدف تبدیل داده های رابطه ای به قالب 
USE Northwind
--FOR XML RAW (Attribute Centric)
--نمی باشد Root Element است چون دارایFragment خروجی
--است Row هر ردیف دارای المان

SELECT CustomerID,CompanyName,Country FROM Customers
WHERE Country='Germany'
FOR XML RAW
---------------------------
--FOR XML RAW (Attribute Centric)
--Root Element ایجاد

SELECT CustomerID,CompanyName,Country FROM Customers
WHERE Country='Germany'
FOR XML RAW, ROOT('Customer_Root')

---------------------------
--FOR XML AUTO (Attribute Centric)

SELECT CustomerID,CompanyName,Country FROM Customers
WHERE Country='Germany'
FOR XML AUTO

GO


---------------------------
--FOR XML AUTO (Attribute Centric)
--Root Element ایجاد

SELECT CustomerID,CompanyName,Country FROM Customers
WHERE Country='Germany'
FOR XML AUTO,ROOT('ROOT_Customer')

GO
---------------------------
--FOR XML RAW (Element Centric)
--Root Element ایجاد

SELECT CustomerID,CompanyName,Country FROM Customers
WHERE Country='Germany'
FOR XML  RAW,ELEMENTS,ROOT('Customers_Root')

--FOR XML AUTO (Element Centric)
--Root Element ایجاد
SELECT 
	CustomerID,CompanyName,Country
FROM Customers 
	WHERE Country='Germany'
FOR XML AUTO,ELEMENTS,ROOT('Customers_Root')
GO
---------------------------
--FOR XML AUTO (Attribute Centric ** With Binary Values. Only a reference appears)
--Root Element ایجاد
SELECT 
	EmployeeID,FirstName,LastName,Photo
FROM Employees 
FOR XML AUTO,ROOT('Employees_Root')
GO
--FOR XML AUTO (Attribute Centric ** With Binary Values(BINARY BASE64))
--Root Element ایجاد
SELECT EmployeeID,FirstName,LastName,Photo FROM Employees
FOR XML AUTO,BINARY BASE64 ,ROOT('EMPLOYEE')
GO

--FOR XML AUTO (Attribute Centric ** With Alias)
--Root Element ایجاد
SELECT 
	EmployeeID AS EmpID,FirstName AS FName,LastName
FROM Employees 
FOR XML AUTO,ROOT('Employees_Root')
GO
---------------------------
--FOR XML PATH (Element Centric)
--XML اعمال کنترل کامل بر روی تعداد سطح ساختار 

SELECT EmployeeID,FirstName,LastName FROM Employees
FOR XML PATH
GO

SELECT EmployeeID,FirstName,LastName FROM Employees
FOR XML PATH('Employee'),ROOT('Employee_Root')
GO
SELECT EmployeeID,FirstName,LastName FROM Employees
FOR XML PATH(''),ROOT('Employee_Root')
GO
---------------------------
--FOR XML PATH (Attribute Centric & Element Centric ** If you use @ sign for a column, it appears as Attribute)

SELECT EmployeeID AS "@EMP",FirstName AS "@FNAM" ,LastName FROM Employees
FOR XML PATH('Employee'),ROOT('EMP')
--------------

SELECT CustomerID AS "@ID",CompanyName AS "@COMPANY"
,Country AS "Location/Country",
City AS "Location/Country"

FROM Customers

FOR XML PATH ,ROOT('Customer')

-------------------
SELECT O.OrderID AS "@OrderID",O.CustomerID AS "@CustomerId",
o.EmployeeID as "@EmployeeID" ,o.OrderDate AS "@OrderDate"
,(SELECT OD.ProductID AS "@ProductID",
			OD.Quantity AS "@Quantity",
			OD.UnitPrice AS "@UnitPrice",
			OD.Discount AS "@Discount" FROM [Order Details] OD WHERE OD.OrderID=O.OrderID FOR XML PATH('OrderDetilas'),TYPE ) 
FROM Orders O FOR XML PATH('Orders'),ROOT('COOOL')

GO
--FOR XML XMLSCHEMA
--XSD برگرداندن

SELECT EmployeeID,FirstName,LastName FROM Employees
FOR XML AUTO,XMLSCHEMA

--به قالب رابطه ایXML تبدیل داده 
--	Using XML.exist

CREATE TABLE Test_Exist
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO

INSERT INTO Test_Exist VALUES (
'<Employee EmployeeID="1">
	  <Name>
		<FirstName>Ali</FirstName>
		<LastName>Nouri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)

INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="2">
	  <Name>
		<FirstName>AliReza</FirstName>
		<LastName>Nouri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="3">
	  <Name>
		<FirstName>Janet</FirstName>
		<LastName>Leverling</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
		<City>Kirkland</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES (NULL)
go

SELECT * FROM Test_Exist

go

--------------------------------------------------------------------
--	Using XML.exist
--	Syntax: exist (XQuery)
--به منظور کنترل وجود نودهاXQuery امکان اجرای عبارت های
--است Bit دریافت می کند و خروجی آن از نوع XPath/این متد یک آدرس
--Show Execution Plan

--مقدارش برابر 1 استEmployeeID با نام Attribute آیا Employee در المنت
SELECT ID, XML_Data.exist('Employee[@EmployeeID="1"]') FROM Test_Exist
go
SELECT * FROM Test_Exist
WHERE XML_Data.exist('Employee[@EmployeeID="1"]')=1
go

SELECT ID, XML_Data.exist('Employee/Name[FirstName="Janet"]') FROM Test_Exist
GO
SELECT ID, XML_Data.exist('Employee/Location[City="Miyaneh"]') FROM Test_Exist

--مقایسه پلن اجرایی
--XML Reader 1 : انتخاب
--XML Reader 2 : فیلتر
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('Employee[@EmployeeID="1"]')=1
GO
--برای پردازش استفاده کنXML Reader دات یعنی زیاد پردازش نکن و از همین 
SELECT * FROM Test_Exist
WHERE XML_Data.exist('(/Employee/@EmployeeID)[.= "1"]') = 1
GO
SELECT * FROM Test_Exist
WHERE XML_Data.exist('(/Employee/@EmployeeID)[1][.= "1"]') = 1
--بالاتر از سایر متدها است Exists کارایی متد 

---------------------------------Exist نمونه ای از کاربرد 
go
CREATE FUNCTION dbo.CheckXMLData_Exist(@data XML) RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
 RETURN @data.exist('/Employee/Name/FirstName') --/Employee/Name/FirstName بررسی وجود نود
END
GO
CREATE TABLE TestTable_Exist(
Id INT IDENTITY PRIMARY KEY,
XML_Data XML CHECK(dbo.CheckXMLData_Exist(XML_Data)=1)

)
GO

INSERT INTO TestTable_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO TestTable_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="5">
	  <Name>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
--انجام داد XSD نکته : می توان اینکار را با 
------------VALUE
GO
CREATE TABLE Test_Value
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO
INSERT INTO Test_Value(XML_Data) VALUES
(
	'<Employee EmployeeID="1">
	  <Name>
		<FirstName>ALI</FirstName>
		<LastName>Nori</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Value(XML_Data) VALUES
(
	'<Employee EmployeeID="2">
	  <Name>
		<FirstName>AliReza</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Value(XML_Data) VALUES
(
	'<Employee EmployeeID="3">
	  <Name>
		<FirstName>Janet</FirstName>
		<LastName>Leverling</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
		<City>Kirkland</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Value(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Value(XML_Data) VALUES (NULL)
GO
SELECT * FROM Test_Value
GO


--استخراج اطلاعات از المنت ها و ساب المنت ها
SELECT ID, XML_Data.value('Employee[1]/Name[1]/FirstName[1]','varchar(50)') FROM Test_Value
GO
SELECT ID, XML_Data.value('Employee[1]/@EmployeeID','int') FROM Test_Value
GO
--Singleton Error
--varchar(50) حروف کوچیک باشه
--مشخص کردن شماره المنت اجباری است
SELECT ID, XML_Data.value('Employee/Name[1]/FirstName[1]','varchar(50)') FROM Test_Value
GO
SELECT * FROM Test_Value
	 WHERE XML_Data.value('Employee[1]/Name[1]/FirstName[1]','varchar(50)') ='masoud'
GO
SELECT * FROM Test_Value
	 WHERE XML_Data.value('Employee[1]/@EmployeeID','int')=3
GO
SELECT 
	ID,
	XML_Data.value('Employee[1]/@EmployeeID','int') AS EmployeeID,
	XML_Data.value('Employee[1]/Name[1]/FirstName[1]','varchar(50)') AS FirstName,
	XML_Data.value('Employee[1]/Name[1]/LastName[1]','varchar(50)') AS LastName,
	XML_Data.value('Employee[1]/Location[1]/Country[1]','varchar(50)') AS Country,
	XML_Data.value('Employee[1]/Location[1]/City[1]','varchar(50)') AS City
FROM Test_Value
GO
----------

CREATE FUNCTION dbo.CheckXMLData_Value(@data XML) RETURNS INT
WITH SCHEMABINDING 
AS
BEGIN
RETURN @data.value('Employee[1]/@EmployeeID','int') --Employee[1]/@EmployeeID استخراج مقدار
END
GO

CREATE TABLE TE_VALUE(
ID INT IDENTITY PRIMARY KEY,
XML_DATA XML CHECK(dbo.CheckXMLData_Value(XML_DATA)>100)
)
INSERT INTO TE_VALUE(XML_Data) VALUES
(
	'<Employee EmployeeID="101">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO TE_VALUE(XML_Data) VALUES
(
	'<Employee EmployeeID="5">
	  <Name>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
--انجام داد XSD نکته : می توان اینکار را با 
--	Using XML.query
--تحویل می دهد XML را به عنوان ورودی دریافت کرده و به عنوان خروجی یک XQuery یا XPath یک 
USE TempDB
GO
--ایجاد جدول تستی و درج تعدادی رکورد به صورت تستی
IF OBJECT_ID('Test_Query')>0
	DROP TABLE Test_Query
GO
CREATE TABLE Test_Query
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO
INSERT INTO Test_Query(XML_Data) VALUES
(
	'<Employee EmployeeID="1">
	  <Name>
		<FirstName>ALI</FirstName>
		<LastName>NOURI</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Query(XML_Data) VALUES
(
	'<Employee EmployeeID="2">
	  <Name>
		<FirstName>AliReza</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Query(XML_Data) VALUES
(
	'<Employee EmployeeID="3">
	  <Name>
		<FirstName>Janet</FirstName>
		<LastName>Leverling</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
		<City>Kirkland</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Query(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Query(XML_Data) VALUES (NULL)
GO
SELECT * FROM Test_Query
GO

--------------------------------------------------------------------
--Syntax: value (XQuery, SQLType)
--Show Execution Plan
USE tempdb
GO
--استخراج اطلاعات از المنت ها و ساب المنت ها
SELECT ID, XML_Data.query('Employee') FROM Test_Query
GO
SELECT ID, XML_Data.query('Employee/Name') FROM Test_Query
GO
SELECT ID, XML_Data.query('Employee/Name/LastName') FROM Test_Query
GO
INSERT INTO Test_Query(XML_Data) VALUES
(
	'<Employee EmployeeID="100">
		  <Name>
			<FirstName>Nancy</FirstName>
			<LastName>Davolio</LastName>
		  </Name>
		  <Location>
			<Country>USA</Country>
			<City>Seattle</City>
		  </Location>
		</Employee>

		<Employee EmployeeID="200">
		  <Name>
			<FirstName>Andrew</FirstName>
			<LastName>Fuller</LastName>
		  </Name>
		  <Location>
			<Country>USA</Country>
			<City>Tacoma</City>
		  </Location>
		</Employee>

		<Employee EmployeeID="300">
		  <Name>
			<FirstName>Janet</FirstName>
			<LastName>Leverling</LastName>
		  </Name>
		  <Location>
			<Country>USA</Country>
			<City>Kirkland</City>
		  </Location>
		</Employee>'
)
GO
SELECT * FROM Test_Query
GO
--هر چی دارد نمایش بده * به المنت خاصی اشاره نمی شود
SELECT ID, XML_Data.query('.') FROM Test_Query
GO
--به این ور را نشون بده Employee از المنت 
SELECT ID, XML_Data.query('Employee') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee/Name') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee/Location') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee/Location/City') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee[1]') FROM Test_Query --باز گرداندن از روی شماره سینگل تون
GO
SELECT ID, XML_Data.query('/Employee[2]') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee[3]') FROM Test_Query
GO
SELECT ID, XML_Data.query('/Employee[5]') FROM Test_Query
GO
--XQUERY 
--------------------------------------------------------------------
USE tempdb
GO
--هر دو کوئری یکسان هستند
SELECT ID, XML_Data.query('Employee') FROM Test_Query
GO
--Xquery قسمت های مربوط به یک عبارت
--FLOWR For Let Orderby Where Return
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee return $a')
 FROM Test_Query
GO
--استفاده از حالت های پیشرفته
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee where $a/@EmployeeID="2" return $a')
 FROM Test_Query
GO
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee where $a/@EmployeeID="200" return $a') --Attribute @EmployeeID
 FROM Test_Query
GO
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee where $a/Location/City="Miyaneh" return $a')
 FROM Test_Query
GO
--این کوئری با رکوردهای پایینی نتیجه یکسانی دارد
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee where $a/Location/City="Miyaneh" return $a')
 FROM Test_Query
GO
--این کوئری با رکوردهای بالایی نتیجه یکسانی دارد
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee/Location where $a/City="Miyaneh" return $a')
 FROM Test_Query
GO
--مرتب سازی
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee/Name order by $a/FirstName[1] ascending return $a')
 FROM Test_Query
GO
--بازیابی از لوکیشن و لوکیشن به قبل
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee/Location where $a/City="Miyaneh" return $a/..') 
 FROM Test_Query
GO
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee/Location where $a/City="Miyaneh" return $a/../Name') --بازیابی از لوکیشن و لوکیشن به قبل
 FROM Test_Query
GO
--Rootایجاد 
SELECT 
	ID, 
	XML_Data.query ('for $a in /Employee/Location where $a/City="Miyaneh" return <Root>{$a}</Root>') 
 FROM Test_Query
GO
-	Using XML.Node
USE TempDB
GO
--ایجاد جدول تستی و درج تعدادی رکورد به صورت تستی
IF OBJECT_ID('Test_Node')>0
	DROP TABLE Test_Node
GO
CREATE TABLE Test_Node
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO
INSERT INTO Test_Node(XML_Data) VALUES
(
	'<Order OrderID="10250" CustomerID="HANAR">
	  <Destination ToCountry="Brazil" ToCity="Rio de Janeiro" />
	  <RegisteredBy>4</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-07-08T00:00:00</OrderDate>
		<RequiredDate>1996-08-05T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>

	<Order OrderID="10251" CustomerID="VICTE">
	  <Destination ToCountry="France" ToCity="Lyon" />
	  <RegisteredBy>3</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-07-08T00:00:00</OrderDate>
		<RequiredDate>1996-08-05T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>

	<Order OrderID="10255" CustomerID="RICSU">
	  <Destination ToCountry="Switzerland" ToCity="Genève" />
	  <RegisteredBy>9</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-07-12T00:00:00</OrderDate>
		<RequiredDate>1996-08-09T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>

	<Order OrderID="10253" CustomerID="HANAR">
	  <Destination ToCountry="Brazil" ToCity="Rio de Janeiro" />
	  <RegisteredBy>3</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-07-10T00:00:00</OrderDate>
		<RequiredDate>1996-07-24T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>'
)
GO
INSERT INTO Test_Node(XML_Data) VALUES
(
	'<Order OrderID="10369" CustomerID="SPLIR">
	  <Destination ToCountry="USA" ToShipCity="Lander" />
	  <RegisteredBy>8</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-12-02T00:00:00</OrderDate>
		<RequiredDate>1996-12-30T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>
	<Order OrderID="10370" CustomerID="CHOPS">
	  <Destination ToCountry="Switzerland" ToShipCity="Bern" />
	  <RegisteredBy>6</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-12-03T00:00:00</OrderDate>
		<RequiredDate>1996-12-31T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>
	<Order OrderID="10371" CustomerID="LAMAI">
	  <Destination ToCountry="France" ToShipCity="Toulouse" />
	  <RegisteredBy>1</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-12-03T00:00:00</OrderDate>
		<RequiredDate>1996-12-31T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>
	<Order OrderID="10372" CustomerID="QUEEN">
	  <Destination ToCountry="Brazil" ToShipCity="Sao Paulo" />
	  <RegisteredBy>5</RegisteredBy>
	  <DateInfo>
		<OrderDate>1996-12-04T00:00:00</OrderDate>
		<RequiredDate>1997-01-01T00:00:00</RequiredDate>
	  </DateInfo>
	</Order>'
)
GO
SELECT * FROM Test_Node
GO
--------------------------------------------------------------------
--	Using XML.node
--	Syntax: node (XPath)
--های کوچکتر تقسیم می کندDocument مورد نیاز به Path را بر حسب XML این متد محتویات 
--Show Execution Plan
USE tempdb
GO
DECLARE @MyVar XML
SELECT @MyVar=XML_Data FROM Test_Node
	WHERE ID=1
SELECT @MyVar.query ('for $a in /Order return $a')
GO
--تقسیم محتویات به داکیوممنت های کوچکتر
DECLARE @MyVar XML
SELECT @MyVar=XML_Data FROM Test_Node
	WHERE ID=1
--Error! we HAVE TO use one of the methods of XML type
--SELECT * FROM @MyVar.nodes('Order') MyAlias(ColName)
SELECT ColName.query('.') FROM @MyVar.nodes('Order') MyAlias(ColName)--TVF خروجی یک 
GO
DECLARE @MyVar XML
SELECT @MyVar=XML_Data FROM Test_Node
	WHERE ID=1
SELECT ColName.query('.') FROM @MyVar.nodes('Order/Destination') MyAlias(ColName)--TVF خروجی یک 
GO
--Node& Value ترکیب
DECLARE @MyVar XML
SELECT @MyVar=XML_Data FROM Test_Node
	WHERE ID=1
SELECT 
	ColName.query('.'),
	ColName.value('@OrderID','INT')
FROM @MyVar.nodes('Order') MyAlias(ColName)--TVF خروجی یک 
GO
--Node& Value ترکیب
DECLARE @MyVar XML
SELECT @MyVar=XML_Data FROM Test_Node
	WHERE ID=1
SELECT 
	ColName.query('.'),
	ColName.value('@OrderID','INT'),
	ColName.value('@CustomerID','CHAR(5)'),
	ColName.value('Destination[1]/@ToCountry','NVARCHAR(50)')
FROM @MyVar.nodes('Order') MyAlias(ColName)--TVF خروجی یک 
GO
--استخراج مقدار به ازای هر رکورد
SELECT * FROM Test_Node
GO
SELECT 
	Test_Node.ID,
	Test_Node.XML_Data,
	MyAlias.ColName.query('.') AS 'عبارت تقسیم شده',
	MyAlias.ColName.value('@OrderID','INT') AS OrderID,
	MyAlias.ColName.value('@CustomerID','CHAR(5)') AS CustomerID,
	MyAlias.ColName.value('Destination[1]/@ToCountry','NVARCHAR(50)') AS Country
FROM Test_Node
CROSS APPLY Test_Node.XML_Data.nodes('Order') MyAlias(ColName)
GO





--Index
--ایجاد جدول تستی و درج تعدادی رکورد به صورت تستی
IF OBJECT_ID('Test_Exist')>0
	DROP TABLE Test_Exist
GO
CREATE TABLE Test_Exist
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="1">
	  <Name>
		<FirstName>Masoud</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="2">
	  <Name>
		<FirstName>AliReza</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="3">
	  <Name>
		<FirstName>Janet</FirstName>
		<LastName>Leverling</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
		<City>Kirkland</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Exist(XML_Data) VALUES (NULL)
GO
SELECT * FROM Test_Exist
GO
--------------------------------------------------------------------
--Execution Plan
--مقایسه پلن اجرایی
--XML Reader 1 : انتخاب
--XML Reader 2 : فیلتر
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('Employee[@EmployeeID="1"]')=1
GO
--برای پردازش استفاده کنXML Reader دات یعنی زیاد پردازش نکن و از همین 
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('(/Employee/@EmployeeID)[.= "1"]') = 1
GO
--بالاتر از سایر متدها است Exists کارایی متد 
--Value نسبت به
--را ذکر کنیدOrdinal
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('(/Employee/@EmployeeID)[1][.= "1"]') = 1
GO
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('for $a in /Employee/@EmployeeID where $a=1 return $a') = 1
GO
SELECT * FROM Test_Exist
	WHERE XML_Data.value('(/Employee/@EmployeeID)[1]','int') = 1
GO
--------------------------------------------------
IF OBJECT_ID('Test_Index')>0
	DROP TABLE Test_Index
GO
CREATE TABLE Test_Index
(
	ID INT IDENTITY PRIMARY KEY,
	XML_Data XML
)
GO
INSERT INTO Test_Index(XML_Data) VALUES
(
	'<Employee EmployeeID="1">
	  <Name>
		<FirstName>Masoud</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Index(XML_Data) VALUES
(
	'<Employee EmployeeID="2">
	  <Name>
		<FirstName>AliReza</FirstName>
		<LastName>Taheri</LastName>
	  </Name>
	  <Location>
		<Country>Iran</Country>
		<City>Miyaneh</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Index(XML_Data) VALUES
(
	'<Employee EmployeeID="3">
	  <Name>
		<FirstName>Janet</FirstName>
		<LastName>Leverling</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
		<City>Kirkland</City>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Index(XML_Data) VALUES
(
	'<Employee EmployeeID="4">
	  <Name>
		<FirstName>Margaret</FirstName>
		<LastName>Peacock</LastName>
	  </Name>
	  <Location>
		<Country>USA</Country>
	  </Location>
	</Employee>'
)
GO
INSERT INTO Test_Index(XML_Data) VALUES (NULL)
GO
SELECT * FROM Test_Index
GO
SP_SPACEUSED Test_Index
GO

--Primary XML Index
CREATE PRIMARY XML INDEX IX_Test_Index ON Test_Index(XML_Data)
GO
--Node Table بررسی 
--XML محل قرار گیری ایندکس های 
SELECT * FROM sys.internal_tables
	WHERE name LIKE '%XML%'
GO
--DAC Connection
SELECT * FROM SYS.xml_index_nodes_1653580929_256000
GO
SP_SPACEUSED Test_Index
GO
--مقایسه پلن
--با ایندکس
SELECT * FROM Test_Index
	WHERE XML_Data.exist('(/Employee/@EmployeeID)[1][.= "1"]') = 1
GO
--بدون ایندکس
SELECT * FROM Test_Exist
	WHERE XML_Data.exist('(/Employee/@EmployeeID)[1][.= "1"]') = 1
GO
--------------------------------------------------
--******Secondry Index
--For Value
--For Path
--For Property
--Selective

--For Value
--بهینه سازی برای بررسی مقدار
CREATE XML INDEX IxForValue_Test_Index ON Test_Index(XML_Data)
	USING XML INDEX IX_Test_Index FOR PATH
GO
--For Path
--بهینه سازی برای بررسی مسیر
CREATE XML INDEX IxForPath_Test_Index ON Test_Index(XML_Data)
	USING XML INDEX IX_Test_Index FOR PATH
GO



--Selective
--صرفا مسیرهای مورد نظر ما ایندکس خواهند شد
/*
sys.sp_db_selective_xml_index @dbname = 'dbname', @selective_xml_index = 'action: on|off|true|false'
*/
create selective xml index index_name
on table_name(column_name)
for (<path>)
/*
for(
pathColor = '/Item/Product/Color' as SQL nvarchar(20),
pathSize = '/Item/Product/Size' as SQL int
*/