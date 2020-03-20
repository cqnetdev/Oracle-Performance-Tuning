-- RAC supported

define INTERVAL=60
 
set feed off verify off
accept OBJ_ID prompt "Enter object_name: "
 
set lines 200
set pages 50000
col OWNER for a15
col sql_id for a15
col text for a100
prompt


select O.OWNER, s.SQL_ID, COUNT(*), substr(sql.sql_text,1,99) as text FROM v$active_session_history s, dba_objects o, (select distinct sql_id, sql_text from V$sql) sql
where o.object_name = '&OBJ_ID' and o.object_id=s.CURRENT_OBJ# and sql.sql_ID=S.SQL_ID
and SAMPLE_TIME > sysdate-1/24/60/60*&INTERVAL
group by O.OWNER, s.SQL_ID, substr(sql.sql_text,1,99)
order by 3;

 
 
set feed on
prompt
 
 
