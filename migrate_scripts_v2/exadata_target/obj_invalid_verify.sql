col owner format a30 
col object_name format a30
col object_type format a30
select owner||'|'||object_name||'|'||object_type from dba_objects o 
where status <> 'VALID'
and owner not in ('OJVMSYS','SYSKM','GSMCATUSER','SYSBACKUP','SYSDG','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','GSMUSER','AUDSYS','APEX_030200','APEX_040200','GSMADMIN_INTERNAL','XS$NULL','ORACLE_OCM','MDDATA','OUTLN','DIP','APEX_PUBLIC_USER','MDSYS','ORDSYS','WMSYS','APPQOSSYS','ORDDATA','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
and ORACLE_MAINTAINED='N'
and exists (select 1 from SCOTT.mig_dba_objects f 
where f.owner=o.owner and f.object_name=o.object_name and f.object_type=o.object_type
and f.status='VALID'
);
