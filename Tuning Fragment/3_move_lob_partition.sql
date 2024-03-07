CREATE OR REPLACE PROCEDURE move_lob_partition (
    oldtablespace IN VARCHAR2,
    newtablespace IN VARCHAR2
) IS

    executestatement VARCHAR2(500);
    isexecute        NUMBER;
    currenttable     VARCHAR(50);
    isnewtable       NUMBER;
    CURSOR c IS
    SELECT
        table_owner,
        table_name,
        partition_name,
        column_name
    FROM
        dba_lob_partitions
    WHERE
        tablespace_name = oldtablespace
    ORDER BY
        1,
        2,
        3;

BEGIN
    currenttable := 'current';
    isexecute := 0;
    isnewtable := 0;
    executestatement := 'statement';
    FOR t1 IN c LOOP
        BEGIN
            IF ( currenttable != t1.table_name ) THEN
                currenttable := t1.table_name;
                isnewtable := 1;
                IF ( executestatement = 'statement' ) THEN
                    isexecute := 0;
                ELSE
                    isexecute := 1;
                END IF;

            ELSE
                isnewtable := 0;
            END IF;

            IF ( isexecute = 1 ) THEN
                dbms_output.put_line(executestatement);

--EXECUTE IMMEDIATE executeStatement;
                executestatement := 'statement';
                isexecute := 0;
            END IF;

            IF isnewtable = 1 THEN
                executestatement := 'alter table '
                                    || t1.table_owner
                                    || '.'
                                    || t1.table_name
                                    || ' move partition '
                                    || t1.partition_name
                                    || ' lob ('
                                    || t1.column_name
                                    || ') store as (tablespace '
                                    || newtablespace
                                    || ')';
            ELSE
                executestatement := executestatement
                                    || chr(10)
                                    || 'alter table '
                                    || t1.table_owner
                                    || '.'
                                    || t1.table_name
                                    || ' move partition '
                                    || t1.partition_name
                                    || ' lob ('
                                    || t1.column_name
                                    || ') store as (tablespace '
                                    || newtablespace
                                    || ')';
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    dbms_output.put_line(executestatement);
END move_lob_partition;