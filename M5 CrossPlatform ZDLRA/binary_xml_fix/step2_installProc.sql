set serveroutput on;
spool step2_installProc.log


create table XDB$XMLTABLE_CLOBCOPY(
  owner VARCHAR2(128),
  table_name varchar2(128)
);



create table XDB$XML_COLUMN_CLOBCOPY(
  owner VARCHAR2(128),
  table_name varchar2(128),
  column_name varchar2(128)
);


create or replace procedure copyBinXmlTypeTable(owner varchar2, 
                                                table_name varchar2)
as  
  new_table_name varchar2(100);
  stmt VARCHAR2(3000);
begin
  insert into XDB$XMLTABLE_CLOBCOPY values (owner, table_name);
  dbms_output.put_line('copying binary xml type table: ' || owner || '.' || table_name);

  new_table_name := table_name || '_CL$CP$';
  stmt := 'CREATE TABLE "' || new_table_name || '" AS (';
  stmt := stmt || 'SELECT SYS_NC_OID$ "OID" , x.object_value.getClobVal() "CLOB" ';
  stmt := stmt || 'FROM "' || owner || '"."' || table_name ||'" x)';

  dbms_output.put_line(stmt); 
  execute immediate(stmt);

  stmt := 'TRUNCATE TABLE "' ||  owner || '"."' || table_name || '"';
  dbms_output.put_line(stmt); 
  execute immediate(stmt);
  commit;
end;
/


create or replace procedure copyBinXmlTypeTables AS
 CURSOR xmltab_cur IS
   SELECT owner, table_name FROM  dba_xml_tables WHERE storage_type = 'BINARY';
  xmltab   xmltab_cur%ROWTYPE;
begin
  open xmltab_cur;
  loop
    fetch xmltab_cur into xmltab;
    exit when xmltab_cur%NOTFOUND;
      copyBinXmlTypeTable(xmltab.owner, xmltab.table_name);
  end loop;
  close xmltab_cur;
end;
/



create or replace procedure copyBinXmlTypeColumn(owner varchar2, 
                                                table_name varchar2,
                                                column_name varchar2) AS
  new_column_name varchar2(100);
  stmt VARCHAR2(3000);
begin
  dbms_output.put_line('INFO: copying binary xml type column: ' || owner || '.' || table_name || '.'|| column_name);
  insert into XDB$XML_COLUMN_CLOBCOPY values (owner, table_name, column_name);
  new_column_name := column_name || '_CL$CP$';
  stmt := 'ALTER TABLE "' || owner || '"."' || table_name || '" ADD ("' || new_column_name || '" CLOB)';
  dbms_output.put_line(stmt); 
  execute immediate(stmt);

  stmt := 'UPDATE "' || owner || '"."' || table_name || '" tab$$ SET "' ||  new_column_name || '" =  tab$$."' || column_name || '".getClobVal()' ;
  dbms_output.put_line(stmt); 
  execute immediate(stmt);
  commit;
end;
/




create or replace procedure copyBinXmlTypeColumns AS
 CURSOR xmltabcol_cur IS
   SELECT owner, table_name, column_name FROM  dba_xml_tab_cols WHERE storage_type = 'BINARY';
  xmltabcol   xmltabcol_cur%ROWTYPE;
begin
  open xmltabcol_cur;
  loop
    fetch xmltabcol_cur into xmltabcol;
    exit when xmltabcol_cur%NOTFOUND;
      copyBinXmlTypeColumn(xmltabcol.owner, xmltabcol.table_name, xmltabcol.column_name);
  end loop;
  close xmltabcol_cur;
end;
/

create or replace procedure recreateBinXmlTypeColumn(owner varchar2, 
                                                     table_name varchar2,
                                                     column_name varchar2) AS
  new_column_name varchar2(100);
  stmt VARCHAR2(3000);
begin

 new_column_name := column_name || '_CL$CP$';

 dbms_output.put_line('recreating binary xml type column: ' || owner || '.' || table_name || '.'|| column_name);
 
  stmt := 'UPDATE "' || owner || '"."' || table_name || '" tab$$ SET "' ||  column_name || '" = xmltype(tab$$."' || new_column_name || '") WHERE tab$$."' || new_column_name || '" IS NOT NULL' ;
  dbms_output.put_line(stmt); 
  execute immediate(stmt);

  stmt := 'ALTER TABLE "' || owner || '"."' || table_name || '" DROP COLUMN "' || new_column_name || '"';

  dbms_output.put_line(stmt); 
  execute immediate(stmt);
  commit;
end;
/


create or replace procedure recreateBinXmlTypeColumns AS
CURSOR xcol_cur IS
   SELECT owner, table_name, column_name FROM  XDB$XML_COLUMN_CLOBCOPY;
    xcol  xcol_cur%ROWTYPE;
begin
  open xcol_cur;
  loop
    fetch xcol_cur into xcol;
    exit when xcol_cur%NOTFOUND;
      recreateBinXmlTypeColumn(xcol.owner, xcol.table_name, xcol.column_name);
  end loop;
  close xcol_cur;
end;
/



create or replace procedure recreateBinXmlTypeTable(owner varchar2, 
                                                    table_name varchar2)
as  
  new_table_name varchar2(100);
  stmt VARCHAR2(3000);
begin

  new_table_name := table_name || '_CL$CP$';
  dbms_output.put_line('recreating binary xml type table: ' || owner || '.' || table_name);

  stmt := 'INSERT INTO "' || owner || '"."' || table_name || '" (sys_nc_oid$, object_value) SELECT OID, xmltype(CLOB)  from "' ||  new_table_name || '"';
  
  dbms_output.put_line(stmt); 
  execute immediate(stmt);

  stmt := 'DROP TABLE "' || new_table_name || '"' ;
  dbms_output.put_line(stmt); 
  execute immediate(stmt);

  commit;
end;
/


create or replace procedure recreateBinXmlTypeTables AS
 CURSOR xmltab_cur IS
   SELECT owner, table_name FROM  XDB$XMLTABLE_CLOBCOPY;
  xmltab   xmltab_cur%ROWTYPE;
begin
  open xmltab_cur;
  loop
    fetch xmltab_cur into xmltab;
    exit when xmltab_cur%NOTFOUND;
      recreateBinXmlTypeTable(xmltab.owner, xmltab.table_name);
  end loop;
  close xmltab_cur;
end;
/


create or replace procedure replaceTokenTables AS
  TT     VARCHAR2(26);
  qnTT   VARCHAR2(100);
  nmTT   VARCHAR2(100);
  stmt   VARCHAR2(100);
begin
  select TOKSUF into TT from xdb.xdb$ttset;
  qnTT := 'XDB.X$QN' || TT;
  nmTT := 'XDB.X$NM' || TT;

  dbms_output.put_line('.');
  dbms_output.put_line('qname token table: ' || qnTT);
  dbms_output.put_line('namespace token table '|| nmTT);

  stmt := 'TRUNCATE TABLE ' || qnTT;
  dbms_output.put_line(stmt);
  execute immediate(stmt);

  stmt := 'TRUNCATE TABLE ' || nmTT;
  dbms_output.put_line(stmt);
  execute immediate(stmt);

  stmt := 'INSERT INTO ' || qnTT || ' SELECT * FROM  XDB$TT_TEMP$';
  dbms_output.put_line(stmt);
  execute immediate(stmt);

  stmt := 'INSERT INTO ' || nmTT || ' SELECT * FROM  XDB$NM_TEMP$';
  dbms_output.put_line(stmt);
  execute immediate(stmt);

end;
/ 

quit;