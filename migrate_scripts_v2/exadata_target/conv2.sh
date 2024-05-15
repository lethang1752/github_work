export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
rman target / nocatalog log=/cbs_nfs/scripts/conv2.log << EOS
@conv2.rman
EOS
