define INTERVAL=5

set feed off
prompt Taking snapshot...
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate ' create table SOLAR_begin_stats as select owner, OBJECT_NAME, sum(VALUE) as value from V$SEGMENT_STATISTICS where STATISTIC_NAME=''logical reads'' group by owner, OBJECT_NAME';
exception
when others then  null;
end;
end;
/

prompt ... sleeping for &INTERVAL seconds ...

host sleep &INTERVAL


col "Total Logical" for 999,999,999,999
col "Logical IO" for 999,999,999
col OBJECT_NAME for a30
col owner for a15
set lines 200
set pages 50000
prompt
prompt Objects by Logical Reads for &INTERVAL seconds


select owner, OBJECT_NAME, value as "Total Logical", io  as "Logical IO" from (
select
new.owner, new.OBJECT_NAME,  new.value,new.value  - nvl(old.value,0) as io,
row_number () over (order by nvl(old.value,0) - new.value, new.value desc ) as rnk
from SOLAR_begin_stats old,
(
select owner, OBJECT_NAME, sum(VALUE) as value from V$SEGMENT_STATISTICS where STATISTIC_NAME='logical reads' group by owner, OBJECT_NAME) new
where old.owner(+)=new.owner and old.OBJECT_NAME(+) = new.OBJECT_NAME
) where rnk <=15  and io>0 order by rnk desc;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on
prompt

