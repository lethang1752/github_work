#!/bin/bash

. migrate.properties

file_name=`date '+%Y.%m.%d_%H.%M.%S'`

sqlplus -S "/ as sysdba" << !
spool initial_backup.rman
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
select 'backup as compressed backupset incremental level 0 datafile ' || file_id || ' format ''${src_backup_dest}/' ||
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
spool initial_restore.rman
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
select 'restore from platform ''${src_platform_name}'' foreign datafile ' || file_id || ' format ''${target_datafile_dest}/' ||
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

rman target / @initial_backup.rman