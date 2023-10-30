## --------------------------------------------------------------------------##
## File Name     : https://oracle-base.com/dba/script_creation/user_ddl.sql  ##
## Author        : Tim Hall                                                  ##
## Description   : Displays the DDL for a specific user.                     ##
## Call Syntax   : @user_ddl (username)                                      ##
## Last Modified : 07/08/2018                                                ##
##---------------------------------------------------------------------------## 
## Mod by        : Victor - MPS                                              ##
## Last Modified : 30/10/2023                                                ##
## Changed       : Get all users not belong to system in 1 time              ##
## --------------------------------------------------------------------------##

#!/bin/sh

user_list=$(
sqlplus -s / as sysdba <<EOF
set head off
set feed off
select username from dba_users where trunc(created) > (select trunc(created) from dba_users where username='SYS');
exit
EOF
)

for user in $user_list;
do
echo "#=============================================================="
echo "#--User: " $user
echo "#=============================================================="
sqlplus -s / as sysdba <<EOF
set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/
 
variable v_username VARCHAR2(30);

exec :v_username := upper('$user');

select dbms_metadata.get_ddl('USER', u.username) AS ddl
from   dba_users u
where  u.username = :v_username
union all
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', tq.username) AS ddl
from   dba_ts_quotas tq
where  tq.username = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_username
and    rp.default_role = 'YES'
and    rownum = 1
union all
select to_clob('/* Start profile creation script in case they are missing') AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
and    rownum = 1
union all
select dbms_metadata.get_ddl('PROFILE', u.profile) AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
union all
select to_clob('End profile creation script */') AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
and    rownum = 1
/

set linesize 80 pagesize 14 feedback on trimspool on verify on
exit
EOF
done