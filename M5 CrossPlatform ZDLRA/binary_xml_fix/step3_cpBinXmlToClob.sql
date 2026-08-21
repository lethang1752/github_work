set serveroutput on;
spool step3_cpBinXmlToClob.log

exec copyBinXmlTypeTables;
exec copyBinXmlTypeColumns;
exec replaceTokenTables;
quit;
