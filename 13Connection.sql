--session id 51>x not system
Sp_who
go
sp_who2 
go
sp_who2 77
go
select * from sys.dm_exec_connections
go
select * from sys.sysprocesses
go

SELECT * FROM sys.dm_exec_sessions

GO
SELECT S.session_id,S.host_name,P.client_net_address
FROM sys.dm_exec_sessions S
INNER JOIN sys.dm_exec_connections P
ON  S.session_id=P.session_id
GO
SELECT login_name,COUNT(session_id)
AS CO FROM sys.dm_exec_sessions
GROUP BY login_name
GO
SELECT 'ALI'
GO

DBCC INPUTBUFFER(71)
GO


SELECT S.session_id,S.host_name,C.client_net_address,S.program_name,COMMAND.text
FROM sys.dm_exec_sessions S
INNER JOIN sys.dm_exec_connections C
ON S.session_id=C.session_id
OUTER APPLY sys.dm_exec_sql_text(C.most_recent_sql_handle) AS COMMAND
GO
kill 72
go
--پاک کردن کلیه کانکشن ها
set nocount on
declare @databasename varchar(100)
declare @query varchar(max)
set @query = ''

set @databasename = 'xxx'
if db_id(@databasename) < 4
begin
	print 'system database connection cannot be killeed'
return
end

select @query=coalesce(@query,',' )+'kill '+convert(varchar, spid)+ '; '
from master..sysprocesses where dbid=db_id(@databasename)

if len(@query) > 0
begin
print @query
	exec(@query)
end