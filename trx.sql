set lines 200 pages 50000
COLUMN username FORMAT A20
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 99999
col segment_name for a20
col MB for 999,999
 
SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_ublk*8192/1024/1024 MB,
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND   rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC
/

