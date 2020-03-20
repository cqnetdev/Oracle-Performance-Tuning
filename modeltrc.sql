define INTERVAL=10

set feed off verify off
accept SID prompt "Enter Session SID : "

prompt Taking snapshot...
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate ' create table SOLAR_begin_stats as select * from V$SESS_TIME_MODEL where SID = ''&sid''';
-- exception
-- when others then  null;
end;
end;
/

prompt ... sleeping for &INTERVAL seconds ...

host sleep &INTERVAL


col "Total Logical" for 999,999,999,999
col "Total" for 999,999,999
set lines 200
set pages 50000
col "% Time" for 99.99
col STAT_NAME for a40
prompt
prompt Session Time model profile for Session &sid for &INTERVAL seconds


select old.sid,old.STAT_NAME, NEW.VALUE - OLD.VALUE as "Total",
( NEW.VALUE - OLD.VALUE)/1000000/&INTERVAL*100 as "% Time"
from 
SOLAR_begin_stats old, V$SESS_TIME_MODEL new
where new.sid = '&sid'
and NEW.STAT_NAME = OLD.STAT_NAME
and NEW.VALUE - OLD.VALUE > 0
order by 3 desc;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on
prompt


