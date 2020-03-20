-- RAC supported

define INTERVAL=10
 
set feed off verify off
accept SQL_ID prompt "Enter SQL_ID : "
 
prompt Taking snapshot...
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate ' create table SOLAR_begin_stats as select * from v$sqlarea where sql_id = ''&sql_id''';
-- exception
-- when others then  null;
end;
end;
/
 
prompt ... sleeping for &INTERVAL seconds ...
 
host sleep &INTERVAL
 
 
col "Total Logical" for 999,999,999,999
col "Logical IO" for 999,999,999
set lines 200
set pages 50000
prompt
prompt Load profile for SQL_ID &sql_id for &INTERVAL seconds
col "Ela/Exe" for 9.9999
 
select old.sql_id,
(new.ELAPSED_TIME-old.ELAPSED_TIME)/1000000 as "Ela",
new.executions-old.executions as "Exe",
new.ROWS_PROCESSED - old.ROWS_PROCESSED as "Rows",
(new.ROWS_PROCESSED - old.ROWS_PROCESSED)/&INTERVAL as "Rows/s",
new.buffer_gets - old.buffer_gets as "Gets",
(new.buffer_gets - old.buffer_gets)/&INTERVAL as "Gets/s",
new.DISK_READS - old.DISK_READS as "Reads" ,
(new.DISK_READS - old.DISK_READS)/&INTERVAL as "Reads/s",
to_number(decode(new.executions-old.executions,0,NULL, ((new.ELAPSED_TIME-old.ELAPSED_TIME)/1000000)/(new.executions-old.executions))) as "Ela/Exe"
from SOLAR_begin_stats old, v$sqlarea new
where new.sql_id = '&sql_id';
 
 
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/
 
set feed on
prompt
 
 
