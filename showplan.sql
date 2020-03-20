spool plan.log

set linesize 150
set pagesize 2000
select * from table(dbms_xplan.display);
