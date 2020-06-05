USE AdventureWorks2014
GO
SELECT SalesPersonID,
YEAR(OrderDate) as OrderYear,--5
COUNT(*) AS NumberOrder FROM --1
Sales.SalesOrderHeader
WHERE CustomerID=29825 --2
GROUP BY SalesPersonID,YEAR(OrderDate)--3
HAVING COUNT(*)>1--4
ORDER BY OrderYear DESC--6
GO
--ctrl + l Or ctrl+m
go
set statistics io on
set statistics time on
go

--Read Ahead = Fragmentation
select * from Person.PersonPhone