set heading off feedback off trimspool on linesize 500
spool tts_tsro.sql
prompt /* =================================== */
prompt /* Make all user tablespaces READ ONLY */
prompt /* =================================== */
select 'ALTER TABLESPACE '|| tablespace_name|| ' READ ONLY;'
 from dba_tablespaces
 where tablespace_name not in ('SYSTEM','SYSAUX')
 and contents = 'PERMANENT';
spool off 
