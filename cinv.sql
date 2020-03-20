set feedback off echo off

set pages 0

select 'alter '||object_type||' '||owner||'.'||object_name||' compile;'
from dba_objects where status = 'INVALID' and object_type = 'FUNCTION';


select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' 
from dba_objects where status = 'INVALID' and object_type = 'PROCEDURE';


select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' 
from dba_objects where status = 'INVALID' and object_type = 'TRIGGER';


select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' 
from dba_objects where status = 'INVALID' and object_type = 'VIEW';


select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' 
from dba_objects where status = 'INVALID' and object_type = 'PACKAGE';


select 'alter package '||owner||'.'||object_name||' compile body;' 
from dba_objects where status = 'INVALID' and object_type = 'PACKAGE BODY';

prompt;

set pages 50000

set feedback on

