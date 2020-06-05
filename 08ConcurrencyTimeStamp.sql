use master
go

if db_id('Test')>0
begin
 alter database Test set single_user with rollback immediate
 drop database Test
 end
 go

 create database Test
 go
  use test
 go
 if object_id('Student')>0
  drop table Student

  go

  create table Student(
  id int identity primary key,
  FirstName Nvarchar(100),
  LatsName Nvarchar(100),
  HomeAddress Nvarchar(100),
  Phone varchar(20),
  CurrentTimeStamp timestamp
  )
  go

  insert into Student(FirstName,LatsName,HomeAddress,Phone) values
  (N'علی',N'نوری',N'تهران','2552'),
  (N'حسین',N'گرگانی',N'تبریز','588'),
  (N'ایمان',N'سیاری',N'همدان','969'),
  (N'حمزه',N'تقوی',N'ساوه','332'),
  (N'هادی',N'سوری',N'رشت','228')

  go

  select * from Student
  go

  create proc update_student
  (
  
   @id int ,
  @FirstName Nvarchar(100),
  @LatsName Nvarchar(100),
  @HomeAddress Nvarchar(100),
  @Phone varchar(20),
  @OldCurrentTimeStamp timestamp
  )
  AS
  BEGIN

  UPDATE Student 
  SET FirstName=@FirstName,
  LatsName=@LatsName
  ,HomeAddress=@HomeAddress,
  Phone=@Phone
  WHERE id=@id AND CurrentTimeStamp=@OldCurrentTimeStamp
  IF
  @@ROWCOUNT=0
  THROW 5999,'Current PROPLEM',1
  END


  SELECT *,CAST (CurrentTimeStamp AS INT)FROM Student