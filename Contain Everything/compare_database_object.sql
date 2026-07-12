--compare tcdnrp
WITH source_data AS (
    SELECT owner, object_type, COUNT(*) AS cnt
    FROM dba_objects@DB_LINK_COMPARE
    WHERE owner IN ('KT_ABIC','QUYLV','TUNGH','TOANDT','NAMLT','BK','R_ABIC','TUNGNV','W_ABIC')
    GROUP BY owner, object_type
),
target_data AS (
    SELECT owner, object_type, COUNT(*) AS cnt
    FROM dba_objects
    WHERE owner IN ('KT_ABIC','QUYLV','TUNGH','TOANDT','NAMLT','BK','R_ABIC','TUNGNV','W_ABIC')
    GROUP BY owner, object_type
)
SELECT COALESCE(s.owner, t.owner) AS owner,COALESCE(s.object_type, t.object_type) AS object_type,NVL(s.cnt, 0) AS source_count,NVL(t.cnt, 0) AS target_count,(NVL(t.cnt, 0) - NVL(s.cnt, 0)) AS diff
FROM source_data s
FULL OUTER JOIN target_data t ON s.owner = t.owner AND s.object_type = t.object_type
WHERE NVL(s.cnt, 0) != NVL(t.cnt, 0)
ORDER BY owner, object_type;

--minus index
select 'SELECT DBMS_METADATA.GET_DDL(''INDEX'','''||index_name||''', ''BK'') FROM DUAL;' from (
select index_name from dba_indexes@DB_LINK_COMPARE where owner='BK'
minus
select index_name from dba_indexes where owner='BK'
);

-- minus grant table - dba_tab_privs - dba_role_privs - dba_sys_privs
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||username||';' from (SELECT
    grantee AS username,
    owner,
    table_name,
    privilege
FROM
    dba_tab_privs@db_link_compare
WHERE
    grantee IN ( 'FLOWS_FILES', 'KT_ABIC', 'PHUONGNN', 'BC_ABIC', 'W_APP',
                 'TUANDN', 'W_HSKT', 'TOANDT', 'ABIMOD', 'GGADMIN',
                 'HIEUNT', 'READONLY', 'MANHDC', 'PMNV', 'TUANNV',
                 'QUYLV', 'SELECT_ALL', 'TAIPA', 'ANHPD', 'DBL_TCDNDEV',
                 'PT_MONITOR', 'BI_ABIC', 'TESTLINK', 'TRIPM', 'NAMLT',
                 'TUNGH', 'HIEUVT', 'GUEST', 'BK', 'TUNGNV',
                 'W_ABIC', 'R_ABIC', 'DATVT' )
MINUS
SELECT
    grantee AS username,
    owner,
    table_name,
    privilege
FROM
    dba_tab_privs
WHERE
    grantee IN ( 'FLOWS_FILES', 'KT_ABIC', 'PHUONGNN', 'BC_ABIC', 'W_APP',
                 'TUANDN', 'W_HSKT', 'TOANDT', 'ABIMOD', 'GGADMIN',
                 'HIEUNT', 'READONLY', 'MANHDC', 'PMNV', 'TUANNV',
                 'QUYLV', 'SELECT_ALL', 'TAIPA', 'ANHPD', 'DBL_TCDNDEV',
                 'PT_MONITOR', 'BI_ABIC', 'TESTLINK', 'TRIPM', 'NAMLT',
                 'TUNGH', 'HIEUVT', 'GUEST', 'BK', 'TUNGNV',
                 'W_ABIC', 'R_ABIC', 'DATVT' ));