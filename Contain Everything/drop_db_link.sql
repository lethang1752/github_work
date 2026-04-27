--DROP PUBLIC DATABASE LINK
select 'drop public database link '||DB_LINK||';' from dba_db_links where owner='PUBLIC';

--DROP DATABASE LINK
CREATE OR REPLACE DIRECTORY TEMP_DIR AS '/tmp';
/

DECLARE
    F1          UTL_FILE.FILE_TYPE;
    CURSOR c    IS SELECT OWNER, DB_LINK FROM DBA_DB_LINKS WHERE OWNER <> 'PUBLIC';
    v_dir_name  VARCHAR2(128);
    v_file_name VARCHAR2(100) := 'drop_dblink.sql';
    v_path      VARCHAR2(500) := '/tmp'; -- Đường dẫn vật lý để check
BEGIN
    -- 1. Lấy đúng TÊN directory dựa trên đường dẫn
    BEGIN
        SELECT DIRECTORY_NAME 
        INTO v_dir_name 
        FROM DBA_DIRECTORIES 
        WHERE RTRIM(DIRECTORY_PATH, '/') = RTRIM(v_path, '/')
        AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('LỖI: Không tìm thấy Directory object cho đường dẫn: ' || v_path);
            RETURN;
    END;

    -- 2. Mở file (Sử dụng v_dir_name thay vì đường dẫn)
    F1 := UTL_FILE.FOPEN(v_dir_name, v_file_name, 'w', 32767);

    FOR rec IN c LOOP
        -- Viết script tạo procedure tạm cho từng user
        UTL_FILE.PUT_LINE(F1, 'CREATE OR REPLACE PROCEDURE ' || rec.OWNER || '.tmp_drop_dblink AS');
        UTL_FILE.PUT_LINE(F1, 'BEGIN');
        UTL_FILE.PUT_LINE(F1, '   EXECUTE IMMEDIATE ''DROP DATABASE LINK "' || rec.DB_LINK || '"'';');
        UTL_FILE.PUT_LINE(F1, 'END;');
        UTL_FILE.PUT_LINE(F1, '/');
        
        -- Gọi procedure để thực hiện drop
        UTL_FILE.PUT_LINE(F1, 'BEGIN ' || rec.OWNER || '.tmp_drop_dblink; END;');
        UTL_FILE.PUT_LINE(F1, '/');
        
        -- Xóa procedure sau khi dùng xong
        UTL_FILE.PUT_LINE(F1, 'DROP PROCEDURE ' || rec.OWNER || '.tmp_drop_dblink;');
        UTL_FILE.NEW_LINE(F1);
    END LOOP;

    UTL_FILE.FCLOSE(F1);
    DBMS_OUTPUT.PUT_LINE('Thành công: File ' || v_file_name || ' đã được tạo tại ' || v_path);

EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
        DBMS_OUTPUT.PUT_LINE('Lỗi: Đường dẫn file không hợp lệ hoặc thiếu quyền ghi.');
        IF UTL_FILE.IS_OPEN(F1) THEN UTL_FILE.FCLOSE(F1); END IF;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Lỗi không xác định: ' || SQLERRM);
        IF UTL_FILE.IS_OPEN(F1) THEN UTL_FILE.FCLOSE(F1); END IF;
END;
/