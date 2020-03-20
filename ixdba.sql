set verify off
accept TAB prompt "Enter table name: "
set pages 50000
set long 100000
set serveroutput on size 20000
break on index_name skip 1
declare
  l_local varchar2(100);
  l_par varchar2(100);
  

begin
  for l_tables in (select owner, table_name, partitioned from dba_tables where table_name = upper('&TAB')) loop
    select decode(l_tables.partitioned,'YES',' (partitioned)',null) into l_par from dual;
    dbms_output.put_line('==========================================================================');
    dbms_output.put_line('Indexes for table '||l_tables.owner||'.'||l_tables.table_name||l_par);
    dbms_output.put_line('==========================================================================');
    for l_indexes in (select owner, index_name, decode(uniqueness,'UNIQUE',' unique',NULL) uq, decode(last_analyzed,null,' NO STAT !',' analyzed: '||to_char(last_analyzed,'DD.MM.YYYY HH24:MI:SS')) stat, partitioned from dba_indexes where table_name = l_tables.table_name and TABLE_OWNER=l_tables.owner order by uniqueness desc, index_name) loop
      select decode (l_tables.partitioned||l_indexes.partitioned,
         'YESYES',' local',
         'YESNO', ' *** GOBAL ***',
         'NOYES', ' *** PARTITIONED ***',
         NULL) into l_par from dual;
      dbms_output.put_line(l_indexes.owner||'.'||l_indexes.index_name||l_indexes.uq||l_par||l_indexes.stat);
      dbms_output.put_line('--------------------------------------------------------------------------');
        for l_columns in (select column_name from dba_ind_columns where index_name = l_indexes.index_name and INDEX_OWNER= l_indexes.owner order by COLUMN_POSITION) loop
          dbms_output.put_line('-   '||l_columns.column_name);
        end loop;
        dbms_output.put_line(chr(10));
    




    end loop;




  end loop;
end;
/

