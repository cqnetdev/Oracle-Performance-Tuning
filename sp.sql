SELECT
  s.sid "SID",
  s.serial# "SERIAL#",
  SUBSTR(s.username,1,15) username,
  p.spid "Pid",
  s.status
--  ,trunc((sysdate-s.logon_time)*24) "Hours"
FROM
  v$session s,
  v$process p
WHERE
  s.serial# != 1
AND
  s.paddr = p.addr (+)
order by sid;
