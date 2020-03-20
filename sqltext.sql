set verify off
accept SQL_ADDR prompt "Enter SQL_ADDRESS of a session: "
col sql_text for a60
set pages 50000
select 
sql_text ||chr(10)||chr(10)||
'Executions: '||to_char(executions)||chr(10)||
'Buffer gets (logical IO): '||to_char(buffer_gets)||chr(10)||
'Buffer gets per execution: '||to_char(floor(buffer_gets/decode(executions,0,1,executions)*10)/10) "SQL text"
from v$sqlarea where sql_id ='&SQL_ADDR';
set verify on
undefine SQL_ADDR
