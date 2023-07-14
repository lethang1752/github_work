--Check Database Information (V)
SELECT 
    TABLE_SCHEMA 'DATABASE NAME', 
    (SELECT mysql_version FROM sys.version) 'VERSION',
    CONCAT(ROUND(SUM(INDEX_LENGTH+DATA_LENGTH)/1024/1024/1024,2)) 'DATABASE SIZE (GB)'
FROM 
    INFORMATION_SCHEMA.TABLES 
WHERE 
    TABLE_SCHEMA='$dbname';

--Check Log Variable Status (V)
SELECT
    VARIABLE_NAME 'LOG TYPE',
    VARIABLE_VALUE 'LOG STATUS'
FROM
    performance_schema.global_variables
WHERE
    VARIABLE_NAME IN ('log_error','binlog_error_action','general_log','general_log_file','slow_query_log','slow_query_log_file');

--Check Error Log (V)
SELECT
    *
FROM
    performance_schema.error_log
ORDER BY
    LOGGED DESC LIMIT 30;

--Check Table Information (V)
SELECT 
    CONCAT(TABLE_NAME) as 'TABLE',
    ENGINE,
    CONCAT(ROUND(TABLE_ROWS/1000000,2), 'M') 'ROWS',
    CONCAT(ROUND(DATA_LENGTH/1024/1024,2)) 'DATA (MB)',
    CONCAT(ROUND(INDEX_LENGTH/1024/1024,2)) 'IDX (MB)',
    CONCAT(ROUND(DATA_LENGTH + INDEX_LENGTH)/1024/1024,2) 'TOTAL SIZE (MB)',
    ROUND(INDEX_LENGTH/DATA_LENGTH,2) IDXFRAC,
    ROUND(DATA_FREE/(INDEX_LENGTH+DATA_LENGTH)*100) 'FRAG RATIO (%)'
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_SCHEMA='$dbname'
ORDER BY 
    DATA_LENGTH+INDEX_LENGTH DESC;

--Check Database File Information

*/
echo "<p>+ DB_FILE_SIZE</p>" >>$file_name
du -sh $dbhome/$dbname/* | $awk 'BEGIN{print("<table WIDTH='90%' BORDER='1'><tr><th>'FILENAME'</th><th>'SIZE'</th></tr>")}
{
	print("<tr><td>",$2,"</td><td>",$1,"</td></tr>")
}
END{
	print("</table><p><p>")
}' >>$file_name
*/

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