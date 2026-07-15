SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LONG 2000000;
SET PAGESIZE 0;

DECLARE
    v_username VARCHAR2(30) := 'USERNAME'; -- Must be UPPERCASE
    v_ddl      CLOB;
    v_count    NUMBER;
BEGIN
    dbms_output.put_line('-- =========================================');
    dbms_output.put_line('-- DDL FOR USER: ' || v_username);
    dbms_output.put_line('-- =========================================');

    -- 1. BASE USER CREATION DDL
    BEGIN
        v_ddl := dbms_metadata.get_ddl('USER', v_username);
        dbms_output.put_line(v_ddl || ';');
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('-- Error getting user creation DDL: ' || SQLERRM);
    END;

    -- 2. TABLESPACE QUOTAS
    BEGIN
        SELECT COUNT(*) INTO v_count FROM dba_ts_quotas WHERE username = v_username;
        IF v_count > 0 THEN
            v_ddl := dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', v_username);
            dbms_output.put_line(v_ddl || ';');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- 3. GRANTED ROLES
    BEGIN
        SELECT COUNT(*) INTO v_count FROM dba_role_privs WHERE grantee = v_username;
        IF v_count > 0 THEN
            v_ddl := dbms_metadata.get_granted_ddl('ROLE_GRANT', v_username);
            dbms_output.put_line(v_ddl || ';');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- 4. SYSTEM PRIVILEGES
    BEGIN
        SELECT COUNT(*) INTO v_count FROM dba_sys_privs WHERE grantee = v_username;
        IF v_count > 0 THEN
            v_ddl := dbms_metadata.get_granted_ddl('SYSTEM_GRANT', v_username);
            dbms_output.put_line(v_ddl || ';');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- 5. OBJECT PRIVILEGES
    BEGIN
        SELECT COUNT(*) INTO v_count FROM dba_tab_privs WHERE grantee = v_username;
        IF v_count > 0 THEN
            v_ddl := dbms_metadata.get_granted_ddl('OBJECT_GRANT', v_username);
            dbms_output.put_line(v_ddl || ';');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
END;
/