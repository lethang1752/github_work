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
create table foreign_datafile(file_id int, name varchar(200)) tablespace system;
!

cat rman_output_restore_full.log | $grep 'restoring foreign file' | $grep '+' | $awk '{print "insert into foreign_datafile values ("$6",\x27"$8"\x27);"}' > foreign_datafile_table.sql

sqlplus -S "/ as sysdba" @foreign_datafile_table.sql
