set lines 200 pages 50000
col TABLESPACE_NAME for a20
col "Allocated" for 99,999,999
col " Free MB"  for 99,999,999
col "Used" for 99,999,999
col "Available" for 99,999,999
col "Capacity" for 99,999,999



select 
  q3.alloc, 
  q1.tablespace_name, 
  q1.total "Allocated", 
  q2.free " Free MB", 
  q1.total-q2.free as "Used",
  floor(100*(1-q2.free/q1.total)) "Used %", 
  decode(floor(20*(q2.free/q1.total)),0,'*',' ') "W", 
  -- q2.maxmb "Max MB",
  q1.maxmbgrowth-q1.total+q2.free "Available",
  q1.maxmbgrowth "Capacity"
from
(select tablespace_name, floor(sum(bytes)/1024/1024) free, floor(max(bytes)/1024/1024) maxmb from dba_free_space group by tablespace_name 
  union select tablespace_name,  floor(BYTES_FREE/1024/1024), null from V$TEMP_SPACE_HEADER) q2,
(select tablespace_name, floor(sum(decode(AUTOEXTENSIBLE,'YES',maxbytes,bytes))/1024/1024) maxmbgrowth, floor(sum(bytes)/1024/1024) total from dba_data_files group by tablespace_name 
  union select tablespace_name, floor(sum(decode(AUTOEXTENSIBLE,'YES',maxbytes,bytes))/1024/1024) maxmbgrowth, floor(sum(bytes)/1024/1024) total from dba_temp_files group by tablespace_name) q1,
(select tablespace_name, DECODE(substr(EXTENT_MANAGEMENT,1,1),'D',' ',substr(ALLOCATION_TYPE,1,1)) alloc from dba_tablespaces) q3
where q1.tablespace_name=q2.tablespace_name(+)
and q3.tablespace_name=q1.tablespace_name
order by q1.tablespace_name;

prompt Allocated : current size of the tablespace in MB
prompt Free MB   : free space in the tablespace
prompt Used      : space used by the data (allocated to segments)
prompt Available : free space + growth capacity (this much data can be added)
prompt Capacity  : maximum size to which the tablespace is allowed to grow
