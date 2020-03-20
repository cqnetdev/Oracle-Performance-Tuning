set lines 200 pages 50000

col event for a30
col "SQL Text" for a55
col "Avg Ela" for 9.9999

select 
    m.start_time, 
    s.sql_id,
    substr(s.SQL_TEXT,1,50) as "SQL Text", 
    s.ELAPSED_TIME/1000000/s.EXECUTIONS as "Avg Ela", 
    m.max_exe as "Max Ela", 
    m.event, 
    round(m.cnt/m.max_exe*100) as "% Time"
from v$sql s, 
(select start_time, sql_id, event,max_exe,cnt from (
select to_char(SQL_EXEC_START,'DD.MM.YYYY HH24:MI:SS') start_time, sql_id, event,
max((to_date(to_char(SAMPLE_TIME,'DD.MM.YYYY HH24:MI:SS'),'DD.MM.YYYY HH24:MI:SS')- SQL_EXEC_START)*3600*24) as exe,
max(max((to_date(to_char(SAMPLE_TIME,'DD.MM.YYYY HH24:MI:SS'),'DD.MM.YYYY HH24:MI:SS')- SQL_EXEC_START)*3600*24))
                                           over (partition by to_char(SQL_EXEC_START,'DD.MM.YYYY HH24:MI:SS'), sql_id)  as max_exe,
row_number() over (partition by to_char(SQL_EXEC_START,'DD.MM.YYYY HH24:MI:SS'), sql_id order by count (1) desc) as my_rank,
count (1) as cnt 
from v$active_session_history 
where (to_date(to_char(SAMPLE_TIME,'DD.MM.YYYY HH24:MI:SS'),'DD.MM.YYYY HH24:MI:SS')- SQL_EXEC_START)*3600*24 > 10
group by to_char(SQL_EXEC_START,'DD.MM.YYYY HH24:MI:SS'), sql_id, event) where my_rank  = 1) m
where s.sql_id = m.sql_id and s.executions > 1000 and s.ELAPSED_TIME/1000000/s.EXECUTIONS < 1 
order by m.max_exe
;

/*
select s.sql_id, substr(s.SQL_TEXT,1,30), s.ELAPSED_TIME/1000000/s.EXECUTIONS as avg_exe, m.max_exe from v$sql s, 
(select sql_id, max(to_date(to_char(SAMPLE_TIME,'DD.MM.YYYY HH24:MI:SS'),'DD.MM.YYYY HH24:MI:SS')  - SQL_EXEC_START) *3600*24 as max_exe 
from v$active_session_history group by sql_id) m
where s.sql_id = m.sql_id and s.executions > 1000 and s.ELAPSED_TIME/1000000/s.EXECUTIONS < 1 and m.max_exe > 10
order by 4
;

*/

