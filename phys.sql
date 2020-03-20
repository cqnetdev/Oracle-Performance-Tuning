define INTERVAL=5

prompt Taking snapshot...

set feed off
begin
begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
begin
execute immediate ' create table SOLAR_begin_stats as select owner, OBJECT_NAME, sum(VALUE) as value from V$SEGMENT_STATISTICS where STATISTIC_NAME=''physical reads'' group by owner, OBJECT_NAME';
exception
when others then  null;
end;
end;
/

prompt ... sleeping for &INTERVAL seconds ...


host sleep 5


col "Total Phys" for 999,999,999,999
col "Phys IO" for 999,999,999
col owner for a20
col OBJECT_NAME for a30
set lines 200
set pages 50000
prompt
prompt Objects by Pysical Reads in &INTERVAL seconds


select owner, OBJECT_NAME, value as "Total Phys", io  as "Phys IO" from (
select
new.owner, new.OBJECT_NAME,  new.value,new.value  - nvl(old.value,0) as io,
row_number () over (order by nvl(old.value,0) - new.value, new.value desc ) as rnk
from SOLAR_begin_stats old,
(
select owner, OBJECT_NAME, sum(VALUE) as value from V$SEGMENT_STATISTICS where STATISTIC_NAME='physical reads' group by owner, OBJECT_NAME) new
where old.owner(+)=new.owner and old.OBJECT_NAME(+) = new.OBJECT_NAME
) where rnk <=15  and io>0 order by rnk desc;


begin
execute immediate 'drop table SOLAR_begin_stats';
exception
when others then  null;
end;
/

set feed on

prompt @objacc - shows who accesses the object...
