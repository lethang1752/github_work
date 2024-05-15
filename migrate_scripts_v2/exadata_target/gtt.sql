  CREATE GLOBAL TEMPORARY TABLE "FCCAPP"."SYS_TEMP_FBT"                         
   (	"SCHEMA" VARCHAR2(32),                                                     
	"OBJECT_NAME" VARCHAR2(32),                                                    
	"OBJECT#" NUMBER,                                                              
	"RID" UROWID (4000),                                                           
	"ACTION" CHAR(1)                                                               
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."BANK_MSTGLOABLLIMITS_TMP"       
   (	"ID_ENTITY" VARCHAR2(5),                                                   
	"PACKAGE_ID" VARCHAR2(50),                                                     
	"PACKAGE_DESC" VARCHAR2(100),                                                  
	"LIMITS" BLOB,                                                                 
	"CREATEDBY" VARCHAR2(50),                                                      
	"CREATEDON" DATE DEFAULT sysdate,                                              
	"LASTUPDATEDBY" VARCHAR2(50),                                                  
	"LASTUPDATEDON" DATE DEFAULT sysdate,                                          
	"ISDEFAULT" VARCHAR2(1) DEFAULT 'N',                                           
	"TYPEUSER" VARCHAR2(3)                                                         
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."BANK_MSTUSER_TMP"               
   (	"ID_ENTITY" VARCHAR2(5),                                                   
	"TYPEUSER" VARCHAR2(3),                                                        
	"IDUSER" VARCHAR2(20),                                                         
	"NICNAME" VARCHAR2(40),                                                        
	"SALUTION" VARCHAR2(20),                                                       
	"FIRSTNAME" VARCHAR2(50),                                                      
	"LASTNAME" VARCHAR2(50),                                                       
	"ADDRESS1" VARCHAR2(60),                                                       
	"ADDRESS2" VARCHAR2(60),                                                       
	"CITY" VARCHAR2(60),                                                           
	"STATE" VARCHAR2(60),                                                          
	"COUNTRY" VARCHAR2(60),                                                        
	"ZIP" VARCHAR2(30),                                                            
	"DOB" DATE,                                                                    
	"EMAIL" VARCHAR2(100),                                                         
	"ACTIVEFLAG" CHAR(1) DEFAULT 'N',                                              
	"PHONENUMBER" VARCHAR2(20),                                                    
	"FAXNBR" VARCHAR2(20),                                                         
	"PERSCSS" VARCHAR2(50),                                                        
	"STATEBIT" NUMBER(3,0) DEFAULT 0,                                              
	"USERCERT" VARCHAR2(4000),                                                     
	"CERTTOKENTYPE" CHAR(1),                                                       
	"TXNLIMITFLAG" CHAR(1) DEFAULT 'Y',                                            
	"ACCOUNTMAPFLAG" CHAR(1) DEFAULT 'Y',                                          
	"USERSEQNBR" NUMBER,                                                           
	"USERTOKEN" VARCHAR2(100),                                                     
	"SECURETOKENID" VARCHAR2(2000),                                                
	"AUTHREQD" CHAR(1) DEFAULT 'Y',                                                
	"DATCREATED" DATE DEFAULT sysdate,                                             
	"MAKERID" VARCHAR2(20),                                                        
	"DELETECOMMENTS" VARCHAR2(255),                                                
	"IDHARDTOKEN" VARCHAR2(10),                                                    
	"PRODUCTNAME" VARCHAR2(50),                                                    
	"PRODUCTVERSION" VARCHAR2(10),                                                 
	"USERGROUPBASETYPE" CHAR(1) DEFAULT 'E',                                       
	"USERGROUPTYPE" CHAR(1) DEFAULT 'N',                                           
	"SERIALNO" VARCHAR2(22),                                                       
	"IDSEGMENT" VARCHAR2(30),                                                      
	"USERKEY" VARCHAR2(18),                                                        
	"REF_USERTYPE" VARCHAR2(255),                                                  
	"PREFERENCES" BLOB,                                                            
	"USERDATA" BLOB,                                                               
	"PACKAGE_ID" VARCHAR2(50),                                                     
	"KYCSTATUS" NUMBER(1,0) DEFAULT 0,                                             
	"OPERATIVEACCTNO" VARCHAR2(30),                                                
	"OPERATIVEBRNCODE" VARCHAR2(5),                                                
	"NBRTNCDECLINE" NUMBER(2,0) DEFAULT 0,                                         
	"TNCSTATUS" CHAR(1) DEFAULT 'N',                                               
	"LASTTNCACTIONDATETIME" TIMESTAMP (6)                                          
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."BCTMS_FFT_MASTER_TMP"           
   (	"FFT_CODE" VARCHAR2(12),                                                   
	"LANG_CODE" VARCHAR2(3),                                                       
	"FREE_FORMAT_TEXT" CLOB,                                                       
	"MAKER_ID" VARCHAR2(12),                                                       
	"MAKER_DT_STAMP" DATE,                                                         
	"CHECKER_ID" VARCHAR2(12),                                                     
	"CHECKER_DT_STAMP" DATE,                                                       
	"RECORD_STAT" CHAR(1),                                                         
	"AUTH_STAT" CHAR(1),                                                           
	"ONCE_AUTH" CHAR(1),                                                           
	"MOD_NO" NUMBER(4,0)                                                           
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."GLOBAL_TEMP_ACCOUNT"            
   (	"IDCUST" VARCHAR2(30),                                                     
	"TXTCORPDESC" VARCHAR2(105),                                                   
	"IDACCOUNT" VARCHAR2(20),                                                      
	"CODBRANCH" VARCHAR2(5),                                                       
	"NAMBRANCH" VARCHAR2(105),                                                     
	"ACCTTYPE" VARCHAR2(2),                                                        
	"TXTACCTSTATUS" VARCHAR2(10),                                                  
	"PRDNAME" VARCHAR2(105),                                                       
	"PRDTYPE" VARCHAR2(50),                                                        
	"IDRELATIONSHIP" VARCHAR2(4),                                                  
	"JOINTACCTINDICATOR" VARCHAR2(1),                                              
	"IDLOCATION" VARCHAR2(20),                                                     
	"IBANNO" VARCHAR2(35),                                                         
	"CHQFACILITY" VARCHAR2(1),                                                     
	"CODCURRENCY" VARCHAR2(300),                                                   
	"DATLASTUPDATED" DATE,                                                         
	"ID_ENTITY" VARCHAR2(5),                                                       
	"CODPROD" VARCHAR2(50),                                                        
	"CURRBALANCE" NUMBER,                                                          
	"AVLBALANCE" NUMBER,                                                           
	"EQVBALANCE" NUMBER,                                                           
	"IDCUSTEXT" VARCHAR2(30),                                                      
	"EXTCORPDESC" VARCHAR2(105),                                                   
	"BANKCODE" VARCHAR2(15),                                                       
	"BANKNAME" VARCHAR2(80),                                                       
	"BANKCOUNTRYCODE" VARCHAR2(3),                                                 
	"NICKNAME" VARCHAR2(100),                                                      
	"MATURITY_DATE" DATE,                                                          
	"NEXT_DUE_DATE" DATE,                                                          
	"UDF1" VARCHAR2(20),                                                           
	"UDF2" VARCHAR2(20),                                                           
	"UDF3" VARCHAR2(20),                                                           
	"UDF4" VARCHAR2(20),                                                           
	"UDF5" VARCHAR2(20),                                                           
	"UDF6" VARCHAR2(20),                                                           
	"UDF7" VARCHAR2(20),                                                           
	"UDF8" VARCHAR2(20),                                                           
	"UDF9" VARCHAR2(20),                                                           
	"UDF10" VARCHAR2(20),                                                          
	"IDTXN" VARCHAR2(3),                                                           
	"IDUSER" VARCHAR2(20),                                                         
	 CONSTRAINT "CA_GLOBAL_TEMP_ACCOUNT" CHECK (   "IDCUST" IS NOT NULL) ENABLE,   
	 CONSTRAINT "CB_GLOBAL_TEMP_ACCOUNT" CHECK (   "IDACCOUNT" IS NOT NULL) ENABLE,
	 CONSTRAINT "CC_GLOBAL_TEMP_ACCOUNT" CHECK (   "CODBRANCH" IS NOT NULL) ENABLE,
	 CONSTRAINT "CD_GLOBAL_TEMP_ACCOUNT" CHECK (   "ACCTTYPE" IS NOT NULL) ENABLE, 
	 CONSTRAINT "CE_GLOBAL_TEMP_ACCOUNT" CHECK (   "ID_ENTITY" IS NOT NULL) ENABLE,
	 CONSTRAINT "CF_GLOBAL_TEMP_ACCOUNT" CHECK ( "IDUSER" IS NOT NULL) ENABLE      
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."LCTBS_DOCUMENTS_TMP"            
   (	"CONTRACT_REF_NO" VARCHAR2(16),                                            
	"VERSION_NO" NUMBER(4,0),                                                      
	"EVENT_SEQ_NO" NUMBER,                                                         
	"EVENT_CODE" VARCHAR2(4),                                                      
	"DOC_CODE" VARCHAR2(12),                                                       
	"DOC_SL_NO" NUMBER(4,0),                                                       
	"DOC_TYPE" CHAR(1),                                                            
	"DOC_DESCR" CLOB,                                                              
	"DOC_ORIGINAL" CHAR(1),                                                        
	"DOC_COPIES" NUMBER(4,0),                                                      
	"NO_OF_ORIGINALS" VARCHAR2(5),                                                 
	"DOC_REFERENCE" VARCHAR2(105),                                                 
	 CONSTRAINT "PK01_LCTB_DOCUMENTS" PRIMARY KEY ("CONTRACT_REF_NO", "EVENT_SEQ_NO", "DOC_CODE") ENABLE                           ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."LCTBS_FFTS_TMP"                 
   (	"CONTRACT_REF_NO" VARCHAR2(16),                                            
	"VERSION_NO" NUMBER(4,0),                                                      
	"EVENT_SEQ_NO" NUMBER,                                                         
	"EVENT_CODE" VARCHAR2(4),                                                      
	"FFT_INS_CODE" VARCHAR2(12),                                                   
	"FFT_INS_SL_NO" NUMBER(4,0),                                                   
	"FFT_INS_DESCR" CLOB,                                                          
	"MESG_TYPE" VARCHAR2(15),                                                      
	"PARTY_TYPE" VARCHAR2(3),                                                      
	"SINGLE_FFT" VARCHAR2(1),                                                      
	"GUARREFNO" VARCHAR2(16)                                                       
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."LCTBS_GOODS_TMP"                
   (	"CONTRACT_REF_NO" VARCHAR2(16),                                            
	"VERSION_NO" NUMBER(4,0),                                                      
	"EVENT_SEQ_NO" NUMBER,                                                         
	"EVENT_CODE" VARCHAR2(4),                                                      
	"GOODS_DESCR" CLOB,                                                            
	"GOODS_CODE" VARCHAR2(12),                                                     
	"PRE_ADVICE_DESCR" VARCHAR2(9),                                                
	"INCO_TERM" VARCHAR2(15)                                                       
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."LCTBS_SHIPMENT_TMP"             
   (	"CONTRACT_REF_NO" VARCHAR2(16),                                            
	"VERSION_NO" NUMBER(4,0),                                                      
	"EVENT_SEQ_NO" NUMBER,                                                         
	"EVENT_CODE" VARCHAR2(4),                                                      
	"FROM_PLACE" VARCHAR2(65),                                                     
	"TO_PLACE" VARCHAR2(65),                                                       
	"LATEST_SHIPMENT_DATE" DATE,                                                   
	"PARTIAL_SHIPMENT" CHAR(1),                                                    
	"TRANS_SHIPMENT" CHAR(1),                                                      
	"SHIPMENT_DETAILS" CLOB,                                                       
	"SHIPMENT_MARKS" VARCHAR2(2000),                                               
	"SHIPMENT_PERIOD" VARCHAR2(395),                                               
	"PORT_DISCHARGE" VARCHAR2(65),                                                 
	"PORT_LOADING" VARCHAR2(65),                                                   
	"SHIPMENT_DAYS" NUMBER,                                                        
	"PARTIAL_SHIPMENT_DETAILS" VARCHAR2(35),                                       
	"TRANS_SHIPMENT_DETAILS" VARCHAR2(35)                                          
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."MSTBS_DLY_MSG_OUT_TMP"          
   (	"BRANCH" VARCHAR2(3),                                                      
	"DCN" VARCHAR2(16),                                                            
	"REFERENCE_NO" VARCHAR2(35),                                                   
	"MODULE" VARCHAR2(2),                                                          
	"MSG_TYPE" VARCHAR2(15),                                                       
	"MEDIA" VARCHAR2(15),                                                          
	"CHECKER_DT_STAMP" DATE,                                                       
	"MESSAGE" CLOB                                                                 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNADMIN_PRD"."MSTGLOBALLIMITSPACKAGE_TMP"     
   (	"ID_ENTITY" VARCHAR2(5),                                                   
	"PACKAGE_ID" VARCHAR2(50),                                                     
	"PACKAGE_DESC" VARCHAR2(100),                                                  
	"LIMITS" BLOB,                                                                 
	"CREATEDBY" VARCHAR2(50),                                                      
	"CREATEDON" DATE,                                                              
	"LASTUPDATEDBY" VARCHAR2(50),                                                  
	"LASTUPDATEDON" DATE,                                                          
	"ISDEFAULT" VARCHAR2(1),                                                       
	"TYPEUSER" VARCHAR2(3)                                                         
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."ACTW_TANK"                           
   (	"TRN_REF_NO" VARCHAR2(16 CHAR),                                            
	"EVENT" VARCHAR2(4 CHAR),                                                      
	"BALANCE_UPD" CHAR(1 CHAR),                                                    
	"TRN_DT" DATE,                                                                 
	"AC_BRANCH" VARCHAR2(3 CHAR)                                                   
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."CLTB_ACCOUNT_COMP_SCH_TMP"           
   (	"ACCOUNT_NUMBER" VARCHAR2(35 CHAR) NOT NULL ENABLE,                        
	"BRANCH_CODE" VARCHAR2(35 CHAR) NOT NULL ENABLE,                               
	"COMPONENT_NAME" VARCHAR2(20 CHAR) NOT NULL ENABLE,                            
	"SCHEDULE_TYPE" VARCHAR2(1 CHAR) NOT NULL ENABLE,                              
	"SCHEDULE_FLAG" VARCHAR2(1 CHAR),                                              
	"FORMULA_NAME" VARCHAR2(27 CHAR),                                              
	"SCH_START_DATE" DATE NOT NULL ENABLE,                                         
	"NO_OF_SCHEDULES" NUMBER,                                                      
	"FREQUENCY" NUMBER,                                                            
	"UNIT" VARCHAR2(1 CHAR),                                                       
	"SCH_END_DATE" DATE,                                                           
	"AMOUNT" NUMBER,                                                               
	"PAYMENT_MODE" VARCHAR2(20 CHAR),                                              
	"PMNT_PROD_AC" VARCHAR2(20 CHAR),                                              
	"PAYMENT_DETAILS" VARCHAR2(20 CHAR),                                           
	"BEN_ACCOUNT" VARCHAR2(20 CHAR),                                               
	"BEN_BANK" VARCHAR2(20 CHAR),                                                  
	"BEN_NAME" VARCHAR2(105 CHAR),                                                 
	"CAPITALIZED" VARCHAR2(1 CHAR),                                                
	"FIRST_DUE_DATE" DATE,                                                         
	"WAIVER_FLAG" VARCHAR2(1 CHAR),                                                
	"COMPOUND_DAYS" NUMBER,                                                        
	"COMPOUND_MONTHS" NUMBER,                                                      
	"COMPOUND_YEARS" NUMBER,                                                       
	"EMI_AMOUNT" NUMBER,                                                           
	"DUE_DATES_ON" NUMBER(2,0),                                                    
	"DAYS_MTH" VARCHAR2(1 CHAR),                                                   
	"DAYS_YEAR" VARCHAR2(1 CHAR),                                                  
	"DP_AMOUNT" NUMBER,                                                            
	"PAY_MODE" VARCHAR2(1 CHAR),                                                   
	"PAYABLE_ACC" VARCHAR2(20 CHAR),                                               
	"EXCH_RATE" NUMBER(24,12),                                                     
	"PAYABLE_ACC_CCY" VARCHAR2(3 CHAR),                                            
	"EMI_AS_PERCENTAGE_SALARY" NUMBER                                              
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."ICTB_TMP_ACC_SDE"                    
   (	"BRN" VARCHAR2(3),                                                         
	"ACC" VARCHAR2(20)                                                             
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."ICTW_ADVINT_CALC"                    
   (	"BRN" VARCHAR2(3 CHAR),                                                    
	"ACC" VARCHAR2(20 CHAR),                                                       
	"FROM_DATE" DATE,                                                              
	"TO_DATE" DATE,                                                                
	"BASIS_AMT" NUMBER(22,3),                                                      
	 CONSTRAINT "PK_ICTW_ADVINT_CALC" PRIMARY KEY ("BRN", "ACC", "FROM_DATE", "TO_DATE") ENABLE                                    ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."ICTW_MEMO_BOOKING"                   
   (	"BRN" VARCHAR2(3 CHAR),                                                    
	"ACC" VARCHAR2(35 CHAR),                                                       
	"PROD" VARCHAR2(4 CHAR),                                                       
	"FRM_NO" VARCHAR2(3 CHAR),                                                     
	"IS_TAX" VARCHAR2(1 CHAR),                                                     
	"DRCR_IND" VARCHAR2(1 CHAR),                                                   
	"AMT" NUMBER,                                                                  
	 CONSTRAINT "PK_ICTW_MEMO_BOOKING" PRIMARY KEY ("ACC", "BRN", "PROD", "FRM_NO") ENABLE                                         ) ON COMMIT PRESERVE ROWS ;                                       
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."MSTB_ADV_INPUT"                      
   (	"DCN" VARCHAR2(16),                                                        
	"FIELD_TAG" VARCHAR2(50),                                                      
	"LOOP_NO" NUMBER,                                                              
	"VALUE" VARCHAR2(2000),                                                        
	"JUSTIFY" CHAR(1),                                                             
	 CONSTRAINT "PK_MSTB_ADV_INPUT" PRIMARY KEY ("DCN", "FIELD_TAG", "LOOP_NO") ENABLE                                             ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."MSTB_ADV_INPUT_DET"                  
   (	"DCN" VARCHAR2(16),                                                        
	"FIELD_TAG" VARCHAR2(50),                                                      
	"LOOP_NO" NUMBER,                                                              
	"VALUE" VARCHAR2(2000),                                                        
	"JUSTIFY" CHAR(1),                                                             
	"INNER_LOOP_NO" NUMBER,                                                        
	 CONSTRAINT "PK_MSTB_ADV_INPUT_DET" PRIMARY KEY ("DCN", "FIELD_TAG", "LOOP_NO","INNER_LOOP_NO") ENABLE                         ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."OFAT_FILE_COMPARE_SOURCE"            
   (	"LINE_NO" NUMBER,                                                          
	"FILE_CONTENTS" VARCHAR2(4000 CHAR),                                           
	 CONSTRAINT "PK_OFAT_FILE_COMPARE_SOURCE" PRIMARY KEY ("LINE_NO") ENABLE       
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."OFAT_FILE_COMPARE_TARGET"            
   (	"LINE_NO" NUMBER,                                                          
	"FILE_CONTENTS" VARCHAR2(4000 CHAR),                                           
	 CONSTRAINT "PK_OFAT_FILE_COMPARE_TARGET" PRIMARY KEY ("LINE_NO") ENABLE       
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."OFAT_TEMPORARY_FILES"                
   (	"TODAY" DATE,                                                              
	"ENVCODE" VARCHAR2(255 CHAR),                                                  
	"FILEPATH" VARCHAR2(255 CHAR),                                                 
	"FILENAME" VARCHAR2(255 CHAR),                                                 
	 CONSTRAINT "PK_OFAT_TEMPORARY_FILES" PRIMARY KEY ("TODAY", "ENVCODE", "FILEPATH", "FILENAME") ENABLE                         ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."OFTB_BRANCH_SEL"                     
   (	"ENVCODE" VARCHAR2(50 CHAR),                                               
	"BRANCH_CODE" VARCHAR2(10 CHAR),                                               
	"BRANCH_DESC" VARCHAR2(100 CHAR),                                              
	 CONSTRAINT "PK_OFTB_BRANCH_SEL" PRIMARY KEY ("ENVCODE", "BRANCH_CODE") ENABLE 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."OFTB_CUSTOMER_LIST"                  
   (	"ENVCODE" VARCHAR2(100 CHAR),                                              
	"BRANCH_CODE" VARCHAR2(3 CHAR),                                                
	"CUSTOMER_NO" VARCHAR2(9 CHAR),                                                
	"CUSTOMER_CATEGORY" VARCHAR2(100 CHAR),                                        
	 CONSTRAINT "PK_OFTB_CUSTOMER_LIST" PRIMARY KEY ("ENVCODE", "BRANCH_CODE", "CUSTOMER_NO", "CUSTOMER_CATEGORY") ENABLE          ) ON COMMIT DELETE ROWS ;                                                    
 
CREATE GLOBAL TEMPORARY TABLE "SPNLIVE"."SMTW_BRANCH_SHARED_LOCK"
   (    "LOCK_NAME" VARCHAR2(100 CHAR)
   ) ON COMMIT DELETE ROWS;

/
