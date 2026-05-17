# AIX Installation Guide
### **Config OS for oracle database**
```bash
vmo -r -o vmm_klock_mode=2
vmo -r -o vpm_xvcpus=2
schedo -r -o vpm_xvcpus=2
/usr/sbin/no –o -p udp_sendspace=655360
/usr/sbin/no –o -p udp_recvspace=655360
/usr/sbin/no -o -p tcp_sendspace=65536
/usr/sbin/no –o -p tcp_recvspace=65536 
/usr/sbin/no –o -p rfc1323=1
/usr/sbin/no -o -p sb_max=4194304 
/usr/sbin/no -o -p ipqmaxlen=512
```
### **Setting limit of user : /etc/security/limit**
```bash
root:
 fsize = -1
 data = -1
 stack = -1
 core = -1
 nofiles = -1
 rss = -1
 cpu = -1
 stack_hard = -1
grid:
 fsize = -1
 data = -1
 stack = -1
 core = -1
 nofiles = -1
 rss = -1
 cpu = -1
 stack_hard = -1
oracle:
 fsize = -1
 data = -1
 stack = -1
 core = -1
 nofiles = -1
 rss = -1
 cpu = -1
 stack_hard = -1
```
### **DISK for grid**
```bash
lspv -u (check disk)
lkdev -l hdisk* -d (unlock disk)
lsattr -El hdisk* -a reserve_policy (check policy)
chdev -l hdisk* -a reserve_policy=no_reserve (change policy)

chown grid:asmadmin /dev/rhdisk* 
chmod 660 /dev/rhdisk* 
```
### **Create user grid and oracle on both nodes**
```bash
mkgroup -A id=54421 oinstall
mkgroup -A id=54322 dba
mkgroup -A id=54323 oper
mkgroup -A id=54327 asmdba
mkgroup -A id=54328 asmoper
mkgroup -A id=54329 asmadmin

mkuser id='54321' pgrp='oinstall' groups='dba,oper,asmdba,asmoper,asmadmin' home='/home/oracle' shell='/usr/bin/bash' oracle
mkuser id='54322' pgrp='oinstall' groups='asmadmin,asmdba,dba,asmoper' home='/home/grid' shell='/usr/bin/bash' grid

chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE oracle
chuser capabilities=CAP_NUMA_ATTACH,CAP_BYPASS_RAC_VMM,CAP_PROPAGATE grid

passwd grid 
passwd oracle
```
### **Create folder for install grid and database**
```bash
mkdir -p /u01/app/19.0.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle/product/11.2.0.4/dbhome_1
mkdir -p /u01/app/oracle
chown -R grid:oinstall /u01
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01
```
### **Vi .profile grid**
### **Node 1**
```bash
export PS1="[\u@\h \W]# "
export AIXTHREAD_SCOPE=S
export ORACLE_SID=+ASM1
export ORACLE_HOME=/u01/app/19.0.0/grid
export PATH=$PATH:$ORACLE_HOME/bin
export LDR_CNTRL=MAXDATA=0x80000000
```
### **Node 2**
```bash
export PS1="[\u@\h \W]# "
export AIXTHREAD_SCOPE=S
export ORACLE_SID=+ASM2
export ORACLE_HOME=/u01/app/19.0.0/grid
export PATH=$PATH:$ORACLE_HOME/bin
export LDR_CNTRL=MAXDATA=0x80000000
```
### **Setting ssh for grid between 2 node**
```bash
./sshUserSetup.sh -user grid -hosts "dcdwhdbstb01 dcdwhdbstb02" -noPromptPassphrase -confirm -advanced
```
### **Change SCP file both nodes**
```bash
mv /usr/bin/scp /usr/bin/scp.orig
vi /usr/bin/scp
--
#!/bin/bash
/usr/bin/scp.orig -O "$@"
--
chmod 555 /usr/bin/scp
```
### **Patch grid**
```bash
./opatchauto apply /u01/app/software/software_grid_19c/35642822 -oh /u01/app/19.0.0/grid
```
### **Vi .profile oracle**
### **Node 1**
```bash
export PS1="[\u@\h \w]# "
export AIXTHREAD_SCOPE=S
export ORACLE_SID=DCDWHDBSTB1
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
export LDR_CNTRL=DATAPSIZE=64K@TEXTPSIZE=64K@STACKPSIZE=64K
export LDR_CNTRL=MAXDATA=0x80000000
```
### **Node 2**
```bash
export PS1="[\u@\h \w]# "
export AIXTHREAD_SCOPE=S
export ORACLE_SID=DCDWHDBSTB2
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
export LDR_CNTRL=DATAPSIZE=64K@TEXTPSIZE=64K@STACKPSIZE=64K
export LDR_CNTRL=MAXDATA=0x80000000
```
### **Setting ssh for oracle database between 2 node**
```bash
./sshUserSetup.sh -user grid -hosts "dcdwhdbstb01 dcdwhdbstb02" -noPromptPassphrase -confirm  -advanced
```
### **Patch DB**
### **Setting in both node before patching**
```bash
export USER=oracle
./opatch auto /u01/app/software/patchDB/31718723 -oh /u01/app/oracle/product/11.2.0.4/dbhome_1
```
### **Patch fix bug oracle database home**
```bash
./opatch apply -oh /u01/app/oracle/product/11.2.0.4/dbhome_1  -local /u01/app/software/patchDB/32109594
```
### **Start duplicate**
### **Config file listener.ora in gridhome on both node**
```bash
SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
   (SID_NAME = DCDWHDBSTB1)
   (GLOBAL_DBNAME = DCDWHDBSTB)
  )
 )
SID_LIST_LISTENER =
 (SID_LIST =
  (SID_DESC =
   (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
   (SID_NAME = DCDWHDBSTB2)
   (GLOBAL_DBNAME = DCDWHDBSTB)
  )
 )
```
### **turn off and turn on listener**
```bash
srvctl stop listener –l LISTENER
srvctl start listener –l LISTENER
```
### **Add tnsname DR and DC**
### **DCDWHDBSTB =**
```bash
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dcdwhdbstb01-vip)(PORT = 1521))
    (ADDRESS = (PROTOCOL = TCP)(HOST = dcdwhdbstb02-vip)(PORT = 1521))
(CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DCDWHDBSTB)(UR=A)
    )
  )
DCDWHDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dcdwhdb-scan.cicb.vn)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DCDWHDB)
    )
  )
```
### **Run file dup.sh for duplicate database**
```bash
#!/bin/sh
rman target sys/welcome1@DCDWHDB AUXILIARY sys/welcome1@DCDWHDBSTB log=`pwd`/dup.log <<EOS
run {
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  NOFILENAMECHECK;
}
EOS
```
### **Add broker to DC and DR**
### **DC**
```bash
alter system set dg_broker_config_file1='+DATA/dr1dcdwhdb.dat'
alter system set dg_broker_config_file2='+DATA/dr2dcdwhdb.dat'
alter system set dg_broker_start=TRUE
```
### **DR**
```bash
alter system set dg_broker_config_file1='+DATA/dr1dcdwhdb.dat'
alter system set dg_broker_config_file2='+DATA/dr2dcdwhdb.dat'
alter system set dg_broker_start=TRUE
dgmgrl /
```
### **Srcipt backup level 0:**
```bash
#!/bin/sh
date=`date +%d%m%y`
logfile=bkdb_level0_${date}.log
mkdir -p /acfs_backup/bk_level0/database/${date}
export NLS_DATA_FORMAT="YYYY-MM-DD"
rman target / log=/acfs_backup/bk_level0/$logfile <<EOS
run {
allocate channel c1 device type disk;
allocate channel c2 device type disk;
allocate channel c3 device type disk;
allocate channel c4 device type disk;
allocate channel c5 device type disk;
allocate channel c6 device type disk;
allocate channel c7 device type disk;
allocate channel c8 device type disk;
allocate channel c9 device type disk;
allocate channel c10 device type disk;
allocate channel c11 device type disk;
allocate channel c12 device type disk;
allocate channel c13 device type disk;
allocate channel c14 device type disk;
allocate channel c15 device type disk;
allocate channel c16 device type disk;
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
delete noprompt obsolete;
delete noprompt expired backup;
delete archivelog until time 'SYSDATE-2';
backup as compressed backupset incremental level 0 database format '/acfs_backup/bk_level0/database/${date}/db_%U.bak' MAXSETSIZE 80G;
backup as compressed backupset archivelog all format '/acfs_backup/bk_level0/database/${date}/arc_%U.bak';
backup current controlfile format '/acfs_backup/bk_level0/database/${date}/ctl_%U.bak';
backup spfile format '/acfs_backup/bk_level0/database/${date}/DCDWHDB_spfile_%T%U.bak';
}
EOS
```
### **Srcipt backup level 1:**
```bash
#!/bin/sh
date=`date +%d%m%y`
logfile='bkdb_level1_${date}.log'
mkdir -p /acfs_backup/bk_level1/database/${date}
export NLS_DATA_FORMAT="YYYY-MM-DD"
rman target / log=/acfs_backup/bk_level1/$logfile <<EOS
run {
allocate channel c1 device type disk;
allocate channel c2 device type disk;
allocate channel c3 device type disk;
allocate channel c4 device type disk;
allocate channel c5 device type disk;
allocate channel c6 device type disk;
allocate channel c7 device type disk;
allocate channel c8 device type disk;
allocate channel c9 device type disk;
allocate channel c10 device type disk;
allocate channel c11 device type disk;
allocate channel c12 device type disk;
allocate channel c13 device type disk;
allocate channel c14 device type disk;
allocate channel c15 device type disk;
allocate channel c16 device type disk;
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
delete noprompt obsolete;
delete noprompt expired backup;
delete archivelog until time 'SYSDATE-2';
backup as compressed backupset incremental level 1 database format '/acfs_backup/bk_level1/database/${date}/db_%U.bak' MAXSETSIZE 80G;
backup as compressed backupset archivelog all format '/acfs_backup/bk_level1/database/${date}/arc_%U.bak';
backup current controlfile format '/acfs_backup/bk_level1/database/${date}/ctl_%U.bak';
backup spfile format '/acfs_backup/bk_level1/database/${date}/DCDWHDB_spfile_%T%U.bak';
}
EOS
```