col owner format a20
set pages 999
set line 200
select  owner||'|'||object_type ||'|'||
        count(1) ||'|'|| 
        sum(case when status ='INVALID' then 1 else 0 end)
from dba_objects
where owner in (select username from dba_users where oracle_maintained='N' and username not in ('APEX_030200','SCOTT','OJVMSYS'))
group by owner, object_type
order by owner, object_type;
