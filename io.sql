set feed off
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate ' create table SOLAR_begin_stats as select st.sid, sum(value) io from v$sesstat st, v$statname n where  st.STATISTIC#=n.STATISTIC# and n.name in (''physical reads'') group by st.sid';
exception
when others then  null;
end;
end;
/

host sleep 5


col username for a10
col osuser for a10
col machine for a20
col status for a10
col event for a32
col sid for 99999
col seconds_in_wait for 99999
col SERIAL# for 99999
col "Waiting for:" for a32
col "PID" for a5
col value for 99999
set lines 200
set pages 50000
prompt
prompt Sessions by Pysical Reads


select
s.sid "SID",
p.spid "PID",
iov.value,
SUBSTR(s.username,1,10) username,
SUBSTR(s.osuser,1,10) osuser,
s.sql_id,
s.status,
s.machine,
s.program
from v$session s, v$process p,
(select * from (
select new.sid, new.io - nvl(old.io,0) value from SOLAR_begin_stats old,
(select st.sid, sum(value) io from v$sesstat st, v$statname n
where  st.STATISTIC#=n.STATISTIC#
and n.name in ('physical reads') group by st.sid) new
where old.sid(+)=new.sid) where value > 0) iov
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

