-- RAC supported

set verify off
accept SQL_ID prompt "Enter SQL_ID: "
 
 
set lines 200 pages 2000
col snap_id for 999999
col MS for 999,999,999.999
col "Ela" for 99999
col "Rows" for 99,999,999
col "Rows/sec" for 9,999,999.99
col "Adj. R/s" for 9,999,999.99
col "Exec's" for 99,999,999
col "Rows/Exe" for 999,999.9
col "Ela/Exe" for 999,999.9999
col db_time for 99,999.999
col "Gets/Exe" for 999,999,999.99
col "Phy/Exe" for 9,999,999.99
col "Avg IO" for 999
col end for a20
 
 
SELECT   TO_CHAR(snap.end_interval_time,'DD-MON HH24:MI') End,
         time_curr.snap_id                                               ,
         (time_curr.VALUE - time_old.VALUE) / 1000000 / 60             db_time              ,
        sql.EXECUTIONS_DELTA                             AS "Exec's"                  ,
         sql.ELAPSED_TIME_DELTA/1000000                   as "Ela"                ,
         sql.ROWS_PROCESSED_DELTA                         AS "Rows"               ,
         sql.ROWS_PROCESSED_DELTA/(to_date(to_char(snap.END_INTERVAL_TIME,'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
              -to_date(to_char(snap.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI:SS'),'DD-MON-YY HH24:MI:SS'))/24/3600 as "Rows/sec",
         to_number(decode(sql.ELAPSED_TIME_DELTA,0,NULL,sql.ROWS_PROCESSED_DELTA/sql.ELAPSED_TIME_DELTA*1000000)) as "Adj. R/s",
         to_number(decode(sql.EXECUTIONS_DELTA,0,NULL,sql.ROWS_PROCESSED_DELTA/sql.EXECUTIONS_DELTA))      AS "Rows/Exe",
         to_number(decode(sql.EXECUTIONS_DELTA,0,NULL,sql.ELAPSED_TIME_DELTA  /1000000/sql.EXECUTIONS_DELTA)) AS "Ela/Exe",
         to_number(decode(sql.EXECUTIONS_DELTA,0,NULL,sql.BUFFER_GETS_DELTA   /sql.EXECUTIONS_DELTA))      AS "Gets/Exe"               ,
         to_number(decode(sql.EXECUTIONS_DELTA,0,NULL,sql.DISK_READS_DELTA    /sql.EXECUTIONS_DELTA))      AS "Phy/Exe",
         to_number(decode(sql.DISK_READS_DELTA,0,null,sql.IOWAIT_DELTA / sql.DISK_READS_DELTA/1000)) as "Avg IO"
FROM     dba_hist_sys_time_model time_curr,
         dba_hist_sys_time_model time_old,
         dba_hist_snapshot snap      ,
         dba_hist_sqlstat sql,
         v$instance i
WHERE    time_old.snap_id   = time_curr.snap_id - 1
AND      time_curr.snap_id   = snap.snap_id
AND      time_curr.stat_name = 'DB time'
AND      time_old.stat_name = time_curr.stat_name
AND      time_curr.snap_id BETWEEN 1 AND      9999999
AND      snap.snap_id=sql.snap_id
AND      sql.sql_id   ='&SQL_ID'
AND i.INSTANCE_NUMBER = time_curr.INSTANCE_NUMBER
AND i.INSTANCE_NUMBER = time_old.INSTANCE_NUMBER
AND i.INSTANCE_NUMBER = snap.INSTANCE_NUMBER
AND i.INSTANCE_NUMBER = sql.INSTANCE_NUMBER
ORDER BY snap_id;
 
 
 
 
