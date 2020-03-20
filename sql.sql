set verify off
accept SQL_ADDR prompt "Enter SQL_ID : "
col  "SQL text for &SQL_ADDR" for a150 WORD_WRAPPED
set pages 50000 lines 200
set long 100000
select
sql_fulltext ||chr(10)||'----------------------------------------------------------------------------------------------------'||
chr(10)||' '||chr(10)||
rpad('Executions: ',15)||to_char(executions,'999,999,999,999')||chr(10)||
rpad(rpad('Rows :',15)||to_char(ROWS_PROCESSED,'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(ROWS_PROCESSED/decode(executions,0,1,executions)*10)/10,'999,999,999,999.9') ||chr(10)||
'-'||chr(10)||
rpad(rpad('Buffer gets :',15)||to_char(buffer_gets,'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(buffer_gets/decode(executions,0,1,executions)*10)/10,'999,999,999,999.9')||chr(10)||
rpad(rpad('Disk reads :',15)||to_char(DISK_READS,'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(DISK_READS/decode(executions,0,1,executions)*10)/10,'999,999,999,999.9')||chr(10)||
'-'||chr(10)||
rpad(rpad('CPU sec:',15)||to_char(floor(CPU_TIME/1000000),'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(CPU_TIME/100/decode(executions,0,1,executions))/10000,'999,999,999,999.9999') ||chr(10)||
rpad(rpad('IOw sec:',15)||to_char(floor(USER_IO_WAIT_TIME/1000000),'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(USER_IO_WAIT_TIME/100/decode(executions,0,1,executions))/10000,'999,999,999,999.9999') ||chr(10)||
rpad(rpad('Elapsed sec:',15)||to_char(floor(ELAPSED_TIME/1000000),'999,999,999,999'),40)||
rpad('Per execution:',15)||to_char(floor(ELAPSED_TIME/100/decode(executions,0,1,executions))/10000,'999,999,999,999.9999') ||chr(10)||
'-'||chr(10)||
'Module: '||module||chr(10)||
'----------------------------------------------------------------------------------------------------' "SQL text for &SQL_ADDR"
from v$sqlarea where sql_id ='&SQL_ADDR';
set verify on
undefine SQL_ADDR

