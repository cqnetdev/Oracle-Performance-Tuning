SELECT owner, object_name, object_type, 
-- obj, 
count(1)			
  FROM x$bh, dba_objects o			
  WHERE x$bh.obj = O.object_id			
    and o.owner not in ('SYS','SYSTEM')			
    and status != 'free'			
  GROUP BY o.owner, object_name, object_type
--  , obj			
  order by count(1) DESC;	
