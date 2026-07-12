/*
============================================================================
 SCRIPT: compare_missing_objects.sql
 MUC DICH:
   - So sanh metadata giua SOURCE (qua DB LINK) va TARGET (local)
   - Sinh ra cau lenh DDL (CREATE / GRANT) cho nhung object con THIEU o TARGET
     sau qua trinh expdp/impdp
   - Bao gom: USER, ROLE, ROLE_GRANT, SYSTEM PRIVILEGE, OBJECT PRIVILEGE,
     DB_LINK, PROCEDURE, FUNCTION, PACKAGE, PACKAGE BODY

 GIA DINH:
   - Dang chay tren TARGET database, voi user co quyen DBA
     (hoac it nhat SELECT_CATALOG_ROLE + EXECUTE tren DBMS_METADATA)
   - Da co san DB LINK ten DB_LINK_COMPARE, tro tu TARGET -> SOURCE,
     ket noi bang user SYSTEM (hoac user co quyen doc dba_* / EXECUTE
     DBMS_METADATA ben SOURCE)
   - Logic MINUS: (SOURCE) MINUS (TARGET) => nhung gi co ben SOURCE
     nhung KHONG co ben TARGET => can tao lai o TARGET

 LUU Y KHI CHAY BANG SQL*PLUS:
   SET LONG 2000000
   SET LONGCHUNKSIZE 2000000
   SET PAGESIZE 0
   SET LINESIZE 32767
   SET TRIMSPOOL ON
   SET FEEDBACK OFF
   SET HEADING OFF
   SPOOL missing_objects.sql

   (DBMS_METADATA.GET_DDL tra ve CLOB, can SET LONG du lon de khong bi cat)
============================================================================
*/


-- ===========================================================================
-- (Tuy chon) Cau hinh DBMS_METADATA de output DDL gon hon, khong kem
-- STORAGE, TABLESPACE, cac thuoc tinh vat ly khac de tranh sinh DDL
-- gay loi/khac biet khong can thiet giua 2 moi truong.
-- Chay 1 lan dau session (ca ben SOURCE qua db link neu can, va ben TARGET)
-- ===========================================================================
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', FALSE);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', FALSE);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', FALSE);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
END;
/


-- ===========================================================================
-- 1. USER con thieu
-- ===========================================================================
PROMPT ===== MISSING USERS =====
SELECT DBMS_METADATA.GET_DDL('USER', u.username)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT username
    FROM dba_users@DB_LINK_COMPARE
    WHERE oracle_maintained='N'
    MINUS
    SELECT username
    FROM dba_users
    WHERE oracle_maintained='N'
) u;


-- ===========================================================================
-- 2. ROLE con thieu
-- ===========================================================================
PROMPT ===== MISSING ROLES =====
SELECT DBMS_METADATA.GET_DDL('ROLE', r.role)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT role
    FROM dba_roles@DB_LINK_COMPARE
    MINUS
    SELECT role
    FROM dba_roles
) r;


-- ===========================================================================
-- 3. ROLE_GRANT (role duoc grant cho user/role) con thieu
--    Sinh truc tiep cau lenh GRANT thay vi dung GET_GRANTED_DDL
--    (vi GET_GRANTED_DDL tra ve TAT CA grant cua grantee, khong chi phan thieu)
-- ===========================================================================
PROMPT ===== MISSING ROLE GRANTS =====
SELECT 'GRANT ' || granted_role || ' TO ' || grantee ||
       CASE WHEN admin_option = 'YES' THEN ' WITH ADMIN OPTION' ELSE '' END
       || ';' AS ddl
FROM (
    SELECT grantee, granted_role, admin_option
    FROM dba_role_privs@DB_LINK_COMPARE
    MINUS
    SELECT grantee, granted_role, admin_option
    FROM dba_role_privs
);


-- ===========================================================================
-- 4. SYSTEM PRIVILEGE con thieu
-- ===========================================================================
PROMPT ===== MISSING SYSTEM PRIVILEGES =====
SELECT 'GRANT ' || privilege || ' TO ' || grantee ||
       CASE WHEN admin_option = 'YES' THEN ' WITH ADMIN OPTION' ELSE '' END
       || ';' AS ddl
FROM (
    SELECT grantee, privilege, admin_option
    FROM dba_sys_privs@DB_LINK_COMPARE
    MINUS
    SELECT grantee, privilege, admin_option
    FROM dba_sys_privs
);


-- ===========================================================================
-- 5. OBJECT PRIVILEGE (tab privs) con thieu
-- ===========================================================================
PROMPT ===== MISSING OBJECT PRIVILEGES =====
SELECT 'GRANT ' || privilege || ' ON ' || owner || '.' || table_name ||
       ' TO ' || grantee ||
       CASE WHEN grantable = 'YES' THEN ' WITH GRANT OPTION' ELSE '' END
       || ';' AS ddl
FROM (
    SELECT grantee, owner, table_name, privilege, grantable
    FROM dba_tab_privs@DB_LINK_COMPARE
    WHERE owner NOT IN ('SYS','SYSTEM')
    MINUS
    SELECT grantee, owner, table_name, privilege, grantable
    FROM dba_tab_privs
    WHERE owner NOT IN ('SYS','SYSTEM')
);


-- ===========================================================================
-- 6. DB_LINK con thieu
--    Luu y: DBMS_METADATA.GET_DDL cho DB_LINK KHONG tra ve mat khau that,
--    thuong ra IDENTIFIED BY VALUES '...' (hash) hoac phai chinh sua lai
--    mat khau bang tay sau khi tao.
-- ===========================================================================
PROMPT ===== MISSING DB_LINKS =====
SELECT DBMS_METADATA.GET_DDL('DB_LINK', d.db_link, d.owner)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT owner, db_link
    FROM dba_db_links@DB_LINK_COMPARE
    MINUS
    SELECT owner, db_link
    FROM dba_db_links
) d;


-- ===========================================================================
-- 7. PROCEDURE / FUNCTION / PACKAGE / PACKAGE BODY con thieu
--    Cac object nay CO trong dba_objects, so sanh theo owner+object_name+type
--    Luu y: object_type trong dba_objects la 'PACKAGE BODY' (co dau cach)
--    nhung DBMS_METADATA.GET_DDL can 'PACKAGE_BODY' (dau gach duoi)
--    => phai REPLACE(object_type,' ','_')
-- ===========================================================================
PROMPT ===== MISSING PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY =====
SELECT DBMS_METADATA.GET_DDL(
         REPLACE(o.object_type,' ','_'), o.object_name, o.owner
       )@DB_LINK_COMPARE AS ddl
FROM (
    SELECT owner, object_name, object_type
    FROM dba_objects@DB_LINK_COMPARE
    WHERE object_type IN ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY')
      AND owner NOT IN ('SYS','SYSTEM')
    MINUS
    SELECT owner, object_name, object_type
    FROM dba_objects
    WHERE object_type IN ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY')
      AND owner NOT IN ('SYS','SYSTEM')
) o;


-- ===========================================================================
-- 8. (Tuy chon) PROFILE con thieu - neu user dung PROFILE rieng
-- ===========================================================================
PROMPT ===== MISSING PROFILES (OPTIONAL) =====
SELECT DBMS_METADATA.GET_DDL('PROFILE', p.profile)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT DISTINCT profile
    FROM dba_profiles@DB_LINK_COMPARE
    WHERE profile <> 'DEFAULT'
    MINUS
    SELECT DISTINCT profile
    FROM dba_profiles
    WHERE profile <> 'DEFAULT'
) p;