set verify off
accept SQL_ID prompt "Enter SQL_ID: "


select * from table(dbms_xplan.display_cursor('&SQL_ID',null,'ALLSTATS LAST'));




