-- RAC supported

set lines 200 pages 50000
col spid for a6
col "Gets/Exec" for 999,999,999
col "Gets" for 999,999,999,999
col program for a20
col username for a16
col sql_id for a13
col text for a40
 
 
select
  s.sid,
p.spid,
  s.sql_id,
  sql.BUFFER_GETS as "Gets",
  sql.EXECUTIONS as "Exec",
  sql.BUFFER_GETS/decode(sql.EXECUTIONS,0,1,sql.EXECUTIONS) as "Gets/Exec",
  substr(s.username,1,12) as username,
  -- s.osuser,
  --s.machine,
  substr(s.program,1,20) as program,
  substr(sql.SQL_TEXT,1,40) as text
from
  (select * from v$session s where sql_id is not null) s,
   v$process p,
  v$sqlarea sql
where
  s.status = 'ACTIVE'
  and sql.sql_id(+)=s.sql_id
  and sql.hash_value(+)=s.SQL_HASH_VALUE
  and p.addr=s.paddr
  and s.SQL_ADDRESS = sql.address(+)
  and s.sql_id is not null
  and sql.buffer_gets (+) is not null
  order by sql.BUFFER_GETS desc nulls last
;
 
