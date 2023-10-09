*NOTE:
- Run all shell script with format ./[script].sh, this way means you need to go into the folder contains all script.

Step 1: Run backup full from source database and restore from target database
- Modify migrate.properties
- Run ./prepare_backup0.sh from source database 
    -> initial_restore.rman + initial_backup.rman + backup file 
- Scp backup file and initial_restore.rman to target database
- Run initial_restore.rman from target database with command:
rman target / @initial_restore.rman > rman_output_restore_full.log
- After restore done in target database, run ./target_foreign_datafile.sh
    -> Check table foreign_datafile (tablespace SYSTEM) in target database to confirm information about new datafile

Step 2: Prepare for foreign datafile information in target database

