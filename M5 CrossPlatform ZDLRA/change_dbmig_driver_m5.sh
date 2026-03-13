################################################################################
#
# dbmig_driver.sh
#
#===============================================================================
# Last modified : September 17, 2025
# Version       : 5.1
# Purpose       : Script to automate Cross Endian Database Migration
#===============================================================================
#  Ver 5.1: Support to parallelize expdp and rman
#  Ver 5.0: RMAN_SCAN support 
#  Ver 4.16: RMAN_DEBUG property, disable rman debug trace by default
#  Ver 4.15: Disable KRB traces (workaround from 2956216.1)
#  Ver 4.14: Check connection before convert to snap on standby
#  Ver 4.13: Standard variable naming, remove redirection on run_expdp, use -L on sqlplus 
#  Ver 4.12: Add support to allow double quote in Tablespace and enhance check for punctuation
#  Ver 4.11: HP-UX changes, add properties file check 
#  Ver 4.10: Add RDBMS version check, tb split and debug script option 
#  Ver 4.9: Adjusting OS parameters for older OS releases
#  Ver 4.8: Split the tablepsace backup based on a fixed number of tablepsaces 
#  Ver 4.7: Add check_conn
#  Ver 4.6: Add RMAN debug, show all and set NLS_DATE_FORMAT
#           Add FROM SCN to avoid breaking the backup sequence if a backup is taken
#           outside the migration process.
#
#  Ver 4.5: Fix gen_restore to exclude autobackup controlfile from restore script
#           Implement SYSTEM_USR
#           Add password input for EXPDP
#

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
        echo "Please call this script using the syntax $0 "
        echo "Example: # sh dbmig_driver.sh L0|L1|L1F [DEBUG_SCRIPT]"
        exit 1
fi

export BKP_LEVEL=${1}
export DEBUG_CMD=${2}

if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
   set -x
   uname -a
fi

M5_version="5.1"
M5_prop_version=5
 
export CMD_DIR=${PWD}/cmd
export NLS_DATE_FORMAT="DD-MM-YYYY HH24:MI:SS"
 
if [ ! -f ${CMD_DIR}/dbmig_driver.properties ]; then
        echo "Properties file not found, exiting. "
        exit 1
        else
        echo "Properties file found, sourcing.";
        . ${CMD_DIR}/dbmig_driver.properties
        export ORACLE_SID
        export ORACLE_HOME
fi
 
if [ -z ${my_M5_prop_version} ] || [ ${my_M5_prop_version} -lt ${M5_prop_version} ]; then 
        echo " The version of the properties file is too old"
        echo ""
        echo " Use the properties file bundled with this file..exiting."
        exit 1
fi

if [ ! -f ${CMD_DIR}/dbmig_ts_list.txt ]; then
        echo "List of Tablespaces: The file ${CMD_DIR}/dbmig_ts_list.txt is not found, exiting. "
        exit 1
fi
 
if [ ! -f ${CMD_DIR}/.next_scn ]; then
        echo "Next SCN file not found, creating it. "
        ${CMD_TOUCH} ${CMD_DIR}/.next_scn
else
       export SCN=`${CMD_CAT} ${CMD_DIR}/.next_scn`
fi
 
export TS=`${CMD_CAT} ${CMD_DIR}/dbmig_ts_list.txt`
export TSF=${CMD_DIR}/dbmig_ts_list.txt


# number of tablespaces per line, do not modify
TS_PLN=60 

 
if [ -d "${LOG_DIR}" ] && [ -d "${CMD_DIR}" ]; then
  echo "LOG and CMD directories found"
else
  echo "LOG and CMD directories not found, creating"
  ${CMD_MKDIR} -p ${LOG_DIR}
  ${CMD_MKDIR} -p ${CMD_DIR}
fi

if [[ "${BKP_DEST_TYPE}" = "DISK" ]]; then
  if [ ! -d "${BKP_DEST_PARM}" ]; then
    echo "Backup to disk, creating ${BKP_DEST_PARM}"
    ${CMD_MKDIR} -p ${BKP_DEST_PARM}
  fi
fi

if [ ! -d "${SOURCE_DPDMP}" ]; then
  echo "Path for ${SOURCE_DPDIR} not found, creating"
  ${CMD_MKDIR} -p ${SOURCE_DPDMP}
fi

 if [ ! -z ${RMAN_SCAN} ] ; then
   RMAN_SCAN_CONN="@${RMAN_SCAN}"
 else
   RMAN_SCAN_CONN=""
 fi  

 SRC_SCAN_CONN="@${SRC_SCAN}"

if [ ! -z ${PDB_NAME} ] ; then
  MIG_PDB=1
else
  MIG_PDB=0
fi



function gen_pdb_ts_list {
    if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
      set -x
    fi
    export TSF=${1}
    export PDB=${2}
 
    # Create or clear the output file
    > ${TSF}.pdb
 
    # Process the tablespaces file and append the pdb name to each
    awk -v PDB="${PDB}" 'BEGIN { FS=","; OFS="," } {
        for (i = 1; i <= NF; i++) {
            gsub(/ /, "", $i);  # Remove spaces in each field
            $i = PDB ":" $i;
        }
        print $0;
    }' ${TSF} >> ${TSF}.pdb
    export TSPDB=`${CMD_CAT} ${TSF}.pdb`
    export TSFPDB=${TSF}.pdb
}
while [[ -f ${LOG_DIR}/rman_mig_bkp.lck ]]; do
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Previous RMAN execution lock is still present!! Resolve issue and delete lock file: ${LOG_DIR}/rman_mig_bkp.lck. Exiting..."
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Previous RMAN execution lock is still present!! Resolve issue and delete lock file: ${LOG_DIR}/rman_mig_bkp.lck. Exiting..." >> ${LOG_DIR}/rman_mig_bkp.log
exit 1;
done
 
 
function gen_backup {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
case ${BKP_DEST_TYPE} in
         "DISK")
                  export FORMAT="'${BKP_DEST_PARM}/${BKP_LEVEL}_%d_%N_%t_%s_%p'"
                  export CMD_FILE=${CMD_DIR}/bkp_${BKP_LEVEL}_${DT}.cmd
                  export TAG=${ORACLE_SID}_${BKP_LEVEL}_${DT}
                  echo "SET ECHO ON;"                                                           > ${CMD_FILE}
                  echo "SHOW ALL;"                                                              >> ${CMD_FILE}
                  case ${BKP_FROM_STDBY} in
                            "0") 
                            echo "ALTER SYSTEM CHECKPOINT GLOBAL;"                                        >> ${CMD_FILE}
                            echo "SELECT checkpoint_change# prev_incr_ckp_scn FROM v\$database;"          >> ${CMD_FILE}
                            ;;
                            "1")
                              case ${MIG_PDB} in
                              "1")
                                echo "SELECT MIN(dfh.checkpoint_change#) prev_incr_ckp_scn FROM v\$datafile_header dfh, v\$pdbs p WHERE dfh.checkpoint_change# != 0 and p.con_id = dfh.con_id and p.name='${PDB_NAME}';"          >> ${CMD_FILE}
                                ;;
                              *)
                                echo "SELECT MIN(checkpoint_change#) prev_incr_ckp_scn FROM v\$datafile_header WHERE checkpoint_change# != 0;"          >> ${CMD_FILE}
                                ;;
                              esac
                            ;;
                  esac         
                  echo "SET EVENT FOR skip_auxiliary_set_tbs TO 1;"                             >> ${CMD_FILE}
                  echo "RUN"                                                                    >> ${CMD_FILE}
                  echo "{"                                                                      >> ${CMD_FILE}
                  i=1
                  while [[ ${i} -le ${CHN} ]];
                  do
                       echo "ALLOCATE CHANNEL d${i} DEVICE TYPE ${BKP_DEST_TYPE} FORMAT ${FORMAT};" >> ${CMD_FILE}
                       echo "sql channel d$i "\"alter session set events \'\'trace[KRB.*] disk disable, memory disable\'\'\""  ;" >> ${CMD_FILE}
                       i=$(expr $i + 1)
                  done
                  case ${MIG_PDB} in
                            "0") 
                             TSA=${TS}
                            ;;
                            "1")
                                gen_pdb_ts_list ${TSF} ${PDB_NAME}
                                TSA=${TSPDB}
                            ;;
                    esac 
                  ts_tot=`echo ${TSA} | awk -F, '{ print NF}'`
                  ts_pln=${TS_PLN}
                  ts_end=${ts_pln}
                  ts_srt=1
                  while [[ ${ts_srt} -le ${ts_tot} ]]; do
                    echo "BACKUP "                                                  >> ${CMD_FILE}
                    echo "       FILESPERSET 1"                                     >> ${CMD_FILE}
                    case ${BKP_LEVEL} in                                            
                            "L1"|"L1F")                                             
                                echo "       INCREMENTAL FROM SCN ${SCN}"           >> ${CMD_FILE}
                            ;;                                                      
                    esac                                                            
                    echo "       SECTION SIZE ${SECTION_SIZE}                    "  >> ${CMD_FILE}
                    echo "       TAG ${TAG}"                                        >> ${CMD_FILE}
                    ts_s=`echo ${TSA} | ${CMD_CUT} -f ${ts_srt}-${ts_end} -d ,`       
                    echo "       TABLESPACE ${ts_s};"                               >> ${CMD_FILE}
                    ts_srt=`expr ${ts_srt} + ${ts_pln}`                             
                    ts_end=`expr ${ts_srt} + ${ts_pln} - 1`                         
                                                                                    
                  done                                                              
                  echo "}"                                                          >> ${CMD_FILE}
                                 
          ;;
         "SBT_TAPE")
                  export FORMAT="${BKP_DEST_PARM}"
                  export CMD_FILE=${CMD_DIR}/bkp_${BKP_LEVEL}_${DT}.cmd
                  export TAG=${ORACLE_SID}_${BKP_LEVEL}_${DT}
                  echo "SET ECHO ON;"                                              > ${CMD_FILE}
                  echo "SHOW ALL;"                                                 >> ${CMD_FILE}
                  case ${BKP_FROM_STDBY} in
                            "0") 
                            echo "ALTER SYSTEM CHECKPOINT GLOBAL;"                                        >> ${CMD_FILE}
                            echo "SELECT checkpoint_change# prev_incr_ckp_scn FROM v\$database;"          >> ${CMD_FILE}
                            ;;
                            "1")                             
                            case ${MIG_PDB} in
                              "1")
                                echo "SELECT MIN(dfh.checkpoint_change#) prev_incr_ckp_scn FROM v\$datafile_header dfh, v\$pdbs p WHERE dfh.checkpoint_change# != 0 and p.con_id = dfh.con_id and p.name='${PDB_NAME}';"          >> ${CMD_FILE}
                                ;;
                              *)
                                echo "SELECT MIN(checkpoint_change#) prev_incr_ckp_scn FROM v\$datafile_header WHERE checkpoint_change# != 0;"          >> ${CMD_FILE}
                                ;;
                              esac
                            ;;
                  esac        
                  echo "SET EVENT FOR skip_auxiliary_set_tbs TO 1;"                             >> ${CMD_FILE}
                  echo "RUN"                                                                    >> ${CMD_FILE}
                  echo "{"                                                                      >> ${CMD_FILE}
                  i=1
                  while [[ ${i} -le ${CHN} ]];
                  do
                       echo "ALLOCATE CHANNEL d$i DEVICE TYPE ${BKP_DEST_TYPE} FORMAT ${FORMAT};" >> ${CMD_FILE}
                       echo "sql channel d$i "\"alter session set events \'\'trace[KRB.*] disk disable, memory disable\'\'\""  ;" >> ${CMD_FILE}
                       i=$(expr $i + 1)
                  done
                  case ${MIG_PDB} in
                            "0") 
                             TSA=${TS}
                            ;;
                            "1")
                                gen_pdb_ts_list ${TSF} ${PDB_NAME}
                                TSA=${TSPDB}
                            ;;
                    esac 
                  ts_tot=`echo ${TSA} | awk -F, '{ print NF}'`
                  ts_pln=${TS_PLN}
                  ts_end=${ts_pln}
                  ts_srt=1
                  while [[ ${ts_srt} -le ${ts_tot} ]]; do
                    echo "BACKUP "                                                                 >> ${CMD_FILE}
                    echo "       FILESPERSET 1"                                                    >> ${CMD_FILE}
                    case ${BKP_LEVEL} in
                            "L1"|"L1F") 
                                echo "       INCREMENTAL FROM SCN ${SCN}"                        >> ${CMD_FILE}
                            ;;
                    esac         
                    echo "       SECTION SIZE ${SECTION_SIZE}                    "                 >> ${CMD_FILE}
                    echo "       TAG ${TAG}"                                                       >> ${CMD_FILE}
                    ts_s=`echo ${TSA} | ${CMD_CUT} -f ${ts_srt}-${ts_end} -d ,`
                    echo "       TABLESPACE ${ts_s};"                                  >> ${CMD_FILE}
                    ts_srt=`expr ${ts_srt} + ${ts_pln}`
                    ts_end=`expr ${ts_srt} + ${ts_pln} - 1`
                  done        
                  echo "}"                                                                       >> ${CMD_FILE}
                  export FORMAT=`echo ${BKP_DEST_PARM} | sed 's+"+\\\\"+g'`
         ;;
             *)
         ;;
esac
}

function chk_backup {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
export BKP_ERR=`egrep "WARN-|ORA-|RMAN-02001" ${BKP_LOG} | wc -l | awk '{print $1}'`

if [ "${BKP_ERR}" != 0 ];
  then
    echo ""
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Found errors or warnings in backup log file ${BKP_LOG} for pid $$ Aborting..."
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Found errors or warnings in backup log file ${BKP_LOG} for pid $$ Aborting..." >> ${LOG_DIR}/chk_backup.log
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Found errors or warnings in backup log file ${BKP_LOG} for pid $$ Aborting..." >> ${LOG_DIR}/rman_mig_bkp.log
    echo "${BKP_ERR}" >> ${LOG_DIR}/chk_backup.log
    exit 1
  else
    echo ""
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: No errors or warnings found in backup log file for pid $$"
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: No errors or warnings found in backup log file for pid $$" >> ${LOG_DIR}/chk_backup.log
    echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: No errors or warnings found in backup log file for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
fi
 
}

function check_conn {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi

if [ ! -z ${RMAN_SCAN} ]; then
  connection_string="/${3}"
else
  connection_string="${1}/${2}${3}"
fi


sqlplus -L -s ${connection_string} << EOF
  set feedback off
  set heading off
  select 'Connected successfully to SRC_SCAN' from dual;
  exit;
EOF

if [ $? -eq 0 ]; then
  echo "Oracle authentication successful to ${3}"
else
  echo "Oracle authentication failed to ${3}"
  exit 1
fi

if [ ! -z ${RMAN_SCAN} ]; then
  connection_string="/${RMAN_SCAN_CONN}"

  sqlplus -L -s ${connection_string} << EOF
  set feedback off
  set heading off
  select 'Connected successfully to RMAN_SCAN' from dual;
  exit;
EOF

 if [ $? -eq 0 ]; then
   echo "Oracle authentication successful to ${RMAN_SCAN}"
 else
   echo "Oracle authentication failed to ${RMAN_SCAN}"
   exit 1
 fi
fi


}

 
function check_rdbms_version {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi

connection_string="/ as sysdba"

version=`sqlplus -L -s ${connection_string} << EOF
  set feedback off
  set heading off
  select version from v\\$instance;
  exit;
EOF
`
if [ $? -ne 0 ]; then
  echo "Unable to access database using sqlplus..exiting"
  exit 1
fi

mjnum=`echo ${version} | awk -F'.' '{print $1}'`
if [ ${mjnum} -lt 19 ]; then
  echo ""
  echo "RDBMS database version must be 19.18 or greater..exiting"
  exit 1
fi

if [ ${mjnum} -eq 19 ]; then
  version_full=`sqlplus -L -s ${connection_string} << EOF
  set feedback off
  set heading off
  select version_full from v\\$instance;
  exit;
EOF
`
  mnnum=`echo ${version_full} | awk -F'.' '{print $2}'`
  if [ ${mnnum} -lt 18 ]; then
    echo ""
    echo "RDBMS database version must be 19.18 or greater..exiting"
    exit 1
  fi
fi
 
}
 
 
function gen_restore {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
export BKP_LOG=${1}
export RES_CMD=${CMD_DIR}/restore_${BKP_LEVEL}_${ORACLE_SID}_${DT}.cmd
export RES_LOG=restore_${BKP_LEVEL}_${ORACLE_SID}_${DT}.log
export RES_TRC=restore_${BKP_LEVEL}_${ORACLE_SID}_${DT}.trc
if [[ "${RMAN_DEBUG}" = "N" ]]; then
  export RMAN_SPOOL_TRACE_CMD=""
  export RMAN_TRACE_DEBUG_CMD=""
  export piece_location="2"
else   
  export RMAN_SPOOL_TRACE_CMD="SPOOL TRACE TO log/${RES_TRC};"
  export RMAN_TRACE_DEBUG_CMD="DEBUG ON;"
  export piece_location="3"
fi  
export GEN_CMD="${WORKDIR}/gen_restore_cmd.awk"
cat << EOF > ${GEN_CMD}
BEGIN {
   print "SPOOL LOG TO log/${RES_LOG};"
   print "${RMAN_SPOOL_TRACE_CMD}"
   print "SET EVENT FOR catalog_foreign_datafile_restore TO 1;"
   print "SET ECHO ON;"
   print "SHOW ALL;"
   print "${RMAN_TRACE_DEBUG_CMD}"
   print "RUN"
   print "{"
   for (i = 1; i <= ${CHN}; i++)
       {
         channel_string = "ALLOCATE CHANNEL ${BKP_DEST_TYPE}"i" DEVICE TYPE ${BKP_DEST_TYPE} FORMAT ${FORMAT};"
         print channel_string; 
       }
   print "RESTORE ALL FOREIGN DATAFILES TO NEW FROM BACKUPSET"
}
/piece handle=/ && !/autobackup/ && !/AUTOBACKUP/ && !/c-/{
  split(\$${piece_location}, a, "=");
  q="'";
  printf("%s%s%s%s",sep,q,a[2],q);
  sep=",\n";
}
END {
  print ";}"
}
EOF
${CMD_AWK} -f ${GEN_CMD} ${BKP_LOG} > ${RES_CMD}
if [[ -n "${DEST_SERVER}" ]]; then
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Transferring restore script for pid $$ to destination"
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Transferring restore script for pid $$ to destination" >> ${LOG_DIR}/rman_mig_bkp.log
  ${CMD_SCP} ${RES_CMD} ${DEST_USER}\@${DEST_SERVER}:${DEST_WORKDIR}
  
else
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Manually copy restore script to destination"
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`:  => ${RES_CMD}"
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Manually copy restore script to destination" >> ${LOG_DIR}/rman_mig_bkp.log
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`:  => ${RES_CMD}" >> ${LOG_DIR}/rman_mig_bkp.log
fi
}
 
function run_conv_stby {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
export role=${1}
echo ${role}
${ORACLE_HOME}/bin/dgmgrl << EOF
connect / as sysdba
show configuration
convert database ${ORACLE_SID} to ${role} standby;
show configuration
exit
EOF
}
 
function run_ts_ro {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
export TSF=${1}

if [ ! -z ${RMAN_SCAN} ]; then 
    connection_string="/${SRC_SCAN_CONN}"
else
  connection_string="${2}/${3}${SRC_SCAN_CONN}"
fi

if [[ "${REMOVE_TS_QUOTE}" = "1" ]]; then 
  ${CMD_AWK} -F',' 'BEGIN {i=0} {for (i=1;i<=NF;i++) print "ALTER TABLESPACE " $i " READ ONLY;"}' ${TSF} |tr -d '"' > ${CMD_DIR}/dbmig_ts_ro.sql
else
  ${CMD_AWK} -F',' 'BEGIN {i=0} {for (i=1;i<=NF;i++) print "ALTER TABLESPACE " $i " READ ONLY;"}' ${TSF} > ${CMD_DIR}/dbmig_ts_ro.sql
fi
${ORACLE_HOME}/bin/sqlplus -L -s /nolog << EOF
connect  ${connection_string} 
spool ${CMD_DIR}/dbmig_ts_ro.lst
@ ${CMD_DIR}/dbmig_ts_ro.sql
exit
EOF
}

function bkp_report {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
${ORACLE_HOME}/bin/sqlplus -L -s /nolog << EOF
connect / as sysdba
SET LINESIZE 333 TERMOUT OFF FEEDBACK OFF
COL BACKUP_TYPE FOR A20
spool ${CMD_DIR}/bkp_report.lst
SELECT input_type "BACKUP_TYPE"
     , NVL(input_bytes/(1024*1024),0)"INPUT_BYTES(MB)"
     , NVL(output_bytes/(1024*1024),0) "OUTPUT_BYTES(MB)"
     , status
     , TO_CHAR(start_time,'MM/DD/YYYY:hh24:mi:ss') as START_TIME
     , TO_CHAR(end_time,'MM/DD/YYYY:hh24:mi:ss') as END_TIME
     , TRUNC((elapsed_seconds/60),2) "ELAPSED_TIME(Min)"
  FROM v\$rman_backup_job_details
WHERE session_key = (SELECT MAX(session_key)
                        FROM v\$rman_backup_job_details)
ORDER BY END_TIME DESC;
EXIT
EOF
cat ${CMD_DIR}/bkp_report.lst >> ${LOG_DIR}/rman_mig_bkp.log
}
 
function gen_expdp {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
 
if [ ! -z ${RMAN_SCAN} ]; then 
    connection_string="/${SRC_SCAN_CONN}"
else
     connection_string="${1}/${2}${SRC_SCAN_CONN}"
fi

export EXP_PAR=${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par
echo "USERID='${connection_string}'" > ${EXP_PAR}
echo "DUMPFILE=exp_${ORACLE_SID}_${DT}.dmp" >> ${EXP_PAR}
echo "DIRECTORY=${SOURCE_DPDIR}" >> ${EXP_PAR}
echo "LOGFILE=exp_${ORACLE_SID}.log" >> ${EXP_PAR}
echo "REUSE_DUMPFILES=y" >> ${EXP_PAR}
echo "TRANSPORTABLE=ALWAYS" >> ${EXP_PAR}
echo "LOGTIME=ALL" >> ${EXP_PAR}
echo "METRICS=Y" >> ${EXP_PAR}
echo "FULL=Y" >> ${EXP_PAR}
echo "EXCLUDE = STATISTICS" >> ${EXP_PAR}
echo "TRACE=${DP_TRACE}" >> ${EXP_PAR}
echo "PARALLEL=${DP_PARALLEL}" >> ${EXP_PAR}
if [[ "${DP_ENC_PROMPT}" = "Y" ]]; then
  echo "Enter the encryption password to use for export"
  stty -echo
  read encrypt_pw
  stty echo
 # echo "ENCRYPTION_PWD_PROMPT=YES" >> ${EXP_PAR}
  echo "ENCRYPTION_PASSWORD=${encrypt_pw}" >> ${EXP_PAR}
fi  

}
 
function run_expdp {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
${ORACLE_HOME}/bin/expdp parfile=${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par
}

function copy_dmp {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi

if [[ -n "${DEST_SERVER}" ]]; then
  #scp to destination
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Transferring Data Pump dump file to destination"
  ${CMD_SCP} ${SOURCE_DPDMP}/exp_${ORACLE_SID}_${DT}.dmp ${DEST_USER}\@${DEST_SERVER}:${DEST_DPDMP}
else
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Manually copy Data Pump dump file to destination"
  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`:  => ${SOURCE_DPDMP}/exp_${ORACLE_SID}_${DT}.dmp"
fi

}

function run_backup {
if [[ "${DEBUG_CMD}"  = "DEBUG_SCRIPT" ]]; then
  set -x
fi
export BKP_LOG=${LOG_DIR}/bkp_${BKP_LEVEL}_${CHN}CH_${SECTION_SIZE}_${ORACLE_SID}_${DT}.log
export TRC_LOG=${LOG_DIR}/bkp_${BKP_LEVEL}_${CHN}CH_${SECTION_SIZE}_${ORACLE_SID}_${DT}.trc
case ${BKP_LEVEL} in
          "L1F")
              echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing final backup iteration for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
              case ${BKP_DEST_TYPE} in
                        "DISK") 
                              case ${BKP_FROM_STDBY} in
                                        "0") 
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Switching migrated tablespaces to read-only pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          if [ ! -z ${RMAN_SCAN} ]; then
                                             system_pw="IGNORE"
                                          else   
                                            echo "============================================"
                                            echo "Enter the system password to perform read only tablespaces"
                                            stty -echo
                                            read system_pw
                                            stty echo                                                                                
                                          fi    
                                          check_conn ${SYSTEM_USR} ${system_pw} ${SRC_SCAN_CONN}
                                          run_ts_ro ${TSF} ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating export datapump parfile for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                   
                                          gen_expdp ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated export datapump parfile ${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Running export datapump for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_expdp &
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing Backup pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          if [[ "${RMAN_DEBUG}" = "N" ]]; then
                                             ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE}  &
                                          else
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG} &
                                          fi
                                          
                                          echo "waiting "
                                          wait
                                          copy_dmp
                                          
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          chk_backup ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          gen_restore ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log

                                        ;;
                                        "1") 
                                          if [ ! -z ${RMAN_SCAN} ]; then
                                            system_pw="IGNORE"
                                          else
                                            echo "Enter the system password to perform read only tablespaces and export data pump"
                                            stty -echo
                                            read system_pw
                                            stty echo
                                          fi  
                                          check_conn ${SYSTEM_USR} ${system_pw} ${SRC_SCAN_CONN}                            
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Converting Standby to Snapshot for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_conv_stby "snapshot"
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Switching migrated tablespaces to read-only pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "============================================"
                                          run_ts_ro ${TSF} ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating export datapump parfile for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                   
                                          gen_expdp ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated export datapump parfile ${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Running export datapump for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_expdp &
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing Backup pid $$" >> ${LOG_DIR}/rman_mig_bkp.log

                                          if [[ "${RMAN_DEBUG}" = "N" ]]; then
                                             ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE} &
                                          else
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG} &
                                          fi                                      

                                          echo "waiting "
                                          wait
                                          copy_dmp

                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          chk_backup ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          gen_restore ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Converting Standby to Physical for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                                         
                                          run_conv_stby "physical"
                                        ;;
                              esac         
                          ;;
                        "SBT_TAPE")
                              case ${BKP_FROM_STDBY} in
                                        "0") 
                                          if [ ! -z ${RMAN_SCAN} ]; then
                                           system_pw="IGNORE"
                                          else
                                            echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Switching migrated tablespaces to read-only pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                            echo "============================================"
                                            echo "Enter the system password to perform read only tablespaces and export data pump"
                                            stty -echo
                                            read system_pw
                                            stty echo
                                          fi    
                                          check_conn ${SYSTEM_USR} ${system_pw} ${SRC_SCAN_CONN}
                                          run_ts_ro ${TSF} ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating export datapump parfile for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                   
                                          gen_expdp ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated export datapump parfile ${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Running export datapump for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_expdp &
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing Backup pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          if [[ "${RMAN_DEBUG}" = "N" ]]; then
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE} &
                                          else
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG} &
                                          fi  

                                          echo "waiting "
                                          wait
                                          copy_dmp  

                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          chk_backup ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          gen_restore ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          
                                        ;;
                                        "1")
                                                                                  echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Switching migrated tablespaces to read-only pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          if [ ! -z ${RMAN_SCAN} ]; then                                        
                                            system_pw="IGNORE"
                                          else
                                            echo "============================================"
                                            echo "Enter the system password to perform read only tablespaces"
                                            stty -echo
                                            read system_pw
                                            stty echo
                                          fi    
                                          check_conn ${SYSTEM_USR} ${system_pw} ${SRC_SCAN_CONN}   
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Converting Standby to Snapshot for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_conv_stby "snapshot"   
                                          run_ts_ro ${TSF} ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating export datapump parfile for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          gen_expdp ${SYSTEM_USR} ${system_pw}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated export datapump parfile ${CMD_DIR}/exp_${ORACLE_SID}_${DT}_xtts.par for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Running export datapump for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          run_expdp &                                          
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing Backup pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          if [[ "${RMAN_DEBUG}" = "N" ]]; then
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE} &
                                          else
                                            ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG} &
                                          fi

                                          echo "waiting "
                                          wait
                                          copy_dmp

                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          chk_backup ${BKP_LOG}                                         
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          gen_restore ${BKP_LOG}
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                                          echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Converting Standby to Physical for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                                          
                                          run_conv_stby "physical"
                                        ;;
                              esac                       
                          ;;               
              esac
           ;;
          "L0"|"L1")
                echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing backup iteration log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                case ${BKP_DEST_TYPE} in
                "DISK")
                      if [[ "${RMAN_DEBUG}" = "N" ]]; then
                        ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE}
                      else
                        ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG}
                      fi
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      chk_backup ${BKP_LOG}
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log                   
                      gen_restore ${BKP_LOG}
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Saving SCN for next backup for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Saving SCN for next backup for pid $$"
                      if [[ "${RMAN_DEBUG}" = "N" ]]; then
                         ${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk '{gsub(/ /, "", $1); print $1}' > ${CMD_DIR}/.next_scn
                         echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: SCN taken before backup in logfile ${BKP_LOG} is: `${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk '{gsub(/ /, "", $1); print $1}'`" >> ${CMD_DIR}/.next_scn_hist                   
                      else
                         ${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk -F':' '{gsub(/ /, "", $2); print $2}' > ${CMD_DIR}/.next_scn
                         echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: SCN taken before backup in logfile ${BKP_LOG} is: `${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk -F':' '{gsub(/ /, "", $2); print $2}'`" >> ${CMD_DIR}/.next_scn_hist                   
                      fi   
                  ;;
                "SBT_TAPE")
                      if [[ "${RMAN_DEBUG}" = "N" ]]; then
                        ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE}
                      else
                        ${ORACLE_HOME}/bin/rman target /${RMAN_SCAN_CONN} catalog ${CAT_CRED} log=${BKP_LOG} cmdfile=${CMD_FILE} debug trace=${TRC_LOG}
                      fi                
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Checking backup log for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      chk_backup ${BKP_LOG}
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating restore command ${RES_CMD} for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      gen_restore ${BKP_LOG}
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generated restore command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Saving SCN for next backup for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
                      echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Saving SCN for next backup for pid $$"
                      if [[ "${RMAN_DEBUG}" = "N" ]]; then
                         ${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk '{gsub(/ /, "", $1); print $1}' > ${CMD_DIR}/.next_scn
                         echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: SCN taken before backup in logfile ${BKP_LOG} is: `${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk '{gsub(/ /, "", $1); print $1}'`" >> ${CMD_DIR}/.next_scn_hist                   
                      else
                         ${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk -F':' '{gsub(/ /, "", $2); print $2}' > ${CMD_DIR}/.next_scn                         
                         echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: SCN taken before backup in logfile ${BKP_LOG} is: `${CMD_CAT} ${BKP_LOG} | awk '/PREV_INCR_CKP_SCN/{getline; getline; print}' | awk -F':' '{gsub(/ /, "", $2); print $2}'`" >> ${CMD_DIR}/.next_scn_hist                                            
                      fi                         
                  ;;
      esac
esac
}
 
check_rdbms_version


if [ ! -z ${RMAN_SCAN} ]; then 
   check_conn "ignore" "ignore" ${SRC_SCAN_CONN}
fi
echo "=========================================================================================================" >> ${LOG_DIR}/rman_mig_bkp.log
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: No active previous RMAN execution, touching lock file and running DB backup for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
${CMD_TOUCH} ${LOG_DIR}/rman_mig_bkp.lck
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Requested ${BKP_LEVEL} backup for pid $$.  Using ${BKP_DEST_TYPE} destination, ${CHN} channels and ${SECTION_SIZE}${SECTION_SIZE_UNIT} section size."
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Requested ${BKP_LEVEL} backup for pid $$.  Using ${BKP_DEST_TYPE} destination, ${CHN} channels with ${SECTION_SIZE}${SECTION_SIZE_UNIT} section size." >> ${LOG_DIR}/rman_mig_bkp.log
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Performing ${BKP_LEVEL} backup for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Performing ${BKP_LEVEL} backup for pid $$"
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Generating backup script for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
gen_backup
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Executing backup routine command for pid $$" >> ${LOG_DIR}/rman_mig_bkp.log
run_backup
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Backup log is: ${BKP_LOG}" >> ${LOG_DIR}/rman_mig_bkp.log
echo "`date +%Y-%m-%d\ %H:%M:%S` - `date +%s%3N`: Restore command is: ${RES_CMD}" >> ${LOG_DIR}/rman_mig_bkp.log
bkp_report
${CMD_RM} ${LOG_DIR}/rman_mig_bkp.lck