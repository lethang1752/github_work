col name format a50
col value format a50
set line 150
select name , value from V$DATAGUARD_STATS order by 1;
SELECT INST_ID, OPEN_MODE, DATABASE_ROLE FROM GV$DATABASE; 
