col event for a42
col time for 999999999
col sid for 99999
col "% Time" for 999.99
set verify off
set lines 120
variable ELA number;
accept SID prompt "Enter SID of a session: "
col sql_text for a60
set pages 50000
col STAT_NAME for a50
begin
select (sysdate-logon_time)*86400 into :ELA from v$session where sid=&SID;
end;
/

select sid, TIME_WAITED/:ELA "% Time", EVENT, TOTAL_WAITS, TIME_WAITED as TIME, AVERAGE_WAIT, MAX_WAIT
from v$session_event where sid = &SID
union
select sid, value/10000/:ELA, '*** CPU Time in Oracle ***', 0,  floor(value/10000),0,0 from  V$SESS_TIME_MODEL where sid=&SID and STAT_NAME = 'DB CPU'
order by TIME desc ;

prompt Wait times in 1/100 SECONDS (i.e. 100 = 1 second)


col "Ela SEC" for 999,999.999

select sid, STAT_NAME, value/1000000 "Ela SEC" from  V$SESS_TIME_MODEL where sid=&SID
and value/1000000 > 1
order by value/1000000 desc ;

set verify on
undefine SID
