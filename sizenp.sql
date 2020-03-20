set lines 200 pages 50000

col "Table" for 999,999,999
col "Index" for 999,999,999
col "Lob" for 999,999,999
col total for 999,999,999
col table_name for a30

with mylob as (
select 'LOB' as segment_type, t.table_name, sum(s.bytes/1024/1024) as MB from user_segments s, user_lobs t where
s.segment_name = t.SEGMENT_NAME group by t.table_name),
myind as (
select 'INDEX' as segment_type, t.table_name, sum(s.bytes/1024/1024) as MB from user_segments s, user_indexes t where
s.segment_name = t.index_name group by t.table_name),
mytab as (
select 'TABLE' as segment_type, s.segment_name as table_name, sum(s.bytes/1024/1024) as MB from user_segments s where
s.segment_type like 'TABLE%' and partition_name is null group by s.segment_name)
select t.table_name, t.MB as "Table", nvl(i.mb,0) as "Index", nvl(l.mb,0) as "Lob", t.mb+nvl(i.mb,0)+nvl(l.mb,0) as total
from mylob l, mytab t, myind i
where l.table_name (+) = t. table_name
and i.table_name (+) = t. table_name
order by 1;

