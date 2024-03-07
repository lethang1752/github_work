/* Formatted on 2/20/2024 2:01:59 PM (QP5 v5.401) */
CREATE OR REPLACE PROCEDURE move_table (oldtablespace   IN VARCHAR2,
                                             newtablespace   IN VARCHAR2)
IS
    a   VARCHAR2 (250);

    CURSOR c1 IS
          SELECT DISTINCT owner, SEGMENT_NAME, partition_name
            FROM dba_segments
           WHERE     tablespace_name = oldtablespace
                 AND segment_type LIKE '%TABLE PARTITION%'
        ORDER BY owner;

    CURSOR c2 IS
          SELECT DISTINCT owner, SEGMENT_NAME, segment_type
            FROM dba_segments
           WHERE     tablespace_name = oldtablespace
                 AND segment_type LIKE '%TABLE%'
        ORDER BY owner;
BEGIN
    FOR t1 IN c1
    LOOP
        BEGIN
            a :=
                   'alter table '
                || t1.owner
                || '.'
                || t1.SEGMENT_NAME
                || ' move partition '
                || t1.partition_name
                || ' tablespace '
                || newtablespace;

            EXECUTE IMMEDIATE a;
        EXCEPTION
            WHEN OTHERS
            THEN
                CONTINUE;
        END;

        DBMS_OUTPUT.PUT_LINE (a);
    END LOOP;

    FOR t1 IN c2
    LOOP
        BEGIN
            a :=
                   'alter table '
                || t1.owner
                || '.'
                || t1.SEGMENT_NAME
                || ' move tablespace '
                || newtablespace;
            DBMS_OUTPUT.PUT_LINE (a);

            EXECUTE IMMEDIATE a;
        EXCEPTION
            WHEN OTHERS
            THEN
                CONTINUE;
        END;
    END LOOP;
    
END move_table;