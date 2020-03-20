

set lines 200 pages 50000
col username for a15
col operation for a50
col program for a30
break on sql_id skip 1

select distinct h.sql_id, u.username, h.program, lower(p.OPERATION||' '||p.options||' ')||P.OBJECT_NAME operation, s.DISK_READS, s.BUFFER_GETS, floor(elapsed_time / 1000000) elapsed_time
from v$active_session_history h, dba_users u, v$sql_plan p, v$sql s
where 
  h.SQL_ID = p.SQL_ID
  and h.USER_ID = u.USER_ID
  and h.SAMPLE_TIME > sysdate-1/24*4
  and (p.options like '%FULL%' or p.options = 'CARTESIAN' or p.options = 'SKIP SCAN' or p.options = 'ALL')
  AND nvl(P.OBJECT_OWNER,' ') not like 'SYS%'
  and p.HASH_VALUE = s.hash_value
  and s.sql_id=p.sql_id
  and (s.elapsed_time > 10000000 or s.BUFFER_GETS > 100000 or s.executions > 100)
order by 
  floor(s.elapsed_time/1000000),sql_id, 
  lower(p.OPERATION||' '||p.options||' ')||P.OBJECT_NAME
;
  
break on nothing
  
