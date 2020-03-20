 set pages 50000 lines 200
col tablespace for a20
col username for a20
col SQL_ID for a15
select SESSION_NUM, TABLESPACE, USERNAME, SQL_ID, CONTENTS, SEGTYPE, BLOCKS*8192/1024/1024 as "MB Used" from  v$tempseg_usage
  order by TABLESPACE, "MB Used" desc;
