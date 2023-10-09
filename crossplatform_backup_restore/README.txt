*NOTE:
- Run all shell script with format ./[script].sh, this way means you need to go into the folder contains all script.

Step 1: Run backup full from source database and restore from target database
- Modify migrate.properties 
(Ex for target_datafile_dest=+DATA/{$ORACLE_SID}/DATAFILE)
- Run ./prepare_backup0.sh from source database 
    + initial_backup.rman
    + initial_restore.rman
    + target_foreign_datafile_full.sql
    + backup file
- Scp backup file, initial_restore.rman, target_foreign_datafile_full.sql to target database
- Run target_foreign_datafile_full.sql from target database:
    + Check information in table foreign_datafile (tablespace SYSTEM)
- Run initial_restore.rman


Step 2: 

