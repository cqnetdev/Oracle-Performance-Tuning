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
execute immediate 'create table SOLAR_begin_stats as select * from v$sys_time_model';
exception
when others then  null;
end;
end;
/

prompt

prompt Summary of System Time model for &sleep seconds


host sleep &sleep


col "Ela sec" for 999.999
col "% Time" for 99999

set lines 200
set pages 50000



select
s.stat_name, (s.value-o.value)/1000000 as "Ela sec", (s.value-o.value)/10000/&sleep. as "% Time"
from v$sys_time_model s, SOLAR_begin_stats o where s.STAT_ID = o.STAT_ID
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

