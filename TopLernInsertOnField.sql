


INSERT INTO Onlines.ProductType DEFAULT VALUES ---> Onlines.ProductType= ‰«„ ÃœÊ· „Ê—œ ‰Ÿ—

DECLARE @ID INT =(SELECT TOP (1)id  FROM Onlines.ProductType ORDER BY id DESC ) ---> Onlines.ProductType= ‰«„ ÃœÊ· „Ê—œ ‰Ÿ—

INSERT INTO Onlines.ProductTypeLanguage ---> Onlines.ProductTypeLanguage= ‰«„ ÃœÊ· „Ê—œ ‰Ÿ—
(
    IdProductType,
    IdLanguage,
    Name
)
VALUES
(   @ID,  -- IdProductType - int
    0,  -- IdLanguage - int
    N'' -- Name - nvarchar(150)
    )






set identity_insert Onlines.ProductionType off
go
set identity_insert  onlines.ProductType off
go
INSERT INTO Onlines.ProductionType  (Id) Values (1)
go
INSERT INTO Onlines.ProductType(Id) Values (1)
go
set identity_insert Onlines.ProductionType on
go
set identity_insert  onlines.ProductType on

--show 1
SELECT OBJECTPROPERTY(OBJECT_ID('Onlines.ProductionType'), 'TableHasIdentity');
go
SELECT OBJECTPROPERTY(OBJECT_ID('Onlines.ProductType'), 'TableHasIdentity');