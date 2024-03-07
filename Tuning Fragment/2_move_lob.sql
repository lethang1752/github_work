CREATE OR REPLACE PROCEDURE move_lob (
    oldtablespace IN VARCHAR2,
    newtablespace IN VARCHAR2
) IS

    executestatement VARCHAR2(500);
    isexecute        NUMBER;
    currenttable     VARCHAR(50);
    isnewtable       NUMBER;
    CURSOR c IS
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
        AND s.tablespace_name = oldtablespace
        AND l.column_name NOT LIKE '%"%'
    ORDER BY
        1,
        2;

BEGIN
    currenttable := 'current';
    isexecute := 0;
    isnewtable := 0;
    executestatement := 'statement';
    FOR t1 IN c LOOP
        BEGIN
            IF ( currenttable != t1.tablename ) THEN
                currenttable := t1.tablename;
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
                                    || t1.owner
                                    || '.'
                                    || t1.tablename
                                    || ' move lob('
                                    || t1.columnname
                                    || ') store as (tablespace '
                                    || newtablespace
                                    || ');';
            ELSE
                executestatement := executestatement
                                    || chr(10)
                                    || 'alter table '
                                    || t1.owner
                                    || '.'
                                    || t1.tablename
                                    || ' move lob('
                                    || t1.columnname
                                    || ') store as (tablespace '
                                    || newtablespace
                                    || ');';
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                CONTINUE;
        END;
    END LOOP;

    dbms_output.put_line(executestatement);
END move_lob;