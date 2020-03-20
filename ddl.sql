set heading off;
 set echo off;
 Set pages 999;
 set long 90000;
 set lines 200
col ddl for a200
 

select dbms_metadata.get_ddl('INDEX','&Index_name') as ddl from dual;
