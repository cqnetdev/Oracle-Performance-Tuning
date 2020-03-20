col username for a15
col event for a50
col sid for 99999
col seconds_in_wait for 99999
col SERIAL# for 99999
col "Waiting for:" for a50
set lines 200
set pages 50000
col state for a20
col sql_id for a15
prompt 
prompt Active sessions (running statements)
SELECT
  s.sid "SID",
  s.serial# "SERIAL#",
  SUBSTR(s.username,1,15) username,
  s.sql_id,
--  decode(w.wait_time,0,w.event,'ON CPU') "Waiting for:",
  substr(w.WAIT_CLASS||': '||w.event,1,50)   "Waiting for:",
  w.seconds_in_wait,
  w.state
  --s.action
--  s.status
FROM
  v$session s
  ,v$session_wait w
WHERE
w.WAIT_CLASS!= 'Idle'
AND
  serial# != 1
AND
  STATUS = 'ACTIVE'
AND w.sid=s.sid
order by sid;
prompt Use @sqltext for info about running statement
prompt -   @events for wait summary of a session
prompt -   @lock for lock summary
