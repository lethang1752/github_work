#!/bin/bash

. migrate.properties

sqlplus -S "/ as sysdba" << !
spool target_foreign_datafile.sql
set linesize 250
set pagesize 0
set heading off
set trimspool on
set feedback off
set term off
select 'create table foreign_datafile
(
	file_id number not null, 
	name varchar(200),
	constraint file_id_pk primary key (file_id)
) tablespace system;' from dual
union all
select 'insert into foreign_datafile values (' ||file_id|| ','''||file_name||''');' from dba_data_files where tablespace_name not in ('SYSTEM','SYSAUX')
/
!

file_name=`date '+%Y.%m.%d_%H.%M.%S'`

recover_seq=`ls | grep inc_recover | wc -l`
recover_seq=$((recover_seq+1))

sqlplus -S "/ as sysdba" << !
spool inc_backup.rman
set linesize 250
set pagesize 0
set heading off
set trimspool on
set feedback off
set term off
select 'run {'
from dual
union all
select 'allocate channel c' || level || ' device type disk;'
from dual
connect by rownum<=${src_parallel_degree}
union all
select 'backup as compressed backupset incremental level 1 datafile ' || file_id || ' format ''${src_backup_dest}/' ||
       lower(t.tablespace_name) || trim(to_char(row_number() over (partition by t.tablespace_name order by f.file_id),'00')) || '_${file_name}'';'
from dba_data_files f, dba_Tablespaces t
where f.tablespace_name=t.tablespace_name
and   t.CONTENTS='PERMANENT'
and   t.tablespace_name not in ('SYSTEM','SYSAUX')
union all
select '}'
from dual
/
!


sqlplus -S "/ as sysdba" << !
spool inc_recover${recover_seq}.rman
set linesize 250
set pagesize 0
set heading off
set trimspool on
set feedback off
set term off
select 'run {'
from dual
union all
select 'allocate channel c' || level || ' device type disk;'
from dual
connect by rownum<=${target_parallel_degree}
union all
select 'recover from platform ''${src_platform_name}'' foreign datafilecopy ' || ' ''${target_datafile_dest}/' ||
       lower(t.tablespace_name) || trim(to_char(row_number() over (partition by t.tablespace_name order by f.file_id),'00')) ||
       '.dbf'' from backupset ''${target_backup_dest}/' || lower(t.tablespace_name) || trim(to_char(row_number() over (partition by t.tablespace_name order by f.file_id),'00')) || '_${file_name}'';'
from dba_data_files f, dba_Tablespaces t
where f.tablespace_name=t.tablespace_name
and   t.CONTENTS='PERMANENT'
and   t.tablespace_name not in ('SYSTEM','SYSAUX')
union all
select '}'
from dual
/
!

rman target / @inc_backup.rman