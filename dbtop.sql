-- drop  table tmp_shai_delta_3 ;
-- set echo on

set lines 140
set serveroutput on size 50000
set feed off echo off verify off

define threshold = 5000000


begin
dbms_output.put_line ('Creating TEMP table.');
execute immediate 'create global temporary table tmp_shai_delta_X as select sql_id as sql_id, elapsed_time as elapsed_time, cpu_time as cpu_time , executions as executions, sysdate as ttime , ROWS_PROCESSED as rowss, disk_reads as disk_reads , buffer_gets as buffer_gets from v$sqlarea where rownum < 1';
dbms_output.put_line ('Done.');
exception
  when others then dbms_output.put_line ('TEMP table already exists.');
end;

/

prompt Taking START snapshot.


-- delete tmp_shai_delta_3 ;
/*

*/

insert into tmp_shai_delta_X
( select sql_id as sql_id, elapsed_time, cpu_time, executions as executions, sysdate as ttime ,
                ROWS_PROCESSED as rowss , disk_reads , buffer_gets
from v$sqlarea
where
elapsed_time > &threshold
)
;

prompt ...

prompt Press ENTER to take END snapshot.


spool dbtop.log

col ela_sec format 999,999
col cpu_time format 999,999
col ela_exe_mili format 99,999.99
col elap_per_row_mili format 99,999.99
col per_row format 999.99
col textt format a20 trunc
col rate format 999,999
col execs format 999999
col seconds format 999999
col buffer_gets format 99999999
col rk format 99
col textt format a18 trunc

pause
--!sleep 60


select * from
(
select
a.sql_id ,
substr(b.sql_text,1,20) textt ,
b.executions - a.executions  execs , (sysdate - a.ttime ) * 24 * 3600 seconds ,
((b.executions - a.executions) / ((sysdate - a.ttime ) * 24 * 3600 )) as rate ,
b.ROWS_PROCESSED - a.rowss as rowss ,
(b.elapsed_time - a.elapsed_time) / 1000000 as ela_sec ,
(b.cpu_time - a.cpu_time) / 1000000 as cpu_time ,
(b.disk_reads - a.disk_reads) as disk_reads ,
(b.buffer_gets - a.buffer_gets) as buffer_gets ,
( b.elapsed_time - a.elapsed_time )/ 1000 / (1 + b.executions - a.executions ) as ela_exe_mili
, ( b.elapsed_time - a.elapsed_time )/ 1000 / (1 + b.rows_processed - a.rowss ) as per_row
,        row_number() over ( order by b.ELAPSED_TIME - a.ELAPSED_TIME desc  ) as rk
from v$sqlarea b , tmp_shai_delta_X a
where a.sql_id = b.sql_id
and b.ELAPSED_TIME > &threshold
) t1
where t1.rk <= 10;

rollback;


