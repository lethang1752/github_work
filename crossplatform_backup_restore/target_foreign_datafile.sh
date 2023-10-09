#!/bin/bash

os=$(uname)
if [[ "$os" == 'Linux' ]]; then
	grep='grep'
	awk='awk'
else
	grep='ggrep'
	awk='nawk'
fi

. migrate.properties

sqlplus -S "/ as sysdba" << !
create table foreign_datafile
(
	file_id int not null, 
	name varchar(200),
	constraint file_id_pk primary key (file_id)
) tablespace system;
!

cat rman_output_restore_full.log | $grep 'restoring foreign file' | $grep '+' | $awk '{print "insert into foreign_datafile values ("$6",\x27"$8"\x27);"}' > target_foreign_datafile.sql

sqlplus -S "/ as sysdba" @target_foreign_datafile.sql
