-- RAC supported

define load_power_adj=0.8
define field_ln=30
 
set lines 200
set pages 50000
set verify off
 
col "CPU cum." for 999,999
col "IO cum." for 999,999
col "Load: CPU=o  IO=X" for a65
col End for a20
with DBTIME as (select SNAP_ID,instance_number,db_time, max(db_time) over (partition by instance_number) as max_DB_time from (select SNAP_ID, instance_number, trunc(VALUE/1000000)-lag(trunc(VALUE/1000000)) over (partition by instance_number order by SNAP_ID) as db_time from DBA_HIST_SYS_TIME_MODEL where STAT_NAME='DB time' and value >= 0))
select
  TO_CHAR(snap.end_interval_time,'DD-MON-YYYY HH24:MI') End,
  load.snap_id, '|'||lpad(lpad(lpad('|',round(power(load.cpu,&load_power_adj.)/power(greatest(load.limit,dbtime.max_db_time),&load_power_adj.)*&field_ln.)+1,'o'),round(power(dbtime.db_time,&load_power_adj.)/power(greatest(load.limit,dbtime.max_db_time),&load_power_adj.)*&field_ln.)+1,'-'),&field_ln.+1)||
    lpad(lpad('|',1+round((power(greatest(load.limit,dbtime.max_db_time),&load_power_adj.)-power(io,&load_power_adj.))
                           /power(greatest(load.limit,dbtime.max_db_time),&load_power_adj.)*&field_ln.)),&field_ln.+1,'X') as "Load: CPU=o  IO=X",
  cpu as "CPU cum.",
  io as "IO cum.",
  -- max(trunc(dbtime.VALUE/1000000)-lag(trunc(dbtime.VALUE/1000000)) over (order by dbtime.SNAP_ID)) over ()
  dbtime.db_time
  -- ,dbtime.max_db_time
from
  (select snap_id, sum(CPU_TIME_DELTA)/1000000 as CPU, sum(IOWAIT_DELTA)/1000000 as IO,
     greatest(max(sum(CPU_TIME_DELTA/1000000)) over (), max(sum(IOWAIT_DELTA/1000000)) over () ) as limit
     from DBA_HIST_SQLSTAT, V$instance i where i.instance_number=DBA_HIST_SQLSTAT.instance_number and CPU_TIME_DELTA >= 0 and IOWAIT_DELTA >= 0 group by snap_id order by snap_id) load,
  dba_hist_snapshot snap, V$instance i, DBTIME
where snap.snap_id=load.snap_id and i.instance_number=snap.instance_number and dbtime.SNAP_ID=snap.snap_id and dbtime.INSTANCE_NUMBER=snap.instance_number
and dbtime.db_time >= 0
order by snap_id;
 
prompt o = CPU
prompt X = IO
prompt - = DB TIME
