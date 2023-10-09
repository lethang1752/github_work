#!/bin/bash

. migrate.properties

sqlplus -S "/ as sysdba" << !
create table foreign_datafile(file# int, name varchar(200)) tablespace system;
!

cat rman_output_restore_full.log | grep 'restoring foreign file' | grep '+' | awk '{print "insert into foreign_datafile values ("$6",\x27"$8"\x27);"}' > foreign_datafile_table.sql

sqlplus -S "/ as sysdba" @foreign_datafile_table.sql
