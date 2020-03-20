set verify off
accept SQL_ADDR prompt "Enter SQL_ID : "
set pages 50000 lines 200
set long 100000
col owner for a15
col object_name for a30
define PERC=5
define PERIOD=2

prompt "TOTAL"


select * from (
select owner, object_name, cnt, trunc(cnt*100/sum(cnt) over ()) as perc from (
select  
o.owner, 
o.object_name, 
count(*) as cnt 
from 
v$active_session_history h,
dba_objects o 
where 
h.SQL_ID = '&SQL_ADDR'
and h.CURRENT_OBJ# = o.object_id
and h.SAMPLE_TIME > sysdate-&PERIOD
group by o.owner, o.object_name))
where perc > &PERC
order by cnt desc ;

prompt "Last 10 min"
define PERIOD=1/24/6

/

prompt "Last 30 sec"
define PERIOD=1/24/120

/


set verify on
undefine SQL_ADDR

