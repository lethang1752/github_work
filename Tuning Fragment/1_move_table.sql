CREATE OR REPLACE PROCEDURE move_table (
    oldtablespace IN VARCHAR2,
    newtablespace IN VARCHAR2
) IS

    a VARCHAR2(250);
    CURSOR c1 IS
    SELECT DISTINCT
        owner,
        segment_name,
        partition_name
    FROM
        dba_segments
    WHERE
            tablespace_name = oldtablespace
        AND segment_type LIKE '%TABLE PARTITION%'
    ORDER BY
        owner;

    CURSOR c2 IS
    SELECT DISTINCT
        owner,
        segment_name,
        segment_type
    FROM
        dba_segments
    WHERE
            tablespace_name = oldtablespace
        AND segment_type LIKE '%TABLE%'
    ORDER BY
        owner;

    CURSOR c3 IS
    SELECT
        l.owner       owner,
        l.table_name  tablename,
        l.column_name columnname,
        l.tablespace_name,
        s.segment_name,
        s.segment_type
    FROM
             dba_lobs l
        JOIN dba_segments s ON l.segment_name = s.segment_name
    WHERE
        s.segment_type LIKE 'LOBSEGMENT'
        AND s.tablespace_name = oldtablespace;

    CURSOR c4 IS
    SELECT
        table_owner,
        table_name,
        partition_name,
        column_name
    FROM
        dba_lob_partitions
    WHERE
        tablespace_name = oldtablespace;

BEGIN
    FOR t1 IN c1 LOOP
        BEGIN
            a := 'alter table '
                 || t1.owner
                 || '.'
                 || t1.segment_name
                 || ' move partition '
                 || t1.partition_name
                 || ' tablespace '
                 || newtablespace
                 || ';';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    FOR t1 IN c2 LOOP
        BEGIN
            a := 'alter table '
                 || t1.owner
                 || '.'
                 || t1.segment_name
                 || ' move tablespace '
                 || newtablespace
                 || ';';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    FOR t1 IN c3 LOOP
        BEGIN
            a := 'alter table '
                 || t1.owner
                 || '.'
                 || t1.tablename
                 || ' move lob('
                 || t1.columnname
                 || ') store as (tablespace '
                 || newtablespace
                 || ');';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    FOR t1 IN c4 LOOP
        a := 'alter table '
             || t1.table_owner
             || '.'
             || t1.table_name
             || ' move partition '
             || t1.partition_name
             || ' lob ('
             || t1.column_name
             || ') store as basicfile (tablespace '
             || newtablespace
             || ');';

        dbms_output.put_line(a);
    END LOOP;

END move_table;