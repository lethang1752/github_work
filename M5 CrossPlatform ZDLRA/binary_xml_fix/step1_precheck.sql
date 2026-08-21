set serveroutput on
spool step1_precheck.log

-- check 1) unknown binary xmltype tables, should be 0
-- EXPECTED RESULT: 0
SELECT count(1) 
FROM dba_xml_tables 
WHERE STORAGE_TYPE= 'BINARY'
AND OWNER NOT IN ('SYS', 'MDSYS', 'XDB', 'ORDDATA')  and table_name not in ('XDB$ACL', 'XDB$RESCONFIG', 'XDB$CONFIG' );


-- check 2) all xmltype columns owned by NOT SYS, should be 0
-- EXPECTED RESULT: 0 or 1. Its possible that MVREF$_STMT_STATS exists and this can be ignored
SELECT count(1)
FROM DBA_XML_TAB_COLS
WHERE STORAGE_TYPE= 'BINARY'
AND OWNER NOT IN ('SYS', 'MDSYS', 'XDB', 'ORDDATA');


-- check that new token are in temp table
-- they got inserted by either datapump or remote query or sqlldr
-- assumption: new tokens are available before any other migration step
-- below two queries have to return rows
-- do not start migration if these tables are empty (one or both) !!!!!

-- EXPECTED RESULT :> 0, typically hundreds to thousands
SELECT count(1) 
FROM XDB$TT_TEMP$;


-- EXPECTED RESULT :> 0, typically dozens to hundreds
SELECT count(1) 
FROM XDB$NM_TEMP$;



quit;