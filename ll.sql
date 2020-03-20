set lines 200 pages 50000
col kill for a40
col owner for a15
col "User" for a25
col "Pid" for a8
col object_name for a30


SELECT
  distinct
  s.SID,
  p.spid "Pid",
  substr(l.oracle_username || ' (' || NVL(l.OS_USER_NAME,'?') || ')',1,25) "User",
--  s.module,
  substr(o.owner,1,15) "OWNER",
  o.object_name,
  SUBSTR('Alter system KILL SESSION ''' || TO_CHAR(S.SID) ||','|| TO_CHAR(s.SERIAL#) || ''';',1,43) "Kill",
  s.SQL_id
FROM
  v$session s,
  dba_Objects o,
  v$locked_object l,
  v$process p
WHERE
  s.sid = l.session_id
AND
  o.object_id = l.object_id
AND
  s.paddr = p.addr (+)
order by substr(o.owner,1,15), o.object_name;

SELECT
  distinct
  s.SID,
  p.spid "Pid",
  substr(l.oracle_username || ' (' || NVL(l.OS_USER_NAME,'?') || ')',1,25) "User",
--  s.module,
  substr(o.owner,1,15) "OWNER",
  o.object_name,
  SUBSTR('Alter system KILL SESSION ''' || TO_CHAR(S.SID) ||','|| TO_CHAR(s.SERIAL#) || ''';',1,43) "Kill",
  s.SQL_id
FROM
  v$session s,
  dba_Objects o,
  v$locked_object l,
  v$process p
WHERE
  s.sid = l.session_id
AND
  o.object_id = l.object_id
AND
  s.paddr = p.addr (+)
order by 1;


  
  
  
