impdp \'/as sysdba\' directory=ttsdir logfile=imp_user_meta_for_tbs.log metrics=Y TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y dumpfile=exp_all_cbs_meta.dmp full=y include=user,role,role_grant,profile
