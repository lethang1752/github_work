export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
rman target / nocatalog log=/cbs_nfs/scripts/conv1.log << EOS
@conv1.rman
EOS
