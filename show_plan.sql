-- spool plan.log

set linesize 200
set pagesize 20000
select * from table(dbms_xplan.display);
