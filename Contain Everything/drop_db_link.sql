CREATE OR REPLACE PROCEDURE drop_private_dblink
    (p_dblink_name IN VARCHAR2,
     p_owner IN VARCHAR2)
IS
    v_count NUMBER;
BEGIN
    -- Check if the database link exists for the specified owner
    SELECT COUNT(*)
    INTO v_count
    FROM DBA_DB_LINKS
    WHERE DB_LINK = UPPER(p_dblink_name)
    AND OWNER = UPPER(p_owner);

    -- If database link exists, drop it
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP DATABASE LINK "' || p_owner || '"."' || p_dblink_name || '"';
        DBMS_OUTPUT.PUT_LINE('Database link ' || p_owner || '.' || p_dblink_name || ' dropped successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Database link ' || p_owner || '.' || p_dblink_name || ' does not exist.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle any errors that occur during execution
        DBMS_OUTPUT.PUT_LINE('Error dropping database link: ' || SQLERRM);
        RAISE;
END drop_private_dblink;
/

EXEC drop_private_dblink('link_name', 'schema_owner');

GRANT EXECUTE ON drop_private_dblink TO username;

---------------------------------------------------------------------------------------------------------------------
--GET DDL PUBLIC DB LINK
set echo off
set verify off
set pagesize 2000
set linesize 500
set trim on
set heading off
set feedback off
set long 99999
spool tmp.sql
select 'select dbms_metadata.get_ddl(''DB_LINK'', '''||DB_LINK||''', ''PUBLIC'')||'';'' from dual;' from dba_db_links where owner='PUBLIC' ;
spool sync_public_dblink.sql
set trimspool on
set linesize 200
set longchunksize 200000 long 200000 pages 0
@tmp
select 'exit;' from dual;
spool off;
! rm tmp.sql
exit;

--GET DDL NON-PUBLIC DB LINK
set echo off
set verify off
set pagesize 2000
set linesize 500
set trim on
set heading off
set feedback off
set long 99999
spool tmp.sql
select 'select dbms_metadata.get_ddl(''DB_LINK'', '''||DB_LINK||''', '''||OWNER||''')||'';'' from dual;' from dba_db_links where owner <> 'PUBLIC' ;
spool sync_non_public_dblink.sql
set trimspool on
set linesize 200
set longchunksize 200000 long 200000 pages 0
@tmp
select 'exit;' from dual;
spool off;
! rm tmp.sql
exit;
----------------------------------------------------------------------------------------------------------------------
--DROP PUBLIC DATABASE LINK
select 'drop public database link '||DB_LINK||';' from dba_db_links where owner='PUBLIC';

--DROP DATABASE LINK
create directory TEMP as  '/tmp';
define scrip_dir=/tmp;
define file_name=drop_dblink.sql;
DECLARE  
   F1 UTL_FILE.FILE_TYPE;
   CURSOR c  IS SELECT OWNER,DB_LINK FROM DBA_DB_LINKS WHERE OWNER <> 'PUBLIC';
   rec c%rowtype;
   dir_path VARCHAR2(50);
BEGIN
   SELECT DIRECTORY_NAME INTO dir_path FROM DBA_DIRECTORIES WHERE LOWER(DIRECTORY_PATH) = LOWER('&scrip_dir') AND ROWNUM <2;
   IF NOT c%ISOPEN THEN 
      OPEN c; 
   END IF; 
   F1:=UTL_FILE.fopen(location =>dir_path ,filename =>'&file_name' ,open_mode => 'w',max_linesize => 1000);
   FETCH c INTO rec;  
   WHILE c%FOUND   
   LOOP
   UTL_FILE.put(F1,'CREATE OR REPLACE PROCEDURE ' ||rec.OWNER||'.drop_dblink');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'IS');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'BEGIN');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'EXECUTE IMMEDIATE ''drop DATABASE LINK '||rec.DB_LINK||''';'); 
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'END;');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'/');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'EXEC '||rec.OWNER ||'.'||'drop_dblink;');
   UTL_FILE.new_line(F1);
   UTL_FILE.put(F1,'DROP PROCEDURE '||rec.OWNER ||'.'||'drop_dblink;');
   UTL_FILE.new_line(F1);
   UTL_FILE.new_line(F1);
   FETCH c INTO rec;
   END LOOP;
   UTL_FILE.fclose(F1);
   EXCEPTION
   WHEN NO_DATA_FOUND then
     DBMS_OUTPUT.put_line('EXPORT DIRECTORY DOESN''T EXIST .PLEASE CHECK DATABASE!!!!!!!!'); 
   WHEN OTHERS then
     DBMS_OUTPUT.put_line('LOI KHONG XAC DINH !!!!!!!!'); 
END;
/