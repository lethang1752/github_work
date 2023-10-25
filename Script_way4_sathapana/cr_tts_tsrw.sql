set heading off feedback off trimspool on linesize 500
spool tts_tsrw.sql
prompt /* ==================================== */
prompt /* Make all user tablespaces READ WRITE */
prompt /* ==================================== */
select 'ALTER TABLESPACE ' || tablespace_name || ' READ WRITE;'
 from dba_tablespaces
 where tablespace_name not in ('SYSTEM','SYSAUX')
 and contents = 'PERMANENT';
spool off 
