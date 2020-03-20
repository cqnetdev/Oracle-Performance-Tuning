set feed off
set lines 200 pages 50000
col stat_name for a60
define sleep=10
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'create table SOLAR_begin_stats as  select EVENT, EVENT_ID, WAIT_CLASS#, WAIT_CLASS, sum(TIME_WAITED_MICRO/1000000) as waitsec from v$system_event where WAIT_CLASS not in (''Idle'') group by EVENT, EVENT_ID, WAIT_CLASS#, WAIT_CLASS union all select stat_name, -1, -1, ''MODEL'',value/1000000 from v$sys_time_model where stat_name = ''DB time'' union all select stat_name, -2, -2, ''MODEL'',value/1000000 from v$sys_time_model where stat_name = ''DB CPU''' ;
exception
when others then  null;
end;
end;
/

prompt

prompt Summary of System wait events for &sleep seconds

host sleep &sleep

col event for a50
col "WAIT_CLASS" for a30
col "Time spent" for 999.9

set lines 200
set pages 50000


select
s. EVENT, /*s.WAIT_CLASS#,*/ s.WAIT_CLASS, (s.waitsec-o.waitsec) as "Time spent"
from (select EVENT, EVENT_ID, WAIT_CLASS#, WAIT_CLASS, sum(TIME_WAITED_MICRO/1000000) as waitsec from v$system_event group by EVENT, EVENT_ID,WAIT_CLASS#, WAIT_CLASS
union all
select stat_name, -1, -1, 'MODEL',value/1000000 from v$sys_time_model where stat_name = 'DB time'
union all
select stat_name, -2, -2, 'MODEL',value/1000000 from v$sys_time_model where stat_name = 'DB CPU') s
, SOLAR_begin_stats o where s.EVENT_ID = o.EVENT_ID and s.waitsec-o.waitsec > 0.1 order by "Time spent"  desc
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

