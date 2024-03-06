CREATE OR REPLACE PROCEDURE refresh_mview IS

    a VARCHAR2(250);
    CURSOR c IS
    SELECT
        owner,
        object_name,
        object_type
    FROM
        dba_objects
    WHERE
            status = 'INVALID'
        AND object_type = 'MATERIALIZED VIEW';

BEGIN
    FOR t1 IN c LOOP
        a := 'DBMS_SNAPSHOT.REFRESH('
             || t1.owner
             || '.'
             || t1.object_name
             || ')';

        EXECUTE IMMEDIATE a;
    END LOOP;
END refresh_mview;