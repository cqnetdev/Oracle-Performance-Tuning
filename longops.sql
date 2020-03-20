
set lines 200 pages 50000
col "units" for a25
col message for a70
col username for a20
col sql_id for a15
select SID, SQL_ID, username, SOFAR||'/'||TOTALWORK||' '||UNITS as "Units", ELAPSED_SECONDS, TIME_REMAINING, MESSAGE from v$session_longops
where sofar < totalwork;


