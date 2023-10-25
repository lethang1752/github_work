set heading off feedback off trimspool on escape off
set long 1000 linesize 1000
col USERDDL format A150
spool tts_sys_privs.sql
prompt /* ============ */
prompt /* Grant privs */
prompt /* ============ */
select 'grant '||privilege||' on "'||
 owner||'"."'||table_name||'" to "'||grantee||'"'||
 decode(grantable,'YES',' with grant option ')||
 decode(hierarchy,'YES',' with hierarchy option ')||
 ';'
from dba_tab_privs
where owner in
 (select name
 from system.logstdby$skip_support
 where action=0)
 and grantee in
 (select username
 from dba_users);
spool off