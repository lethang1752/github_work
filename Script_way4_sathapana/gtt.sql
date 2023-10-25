  CREATE GLOBAL TEMPORARY TABLE "APEX_030200"."WWV_FLOW_LOV_TEMP"               
   (	"INSERT_ORDER" NUMBER,                                                     
	"DISP" VARCHAR2(4000),                                                         
	"VAL" VARCHAR2(4000)                                                           
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "APEX_030200"."WWV_FLOW_TEMP_TABLE"             
   (	"R" NUMBER,                                                                
	"C001" VARCHAR2(4000),                                                         
	"C002" VARCHAR2(4000),                                                         
	"C003" VARCHAR2(4000),                                                         
	"C004" VARCHAR2(4000),                                                         
	"C005" VARCHAR2(4000),                                                         
	"C006" VARCHAR2(4000),                                                         
	"C007" VARCHAR2(4000),                                                         
	"C008" VARCHAR2(4000),                                                         
	"C009" VARCHAR2(4000),                                                         
	"C010" VARCHAR2(4000),                                                         
	"C011" VARCHAR2(4000),                                                         
	"C012" VARCHAR2(4000),                                                         
	"C013" VARCHAR2(4000),                                                         
	"C014" VARCHAR2(4000),                                                         
	"C015" VARCHAR2(4000),                                                         
	"C016" VARCHAR2(4000),                                                         
	"C017" VARCHAR2(4000),                                                         
	"C018" VARCHAR2(4000),                                                         
	"C019" VARCHAR2(4000),                                                         
	"C020" VARCHAR2(4000),                                                         
	"C021" VARCHAR2(4000),                                                         
	"C022" VARCHAR2(4000),                                                         
	"C023" VARCHAR2(4000),                                                         
	"C024" VARCHAR2(4000),                                                         
	"C025" VARCHAR2(4000),                                                         
	"C026" VARCHAR2(4000),                                                         
	"C027" VARCHAR2(4000),                                                         
	"C028" VARCHAR2(4000),                                                         
	"C029" VARCHAR2(4000),                                                         
	"C030" VARCHAR2(4000),                                                         
	"C031" VARCHAR2(4000),                                                         
	"C032" VARCHAR2(4000),                                                         
	"C033" VARCHAR2(4000),                                                         
	"C034" VARCHAR2(4000),                                                         
	"C035" VARCHAR2(4000),                                                         
	"C036" VARCHAR2(4000),                                                         
	"C037" VARCHAR2(4000),                                                         
	"C038" VARCHAR2(4000),                                                         
	"C039" VARCHAR2(4000),                                                         
	"C040" VARCHAR2(4000),                                                         
	"C041" VARCHAR2(4000),                                                         
	"C042" VARCHAR2(4000),                                                         
	"C043" VARCHAR2(4000),                                                         
	"C044" VARCHAR2(4000),                                                         
	"C045" VARCHAR2(4000),                                                         
	"C046" VARCHAR2(4000),                                                         
	"C047" VARCHAR2(4000),                                                         
	"C048" VARCHAR2(4000),                                                         
	"C049" VARCHAR2(4000),                                                         
	"C050" VARCHAR2(4000),                                                         
	"C051" VARCHAR2(4000),                                                         
	"C052" VARCHAR2(4000),                                                         
	"C053" VARCHAR2(4000),                                                         
	"C054" VARCHAR2(4000),                                                         
	"C055" VARCHAR2(4000),                                                         
	"C056" VARCHAR2(4000),                                                         
	"C057" VARCHAR2(4000),                                                         
	"C058" VARCHAR2(4000),                                                         
	"C059" VARCHAR2(4000),                                                         
	"C060" VARCHAR2(4000),                                                         
	"C061" VARCHAR2(4000),                                                         
	"C062" VARCHAR2(4000),                                                         
	"C063" VARCHAR2(4000),                                                         
	"C064" VARCHAR2(4000),                                                         
	"C065" VARCHAR2(4000)                                                          
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "APEX_030200"."WWV_FLOW_TEMP_TREES"             
   (	"SEQ" NUMBER,                                                              
	"LEV" NUMBER,                                                                  
	"ID" VARCHAR2(4000),                                                           
	"PID" VARCHAR2(4000),                                                          
	"KIDS" NUMBER,                                                                 
	"EXPAND" VARCHAR2(1) DEFAULT 'Y',                                              
	"INDENT" VARCHAR2(4000) DEFAULT null,                                          
	"NAME" VARCHAR2(4000),                                                         
	"LINK" VARCHAR2(4000) DEFAULT null,                                            
	"A1" VARCHAR2(4000) DEFAULT null,                                              
	"A2" VARCHAR2(4000) DEFAULT null                                               
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "GSMADMIN_INTERNAL"."CHUNKDATA_TMP"             
   (	"DATAFILE_NAME" VARCHAR2(512)                                              
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_CS_CONTEXT_INFORMATION"            
   (	"FROM_SRID" NUMBER,                                                        
	"TO_SRID" NUMBER,                                                              
	"CONTEXT" RAW(4)                                                               
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GEOR_DDL__TABLE$$"                 
   (	"ID" NUMBER                                                                
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_MOSAIC_0"                       
   (	"RID" ROWID,                                                               
	"RDT" VARCHAR2(270),                                                           
	"RSTID" NUMBER,                                                                
	"RSTYPE" NUMBER,                                                               
	"SRID" NUMBER,                                                                 
	"RCTIF" VARCHAR2(10),                                                          
	"R0" NUMBER,                                                                   
	"C0" NUMBER,                                                                   
	"B0" NUMBER,                                                                   
	"R1" NUMBER,                                                                   
	"C1" NUMBER,                                                                   
	"B1" NUMBER,                                                                   
	"BANDS" NUMBER,                                                                
	"BCV" NUMBER,                                                                  
	"ILV" VARCHAR2(5),                                                             
	"RBLKSZ" NUMBER,                                                               
	"CBLKSZ" NUMBER,                                                               
	"BBLKSZ" NUMBER,                                                               
	"CDL" NUMBER,                                                                  
	"CDP" VARCHAR2(50),                                                            
	"ULTR" NUMBER,                                                                 
	"ULTC" NUMBER,                                                                 
	"ULTB" NUMBER,                                                                 
	"RROWS" NUMBER,                                                                
	"COLS" NUMBER,                                                                 
	"CPTYPE" VARCHAR2(10),                                                         
	"ID" NUMBER,                                                                   
	"OP" NUMBER,                                                                   
	"NODATA_IND" NUMBER,                                                           
	"DIST" NUMBER,                                                                 
	"EXTENT" "MDSYS"."SDO_GEOMETRY" ,                                              
	"META" "XMLTYPE",                                                              
	 PRIMARY KEY ("ID") ENABLE                                                     
   ) ON COMMIT PRESERVE ROWS                                                    
 XMLTYPE COLUMN "META" STORE AS BASICFILE BINARY XML (                          
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION                                    
  NOCACHE ) ALLOW NONSCHEMA DISALLOW ANYSCHEMA ;                                
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_MOSAIC_1"                       
   (	"RID" ROWID,                                                               
	"ULTR" NUMBER,                                                                 
	"ULTC" NUMBER,                                                                 
	"RSIZE" NUMBER,                                                                
	"CSIZE" NUMBER,                                                                
	"R0" NUMBER,                                                                   
	"R1" NUMBER,                                                                   
	"C0" NUMBER,                                                                   
	"C1" NUMBER,                                                                   
	"B0" NUMBER,                                                                   
	"B1" NUMBER                                                                    
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_MOSAIC_2"                       
   (	"RID" ROWID,                                                               
	"ULTR" NUMBER,                                                                 
	"ULTC" NUMBER,                                                                 
	"RSIZE" NUMBER,                                                                
	"CSIZE" NUMBER,                                                                
	"R0" NUMBER,                                                                   
	"R1" NUMBER,                                                                   
	"C0" NUMBER,                                                                   
	"C1" NUMBER,                                                                   
	"B0" NUMBER,                                                                   
	"B1" NUMBER                                                                    
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_MOSAIC_3"                       
   (	"P" NUMBER                                                                 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_MOSAIC_CB"                      
   (	"ID" NUMBER,                                                               
	"ROWNO" NUMBER,                                                                
	"COLNO" NUMBER,                                                                
	"BAND" NUMBER,                                                                 
	"VAL1" NUMBER,                                                                 
	"VAL2" NUMBER                                                                  
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_PARALLEL"                       
   (	"PID" NUMBER                                                               
   ) ON COMMIT PRESERVE ROWS                                                    
  PARALLEL ;                                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_GR_RDT_1"                          
   (	"RASTERDATATABLE" VARCHAR2(128),                                           
	"RASTERID" NUMBER,                                                             
	"PYRAMIDLEVEL" NUMBER,                                                         
	"BANDBLOCKNUMBER" NUMBER,                                                      
	"ROWBLOCKNUMBER" NUMBER,                                                       
	"COLUMNBLOCKNUMBER" NUMBER,                                                    
	"BLOCKMBR" "MDSYS"."SDO_GEOMETRY" ,                                            
	"RASTERBLOCK" BLOB,                                                            
	 CONSTRAINT "SDO_GR_RDT_1_PK" PRIMARY KEY ("RASTERDATATABLE", "RASTERID", "PYRA
MIDLEVEL", "BANDBLOCKNUMBER", "ROWBLOCKNUMBER", "COLUMNBLOCKNUMBER") ENABLE     
   ) ON COMMIT DELETE ROWS                                                      
 LOB ("RASTERBLOCK") STORE AS BASICFILE (                                       
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION                                    
  NOCACHE )                                                                     
  PARALLEL ;                                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_ST_TOLERANCE"                      
   (	"TOLERANCE" NUMBER                                                         
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TOPO_DATA$"                        
   (	"TOPOLOGY" VARCHAR2(20),                                                   
	"TG_LAYER_ID" NUMBER,                                                          
	"TG_ID" NUMBER,                                                                
	"TOPO_ID" NUMBER,                                                              
	"TOPO_TYPE" NUMBER                                                             
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TOPO_MAPS"                         
   (	"TOPOLOGY_ID" VARCHAR2(20)                                                 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TOPO_RELATION_DATA"                
   (	"TG_LAYER_ID" NUMBER,                                                      
	"TG_ID" NUMBER,                                                                
	"TOPO_ID" NUMBER,                                                              
	"TOPO_TYPE" NUMBER,                                                            
	"TOPO_ATTRIBUTE" VARCHAR2(100)                                                 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TOPO_TRANSACT_DATA"                
   (	"TOPO_SEQUENCE" NUMBER,                                                    
	"TOPOLOGY_ID" VARCHAR2(20),                                                    
	"TOPO_ID" NUMBER,                                                              
	"TOPO_TYPE" NUMBER,                                                            
	"TOPO_OP" VARCHAR2(3),                                                         
	"PARENT_ID" NUMBER                                                             
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TTS_METADATA_TABLE"                
   (	"SDO_INDEX_OWNER" VARCHAR2(130),                                           
	"SDO_INDEX_TYPE" VARCHAR2(32),                                                 
	"SDO_LEVEL" NUMBER,                                                            
	"SDO_NUMTILES" NUMBER,                                                         
	"SDO_MAXLEVEL" NUMBER,                                                         
	"SDO_COMMIT_INTERVAL" NUMBER,                                                  
	"SDO_INDEX_TABLE" VARCHAR2(130),                                               
	"SDO_INDEX_NAME" VARCHAR2(130),                                                
	"SDO_INDEX_PRIMARY" NUMBER,                                                    
	"SDO_TSNAME" VARCHAR2(130),                                                    
	"SDO_COLUMN_NAME" VARCHAR2(2048),                                              
	"SDO_RTREE_HEIGHT" NUMBER,                                                     
	"SDO_RTREE_NUM_NODES" NUMBER,                                                  
	"SDO_RTREE_DIMENSIONALITY" NUMBER,                                             
	"SDO_RTREE_FANOUT" NUMBER,                                                     
	"SDO_RTREE_ROOT" VARCHAR2(32),                                                 
	"SDO_RTREE_SEQ_NAME" VARCHAR2(130),                                            
	"SDO_FIXED_META" RAW(255),                                                     
	"SDO_TABLESPACE" VARCHAR2(130),                                                
	"SDO_INITIAL_EXTENT" VARCHAR2(32),                                             
	"SDO_NEXT_EXTENT" VARCHAR2(32),                                                
	"SDO_PCTINCREASE" NUMBER,                                                      
	"SDO_MIN_EXTENTS" NUMBER,                                                      
	"SDO_MAX_EXTENTS" NUMBER,                                                      
	"SDO_INDEX_DIMS" NUMBER,                                                       
	"SDO_LAYER_GTYPE" VARCHAR2(32),                                                
	"SDO_RTREE_PCTFREE" NUMBER,                                                    
	"SDO_INDEX_PARTITION" VARCHAR2(130),                                           
	"SDO_PARTITIONED" NUMBER,                                                      
	"SDO_RTREE_QUALITY" NUMBER,                                                    
	"SDO_INDEX_VERSION" NUMBER,                                                    
	"SDO_INDEX_GEODETIC" VARCHAR2(8),                                              
	"SDO_INDEX_STATUS" VARCHAR2(32),                                               
	"SDO_NL_INDEX_TABLE" VARCHAR2(131),                                            
	"SDO_DML_BATCH_SIZE" NUMBER,                                                   
	"SDO_RTREE_ENT_XPND" NUMBER,                                                   
	"SDO_NUM_ROWS" NUMBER,                                                         
	"SDO_NUM_BLKS" NUMBER,                                                         
	"SDO_ROOT_MBR" "MDSYS"."SDO_GEOMETRY" ,                                        
	"SDO_TABLE_NAME" VARCHAR2(130),                                                
	"SDO_OPTIMIZED_NODES" NUMBER,                                                  
	"SDO_RTREE_READ_ONLY" NUMBER                                                   
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TXN_IDX_EXP_UPD_RGN"               
   (	"SDO_TXN_IDX_ID" VARCHAR2(32),                                             
	"RID" VARCHAR2(24),                                                            
	"START_1" NUMBER,                                                              
	"END_1" NUMBER,                                                                
	"START_2" NUMBER,                                                              
	"END_2" NUMBER,                                                                
	"START_3" NUMBER,                                                              
	"END_3" NUMBER,                                                                
	"START_4" NUMBER,                                                              
	"END_4" NUMBER,                                                                
	 PRIMARY KEY ("SDO_TXN_IDX_ID", "RID") ENABLE                                  
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_TXN_JOURNAL_GTT"                   
   (	"SID" NUMBER NOT NULL ENABLE,                                              
	"SDO_TXN_IDX_ID" VARCHAR2(130) NOT NULL ENABLE,                                
	"OPERATION" NUMBER NOT NULL ENABLE,                                            
	"RID" VARCHAR2(24) NOT NULL ENABLE,                                            
	"INDEXPTNIDEN" NUMBER NOT NULL ENABLE,                                         
	"TABLEPTNIDEN" NUMBER NOT NULL ENABLE,                                         
	"START_1" BINARY_DOUBLE,                                                       
	"END_1" BINARY_DOUBLE,                                                         
	"START_2" BINARY_DOUBLE,                                                       
	"END_2" BINARY_DOUBLE,                                                         
	"START_3" BINARY_DOUBLE,                                                       
	"END_3" BINARY_DOUBLE,                                                         
	"START_4" BINARY_DOUBLE,                                                       
	"END_4" BINARY_DOUBLE,                                                         
	 PRIMARY KEY ("SID", "SDO_TXN_IDX_ID", "INDEXPTNIDEN", "OPERATION", "RID") ENAB
LE                                                                              
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "MDSYS"."SDO_WFS_LOCAL_TXNS"                    
   (	"SESSIONID" VARCHAR2(128)                                                  
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_ANON_ATTRS_TMP"               
   (	"AAID" NUMBER(*,0) NOT NULL ENABLE,                                        
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                          
	"TAG" VARCHAR2(1999) NOT NULL ENABLE,                                          
	"ANON_ACTION_TYPE_ID" NUMBER NOT NULL ENABLE,                                  
	"ANON_VALUE" VARCHAR2(128 CHAR),                                               
	"TAG_DESC" VARCHAR2(1999 CHAR)                                                 
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_ANON_RULES_TMP"               
   (	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                      
	"RULE_TYPE_ID" NUMBER NOT NULL ENABLE,                                         
	"ANON_ACTION_TYPE_ID" NUMBER NOT NULL ENABLE,                                  
	"ANON_VALUE" VARCHAR2(128 CHAR)                                                
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_ACTION_TMP"                
   (	"PID" NUMBER(*,0),                                                         
	"EVENT" VARCHAR2(20 CHAR),                                                     
	"ACTION" VARCHAR2(20 CHAR),                                                    
	"DESCRIPTION" VARCHAR2(1999 CHAR)                                              
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_DAREFS_TMP"                
   (	"DA_ID" NUMBER(*,0) NOT NULL ENABLE,                                       
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE                                           
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_LOCATORPATHS_TMP"          
   (	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                      
	"PSID" NUMBER(*,0) NOT NULL ENABLE,                                            
	"LOCATOR_PATH" VARCHAR2(1999 CHAR) NOT NULL ENABLE,                            
	"HAS_MACRO_PARAM" NUMBER(1,0) NOT NULL ENABLE,                                 
	"IS_COVERED" NUMBER(1,0)                                                       
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_PRED_OPRD_TMP"             
   (	"PID" NUMBER(*,0),                                                         
	"POS" NUMBER(3,0),                                                             
	"OPERAND" "SYS"."XMLTYPE"                                                      
   ) ON COMMIT PRESERVE ROWS                                                    
 XMLTYPE COLUMN "OPERAND" STORE AS BASICFILE BINARY XML (                       
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION                                    
  NOCACHE ) ALLOW NONSCHEMA DISALLOW ANYSCHEMA ;                                
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_PRED_PAR_TMP"              
   (	"PID" NUMBER(*,0),                                                         
	"PARNAME" VARCHAR2(128 CHAR),                                                  
	"PARVAL" VARCHAR2(1999 CHAR)                                                   
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_PRED_SET_TMP"              
   (	"PSID" NUMBER(*,0),                                                        
	"NAME" VARCHAR2(64 CHAR),                                                      
	"PSTYPE" NUMBER(1,0) NOT NULL ENABLE,                                          
	"PID" NUMBER(*,0),                                                             
	"STATUS" NUMBER(1,0),                                                          
	"SUPER" NUMBER(*,0),                                                           
	"DOC_ID" NUMBER(*,0),                                                          
	"DESCRIPTION" VARCHAR2(1999 CHAR),                                             
	 PRIMARY KEY ("PSID") ENABLE                                                   
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_CT_PRED_TMP"                  
   (	"PID" NUMBER(*,0),                                                         
	"FPID" NUMBER(*,0),                                                            
	"POS" NUMBER(3,0) NOT NULL ENABLE,                                             
	"REF_PID" NUMBER(*,0),                                                         
	"OP" NUMBER(3,0),                                                              
	"DESCRIPTION" VARCHAR2(1999 CHAR),                                             
	 PRIMARY KEY ("PID") ENABLE                                                    
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_DICT_ATTRS_TMP"               
   (	"DA_ID" NUMBER(*,0),                                                       
	"SA_ID" NUMBER(*,0),                                                           
	"PA_ID" NUMBER(*,0),                                                           
	 PRIMARY KEY ("DA_ID") ENABLE                                                  
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_DOCS_TMP"                     
   (	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                      
	"DOC_NAME" VARCHAR2(100 CHAR) NOT NULL ENABLE,                                 
	"DOC_TYPE_ID" NUMBER NOT NULL ENABLE,                                          
	"DOC_CONTENT" "SYS"."XMLTYPE"  NOT NULL ENABLE,                                
	"ORACLE_INSTALL" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                        
	"CREATE_DATE" DATE DEFAULT SYSDATE NOT NULL ENABLE                             
   ) ON COMMIT PRESERVE ROWS                                                    
 XMLTYPE COLUMN "DOC_CONTENT" STORE AS BASICFILE BINARY XML (                   
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION                                    
  NOCACHE ) ALLOW NONSCHEMA DISALLOW ANYSCHEMA ;                                
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_DOC_REFS_TMP"                 
   (	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                      
	"REF_BY_DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                   
	"DOC_NAME" VARCHAR2(100) NOT NULL ENABLE,                                      
	"REF_BY_DOC_NAME" VARCHAR2(100) NOT NULL ENABLE                                
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_MAPPED_PATHS_TMP"             
   (	"MPID" NUMBER(*,0) NOT NULL ENABLE,                                        
	"ATTR_TAG" VARCHAR2(1999) NOT NULL ENABLE,                                     
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                          
	"REL_PATH" VARCHAR2(1999 CHAR) NOT NULL ENABLE,                                
	"OCCURS" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                                
	"NOT_EMPTY" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                             
	"WRITE_TAG" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                             
	"WRITE_DEFINER" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                         
	"WRITE_NAME" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                            
	"WRITE_RAW_VALUE" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE                        
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_MAPPING_DOCS_TMP"             
   (	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                      
	"ROOT_TAG" VARCHAR2(128 CHAR) NOT NULL ENABLE,                                 
	"METADATA_NS" VARCHAR2(700 CHAR),                                              
	"MAPPED_ELEM" VARCHAR2(128 CHAR),                                              
	"UNMAPPED_ELEM" VARCHAR2(128 CHAR),                                            
	"XSLT" "SYS"."XMLTYPE" ,                                                       
	"IS_COVERED" NUMBER(1,0) NOT NULL ENABLE                                       
   ) ON COMMIT PRESERVE ROWS                                                    
 XMLTYPE COLUMN "XSLT" STORE AS BASICFILE BINARY XML (                          
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION                                    
  NOCACHE ) ALLOW NONSCHEMA DISALLOW ANYSCHEMA ;                                
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_PRV_ATTRS_TMP"                
   (	"PA_ID" NUMBER(*,0) NOT NULL ENABLE,                                       
	"TAG" VARCHAR2(8),                                                             
	"DEFINER_NAME" VARCHAR2(64 CHAR) NOT NULL ENABLE,                              
	"NAME" VARCHAR2(128 CHAR) NOT NULL ENABLE,                                     
	"START_TAG" VARCHAR2(8 CHAR),                                                  
	"END_TAG" VARCHAR2(8 CHAR),                                                    
	"DEFINER_UID" VARCHAR2(128),                                                   
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                          
	"VR" VARCHAR2(5),                                                              
	"VM" VARCHAR2(128),                                                            
	"ISRETIRED" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                             
	"ISWILDCARD" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE                             
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_RT_PREF_PARAMS_TMP"           
   (	"PPID" NUMBER(*,0) NOT NULL ENABLE,                                        
	"NAME" VARCHAR2(64) NOT NULL ENABLE,                                           
	"VALUE" VARCHAR2(1999 CHAR) NOT NULL ENABLE,                                   
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                          
	"PARAM_DESC" VARCHAR2(1999 CHAR)                                               
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_STD_ATTRS_TMP"                
   (	"SA_ID" NUMBER(*,0) NOT NULL ENABLE,                                       
	"TAG" VARCHAR2(8) NOT NULL ENABLE,                                             
	"NAME" VARCHAR2(128 CHAR) NOT NULL ENABLE,                                     
	"VR" VARCHAR2(5),                                                              
	"VM" VARCHAR2(128),                                                            
	"ISRETIRED" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                             
	"ISWILDCARD" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                            
	"DEFINER_NAME" VARCHAR2(5) DEFAULT 'DICOM' NOT NULL ENABLE,                    
	"DEFINER_UID" VARCHAR2(128) DEFAULT '1.2.840.10008.1' NOT NULL ENABLE,         
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE                                           
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_STORED_TAGS_TMP"              
   (	"STID" NUMBER(*,0) NOT NULL ENABLE,                                        
	"ATTR_TAG" VARCHAR2(1999) NOT NULL ENABLE,                                     
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE                                           
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "ORDDATA"."ORDDCM_UID_DEFS_TMP"                 
   (	"UDID" NUMBER(*,0),                                                        
	"DICOM_UID" VARCHAR2(128) NOT NULL ENABLE,                                     
	"DOC_ID" NUMBER(*,0) NOT NULL ENABLE,                                          
	"NAME" VARCHAR2(128 CHAR) NOT NULL ENABLE,                                     
	"CLASSIFICATION" VARCHAR2(64) NOT NULL ENABLE,                                 
	"ISLE" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE,                                  
	"ISEVR" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE,                                 
	"ISCOMPRESSED" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE,                          
	"ISRETIRED" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE,                             
	"CONTENTTYPE" VARCHAR2(64) DEFAULT 'IMAGE' NOT NULL ENABLE,                    
	"UID_DESC" VARCHAR2(1999 CHAR)                                                 
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "OWS"."SY_MON_CALL"                             
   (	"OPER_OBJECT_TYPE" VARCHAR2(1 CHAR),                                       
	"OPER_TYPE" VARCHAR2(1 CHAR),                                                  
	"AGENT_ID" NUMBER(18,0),                                                       
	"OBJECT_PATH" VARCHAR2(255 CHAR),                                              
	"OBJECT_TYPE" VARCHAR2(32 CHAR),                                               
	"MSG_CAT" VARCHAR2(1 CHAR),                                                    
	"MSG_CODE" VARCHAR2(255 CHAR),                                                 
	"MSG_STREAM_HINT_NAME" VARCHAR2(32 CHAR),                                      
	"STREAM_NAME" VARCHAR2(255 CHAR),                                              
	"STREAM_TYPE" VARCHAR2(32 CHAR),                                               
	"MSG_IMPORTANCE" VARCHAR2(1 CHAR),                                             
	"MSG_DEST" VARCHAR2(32 CHAR),                                                  
	"MSG_TEXT" VARCHAR2(3900 CHAR),                                                
	"METRIC_NAME" VARCHAR2(255 CHAR),                                              
	"METRIC_TYPE" VARCHAR2(32 CHAR),                                               
	"METRIC_MEASURE_UNIT" VARCHAR2(32 CHAR),                                       
	"START_UTC_TIME" TIMESTAMP (3),                                                
	"DURATION_MS" NUMBER(9,0) DEFAULT 0,                                           
	"METRIC_DEST" VARCHAR2(32 CHAR),                                               
	"EXPIRE_PERIOD_SECONDS" NUMBER(9,0) DEFAULT 0,                                 
	"NUM_METRIC_VALUE" NUMBER(28,10),                                              
	"STR_METRIC_VALUE" VARCHAR2(255 CHAR),                                         
	"GROUP_NAME" VARCHAR2(255 CHAR),                                               
	"STATUS_NAME" VARCHAR2(255 CHAR),                                              
	"STATUS_TYPE" VARCHAR2(32 CHAR),                                               
	"STORE_PREV_VALUE" VARCHAR2(1 CHAR),                                           
	"STATUS_DATA_VALUE" VARCHAR2(32 CHAR),                                         
	"STATUS_DISPLAY_VALUE" VARCHAR2(255 CHAR),                                     
	"AGENT_NAME" VARCHAR2(255 CHAR),                                               
	"AGENT_ADDRESS" VARCHAR2(255 CHAR),                                            
	"PARAMETER_NAME" VARCHAR2(255 CHAR),                                           
	"PARAMETER_VALUE" VARCHAR2(255 CHAR),                                          
	"PARAMETER_MEASURE_UNIT" VARCHAR2(32 CHAR),                                    
	"PARAMETER_CAT" VARCHAR2(1 CHAR),                                              
	"ADD_DATA" VARCHAR2(3900 CHAR),                                                
	"TABLE_CODE" VARCHAR2(32 CHAR),                                                
	"TABLE_REC_ID" NUMBER(18,0)                                                    
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "OWS"."TEMP_COLLECTION"                         
   (	"SCOPE" VARCHAR2(255 CHAR),                                                
	"MARKED_ID" NUMBER(18,0) NOT NULL ENABLE,                                      
	"ADD_INFO" VARCHAR2(3900 CHAR)                                                 
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "OWS"."TEMP_CONTRACT_DATA"                      
   (	"CONTRACT" NUMBER(18,0),                                                   
	"MARKED_ID" NUMBER(18,0) NOT NULL ENABLE,                                      
	"DOC_ID" NUMBER(18,0),                                                         
	"INVOICE_ID" NUMBER(18,0),                                                     
	"TRANS_CONTRACT_ID" NUMBER(18,0),                                              
	"CURRENCY" VARCHAR2(3 CHAR),                                                   
	"MTR_ID" NUMBER(18,0),                                                         
	"DATA_TYPE" VARCHAR2(1 CHAR),                                                  
	"ADD_INFO" VARCHAR2(3900 CHAR),                                                
	"CODE_1" VARCHAR2(32 CHAR),                                                    
	"CODE_2" VARCHAR2(32 CHAR),                                                    
	"CODE_3" VARCHAR2(32 CHAR),                                                    
	"CODE_4" VARCHAR2(32 CHAR),                                                    
	"CODE_5" VARCHAR2(32 CHAR),                                                    
	"CODE_6" VARCHAR2(32 CHAR),                                                    
	"TAG_1" VARCHAR2(1 CHAR),                                                      
	"TAG_2" VARCHAR2(1 CHAR),                                                      
	"TAG_3" VARCHAR2(1 CHAR),                                                      
	"TAG_4" VARCHAR2(1 CHAR),                                                      
	"TAG_5" VARCHAR2(1 CHAR),                                                      
	"TAG_6" VARCHAR2(1 CHAR),                                                      
	"STRING_1" VARCHAR2(255 CHAR),                                                 
	"STRING_2" VARCHAR2(255 CHAR),                                                 
	"STRING_3" VARCHAR2(255 CHAR),                                                 
	"STRING_4" VARCHAR2(255 CHAR),                                                 
	"STRING_5" VARCHAR2(255 CHAR),                                                 
	"STRING_6" VARCHAR2(255 CHAR),                                                 
	"ID_1" NUMBER(18,0),                                                           
	"ID_2" NUMBER(18,0),                                                           
	"ID_3" NUMBER(18,0),                                                           
	"ID_4" NUMBER(18,0),                                                           
	"ID_5" NUMBER(18,0),                                                           
	"ID_6" NUMBER(18,0),                                                           
	"NUMBER_1" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_2" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_3" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_4" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_5" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_6" NUMBER(9,0) DEFAULT 0,                                              
	"AMOUNT_1" NUMBER(28,10),                                                      
	"AMOUNT_2" NUMBER(28,10),                                                      
	"AMOUNT_3" NUMBER(28,10),                                                      
	"AMOUNT_4" NUMBER(28,10),                                                      
	"AMOUNT_5" NUMBER(28,10),                                                      
	"AMOUNT_6" NUMBER(28,10),                                                      
	"DATE_1" DATE,                                                                 
	"DATE_2" DATE,                                                                 
	"DATE_3" DATE,                                                                 
	"DATE_4" DATE,                                                                 
	"DATE_5" DATE,                                                                 
	"DATE_6" DATE,                                                                 
	"MEMO_1" VARCHAR2(3900 CHAR),                                                  
	"MEMO_2" VARCHAR2(3900 CHAR),                                                  
	"MEMO_3" VARCHAR2(3900 CHAR),                                                  
	"MEMO_4" VARCHAR2(3900 CHAR),                                                  
	"MEMO_5" VARCHAR2(3900 CHAR),                                                  
	"MEMO_6" VARCHAR2(3900 CHAR),                                                  
	"MEMO_7" VARCHAR2(3900 CHAR),                                                  
	"MEMO_8" VARCHAR2(3900 CHAR),                                                  
	"MEMO_9" VARCHAR2(3900 CHAR),                                                  
	"MEMO_10" VARCHAR2(3900 CHAR),                                                 
	"CODE_7" VARCHAR2(32 CHAR),                                                    
	"CODE_8" VARCHAR2(32 CHAR),                                                    
	"CODE_9" VARCHAR2(32 CHAR),                                                    
	"CODE_10" VARCHAR2(32 CHAR),                                                   
	"TAG_7" VARCHAR2(1 CHAR),                                                      
	"TAG_8" VARCHAR2(1 CHAR),                                                      
	"TAG_9" VARCHAR2(1 CHAR),                                                      
	"TAG_10" VARCHAR2(1 CHAR),                                                     
	"STRING_7" VARCHAR2(255 CHAR),                                                 
	"STRING_8" VARCHAR2(255 CHAR),                                                 
	"STRING_9" VARCHAR2(255 CHAR),                                                 
	"STRING_10" VARCHAR2(255 CHAR),                                                
	"DATE_7" DATE,                                                                 
	"DATE_8" DATE,                                                                 
	"DATE_9" DATE,                                                                 
	"DATE_10" DATE,                                                                
	"AMOUNT_7" NUMBER(28,10),                                                      
	"AMOUNT_8" NUMBER(28,10),                                                      
	"AMOUNT_9" NUMBER(28,10),                                                      
	"AMOUNT_10" NUMBER(28,10),                                                     
	"NUMBER_7" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_8" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_9" NUMBER(9,0) DEFAULT 0,                                              
	"NUMBER_10" NUMBER(9,0) DEFAULT 0,                                             
	"ID_7" NUMBER(18,0),                                                           
	"ID_8" NUMBER(18,0),                                                           
	"ID_9" NUMBER(18,0),                                                           
	"ID_10" NUMBER(18,0)                                                           
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "OWS"."TEMP_STORNO_CORRECTION"                  
   (	"CONTRACT" NUMBER(18,0),                                                   
	"CYCLE_START_DATE" DATE,                                                       
	"CYCLE_END_DATE" DATE,                                                         
	"CORRECTION_TYPE" VARCHAR2(1 CHAR),                                            
	"SERVICE_CLASS" VARCHAR2(1 CHAR),                                              
	"AMOUNT_BEFORE" NUMBER(28,10) DEFAULT 0 NOT NULL ENABLE,                       
	"AMOUNT_AFTER" NUMBER(28,10) DEFAULT 0 NOT NULL ENABLE,                        
	"POSTING_DATE" DATE,                                                           
	"GL_DATE" DATE,                                                                
	"REASON" VARCHAR2(255 CHAR)                                                    
   ) ON COMMIT DELETE ROWS ;                                                    
                                                                                
                                                                                
  CREATE GLOBAL TEMPORARY TABLE "WMSYS"."WM$MW_TABLE$"                          
   (	"WORKSPACE#" NUMBER(*,0) NOT NULL ENABLE                                   
   ) ON COMMIT PRESERVE ROWS ;                                                  
                                                                                
CREATE INDEX "OWS"."TEMP_COLLECTION_ID" ON "OWS"."TEMP_COLLECTION" ("SCOPE", "MARKED_ID");
CREATE INDEX "OWS"."TEMP_CONTR_DAT" ON "OWS"."TEMP_CONTRACT_DATA" ("CONTRACT","MARKED_ID", "DOC_ID", "CURRENCY");
