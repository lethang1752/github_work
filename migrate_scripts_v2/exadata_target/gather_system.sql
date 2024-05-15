BEGIN
     DBMS_STATS.GATHER_SYSTEM_STATS('start');
	 DBMS_STATS.gather_dictionary_stats;
	 dbms_stats.gather_fixed_objects_stats();
	 dbms_stats.gather_system_stats('EXADATA');
END;
/
