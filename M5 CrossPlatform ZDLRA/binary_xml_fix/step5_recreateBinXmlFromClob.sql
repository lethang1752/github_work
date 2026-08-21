set serveroutput on;
spool step5_recreateBinXmlFromClob.log

exec recreateBinXmlTypeTables;

exec recreateBinXmlTypeColumns;


drop table XDB$XMLTABLE_CLOBCOPY;
drop table XDB$XML_COLUMN_CLOBCOPY;
drop procedure copyBinXmlTypeTables;
drop procedure copyBinXmlTypeTable;
drop procedure copyBinXmlTypeColumns;
drop procedure copyBinXmlTypeColumn;
drop procedure recreateBinXmlTypeColumns;
drop procedure recreateBinXmlTypeColumn;
drop procedure recreateBinXmlTypeTables;
drop procedure recreateBinXmlTypeTable;
drop procedure replaceTokenTables;
quit;
