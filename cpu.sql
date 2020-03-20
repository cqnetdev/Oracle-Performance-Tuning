define TIME=10
set verify off


set feed off
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'create table SOLAR_begin_stats as select sid, VALUE val from v$sess_time_model where STAT_NAME=''DB CPU''';
exception
when others then  null;
end;
end;
/

host sleep &TIME


col username for a10
col "% CPU" for 9999
col osuser for a10
col machine for a20
col status for a10
col event for a32
col sid for 99999
col seconds_in_wait for 99999
col SERIAL# for 99999
col "Waiting for:" for a32
col "PID" for a5
col value for 999
set lines 200
set pages 50000
prompt
prompt Sessions by % DB CPU in the last &TIME sec.


select
s.sid "SID",
p.spid "PID",
trunc(iov.value*100 /1000000/&TIME) "% CPU",
SUBSTR(s.username,1,10) username,
SUBSTR(s.osuser,1,10) osuser,
s.sql_id,
s.status,
s.machine,
s.program
from v$session s, v$process p,
(select * from (
select new.sid, new.val - nvl(old.val,0) value from SOLAR_begin_stats old,
( select sid, VALUE val from v$sess_time_model where STAT_NAME='DB CPU') new
where old.sid(+)=new.sid) where value*100 /1000000/&TIME > 1) iov
where s.sid=iov.sid
and p.addr(+)=s.paddr
order by iov.value desc
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

