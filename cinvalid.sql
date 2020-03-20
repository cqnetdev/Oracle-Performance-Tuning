set feedback off echo off

set pages 0

select 'alter '||object_type||' '||object_name||' compile;'
from user_objects where status = 'INVALID' and object_type = 'FUNCTION';


select 'alter '||object_type||' '||object_name||' compile;' 
from user_objects where status = 'INVALID' and object_type = 'PROCEDURE';


select 'alter '||object_type||' '||object_name||' compile;' 
from user_objects where status = 'INVALID' and object_type = 'TRIGGER';


select 'alter '||object_type||' '||object_name||' compile;' 
from user_objects where status = 'INVALID' and object_type = 'VIEW';


select 'alter '||object_type||' '||object_name||' compile;' 
from user_objects where status = 'INVALID' and object_type = 'PACKAGE';


select 'alter package '||object_name||' compile body;' 
from user_objects where status = 'INVALID' and object_type = 'PACKAGE BODY';

prompt;

set pages 50000

set feedback on

