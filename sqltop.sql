define TIME=60
set verify off
set serveroutput on size 200000


set feed off
begin
begin
execute immediate 'truncate table SOLAR_begin_stats';
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'truncate table SOLAR_end_stats';
execute immediate 'drop table SOLAR_end_stats';
exception
when others then  null;
end;
begin
execute immediate 'truncate table SOLAR_diff_stats';
execute immediate 'drop table SOLAR_diff_stats';
exception
when others then  null;
end;

begin
execute immediate 'create global temporary table SOLAR_begin_stats on commit preserve rows as select sql_id, sql_text, sum(buffer_gets) as buffer_gets, sum(DISK_READS) as DISK_READS, sum(ELAPSED_TIME) as ELAPSED_TIME, sum(ROWS_PROCESSED) as ROWS_PROCESSED, sum(CPU_TIME) as CPU_TIME, sum(EXECUTIONS ) as EXECUTIONS,sum(APPLICATION_WAIT_TIME) as APPLICATION_WAIT_TIME, sum(CONCURRENCY_WAIT_TIME) as CONCURRENCY_WAIT_TIME, sum(CLUSTER_WAIT_TIME) as CLUSTER_WAIT_TIME, sum (USER_IO_WAIT_TIME) as USER_IO_WAIT_TIME, sum (PLSQL_EXEC_TIME) as PLSQL_EXEC_TIME, sum(JAVA_EXEC_TIME) as JAVA_EXEC_TIME  from v$sql group by  sql_id, sql_text';
--exception
--when others then  null;
end;
end;
/

prompt "Snapshot taken, sleeping &TIME sec."

host sleep &TIME

begin
execute immediate 'create global temporary table SOLAR_end_stats on commit preserve rows as select sql_id, sql_text, sum(buffer_gets) as buffer_gets, sum(DISK_READS) as DISK_READS, sum(ELAPSED_TIME) as ELAPSED_TIME, sum(ROWS_PROCESSED) as ROWS_PROCESSED, sum(CPU_TIME) as CPU_TIME , sum(EXECUTIONS ) as EXECUTIONS,sum(APPLICATION_WAIT_TIME) as APPLICATION_WAIT_TIME, sum(CONCURRENCY_WAIT_TIME) as CONCURRENCY_WAIT_TIME, sum(CLUSTER_WAIT_TIME) as CLUSTER_WAIT_TIME, sum (USER_IO_WAIT_TIME) as USER_IO_WAIT_TIME,sum (PLSQL_EXEC_TIME) as PLSQL_EXEC_TIME, sum(JAVA_EXEC_TIME) as JAVA_EXEC_TIME  from v$sql group by  sql_id, sql_text';
execute immediate 'create global temporary table SOLAR_diff_stats on commit preserve rows as select e.sql_id, e.sql_text, e.buffer_gets-nvl(b.buffer_gets,0) as buffer_gets, e.DISK_READS-nvl(b.DISK_READS,0) as DISK_READS, e.ELAPSED_TIME-nvl(b.ELAPSED_TIME,0) as ELAPSED_TIME, e.ROWS_PROCESSED-nvl(b.ROWS_PROCESSED,0) as ROWS_PROCESSED , e.CPU_TIME-nvl(b.CPU_TIME,0) as CPU_TIME, e.EXECUTIONS-nvl(b.EXECUTIONS,0) as EXECUTIONS, e.APPLICATION_WAIT_TIME-nvl(b.APPLICATION_WAIT_TIME,0) as APPLICATION_WAIT_TIME, e.CONCURRENCY_WAIT_TIME-nvl(b.CONCURRENCY_WAIT_TIME,0) as CONCURRENCY_WAIT_TIME, e.CLUSTER_WAIT_TIME-nvl(b.CLUSTER_WAIT_TIME,0) as CLUSTER_WAIT_TIME, e.USER_IO_WAIT_TIME-nvl(b.USER_IO_WAIT_TIME,0) as USER_IO_WAIT_TIME, e.PLSQL_EXEC_TIME-nvl(b.PLSQL_EXEC_TIME,0) as PLSQL_EXEC_TIME, e.JAVA_EXEC_TIME-nvl(b.JAVA_EXEC_TIME,0) as JAVA_EXEC_TIME from SOLAR_end_stats e, SOLAR_begin_stats b where e.sql_id=b.sql_id(+)';
end;
/




set lines 200 pages 50000
col "Hits" for 99999
col program for a48
col username for a15

prompt Top SQLs for last &TIME sec by ELAPSED 

set long 30

col "Ela sec" for 999.9
col "CPU sec" for 999.9
col "Rows/sec" for 99999.99
col "Adj. R/s" for 99999.99
col "CPU Rate" for 999
col "IO Rate" for 999.999
col  "Ela/Exe" for 999.9999
col "Phy/Exe" for 999999.999
col "SQL Text" for a45

select 
sql_id, 
substr(sql_text,1,45) "SQL Text",
ELAPSED_TIME/1000000 "Ela sec", 
CPU_TIME/1000000 "CPU sec", 
round(CPU_TIME/ELAPSED_TIME*100) "CPU Rate",
ROWS_PROCESSED/&TIME "Rows/sec", 
ROWS_PROCESSED/(ELAPSED_TIME/1000000) "Adj. R/s",
EXECUTIONS,
to_number(decode(EXECUTIONS,0,NULL,1,NULL,round(ELAPSED_TIME/100/EXECUTIONS))/10000) "Ela/Exe"
from (select * from SOLAR_diff_stats where ELAPSED_TIME > 0 order by ELAPSED_TIME desc) where rownum <=10;

prompt
prompt Top SQLs for last &TIME sec by Disk reads

col iorate for 999.999
col global_name for a15
col "Avg IO" for 9999

select
global_name,
sql_id,
substr(sql_text,1,45) "SQL Text",
ELAPSED_TIME/1000000 "Ela sec",
DISK_READS "Disk reads",
buffer_gets "Logical",
to_number(decode (buffer_gets,0,NULL,DISK_READS*100/buffer_gets)) as iorate,
ROWS_PROCESSED "Rows",
to_number(decode (EXECUTIONS,0,NULL,1,NULL,DISK_READS/EXECUTIONS)) "Phy/Exe",
USER_IO_WAIT_TIME/DISK_READS/1000 "Avg IO"
from (select * from SOLAR_diff_stats where DISK_READS > 0 order by DISK_READS desc), global_name where rownum <=10;

prompt
prompt Execution histogram

col "CPU" for 999
col "IO" for 999
col "Conc" for 999
col "App" for 999
col "Cluster" for 999
col "PL/SQL" for 999
col "Java" for 999
col "CPU/Exe" for 999.9999
col "IO/Exe" for 999.9999

select
sql_id,
substr(sql_text,1,45) "SQL Text",
ELAPSED_TIME/1000000 "Ela sec",
to_number(decode(EXECUTIONS,0,NULL,1,NULL,round(ELAPSED_TIME/100/EXECUTIONS))/10000) "Ela/Exe",
to_number(decode (EXECUTIONS,0,NULL,1,NULL,CPU_TIME/1000000/EXECUTIONS)) "CPU/Exe",
to_number(decode (EXECUTIONS,0,NULL,1,NULL,USER_IO_WAIT_TIME/1000000/EXECUTIONS)) "IO/Exe",
to_number(decode(round(CPU_TIME/ELAPSED_TIME*100),0,NULL,round(CPU_TIME/ELAPSED_TIME*100))) as "CPU",
to_number(decode(round(USER_IO_WAIT_TIME/ELAPSED_TIME*100),0,NULL,round(USER_IO_WAIT_TIME/ELAPSED_TIME*100))) as "IO",
to_number(decode(round(CONCURRENCY_WAIT_TIME/ELAPSED_TIME*100),0,NULL,round(CONCURRENCY_WAIT_TIME/ELAPSED_TIME*100))) as "Conc",
to_number(decode(round(APPLICATION_WAIT_TIME/ELAPSED_TIME*100),0,NULL,round(APPLICATION_WAIT_TIME/ELAPSED_TIME*100))) as "App",
to_number(decode(round(CLUSTER_WAIT_TIME/ELAPSED_TIME*100),0,NULL,round(CLUSTER_WAIT_TIME/ELAPSED_TIME*100))) as "Cluster",
to_number(decode(round(PLSQL_EXEC_TIME/ELAPSED_TIME*100),0,NULL,round(PLSQL_EXEC_TIME/ELAPSED_TIME*100))) as "PL/SQL",
to_number(decode(round(JAVA_EXEC_TIME/ELAPSED_TIME*100),0,NULL,round(JAVA_EXEC_TIME/ELAPSED_TIME*100))) as "Java"
from (select * from SOLAR_diff_stats where ELAPSED_TIME > 0 order by ELAPSED_TIME desc) where rownum <=10;





begin
begin
execute immediate 'truncate table SOLAR_begin_stats';
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'truncate table SOLAR_end_stats';
execute immediate 'drop table SOLAR_end_stats';
exception
when others then  null;
end;
begin
execute immediate 'truncate table SOLAR_diff_stats';
execute immediate 'drop table SOLAR_diff_stats';
exception
when others then  null;
end;
end;
/


