-- RAC NOT TESTED
-- Accepts SID
-- Samples the DB for X seconds and shows the events for the session



set feed off
set verify off

define time=20

accept SID prompt "Enter SID of a session: "

begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'drop table SOLAR_end_stats';
exception
when others then  null;
end;
begin
execute immediate 'drop table SOLAR_diff_stats';
exception
when others then  null;
end;

execute immediate 'create table SOLAR_begin_stats as select sysdate as snap, sid,EVENT, TOTAL_WAITS, TIME_WAITED as TIME, AVERAGE_WAIT, MAX_WAIT from v$session_event where sid = &SID union select sysdate, sid,''*** CPU Time in Oracle ***'', 0,  floor(value/10000),0,0 from  V$SESS_TIME_MODEL where sid=&SID and STAT_NAME = ''DB CPU''';
end;
/


prompt "Snapshot taken, sleeping &TIME sec."

host sleep &TIME

begin
execute immediate 'create table SOLAR_end_stats as select sysdate as snap, sid,EVENT, TOTAL_WAITS, TIME_WAITED as TIME, AVERAGE_WAIT, MAX_WAIT from v$session_event where sid = &SID union select sysdate, sid,''*** CPU Time in Oracle ***'', 0,  floor(value/10000),0,0 from  V$SESS_TIME_MODEL where sid=&SID and STAT_NAME = ''DB CPU''';
execute immediate 'create table SOLAR_diff_stats as select (e.snap-b.snap)*24*60*60 as tdif, e.sid, e.event, e.TOTAL_WAITS-nvl(b.TOTAL_WAITS,0) as TOTAL_WAITS, e.TIME-nvl(b.TIME,0) as TIME from  SOLAR_begin_stats b, SOLAR_end_stats e where e.sid=b.sid(+) and e.EVENT=b.event(+)';
end;
/


col event for a42
col sid for 99999
col "% Time" for 999.99
set verify off
set lines 120
set pages 50000
col PERC for 99
col TIME for 99.99
col "Avg ms" for 999,999.9

select sid, event, TIME/100 as TIME, decode(TOTAL_WAITS,0,TIME/100*1000,TIME/100/TOTAL_WAITS*1000) "Avg ms", TIME/tdif PERC  from SOLAR_diff_stats  where TIME/tdif > 0.5 order by TIME desc;

set verify on
undefine SID
