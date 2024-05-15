alter session set nls_date_format='YYYY-MM-DD-HH24:MI:SS';
set serveroutput on linesize 150 pagesize 999 echo off verify off pagesize 999 linesize 150 trim on trimspool on heading on

spool precheck_sparc_before_migrate.log
Prompt
Prompt #1. Check tablespace self-containment
declare 
 checklist varchar2(4000); 
 i number := 0; 
begin 
 for ts in 
 (select tablespace_name 
 from dba_tablespaces 
 where tablespace_name not in ('SYSTEM','SYSAUX') 
 and contents = 'PERMANENT') 
 loop 
 if (i=0) then 
 checklist := ts.tablespace_name; 
 else 
 checklist := checklist||','||ts.tablespace_name; 
 end if; 
 i := 1; 
 end loop;
 dbms_output.put_line ('TBS_TRANSPORT_SET='||checklist); 
 dbms_tts.transport_set_check(checklist,TRUE,TRUE); 
end; 
/
Prompt TBS_TRANSPORT_VIOLATIONS:
select * from transport_set_violations;

Prompt
Prompt #2. Database timezone
select version from v$timezone_file;

Prompt 
Prompt #3. NLS LANGUAGE
col PARAMETER format a60
col value format a60
select * from NLS_DATABASE_PARAMETERS where PARAMETER in ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET');

Prompt
Prompt #4. Check tables with XMLTYPE datatype
col schema_name format a30
col table_name format a30
col column_name format a30
col data_type format a40
select col.owner as schema_name,
       col.table_name,
       column_id,
       column_name,
       data_type
from sys.dba_tab_cols col
join sys.dba_tables tab on col.owner = tab.owner
                        and col.table_name = tab.table_name
where col.data_type like '%XMLTYPE%'
      and col.owner not in 
      ('ANONYMOUS','CTXSYS','DBSNMP','EXFSYS', 'LBACSYS', 
      'MDSYS', 'MGMT_VIEW','OLAPSYS','OWBSYS','ORDPLUGINS', 'ORDSYS',
      'SI_INFORMTN_SCHEMA','SYS','SYSMAN','SYSTEM', 'TSMSYS','WK_TEST',
      'WKPROXY','WMSYS','XDB','APEX_040000', 'APEX_PUBLIC_USER','DIP', 
      'FLOWS_30000','FLOWS_FILES','MDDATA', 'ORACLE_OCM', 'XS$NULL',
      'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR', 'PUBLIC',
      'OUTLN', 'WKSYS', 'APEX_040200')
order by col.owner,
         col.table_name,
         column_id;

Prompt 
Prompt #5. Get list of users
col USERNAME format a30
col PROFILE format a30
select USERNAME, ORACLE_MAINTAINED, ACCOUNT_STATUS,PROFILE, DEFAULT_TABLESPACE from dba_users order by 2,1;

Prompt 
Prompt #6. Get DB option
select * from v$option order by 2,1;

Prompt
Prompt #7. Get invalid object info
Prompt #Count object per user
col owner format a30
select owner, count(*) from dba_objects GROUP BY OWNER;

Prompt #Count invalid object per user
col owner format a30
select owner, count(*) from dba_objects where status <> 'VALID' GROUP BY OWNER;

col name format a40
Prompt
Prompt #List of invalid objects
col owner format a30
col object_name  format a50
col object_type format a50
select OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS,EDITIONABLE,ORACLE_MAINTAINED 
from dba_objects where status <>'VALID' order by 1,2;

spool off