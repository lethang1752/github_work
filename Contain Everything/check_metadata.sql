set lines 200 pages 999
col owner format a20
col segment_type format a20
col size_mb format 9999999.99

PROMPT + METADATA_BY_OWNER

SELECT
    owner,
    segment_type,
    COUNT(*) AS segment_count,
    ROUND(SUM(bytes) / 1024 / 1024, 2) AS size_mb
FROM
    dba_segments
WHERE
    owner IN (
        SELECT username
        FROM dba_users
        WHERE account_status = 'OPEN'
          AND trunc(created) > (SELECT trunc(created) FROM dba_users WHERE username = 'SYS')
    )
GROUP BY
    owner,
    segment_type
ORDER BY
    owner,
    segment_count DESC;

PROMPT + METADATA_BY_TOTAL

SELECT
    segment_type,
    COUNT(*) AS total_count,
    ROUND(SUM(bytes) / 1024 / 1024, 2) AS total_size_mb
FROM
    dba_segments
WHERE
    owner IN (
        SELECT username
        FROM dba_users
        WHERE account_status = 'OPEN'
          AND trunc(created) > (SELECT trunc(created) FROM dba_users WHERE username = 'SYS')
    )
GROUP BY
    segment_type
ORDER BY
    total_count DESC;

exit
