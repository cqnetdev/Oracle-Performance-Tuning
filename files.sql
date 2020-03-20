set pages 50000 lines 200

set feedback off

col "DATA Files" for a50
select file_name "DATA Files" from dba_data_files;

col "Controlfiles" for a50
select name "Controlfiles"  from v$controlfile;

col "Redo logs" for a50
select member "Redo logs" from v$logfile;

