-- RAC supported

set verify off lines 200 pages 50000
col "Ela sec." for 999,999.9
col "SQL" for a60
col  "Program" for a70
accept SID prompt "Enter SID of the session: "
 
select sid, serial#, substr(nvl(program,'[???]')||' on '||machine||'('||process||')',1,60) as "Program" from v$session where sid=&SID ;
 
select hist.sql_id, hist.cnt as "Hits", hist.perc, s.buffer_gets, s.executions, s.elapsed_time/1000000 "Ela sec.", substr(s.sql_text,1,60) as "SQL"
from v$sqlarea s,(
select nvl(sql_id,' - NO WORK -') as SQL_ID, count(1) as cnt, round(count(1)*100/tot) as perc from
(select session_id as sid, session_serial# as serial#, sql_id, count(1) over () as tot from
  (select h.*, row_number() over (order by SAMPLE_TIME desc) as rn from v$active_session_history h, v$session s where s.sid=&SID
and h.session_id = s.sid and h.session_serial# = s.serial#) where rn <= 1000) group by sql_id, tot) hist
where s.sql_id=hist.sql_id order by hist.cnt desc;
 
@eventrc2.sql


 
