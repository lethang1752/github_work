--Check Table Information
SELECT CONCAT(table_name) as 'TABLE',
ENGINE,
CONCAT(ROUND(table_rows/1000000,2), 'M') 'ROWS',
CONCAT(ROUND(data_length/1024/1024,2)) 'DATA (MB)',
CONCAT(ROUND(index_length/1024/1024,2)) 'IDX (MB)',
CONCAT(ROUND(data_length + index_length)/1024/1024,2) 'TOTAL SIZE (MB)',
ROUND(index_length / data_length,2) IDXFRAC,
ROUND(data_free/(index_length+data_length)*100) 'FRAG RATIO'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='$dbname'
ORDER BY data_length + index_length DESC;

--Check Database Information

SELECT table_schema 'DATABASE NAME', 
CONCAT(ROUND(SUM(index_length+data_length)/1024/1024/1024,2)) 'DATABASE SIZE (GB)'
FROM information_schema.tables 
WHERE table_schema='oggdb1';


(SELECT mysql_version FROM sys.version) 'VERSION',

--Check Database File Information

SELECT 
    FILE_ID 'FILE ID',
    TABLESPACE_NAME 'TABLESPACE NAME',
    FILE_NAME 'FILE NAME',
    ENGINE 'ENGINE',
    CREATE_TIME 'CREATE TIME',
    
    