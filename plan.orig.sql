set verify off
accept SQL_ID prompt "Enter SQL_ID: "


set serveroutput on size 500000;
set lines 200 pages 50000
declare
-- l_divided boolean := TRUE;
l_divided boolean := FALSE;
l_show_alias boolean := FALSE;
l_prefix varchar2(100);
l_next char(1);
l_children number;
l_more number;
l_parent varchar2(100);
l_this  char(1):='+';
l_down  char(1):='|';
l_end   char(1):='`';
l_space char(1):=' ';
l_child varchar2(20);
l_last number :=0;
l_alias varchar2(100);
l_warning char(1);
begin
  select max(CHILD_ADDRESS) into l_child from  v$sql_plan where sql_id = '&SQL_ID' and timestamp=
    (select max(timestamp) from v$sql_plan where sql_id = '&SQL_ID');
  for c_plan in (SELECT OBJECT_ALIAS, level, object_name, sql_id, decode(optimizer,NULL,NULL,' (mode='||optimizer||')')  as optmode, operation, id, parent_id, cardinality, cost, CHILD_ADDRESS, plan_hash_value, object_owner, options, timestamp, access_predicates, filter_predicates  from v$sql_plan CONNECT BY prior id = parent_id  AND prior sql_id = sql_id and prior CHILD_ADDRESS = CHILD_ADDRESS START WITH id = 0 AND CHILD_ADDRESS=l_child AND sql_id = '&SQL_ID' ORDER BY CHILD_ADDRESS, id) loop
    l_last := 0;
    if c_plan.options like '%FULL%' or c_plan.options = 'CARTESIAN' or c_plan.options = 'SKIP SCAN' or c_plan.options = 'ALL' then
      l_warning := '*';
    else
      l_warning := ' ';
    end if;
    if c_plan.OBJECT_ALIAS is not null and l_show_alias then
      l_alias := ' ('||c_plan.OBJECT_ALIAS||')';
    else
      l_alias := NULL;
    end if;
    if c_plan.level=1 then
      l_prefix := NULL;
      l_next:=NULL;
      dbms_output.put_line(lpad('-',110,'-'));
      dbms_output.put_line(rpad('Id',3)||'| '||rpad('SQL Id: '||c_plan.sql_id||'     Child address: '||c_plan.CHILD_ADDRESS,82)||'|'||lpad('Rows',10)||'|'||lpad('Cost',10)||'|');
      dbms_output.put_line(lpad('-',110,'-'));
    end if;
    l_next := l_space;
    select count(*) into l_more from v$sql_plan where sql_id = c_plan.sql_id and CHILD_ADDRESS = c_plan.CHILD_ADDRESS and parent_id=c_plan.parent_id and id>c_plan.id;
    if c_plan.level-1 < length(l_prefix) then
      l_prefix :=substr(l_prefix,1,c_plan.level-1);
      if l_divided then  
        dbms_output.put_line(rpad('.',3)||'| '||rpad(l_prefix||l_down,82)||'|'||lpad(' ',10)||'|'||lpad(' ',10)||'|');
      end if;
      if l_more > 0 then
        l_next:=l_this;
      else
        l_next:=l_end;
      end if;
    else
      if l_more > 0 then
        l_prefix :=substr(l_prefix,1,c_plan.level-1);
        l_next:=l_this;
        if l_divided then
          dbms_output.put_line(rpad('.',3)||'| '||rpad(l_prefix||l_down,82)||'|'||lpad(' ',10)||'|'||lpad(' ',10)||'|');
        end if;
      end if; 
    end if;
    select count(*) into l_children from v$sql_plan where sql_id = c_plan.sql_id and CHILD_ADDRESS = c_plan.CHILD_ADDRESS and parent_id=c_plan.id;
    if c_plan.id-c_plan.parent_id>1 then
      select ' ->'||lower(operation)||':'||id into l_parent from v$sql_plan where sql_id = c_plan.sql_id and CHILD_ADDRESS = c_plan.CHILD_ADDRESS and id=c_plan.parent_id;
    else
      l_parent := NULL;
    end if;
    dbms_output.put_line(rpad(c_plan.id,3)||'|'||l_warning||rpad(l_prefix||l_next||c_plan.operation||' '||
      c_plan.options||' '||c_plan.object_name||l_alias||l_parent||c_plan.optmode,82)||'|'||lpad(nvl(to_char(c_plan.cardinality),' '),10)||'|'||lpad(nvl(to_char(c_plan.cost),' '),10)||'|');
    if l_more=0 then
      l_prefix:=l_prefix||l_space;
    else
      l_prefix:=l_prefix||l_down;
    end if;
  end loop;
  dbms_output.put_line(lpad('-',110,'-'));
end;
/

    

