
set lines 200 pages 50000
col "Hits" for 99999
col program for a30
col username for a15
col "SQL text" for a60
col sql_id for a15


prompt Top SQLs for last 10 min from session history

select * from (
select s.username, substr(s.program,1,30) as "Program", h.sql_id, count(*) "Hits", substr(sql.sql_text,1,60) as "SQL text"
from v$session s,v$active_session_history h, v$sql sql
where s.sid=h.session_id and s.serial# = h.session_serial# and sql.sql_id = h.sql_id and h.SAMPLE_TIME > sysdate-1/24/6
group by s.username, s.program, h.sql_id, sql.sql_text order by count(*) desc ) where rownum < 21 order by 4;


