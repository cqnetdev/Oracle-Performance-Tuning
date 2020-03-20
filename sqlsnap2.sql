set verify off
set serveroutput on size 200000

accept START_SNAP_ID prompt "Enter Start SNAP_ID: "
accept END_SNAP_ID prompt "Enter END SNAP_ID: "




set feed off

set lines 200 pages 50000
col "Hits" for 99999
col program for a48
col username for a15

set long 70

col "Ela sec" for 999,999.9
col "CPU sec" for 999.9
col "Rows/sec" for 99999.99
col "Adj. R/s" for 99999.99
col "CPU Rate" for 999
col "IO Rate" for 999.999
col  "Ela/Exe" for 999.9999
col "Phy/Exe" for 999999.999
col "SQL Text" for a70

select 
stat.sql_id, 
substr(sql.sql_text,1,70) "SQL Text",
ELAPSED_TIME/1000000 "Ela sec", 
CPU_TIME/1000000 "CPU sec", 
round(CPU_TIME/ELAPSED_TIME*100) "CPU Rate",
-- ROWS_PROCESSED/TIME "Rows/sec", 
ROWS_PROCESSED/(ELAPSED_TIME/1000000) "Adj. R/s",
EXECUTIONS,
to_number(decode(EXECUTIONS,0,NULL,1,NULL,round(ELAPSED_TIME/100/EXECUTIONS))/10000) "Ela/Exe"
from (select * from (select -- snap_id, 
      sql_id,
      sum(EXECUTIONS_DELTA) as EXECUTIONS,
      sum(ROWS_PROCESSED_DELTA) as ROWS_PROCESSED,
      sum(ELAPSED_TIME_DELTA) as ELAPSED_TIME,
      sum(CPU_TIME_DELTA) as CPU_TIME
 from dba_hist_sqlstat where snap_id>=&START_snap_id and snap_id<=&END_snap_id and ELAPSED_TIME_DELTA > 0 group by sql_id --,snap_id 
 order by sum(ELAPSED_TIME_DELTA) desc) where rownum <=20) stat,
  DBA_HIST_SQLTEXT sql
  where sql.sql_id = stat.sql_id
  order by ELAPSED_TIME desc;

