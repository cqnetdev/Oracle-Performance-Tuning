set feed off
set lines 200 pages 50000

PROMPT Total system event summary

col "Metric" for a40
col "Total sec." for 999,999,999
col "% DB TIME" for 999.9
with db_time as (select /*+materialize*/ VALUE/1000000 as value from v$sys_time_model where STAT_NAME='DB time')
select wait_class as "Metric", round(sum(TIME_WAITED_MICRO/1000000)) as "Total sec.", sum(TIME_WAITED_MICRO/1000000)/(select value from db_time)*100 "% DB TIME" from v$system_event
where wait_class not in ('Idle','Network')
group by wait_class having round(sum(TIME_WAITED_MICRO/1000000)/(select value from db_time)*100) > 1
Union
select 
'DB CPU (=CPU Time)', round(t.VALUE/1000000), t.VALUE/1000000/db_time.value*100 from v$sys_time_model t, db_time
where STAT_NAME='DB CPU'
Union
select 
'Total DB Time', round(VALUE), 100 from db_time
order by 2 desc;





begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'create table SOLAR_begin_stats as with db_time as (select /*+materialize*/ VALUE, STAT_NAME  from v$sys_time_model where STAT_NAME=''DB time'') select event, TIME_WAITED_MICRO, total_waits, TOTAL_TIMEOUTS, db_time.value as db_time  from v$system_event, db_time where wait_class not in (''Idle'',''Network'') Union all select t.stat_name, t.VALUE, null, null, db_time.value from v$sys_time_model t, db_time where t.STAT_NAME=''DB CPU'' Union all select STAT_NAME, VALUE,null, null, value from db_time';
--exception
--when others then  null;
end;
end;
/

host sleep 5

PROMPT System events captured in last 5 sec

col "Total sec." for 999,999.9
col "% DB TIME" for 999.9
with db_time as (select /*+materialize*/ VALUE, STAT_NAME  from v$sys_time_model where STAT_NAME='DB time') 
select e.event, (e.TIME_WAITED_MICRO-b.TIME_WAITED_MICRO)/1000000 as "Total sec.", e.total_waits-b.total_waits as "Waits", 
e.TOTAL_TIMEOUTS-b.TOTAL_TIMEOUTS as "Timeouts", (e.TIME_WAITED_MICRO-b.TIME_WAITED_MICRO)/(db_time.value-b.db_time)*100 as "% DB TIME"  
from v$system_event e, db_time, SOLAR_begin_stats b where 
e.event=b.event and (e.TIME_WAITED_MICRO-b.TIME_WAITED_MICRO)/(db_time.value-b.db_time)*100 > 0.5
Union all select 'DB CPU (=CPU Time)', (t.VALUE-b.TIME_WAITED_MICRO)/1000000, null, null, (t.VALUE-b.TIME_WAITED_MICRO)/(db_time.value-b.db_time)*100 from v$sys_time_model t, db_time, SOLAR_begin_stats b 
where t.STAT_NAME='DB CPU' and b.event=t.STAT_NAME
Union all select 'DB time', (VALUE-b.TIME_WAITED_MICRO)/1000000,null, null, (VALUE-b.TIME_WAITED_MICRO)/(value-b.db_time)*100 from db_time, SOLAR_begin_stats b where b.event=db_time.STAT_NAME
order by 2 desc;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on


