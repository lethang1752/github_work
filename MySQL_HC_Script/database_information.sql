--Check Table Information
SELECT CONCAT(table_name) as 'TABLE',
ENGINE,
CONCAT(ROUND(table_rows/1000000,2), 'M') 'ROWS',
CONCAT(ROUND(data_length/1024/1024,2)) 'DATA (MB)',
CONCAT(ROUND(index_length/1024/1024,2)) 'IDX (MB)',
CONCAT(ROUND(data_length + index_length)/1024/1024,2) 'TOTAL SIZE (MB)',
ROUND(index_length / data_length,2) IDXFRAC
FROM information_schema.TABLES
WHERE TABLE_SCHEMA="$dbname"
ORDER BY data_length + index_length DESC;