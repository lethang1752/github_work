set line 150
set pagesize 999
select r.grantee||'|'||PRIVILEGE
from DBA_SYS_PRIVS r, dba_users u 
WHERE r.grantee=u.username
and u.username not in 
('ANONYMOUS','CTXSYS','DBSNMP','EXFSYS', 'LBACSYS', 
      'MDSYS', 'MGMT_VIEW','OLAPSYS','OWBSYS','ORDPLUGINS', 'ORDSYS',
      'SI_INFORMTN_SCHEMA','SYS','SYSMAN','SYSTEM', 'TSMSYS','WK_TEST',
      'WKPROXY','WMSYS','XDB','APEX_040000', 'APEX_PUBLIC_USER','DIP', 
      'FLOWS_30000','FLOWS_FILES','MDDATA', 'ORACLE_OCM', 'XS$NULL',
      'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR',
      'OUTLN', 'WKSYS', 'APEX_040200','OJVMSYS') order by 1;

