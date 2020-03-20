set feed off
define sleep=5
define ela=1
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'create table SOLAR_begin_stats as select * from v$sqlarea';
exception
when others then  null;
end;
end;
/

prompt Scanning for SQLs with elapsed time longer than &ela. second(s)
set verify off


prompt
host sleep &sleep


col "Ela sec" for 999.999
col "% Time" for 999.99

set lines 200
set pages 50000



select
s.sql_id,
-- ss.sid,
substr(s.SQL_TEXT,1,30) as "Text",
s.executions-o.executions as "Execs",
(s.ELAPSED_TIME-o.ELAPSED_TIME)/1000000 as "Ela Tot",
(s.ELAPSED_TIME-o.ELAPSED_TIME)/1000000/decode((s.executions-o.executions),0,1,(s.executions-o.executions)) as "ELA AVG"
from v$sqlarea s, SOLAR_begin_stats o
-- , v$session ss
where s.sql_id = o.sql_id
and (s.ELAPSED_TIME-o.ELAPSED_TIME)/1000000/decode((s.executions-o.executions),0,1,(s.executions-o.executions)) > &ela
-- and ss.sql_id (+) = s.sql_id
and s.SQL_TEXT not like '%SOLAR_begin_stats%'
and s.SQL_TEXT not like 'create table SOLAR%'
order by (s.ELAPSED_TIME-o.ELAPSED_TIME)/1000000/decode((s.executions-o.executions),0,1,(s.executions-o.executions)) desc
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

