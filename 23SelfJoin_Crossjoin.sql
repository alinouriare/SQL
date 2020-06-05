select * from EMPL a, EMPL b
where a.ID=b.REPORTSTO 
go
select * from Products p
cross join CartLine
order by p.ProductID