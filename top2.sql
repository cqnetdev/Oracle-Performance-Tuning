define TIME=10
set verify off
set serveroutput on size 200000


set feed off
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate 'create table SOLAR_begin_stats as select sid, STAT_NAME, STAT_ID, VALUE val from v$sess_time_model';
exception
when others then  null;
end;
end;
/

host sleep &TIME


col username for a10
col "% CPU" for 9999
col sql_id for a15
col osuser for a10
col machine for a15
col status for a10
col event for a32
col sid for 99999
col seconds_in_wait for 99999
col SERIAL# for 99999
col "Waiting for:" for a32
col "PID" for a5
col value for 999
col program for a48
set lines 200
set pages 50000
prompt
prompt Sessions by % DB CPU in the last &TIME sec.


select
s.sid "SID",
p.spid "PID",
trunc(CPU) "% CPU",
trunc(DB_TIME) "% DB_TIME",
trunc(SQL_EXEC) "% SQL_EXEC",
SUBSTR(s.username,1,10) username,
SUBSTR(s.osuser,1,10) osuser,
s.sql_id,
s.status,
replace(s.machine,'.nl.eu.abnamro.com',NULL) machine,
s.program
from v$session s, v$process p,
(select sid, 
        sum(decode(STAT_NAME,'DB CPU',value,0))  as CPU, 
        sum(decode(STAT_NAME,'DB time',value,0)) as DB_TIME,
        sum(decode(STAT_NAME,'sql execute elapsed time',value,0)) as SQL_EXEC
  from (
        select new.sid, new.STAT_ID, new.STAT_NAME, (new.val - nvl(old.val,0))*100/1000000/&TIME  value 
        from SOLAR_begin_stats old,
             (select sid, VALUE val , STAT_NAME, STAT_ID from v$sess_time_model) new
        where old.sid(+)=new.sid and OLD.STAT_ID(+) = new.STAT_ID
       ) 
   group by sid
   having sum(decode(STAT_NAME,'DB time',value,0)) > 1
) iov
where s.sid=iov.sid
and p.addr(+)=s.paddr
order by iov.DB_TIME desc
;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

