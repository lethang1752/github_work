--DROP PUBLIC DATABASE LINK
select 'drop public database link '||DB_LINK||';' from dba_db_links where owner='PUBLIC';

--DROP DATABASE LINK
create or replace directory TEMP as  '/tmp';
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
   UTL_FILE.put(F1,'EXECUTE IMMEDIATE ''DROP DATABASE LINK '||rec.DB_LINK||''';'); 
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