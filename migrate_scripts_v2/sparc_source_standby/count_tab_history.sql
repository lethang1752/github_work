select 'OBJ='||count(*) from SCOTT.mig_dba_objects
union all
select  'SYS_PRIVS='||count(*) from SCOTT.mig_dba_sys_privs
union all
select 'TAB_PRIVS='||count(*) from SCOTT.mig_dba_tab_privs
union all
select 'SEGS='||count(*) from SCOTT.mig_dba_segments
;