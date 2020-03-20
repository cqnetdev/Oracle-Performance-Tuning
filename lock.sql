set lines 120
col user for a24
col owner for a15
col "Program" for a15


SELECT
  s.SID,
--  s.SERIAL#,
--  p.spid "Pid",
  substr(l.oracle_username || ' (' || NVL(l.OS_USER_NAME,'?') || ')',1,25) "User",
--  s.module,
  substr(s.program,1,15) "Program",
  substr(o.owner,1,15) "OWNER",
  o.object_name,
--  SUBSTR('Alter system KILL SESSION ''' || TO_CHAR(S.SID) ||','|| TO_CHAR(s.SERIAL#) || ''';',1,43) "Kill",
  s.SQL_ADDRESS
FROM
  v$session s,
  all_Objects o,
  v$locked_object l,
  v$process p
WHERE
  s.sid = l.session_id
AND
  o.object_id = l.object_id
AND
  s.paddr = p.addr (+);

  
  
  
