/*
============================================================================
 SCRIPT: compare_missing_objects.sql
 MUC DICH:
   - So sanh metadata giua SOURCE (qua DB LINK) va TARGET (local)
   - Sinh ra cau lenh DDL (CREATE / GRANT) cho nhung object con THIEU o TARGET
     sau qua trinh expdp/impdp
   - Bao gom: USER, ROLE, ROLE_GRANT, SYSTEM PRIVILEGE, OBJECT PRIVILEGE,
     DB_LINK, PROCEDURE, FUNCTION, PACKAGE, PACKAGE BODY, TRIGGER,
     SCHEDULER JOB/PROGRAM/SCHEDULE, PUBLIC SYNONYM, DIRECTORY, CONTEXT,
     TABLESPACE QUOTA

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
    WHERE username NOT IN ('SYS','SYSTEM','OUTLN','DBSNMP','APPQOSSYS',
                            'GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER',
                            'XS$NULL','ORACLE_OCM','DIP','WMSYS','ANONYMOUS',
                            'CTXSYS','XDB','MDSYS','ORDSYS','ORDDATA','ORDPLUGINS',
                            'SI_INFORMTN_SCHEMA','LBACSYS','FLOWS_FILES','APEX_PUBLIC_USER')
    MINUS
    SELECT username
    FROM dba_users
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
-- 7. PROCEDURE / FUNCTION / PACKAGE / PACKAGE BODY / TRIGGER con thieu
--    Cac object nay CO trong dba_objects, so sanh theo owner+object_name+type
--    Luu y: object_type trong dba_objects la 'PACKAGE BODY' (co dau cach)
--    nhung DBMS_METADATA.GET_DDL can 'PACKAGE_BODY' (dau gach duoi)
--    => phai REPLACE(object_type,' ','_')
--    (TRIGGER thi khong bi van de nay, GET_DDL nhan thang 'TRIGGER')
-- ===========================================================================
PROMPT ===== MISSING PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY/TRIGGER =====
SELECT DBMS_METADATA.GET_DDL(
         REPLACE(o.object_type,' ','_'), o.object_name, o.owner
       )@DB_LINK_COMPARE AS ddl
FROM (
    SELECT owner, object_name, object_type
    FROM dba_objects@DB_LINK_COMPARE
    WHERE object_type IN ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY','TRIGGER')
      AND owner NOT IN ('SYS','SYSTEM')
    MINUS
    SELECT owner, object_name, object_type
    FROM dba_objects
    WHERE object_type IN ('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY','TRIGGER')
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


-- ===========================================================================
-- 9. SCHEDULER JOB con thieu
--    Luu y: JOB/PROGRAM/SCHEDULE/CHAIN KHONG dung GET_DDL truc tiep voi
--    type 'JOB', ma phai dung type 'PROCOBJ' (Procedural Object) cua
--    DBMS_METADATA. Ham nay tra ve DDL cua job (bao gom ca job dang
--    DISABLED, khong tu chay lai khi tao lai).
-- ===========================================================================
PROMPT ===== MISSING SCHEDULER JOBS =====
SELECT DBMS_METADATA.GET_DDL('PROCOBJ', j.job_name, j.owner)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT owner, job_name
    FROM dba_scheduler_jobs@DB_LINK_COMPARE
    MINUS
    SELECT owner, job_name
    FROM dba_scheduler_jobs
) j;

-- Neu co dung SCHEDULER PROGRAM / SCHEDULE rieng (khong gan lien vao job)
-- thi so sanh tuong tu voi dba_scheduler_programs / dba_scheduler_schedules,
-- van dung GET_DDL('PROCOBJ', name, owner).


-- ===========================================================================
-- 10. PUBLIC SYNONYM con thieu
--     Synonym (ca PUBLIC va cua user) CO trong dba_objects (type SYNONYM),
--     nhung PUBLIC SYNONYM hay bi impdp bo qua vi can quyen CREATE PUBLIC
--     SYNONYM rieng, nen tach ra kiem tra doc lap cho chac.
-- ===========================================================================
PROMPT ===== MISSING PUBLIC SYNONYMS =====
SELECT DBMS_METADATA.GET_DDL('SYNONYM', s.synonym_name, 'PUBLIC')@DB_LINK_COMPARE AS ddl
FROM (
    SELECT synonym_name
    FROM dba_synonyms@DB_LINK_COMPARE
    WHERE owner = 'PUBLIC'
    MINUS
    SELECT synonym_name
    FROM dba_synonyms
    WHERE owner = 'PUBLIC'
) s;


-- ===========================================================================
-- 11. DIRECTORY con thieu
--     Directory object thuong bi bo qua khi impdp vi can quyen DBA that su,
--     va duong dan OS tren TARGET co the khac SOURCE => sau khi chay DDL
--     nay, KIEM TRA LAI duong dan vat ly co ton tai tren server TARGET
--     khong, dieu chinh neu can.
-- ===========================================================================
PROMPT ===== MISSING DIRECTORIES (KIEM TRA LAI DUONG DAN OS) =====
SELECT DBMS_METADATA.GET_DDL('DIRECTORY', d.directory_name)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT directory_name
    FROM dba_directories@DB_LINK_COMPARE
    MINUS
    SELECT directory_name
    FROM dba_directories
) d;


-- ===========================================================================
-- 12. CONTEXT (Application Context) con thieu
-- ===========================================================================
PROMPT ===== MISSING CONTEXTS =====
SELECT DBMS_METADATA.GET_DDL('CONTEXT', c.namespace)@DB_LINK_COMPARE AS ddl
FROM (
    SELECT namespace
    FROM dba_context@DB_LINK_COMPARE
    MINUS
    SELECT namespace
    FROM dba_context
) c;


-- ===========================================================================
-- 13. TABLESPACE QUOTA con thieu
--     Day KHONG phai la object, chi la thuoc tinh cua user, nen impdp
--     hoac buoc tao user thu cong rat de bi thieu/sai. Sinh truc tiep
--     ALTER USER ... QUOTA ...
--     Luu y: neu MAX_BYTES = -1 nghia la UNLIMITED tren tablespace do.
-- ===========================================================================
PROMPT ===== MISSING TABLESPACE QUOTAS =====
SELECT 'ALTER USER ' || username || ' QUOTA ' ||
       CASE WHEN max_bytes = -1 THEN 'UNLIMITED' ELSE TO_CHAR(max_bytes) END ||
       ' ON ' || tablespace_name || ';' AS ddl
FROM (
    SELECT username, tablespace_name, max_bytes
    FROM dba_ts_quotas@DB_LINK_COMPARE
    MINUS
    SELECT username, tablespace_name, max_bytes
    FROM dba_ts_quotas
);


/*
============================================================================
 NHUNG THU KHAC NEN KIEM TRA THEM (khong the/khong nen chi dung MINUS don
 gian theo ten, can luu y rieng):

 - COMMENT tren TABLE/COLUMN (dba_tab_comments, dba_col_comments):
   DBMS_METADATA.GET_DDL('TABLE', ...) KHONG tu dong kem COMMENT.
   Phai lay rieng bang:
     DBMS_METADATA.GET_DEPENDENT_DDL('COMMENT', table_name, owner)
   hoac tu ghep "COMMENT ON TABLE/COLUMN ... IS '...';" tu 2 view tren.

 - CONSTRAINT bi DISABLE / NOVALIDATE: constraint thuong di kem trong DDL
   cua TABLE, nhung neu source co constraint dang DISABLE ma sau impdp
   lai ra ENABLE (hoac nguoc lai) thi can so sanh rieng dba_constraints
   (cot STATUS, VALIDATED) giua 2 ben.

 - INDEX invisible/unusable: so sanh dba_indexes (cot VISIBILITY, STATUS)
   neu nghi ngo impdp tao thieu index hoac index bi UNUSABLE.

 - MATERIALIZED VIEW LOG (dba_mview_logs) va REFRESH GROUP
   (dba_refresh): khong nam gon trong dba_objects theo kieu don gian,
   nen kiem tra rieng neu he thong co dung MVIEW.

 - AUDIT POLICY / FGA POLICY (dba_audit_policies, dba_sched...): it dung
   nhung neu co thi cung can kiem tra rieng, khong nam trong dba_objects.

 - EDITION / EDITIONING VIEW: chi can quan tam neu he thong co bat
   Edition-Based Redefinition (EBR).

 - Cuoi cung: sau khi chay xong toan bo script, nen doi chieu lai tong so
   dong tung view dba_* giua SOURCE va TARGET (COUNT(*) MINUS COUNT(*) qua
   db link) de chac chan khong con lech ngoai du kien.
============================================================================
*/