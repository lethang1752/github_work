REM
REM Script to compare segment, object, and invalid object counts
REM between two databases. This script should be run on the target
REM database.
REM
REM This script requires a dba_objects from source database
REM
SET HEADING OFF FEEDBACK OFF TRIMSPOOL ON LINESIZE 500
SPOOL tts_verify.out
PROMPT

  SELECT r.owner,
         r.segment_type,
         r.remote_cnt Source_Cnt,
         l.local_cnt Target_Cnt
    FROM (  SELECT owner, segment_type, COUNT (owner) remote_cnt
              FROM SCOTT.mig_dba_segments
             WHERE owner NOT IN (SELECT name
                                   FROM SYSTEM.logstdby$skip_support
                                  WHERE action = 0)
          GROUP BY owner, segment_type) r,
         (  SELECT owner, segment_type, COUNT (owner) local_cnt
              FROM dba_segments
             WHERE owner NOT IN (SELECT name
                                   FROM SYSTEM.logstdby$skip_support
                                  WHERE action = 0)
          GROUP BY owner, segment_type) l
   WHERE     l.owner(+) = r.owner
         AND l.segment_type(+) = r.segment_type
         AND NVL (l.local_cnt, -1) != r.remote_cnt
ORDER BY 1, 3 DESC
/

PROMPT
PROMPT Object count comparison across dblink
PROMPT

  SELECT r.owner,
         r.object_type,
         r.remote_cnt Source_Cnt,
         l.local_cnt Target_Cnt
    FROM (  SELECT owner, object_type, COUNT (owner) remote_cnt
              FROM SCOTT.mig_dba_objects
             WHERE owner NOT IN (SELECT name
                                   FROM SYSTEM.logstdby$skip_support
                                  WHERE action = 0)
          GROUP BY owner, object_type) r,
         (  SELECT owner, object_type, COUNT (owner) local_cnt
              FROM dba_objects
             WHERE owner NOT IN (SELECT name
                                   FROM SYSTEM.logstdby$skip_support
                                  WHERE action = 0)
          GROUP BY owner, object_type) l
   WHERE     l.owner(+) = r.owner
         AND l.object_type(+) = r.object_type
         AND NVL (l.local_cnt, -1) != r.remote_cnt
ORDER BY 1, 3 DESC
/

PROMPT
PROMPT Invalid object count comparison across dblink
PROMPT

  SELECT l.owner,
         l.object_type,
         r.remote_cnt Source_Cnt,
         l.local_cnt Target_Cnt
    FROM (  SELECT owner, object_type, COUNT (owner) remote_cnt
              FROM SCOTT.mig_dba_objects
             WHERE     owner NOT IN (SELECT name
                                       FROM SYSTEM.logstdby$skip_support
                                      WHERE action = 0)
                   AND status = 'INVALID'
          GROUP BY owner, object_type) r,
         (  SELECT owner, object_type, COUNT (owner) local_cnt
              FROM dba_objects
             WHERE     owner NOT IN (SELECT name
                                       FROM SYSTEM.logstdby$skip_support
                                      WHERE action = 0)
                   AND status = 'INVALID'
          GROUP BY owner, object_type) l
   WHERE     l.owner = r.owner(+)
         AND l.object_type = r.object_type(+)
         AND l.local_cnt != NVL (r.remote_cnt, -1)
ORDER BY 1, 3 DESC
/

SPOOL OFF
