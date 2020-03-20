set verify off
set serveroutput on size 1000000
accept TAB prompt "Enter table name: "
set pages 50000
set long 100000
break on index_name skip 1
declare
  l_local varchar2(100);
  l_par varchar2(100);
  

begin
  for l_tables in (select owner, table_name, PARTITIONING_TYPE, PARTITION_COUNT from dba_part_tables where table_name = upper('&TAB')) loop
    dbms_output.put_line('==========================================================================');
    dbms_output.put_line('Partitions for table '||l_tables.owner||'.'||l_tables.table_name);
    dbms_output.put_line('- Partitioning: '||l_tables.PARTITIONING_TYPE||' Partitions: '||l_tables.PARTITION_COUNT);
    dbms_output.put_line('==========================================================================');
    for l_partitions in (select rpad(substr(p.partition_name,1,20),20) as partition_name, p.PARTITION_POSITION, p.HIGH_VALUE, p.NUM_ROWS, rtrim(to_char(s.bytes/1024/1024,'999,999'),7) as sz from dba_tab_partitions p, dba_segments s where p.table_name=l_tables.table_name and p.TABLE_OWNER = l_tables.owner and p.partition_name=s.partition_name and s.segment_name=l_tables.table_name order by p.PARTITION_POSITION) loop
          dbms_output.put_line('-   '||l_partitions.partition_name||'  Bytes: '||l_partitions.sz||' Rows: '||l_partitions.NUM_ROWS);

    end loop;

  end loop;
end;
/

