col username for a20
SELECT
  s.sid "SID",
  s.serial# "SERIAL#",
  decode(s.status,'ACTIVE','* ','  ')||SUBSTR(s.username,1,15) username,
  s.sql_id,
  trunc((sysdate-s.logon_time)*24) "Hours",
  p.spid "Pid",
  substr(s.program,1,20) "Program",
  s.osuser
--   s.action
--  s.status,
FROM
  v$session s,
  v$process p
WHERE
  s.serial# != 1
AND
  s.paddr = p.addr (+)
order by sid;

prompt Run "ssa" for active sessions.
