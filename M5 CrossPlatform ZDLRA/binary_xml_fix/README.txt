Migration of Token Table Information (Qname and Namespaces) from an Oracle 11.2 Database to 12.1 database to enable Transportable Table Set (TTS) Import of Binary XML data.


Date: 8/4/2017
Author: bhammers
Version: 1.0


Short Description of problem:
Binary XML uses tokens to compress/encode XML Data. The token ids and their value (Tag name) are stored in a central token table. During TTS import of data the tokens need to be reused, that means tokens on the exporting side and importing side cannot conflict with each other. In case of a conflict not XL data can be imported and an error message is raised during TTS import.

Solution provided by these scripts:
We prevent a token conflict during TTS import by pruning the existing token table on the importing side and only use the tokens from the exporting side.


General Note: the script outputs the operations it is executing (SET SERVEROIUTPUT ON) and spools to .log file. Please check this output for any errors (ORA-...). If you run into any error(s) please contact support. This patch only completes correctly if no error is being raised during execution.

----------------------------------------------------------------------
Execute the following ON THE EXPORTING SIDE to copy the two Token Tables (QN and NM) to temp tables

sqlplus system/password_xxx

set serveroutput on
declare
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

  -- copy
  stmt := 'CREATE TABLE XDB$TT_TEMP$ AS SELECT * FROM ' || qnTT;
  execute immediate (stmt);

  -- copy
  stmt := 'CREATE TABLE XDB$NM_TEMP$ AS SELECT * FROM ' || nmTT;
  execute immediate (stmt);

  commit;
end;
/

The two tables XDB$TT_TEMP$ and XDB$NM_TEMP$ should exist and be non-empty now.

Get DDL of 2 table from source side, they should be owned by system user.

These tables have to be copied to the IMPORTING side. Using DDL from source side and replace owner from system to sys to create table in target side.
Use a database link (INSERT AS SELECT) , conventional export/import or other means to move these two tables to the database where you want to import the data.

sqlplus / as sysdba

create database link binary_xml
connect to system identified by password_xxx
using 'source_ip:1521/source_service';

select count(*) from "SYSTEM".XDB$TT_TEMP$"@binary_xml;
select count(*) from "SYSTEM".XDB$NM_TEMP$"@binary_xml;

create "SYS"."XDB$TT_TEMP$"...
create "SYS"."XDB$NM_TEMP$"...

insert into "SYS"."XDB$TT_TEMP$"
select * from "SYSTEM".XDB$TT_TEMP$"@binary_xml;
insert into "SYS"."XDB$NM_TEMP$"
select * from "SYSTEM".XDB$NM_TEMP$"@binary_xml;

-----------------------------------------------------------------
Now, on the IMPORTING process as follow:

Open, read and run
step1_precheck.sql
***
*** Do not proceed if any of the 4 queries does not return the expected result
*** and contact Oracle support in this case. 
***


Next, run
step2_installProc.sql
to install the required pl/sql procedures

Next, run
step3_cpBinXmlToClob.sql
to perform the migration of token tables

Next, Shutdown and restart the database
**** You need to shutdown/restart here to clear all caches!!!
**** If you do not restart the db here, subsequent operations to reencode 
**** the data will fail!!


Next, run
step5_recreateBinXmlFromClob.sql
to re-encode data using the original tokens.


Next:
perform TTS export import of the data
you should not see any merge conflict during TTS import 
