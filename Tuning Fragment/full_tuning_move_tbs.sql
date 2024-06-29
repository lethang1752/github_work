--move table partition

SELECT
    'alter table '
    || owner
    || '.'
    || segment_name
    || ' move partition '
    || partition_name
    || ' tablespace NEW_TABLESPACE;'
FROM
    dba_segments
WHERE
    tablespace_name = 'OLD_TABLESPACE'
    AND segment_type LIKE '%TABLE PARTITION%';

--move table

SELECT
    'alter table '
    || owner
    || '.'
    || segment_name
    || ' move tablespace NEW_TABLESPACE;'
FROM
    dba_segments
WHERE
    tablespace_name = 'OLD_TABLESPACE'
    AND segment_type LIKE '%TABLE%';

--move lob

SELECT  
    'alter table '
    || l.owner
    || '.'
    || l.table_name
    || ' move lob ('
    || l.column_name
    || ') store as (tablespace NEW_TABLESPACE);'
FROM
    dba_lobs l
    JOIN dba_segments s 
    ON l.segment_name = s.segment_name
WHERE
    s.segment_type LIKE 'LOBSEGMENT'
    AND s.tablespace_name = 'OLD_TABLESPACE'
    AND l.column_name NOT LIKE '%"%';

--move lob partition

SELECT
    'alter table '
    || table_owner
    || '.'
    || table_name
    || ' move partition '
    || partition_name
    || ' lob ('
    || column_name
    || ') store as (tablespace NEW_TABLESPACE);'
FROM
    dba_lob_partitions
WHERE
    tablespace_name = 'OLD_TABLESPACE';

--move index

SELECT
    'alter index '
    || index_owner
    || '.'
    || index_name
    || ' rebuild partition '
    || partition_name
    || ' tablespace NEW_TABLESPACE;'
FROM
    dba_ind_partitions
WHERE
    tablespace_name = 'OLD_TABLESPACE';

SELECT
    'alter index '
    || index_owner
    || '.'
    || index_name
    || ' rebuild tablespace NEW_TABLESPACE;'
FROM 
    dba_indexes
WHERE
    tablespace_name = 'OLD_TABLESPACE';

SELECT 
    'alter index '
    || index_owner
    || '.'
    || index_name
    || ' rebuild subpartition '
    || subpartition_name
    || ' tablespace NEW_TABLESPACE;'
FROM
    dba_ind_subpartitions
WHERE
    tablespace_name = 'OLD_TABLESPACE';

--check segments left on tablespace

SELECT
    segment_type,
    count(*)
FROM
    dba_segments
WHERE 
    tablespace_name = 'OLD_TABLESPACE'
GROUP BY 
    segment_type;
