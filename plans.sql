set verify off
accept SQL_ID prompt "Enter SQL_ID of a session: "

col operation for a80
col id for 999
break on PLAN_HASH_VALUE skip 1


SELECT 
  id,
  decode(level,0,null,1,null,lpad(' ',level-1))||operation||' '||options||' '||object_name||decode(id-parent_id,0,null,1,null,'('||parent_id||
  '.'||(select lower(operation) from v$sql_plan op where p.sql_id=op.sql_id and p.PLAN_HASH_VALUE = op.PLAN_HASH_VALUE and op.id=p. parent_id)|| ')') "Operation",
  cardinality "Rows",
  COST "Cost"
  FROM V$SQL_PLAN p
CONNECT BY prior id = parent_id
        AND prior sql_id = sql_id
        and prior PLAN_HASH_VALUE = PLAN_HASH_VALUE
  START WITH id = 0
        AND sql_id = '&sql_id'
  ORDER BY id;

