/* ==================================== */
/* Make all user tablespaces READ WRITE */
/* ==================================== */

ALTER TABLESPACE USERS READ WRITE;
ALTER TABLESPACE FCCDATALAR READ WRITE;
ALTER TABLESPACE FCCDATAMED READ WRITE;
ALTER TABLESPACE FCCDATASML READ WRITE;
ALTER TABLESPACE FCCDATAXL READ WRITE;
ALTER TABLESPACE FCCINDXLAR READ WRITE;
ALTER TABLESPACE FCCINDXMED READ WRITE;
ALTER TABLESPACE FCCINDXSML READ WRITE;
ALTER TABLESPACE FCCINDXXL READ WRITE;
ALTER TABLESPACE FCAT_PRD READ WRITE;
ALTER TABLESPACE TBS_IDX_LOGDATA_PRD READ WRITE;
ALTER TABLESPACE TBS_LOGDATA_PRD READ WRITE;
ALTER TABLESPACE TBS_OFFLINE_PRD READ WRITE;

ALTER TABLESPACE TBS_REP_SCHEDULAR READ WRITE;
ALTER TABLESPACE FCCREP READ WRITE;
ALTER TABLESPACE AUDIT_AUX READ WRITE;
