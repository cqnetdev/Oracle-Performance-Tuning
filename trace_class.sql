set feed off
accept wait_class prompt "Enter WAIT_CLASS : "
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
execute immediate 'create table SOLAR_begin_stats as  select WAIT_CLASS, sum(TIME_WAITED_MICRO/1000000) as waitsec from v$system_event where WAIT_CLASS not in (''Idle'') group by WAIT_CLASS';
exception
when others then  null;
end;
end;
/

prompt Summary of System Time model for &sleep seconds


prompt
host sleep &sleep


col "WAIT_CLASS" for a30
col "Time spent" for 999.9

set lines 200
set pages 50000



select
s.WAIT_CLASS, (s.waitsec-o.waitsec) as "Time spent"
from (select WAIT_CLASS, sum(TIME_WAITED_MICRO/1000000) as waitsec from v$system_event group by WAIT_CLASS) s
, SOLAR_begin_stats o where s.WAIT_CLASS = o.WAIT_CLASS order by 2 desc
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

