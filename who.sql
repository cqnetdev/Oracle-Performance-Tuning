set verify off
col "Program" for a50
col osuser for a20
accept SQL_ID prompt "Enter SQL_ID: "

prompt Sessions that executed SQL_ID &SQL_ID in last 10 min.



set lines 200 pages 50000
col username for a15
col sid for 99999
col serial# for 99999
select distinct h.session_id as SID, h.session_serial# as serial#, u.username,s.osuser, 
substr(nvl(h.program,'[???]')||' on '||nvl(s.machine,'???')||'('||nvl(s.process,'???')||')',1,60) as "Program", h.sql_id
from v$session s,v$active_session_history h, dba_users u
where 
h.sql_id='&SQL_ID' and
u.user_id = h.user_id and s.sid(+)=h.session_id and s.serial#(+) = h.session_serial# and h.SAMPLE_TIME > sysdate-1/24/6
order by h.session_id;


