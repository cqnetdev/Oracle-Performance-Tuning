set verify off
accept SQL_ADDR prompt "Enter SQL_ID : "
col  "SQL binds for &SQL_ADDR" for a150 WORD_WRAPPED
set pages 50000 lines 200
set long 100000
col name for a20
col VALUE_STRING for a50


with mysnap as (
select max(SNAP_ID) SNAP_ID from dba_hist_sqlbind where sql_id ='&SQL_ADDR')
select distinct
b.SNAP_ID, b.sql_id, b.NAME, b.position,b.DATATYPE, b.VALUE_STRING 
from 
mysnap, dba_hist_sqlbind b
where b.SNAP_ID=mysnap.SNAP_ID and b.sql_id ='&SQL_ADDR'
order by b.position;

set verify on
undefine SQL_ADDR

