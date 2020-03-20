set lines 200 pages 50000
col "Sec." for 999999
col sid for 99999
col username for a15
col program for a20
col event for a30
select distinct
  s.sid,
  substr(s.username,1,15) as username,
  substr(s.program,1,20) as program,
  h.SQL_ID, 
  (sysdate-h.SQL_EXEC_START)*3600*24 as "Sec.",
  substr(sql.SQL_TEXT,1,40),
  substr(h.event,1,30) as event
from v$active_session_history h , v$session s, v$sql sql
where h.SAMPLE_ID=(select max(SAMPLE_ID) from v$active_session_history) 
and (sysdate-h.SQL_EXEC_START)*3600*24 > 1 
and h.SESSION_ID=s.sid
and sql.sql_id = h.sql_id
order by (sysdate-h.SQL_EXEC_START)*3600*24;

