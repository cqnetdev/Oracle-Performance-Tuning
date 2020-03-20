set verify off
accept SQL_ADDR prompt "Enter SQL_ID : "
set pages 50000 lines 200
set long 100000
col owner for a15
col object_name for a30


select * from (
select owner, object_name, cnt, trunc((sum(cnt) over ()*100)/cnt) as perc from (
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
group by o.owner, o.object_name))
where perc > 10
order by cnt desc ;

set verify on
undefine SQL_ADDR

