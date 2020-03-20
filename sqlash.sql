set lines 200 pages 30
col SNAP for a20
col event for a50
col wait_class for a20
set verify off


accept SQL_ID prompt "Enter SQL_ID: "

prompt Hits in ASH by wait class.


select * from (
select 
--to_char(SAMPLE_TIME,'HH24:MI'),
to_char(trunc(SAMPLE_TIME,'MI') - MOD(TO_CHAR(SAMPLE_TIME, 'MI'), 5)/(24 * 60),'DD.MM.YYYY HH24:MI') as SNAP,
sum(decode(SESSION_STATE,'WAITING',NULL,1))                                         as "ON CPU",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'User I/O',1,NULL),NULL))      as "USERIO",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Application',1,NULL),NULL))   as "APPLIC",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'System I/O',1,NULL),NULL))    as "SYS IO",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Cluster',1,NULL),NULL))       as "CLUSTR",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Other',1,NULL),NULL))         as "OTHER ",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Concurrency',1,NULL),NULL))   as "CONCUR",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Commit',1,NULL),NULL))        as "COMMIT",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Configuration',1,NULL),NULL)) as "CONFIG",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Network',1,NULL),NULL))       as "NETWRK",
sum(decode(SESSION_STATE,'WAITING',decode(WAIT_CLASS,'Idle',1,NULL),NULL))          as "IDLE"
from v$active_session_history
where SAMPLE_TIME > sysdate-1 
and  sql_id = '&sql_id'
group by to_char(trunc(SAMPLE_TIME,'MI') - MOD(TO_CHAR(SAMPLE_TIME, 'MI'), 5)/(24 * 60),'DD.MM.YYYY HH24:MI')
)
order by to_date(SNAP,'DD.MM.YYYY HH24:MI');

prompt Hits in ASH by event

select 
sql_id, nvl(event,'ON CPU') as event, nvl(WAIT_CLASS,'CPU') as WAIT_CLASS, count(*) from  v$active_session_history
where SAMPLE_TIME > sysdate-1
and  sql_id = '&sql_id'
group by sql_id, event, WAIT_CLASS order by count(*) desc;

