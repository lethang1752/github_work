begin
dbms_stats.gather_database_stats(cascade => TRUE, -
degree => 16,
method_opt => 'FOR ALL COLUMNS SIZE AUTO' );
end;
/

