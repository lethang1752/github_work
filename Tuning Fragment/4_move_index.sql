CREATE OR REPLACE PROCEDURE move_index (
    oldtablespace IN VARCHAR2,
    newtablespace IN VARCHAR2
) IS

    a VARCHAR2(250);
    CURSOR c1 IS
    SELECT
        index_owner     owner,
        index_name      indexname,
        partition_name  partitionname,
        tablespace_name tablespacename
    FROM
        dba_ind_partitions
    WHERE
        tablespace_name = oldtablespace
    ORDER BY
        owner;

    CURSOR c2 IS
    SELECT
        owner      owner,
        index_name indexname
    FROM
        dba_indexes i
    WHERE
        i.tablespace_name = oldtablespace
    ORDER BY
        owner;

    CURSOR c3 IS
    SELECT
        index_owner       owner,
        index_name        indexname,
        subpartition_name subpartitionname,
        tablespace_name   tablespacename
    FROM
        dba_ind_subpartitions
    WHERE
        tablespace_name = oldtablespace
    ORDER BY
        owner;

BEGIN
    FOR t1 IN c1 LOOP
        BEGIN
            a := 'alter index '
                 || t1.owner
                 || '.'
                 || t1.indexname
                 || ' rebuild partition '
                 || t1.partitionname
                 || ' tablespace '
                 || newtablespace
                 || ' online';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    FOR t1 IN c2 LOOP
        BEGIN
            a := 'alter index '
                 || t1.owner
                 || '.'
                 || t1.indexname
                 || ' rebuild tablespace '
                 || newtablespace
                 || ' online';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    FOR t1 IN c3 LOOP
        BEGIN
            a := 'alter index '
                 || t1.owner
                 || '.'
                 || t1.indexname
                 || ' rebuild subpartition '
                 || t1.subpartitionname
                 || ' tablespace '
                 || newtablespace
                 || ' online';

            dbms_output.put_line(a);
        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

END move_index;