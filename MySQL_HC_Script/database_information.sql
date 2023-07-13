--Check Table Information
SELECT 
    CONCAT(TABLE_NAME) as 'TABLE',
    ENGINE,
    CONCAT(ROUND(TABLE_ROWS/1000000,2), 'M') 'ROWS',
    CONCAT(ROUND(DATA_LENGTH/1024/1024,2)) 'DATA (MB)',
    CONCAT(ROUND(INDEX_LENGTH/1024/1024,2)) 'IDX (MB)',
    CONCAT(ROUND(DATA_LENGTH + INDEX_LENGTH)/1024/1024,2) 'TOTAL SIZE (MB)',
    ROUND(INDEX_LENGTH/DATA_LENGTH,2) IDXFRAC,
    ROUND(DATA_FREE/(INDEX_LENGTH+DATA_LENGTH)*100) 'FRAG RATIO'
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_SCHEMA='$dbname'
ORDER BY 
    DATA_LENGTH + INDEX_LENGTH DESC;

--Check Database Information

SELECT TABLE_SCHEMA 'DATABASE NAME', 
CONCAT(ROUND(SUM(INDEX_LENGTH+DATA_LENGTH)/1024/1024/1024,2)) 'DATABASE SIZE (GB)'
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA='oggdb1';


(SELECT MYSQL_VERSION FROM SYS.VERSION) 'VERSION',

--Check Database File Information

SELECT 
    FILE_ID 'FILE ID',
    TABLESPACE_NAME 'TABLESPACE NAME',
    FILE_NAME 'FILE NAME',
    ENGINE 'ENGINE',
    CREATE_TIME 'CREATE TIME',
    
--Check table partition status
SELECT
    TABLE_NAME 'TABLE OWNER',
    PARTITION_NAME 'PARTITION NAME',
    CONCAT(ROUND(DATA_LENGTH/1024/1024,2)) 'DATA SIZE (MB)',
    CONCAT(ROUND(INDEX_LENGTH/1024/1024,2)) 'INDEX SIZE (MB)',
    CONCAT(ROUND(DATA_FREE/1024/1024,2)) 'DATA FREE (MB)'
FROM
    INFORMATION_SCHEMA.PARTITIONS
WHERE
    TABLE_SCHEMA='$dbname'
ORDER BY
    DATA_FREE DESC;

--Check index 

--Check invalid
SELECT 
    TABLE_NAME
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA='$dbname'
    AND TABLE_TYPE='view'
    AND TABLE_ROWS IS NULL
    AND TABLE_COMMENT LIKE '%invalid%';

--Check table statistics
SELECT
    TABLE_NAME 'TABLE NAME',
    UPDATE_TIME 'DATE'
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA='oggdb1'
ORDER BY 
    UPDATE_TIME DESC;

SELECT
  UPDATE_TIME,
  TABLE_SCHEMA,
  TABLE_NAME
FROM
  information_schema.tables
WHERE
  1 = 1
  AND TABLE_SCHEMA = 'oggdb1'
ORDER BY
  UPDATE_TIME DESC,
  TABLE_SCHEMA,
  TABLE_NAME;