-- File Name : sql10.sql
-- Purpose : 显示sql优化信息
-- Date : 2015/09/05
-- 死磕72小时
-- bestpay修改版
-- 20160824 添加分区索引的状态，添加索引分区信息
-- 20160901 增加索引的压缩，分区，临时等属性(UCPTDVS)
-- 20161107 添加从ASH中获取执行计划步骤的统计信息，支持11GR2以上数据库
-- 20161115 添加AWR sql_stat的信息
-- 20161129 添加10GR2版本的支持
-- 20180426 修复部分对象不能统计大小
-- 20181221 改善sql历史执行情况统计
alter session set nls_date_format='yyyymmdd';
set serveroutput on size 1000000

SET VERIFY OFF
set linesize 200
set echo off
set pages 0
undefine sqlid;
select '&&sqlid' from dual;
define _VERSION_11  = "--"
define _VERSION_10  = "--"
col version11  noprint new_value _VERSION_11
col version10  noprint new_value _VERSION_10
select /*+ no_parallel */case
         when substr(banner,
                     instr(banner, 'Release ') + 8,
                     instr(substr(banner, instr(banner, 'Release ') + 8), ' ')) >=
              '10.2' and
              substr(banner,
                     instr(banner, 'Release ') + 8,
                     instr(substr(banner, instr(banner, 'Release ') + 8), ' ')) <
              '11.2' then
          '  '
         else
          '--'
       end  version10,
       case
         when substr(banner,
                     instr(banner, 'Release ') + 8,
                     instr(substr(banner, instr(banner, 'Release ') + 8), ' ')) >=
              '11.2' then
          '  '
         else
          '--'
       end  version11
  from v$version
 where banner like 'Oracle Database%';
-------------------------------------------------------------------------------------------------
col CPU_TIME                heading "CPU|TIME"           for 999999,999,999
col ELAPSED_TIME            heading "ELAPSED|TIME"       for 999999,999,999
col PARSE_CALLS             heading "PARSE|CALLS"        for 99999,999,999
col DISK_READS              heading "DISK|READS"         for 999999,999,999
col BUFFER_GETS             heading "BUFFER|GETS"        for 999999,999,999
col SORTS                   heading "SORTS"              for 999999,999,999
col ROWS_PROCESSED          heading "ROWS|PROCESSED"     for 999999,999,999
COL INSTANCE_NUMBER         heading "I"                  for a1
COL PARSING_SCHEMA_NAME     heading "NAME"               for a15
col FETCHES                 heading "FETCHES"            for 999999,999,999
col ROW_PROCESSES           heading "ROW_PROC"           for a5
col EXECUTIONS              heading "EXEC"               for a10
col CPU_PRE_EXEC            heading "CPU(MS)|PRE EXEC"       for 999999,999
col ELA_PRE_EXEC            heading "ELA(MS)|PRE EXEC"       for 999999,999
col DISK_PRE_EXEC           heading "DISK|PRE EXEC"      for 999,999
col GET_PRE_EXEC            heading "GET|PRE EXEC"       for 999,999,999
col ROWS_PRE_EXEC           heading "ROWS|PRE EXEC"      for 999,999,99
col ROWS_PRE_FETCHES        heading "ROWS|PRE FETCH"     for 99999,999
col c                       heading "CHI|NUM"            for 999
col USERNAME                heading "USER|NAME"          for a10
col PLAN_HASH_VALUE         heading "PLAN|HASH VALUE"    for 999999999999
col APP_WAIT_PRE            heading "APPLI(MS)|PER EXEC" for 999,999
col CON_WAIT_PER            heading "CONCUR(MS)|PER EXEC" for 999,999
col WRITE_PRE_EXEC          heading "WRITE|PER EXEC"     for  999,999
col CLU_WAIT_PER            heading "CLUSTER(MS)|PER EXEC" FOR 999,999
col USER_ID_WAIT_PER        heading "USER_IO(MS)|PER EXEC" FOR 999,999
COL PLSQL_WAIT_PER          heading "PLSQL|PER EXEC"     FOR 999,999
COL JAVA_WAIT_PER           heading "JAVA|PER EXEC"      FOR 999,999
COL F_L_TIME                heading 'FIRST_LOAD_TIME|LAST_LOAD_TIME'   FOR a22
COL SQL_PROFILE             heading 'SQL_PROFILE'        FOR a15
COL END_TIME                heading 'END_TIME'           FOR a6
-------------------------------------------------------------------------------------------------
col TABLE_NAME              heading "TABLE|NAME"         for a35
col SEGMENT_NAME            heading "SEGMENT|NAME"       for a35
col OWNER                   heading "OWNER"              for a15
col TABLESPACE_NAME         heading "TABLESPACE|NAME"    for a10
col LOGGING                 heading "LOG"                for a3
col BUFFER_POOL             heading "BUFFER|POOL"        for a7
col DEGREE                  heading "DEGREE"             for a6
col PARTITIONED             heading "PART"               for a4
col NUM_ROWS                heading "NUM|ROWS"           for 999999,999,999
col BLOCKS                  heading "BLOCKS"             for 999,999,999
col EMPTY_BLOCKS            heading "EMPTY|BLOCKS"       for 999,999,999
col AVG_SPACE               heading "AVG|SPACE"          for 999,999,999
col AVG_ROW_LEN             heading "AVG|ROW_LEN"        for 999,999,999
col AVG_ROW_LEN             heading "AVG|ROW_LEN"        for 999,999,999
col LAST_ANALYZED           heading "LAST|ANALYZED"
col STALE_STATS             heading "OLD|STATS"          FOR A5
col sample_size             heading 'SAMPLE_SIZE'        FOR 999,999,999
col block_size              heading 'BLOCK_SIZE(M)'      FOR 999,999
col avg_size                heading 'AVG_SIZE(M)'        FOR 999,999
-------------------------------------------------------------------------------------------------
col TABLE_OWNER             heading "TABLE|OWNER"        for a15
col INDEX_NAME              heading "Index|Name"         for a30
col UNIQUENESS              heading "UNIQUE"             for a9
col UCPTDVS                 heading "UCPTDVS"            for a7
col COLUMN_NAME             heading "COLUMN|NAME"        for a25
col COLUMN_POSITION         heading "COL|POS"            for 999
col DESCEND                 heading "DESC"               for a4
-------------------------------------------------------------------------------------------------
col CHILD_NUMBER            heading "CHILD|NUMBER"       for 999
col name                    heading "BIND|NAME"          for a10
col value_string            heading "VALUE|STRING"       for a60
col DATATYPE_STRING         heading "DATATYPE|STRING"    for a20
-------------------------------------------------------------------------------------------------
col program                 heading "PROGRAM"            for a30
col event                   heading "EVENT"              for a40
col total                   heading "TOTAL"              for 999,999
col wait_class              heading "WAIT|CLASS"         for a15
-------------------------------------------------------------------------------------------------
col DATA_TYPE               heading "DATA|TYPE"          for a15
col NULLABLE                heading "NL"                 for a2
col HISTOGRAM               heading "HIST"               for a5
col DENSITY                 heading "DENSITY"            for 999,999,999
col NUM_NULLS               heading "NUM|NULLS"          for 999,999,999
col NUM_BUCKETS             heading "NUM|BUCKETS"        for 999,999,999
col AVG_COL_LEN             heading "AVG|COL LEN"        for 999,999,999
-------------------------------------------------------------------------------------------------
col L_T                     heading "LOG|TEMP"           for a7
col STATUS                  heading "STATUS"             for a10
col INDEX_TYPE              heading "INDEX|TYPE"         for a8
col UNIQUENESS              heading "Unique"             for a9
col BLEV                    heading "B"                  for a1
col LEAF_BLOCKS             heading "Leaf|Blks"          for 99999,999
col DISTINCT_KEYS           heading "Distinct|Keys"      for 999,999,999
col AVG_LEAF_BLOCKS_PER_KEY heading "Average|Leaf Blocks|Per Key" for 99,999
col AVG_DATA_BLOCKS_PER_KEY heading "Average|Data Blocks|Per Key" for 99,999
col CLUSTERING_FACTOR       heading "Cluster|Factor"     for 999,999,999
col COLUMN_POSITION         heading "Col|Pos"            for 999
col degree                  heading "D"                  for a1
col index_local             heading "LOCAL|PRE"          for a6
-------------------------------------------------------------------------------------------------
col PLAN_HASH_VALUE for 9999999999;
col instance_number for 9;
col snap_id heading 'SnapId' format 999999;
col executions_delta heading "No. of exec";
col date_time heading 'Date time' for a20;
col avg_lio heading 'LIO/exec' for 9999999999999.99;
col avg_cputime_s heading 'CPUTIM/exec' for 99999.99;
col avg_etime_s heading 'ETIME/exec' for 999999.99;
col avg_pio heading 'PIO/exec' for 999999.99;
col avg_row heading 'ROWs/exec' for 999999999.99;
col sql_profile format a35;
-------------------------------------------------------------------------------------------------
set pages 10000 heading on
prompt
prompt ****************************************************************************************
prompt LITERAL SQL
prompt ****************************************************************************************

DECLARE
  LVC_SQL_TEXT      VARCHAR2(32000);
  LVC_ORIG_SQL_TEXT VARCHAR2(32000);
  LN_CHILD          NUMBER := 10000;
  LVC_BIND          VARCHAR2(200);
  LVC_NAME          VARCHAR2(30);
  CURSOR C1 IS
    SELECT CHILD_NUMBER, NAME, POSITION, DATATYPE_STRING, VALUE_STRING
      -- add
      ,sql_id
      -- add end
      FROM V$SQL_BIND_CAPTURE
     WHERE SQL_ID = '&&sqlid'
     ORDER BY CHILD_NUMBER, POSITION;
BEGIN
  SELECT SQL_FULLTEXT
    INTO LVC_ORIG_SQL_TEXT
    FROM V$SQL
   WHERE SQL_ID = '&&sqlid'
     AND ROWNUM = 1;
  FOR R1 IN C1 LOOP
    IF (R1.CHILD_NUMBER <> LN_CHILD) THEN
      IF LN_CHILD <> 10000 THEN
        DBMS_OUTPUT.PUT_LINE(LVC_NAME);
        DBMS_OUTPUT.PUT_LINE(LVC_SQL_TEXT);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------');
      END IF;
      LN_CHILD     := R1.CHILD_NUMBER;
      LVC_SQL_TEXT := LVC_ORIG_SQL_TEXT;
    END IF;

    -- add
    select parsing_schema_name into LVC_NAME from v$sql where sql_id=r1.sql_id and child_number=r1.CHILD_NUMBER;
    -- add end

    IF R1.NAME LIKE ':SYS_B_%' THEN
      LVC_BIND := ':"'||substr(R1.NAME,2)||'"';
    ELSE
      LVC_BIND := R1.NAME;
    END IF;


    IF r1.VALUE_STRING IS NOT NULL THEN
      IF R1.DATATYPE_STRING = 'NUMBER' THEN
        LVC_SQL_TEXT := REGEXP_REPLACE(LVC_SQL_TEXT, LVC_BIND, R1.VALUE_STRING,1,1,'i');
      ELSIF R1.DATATYPE_STRING LIKE 'VARCHAR%' THEN
        LVC_SQL_TEXT := REGEXP_REPLACE(LVC_SQL_TEXT, LVC_BIND, ''''||R1.VALUE_STRING||'''',1,1,'i');
      ELSE
        LVC_SQL_TEXT := REGEXP_REPLACE(LVC_SQL_TEXT, LVC_BIND, ''''||R1.VALUE_STRING||'''',1,1,'i');
      END IF;
    ELSE
       LVC_SQL_TEXT := REGEXP_REPLACE(LVC_SQL_TEXT, LVC_BIND, 'NULL',1,1,'i');
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(LVC_NAME);
  DBMS_OUTPUT.PUT_LINE(LVC_SQL_TEXT);
END;
/
-- ==========================================================================================
--set heading off
--spool tmp.sql
--SELECT 'select * from table(dbms_xplan.display_cursor(''&&sqlid'','||CHILD_NUMBER||'));' FROM (
--  SELECT CHILD_NUMBER,ROW_NUMBER() OVER(PARTITION BY PLAN_HASH_VALUE ORDER BY CHILD_NUMBER) rn
--  FROM V$SQL WHERE SQL_ID = '&&sqlid'
--) WHERE rn=1;
--spool off
--set heading on
-- ==========================================================================================
-- prompt
-- prompt ****************************************************************************************
-- prompt AWR
-- prompt ****************************************************************************************
-- select * from table(dbms_xplan.display_awr('&&sqlid',null,null,'advanced allstats last'));

prompt ****************************************************************************************
prompt CURSOR
prompt ****************************************************************************************
--select * from table(dbms_xplan.display_cursor('&&sqlid',0,'advanced allstats last'));
select t.*
  from v$sql s,
       table(dbms_xplan.display_cursor(s.sql_id, s.child_number)) t
 where s.sql_id = '&&sqlid';

prompt ****************************************************************************************
prompt PLAN STAT FROM ASH
prompt ****************************************************************************************
/* Formatted on 2016/11/7 11:36:33 (QP5 v5.256.13226.35510) */


 DECLARE
    i_plan_putout        VARCHAR2 (3000);
    i_plan_output_last   VARCHAR2 (3000) := ' ';
    i_ash_output         VARCHAR2 (3000);
    i_length             NUMBER;
    i_version            VARCHAR2 (20);
 BEGIN
    SELECT /*+ no_parallel */
          SUBSTR (
              banner,
              INSTR (banner, 'Release ') + 8,
              INSTR (SUBSTR (banner, INSTR (banner, 'Release ') + 8), ' '))
      INTO i_version
      FROM v$version
     WHERE banner LIKE 'Oracle Database%';
&_VERSION_11    IF i_version > '11.2'
&_VERSION_11    THEN
&_VERSION_11       FOR c_plan_output
&_VERSION_11          IN (WITH htz
&_VERSION_11                   AS (SELECT SQL_ID,
&_VERSION_11                              CHILD_NUMBER,
&_VERSION_11                              PLAN_HASH_VALUE,
&_VERSION_11                              '' FORMAT
&_VERSION_11                         FROM v$sql
&_VERSION_11                        WHERE sql_id = '&&sqlid'),
&_VERSION_11                   htz_pw
&_VERSION_11                   AS (SELECT t.*,
&_VERSION_11                              ROW_NUMBER ()
&_VERSION_11                              OVER (
&_VERSION_11                                 PARTITION BY sql_id,
&_VERSION_11                                              sql_child_number,
&_VERSION_11                                              sql_plan_line_id
&_VERSION_11                                 ORDER BY tcount DESC)
&_VERSION_11                                 event_order
&_VERSION_11                         FROM (  SELECT sql_id,
&_VERSION_11                                        sql_child_number,
&_VERSION_11                                        sql_plan_line_id,
&_VERSION_11                                        event,
&_VERSION_11                                        COUNT (*) tcount,
&_VERSION_11                                           ROUND (
&_VERSION_11                                                (ratio_to_report (COUNT (*))
&_VERSION_11                                                    OVER ())
&_VERSION_11                                              * 100,
&_VERSION_11                                              2)
&_VERSION_11                                        || '%'
&_VERSION_11                                           pct
&_VERSION_11                                   FROM (SELECT a.sql_id,
&_VERSION_11                                                a.sql_child_number,
&_VERSION_11                                                a.sql_plan_line_id,
&_VERSION_11                                                a.sql_plan_hash_value,
&_VERSION_11                                                DECODE (
&_VERSION_11                                                   a.SESSION_STATE,
&_VERSION_11                                                   'ON CPU', DECODE (
&_VERSION_11                                                                a.SESSION_TYPE,
&_VERSION_11                                                                'BACKGROUND', 'BCPU',
&_VERSION_11                                                                'CPU'),
&_VERSION_11                                                   EVENT)
&_VERSION_11                                                   EVENT
&_VERSION_11                                           FROM v$active_session_history a
&_VERSION_11                                          WHERE a.sql_id = '&&sqlid')
&_VERSION_11                               GROUP BY sql_id,
&_VERSION_11                                        sql_child_number,
&_VERSION_11                                        sql_plan_line_id,
&_VERSION_11                                        sql_plan_hash_value,
&_VERSION_11                                        event) t),
&_VERSION_11                   cdhtz
&_VERSION_11                   AS (SELECT sql_id,
&_VERSION_11                              child_number,
&_VERSION_11                              n,
&_VERSION_11                              plan_table_output -- get plan line id from plan_table output
&_VERSION_11                                               ,
&_VERSION_11                              CASE
&_VERSION_11                                 WHEN REGEXP_LIKE (
&_VERSION_11                                         plan_table_output,
&_VERSION_11                                         '^[|][*]? *([0-9]+) *[|].*[|]$')
&_VERSION_11                                 THEN
&_VERSION_11                                    REGEXP_REPLACE (
&_VERSION_11                                       plan_table_output,
&_VERSION_11                                       '^[|][*]? *([0-9]+) *[|].*[|]$',
&_VERSION_11                                       '\1')
&_VERSION_11                              END
&_VERSION_11                                 SQL_PLAN_LINE_ID
&_VERSION_11                         FROM (SELECT ROWNUM n,
&_VERSION_11                                      plan_table_output,
&_VERSION_11                                      SQL_ID,
&_VERSION_11                                      CHILD_NUMBER
&_VERSION_11                                 FROM htz,
&_VERSION_11                                      TABLE (
&_VERSION_11                                         DBMS_XPLAN.display_cursor (
&_VERSION_11                                            htz.SQL_ID,
&_VERSION_11                                            htz.CHILD_NUMBER,
&_VERSION_11                                            htz.FORMAT))))
&_VERSION_11                SELECT plan_table_output,
&_VERSION_11                       CASE
&_VERSION_11                          WHEN f.tcount > 0
&_VERSION_11                          THEN
&_VERSION_11                                SUBSTR (event, 1, 25)
&_VERSION_11                             || '('
&_VERSION_11                             || tcount
&_VERSION_11                             || ')('
&_VERSION_11                             || pct
&_VERSION_11                             || ')'
&_VERSION_11                       END
&_VERSION_11                          cast_info,
&_VERSION_11                       f.SQL_PLAN_LINE_ID
&_VERSION_11                  FROM cdhtz e, htz_pw f
&_VERSION_11                 WHERE     e.sql_id = f.sql_id(+)
&_VERSION_11                       AND e.child_number = f.sql_child_number(+)
&_VERSION_11                       AND e.sql_plan_line_id = f.sql_plan_line_id(+)
&_VERSION_11              ORDER BY e.sql_id, e.child_number, e.n)
&_VERSION_11       LOOP
&_VERSION_11          IF (c_plan_output.plan_table_output <> i_plan_output_last)
&_VERSION_11          THEN
&_VERSION_11             IF (c_plan_output.cast_info IS NOT NULL)
&_VERSION_11             THEN
&_VERSION_11                DBMS_OUTPUT.put_line (
&_VERSION_11                      c_plan_output.plan_table_output
&_VERSION_11                   || RPAD (c_plan_output.cast_info, 37)
&_VERSION_11                   || '|');
&_VERSION_11             ELSE
&_VERSION_11                DBMS_OUTPUT.put_line (c_plan_output.plan_table_output);
&_VERSION_11                i_plan_output_last := c_plan_output.plan_table_output;
&_VERSION_11             END IF;
&_VERSION_11
&_VERSION_11             i_plan_output_last := c_plan_output.plan_table_output;
&_VERSION_11          ELSE
&_VERSION_11             IF (c_plan_output.cast_info IS NOT NULL)
&_VERSION_11             THEN
&_VERSION_11                SELECT LENGTH (i_plan_output_last) INTO i_length FROM DUAL;
&_VERSION_11
&_VERSION_11                DBMS_OUTPUT.put_line (
&_VERSION_11                      '|'
&_VERSION_11                   || LPAD (' ', i_length - 2)
&_VERSION_11                   || '|'
&_VERSION_11                   || RPAD (c_plan_output.cast_info, 37)
&_VERSION_11                   || '|');
&_VERSION_11             ELSE
&_VERSION_11                DBMS_OUTPUT.put_line (c_plan_output.plan_table_output);
&_VERSION_11             END IF;
&_VERSION_11          END IF;
&_VERSION_11       END LOOP;
&_VERSION_11    END IF;
 END;
 /
prompt
prompt ****************************************************************************************
prompt SQL STATS
prompt ****************************************************************************************


PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | infromation  from v$sqlstats               |
PROMPT +------------------------------------------------------------------------+
PROMPT

SELECT trim(EXECUTIONS) EXECUTIONS,
       (CPU_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CPU_PRE_EXEC,
       (ELAPSED_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 ELA_PRE_EXEC,
       DISK_READS / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) DISK_PRE_EXEC,
       BUFFER_GETS / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) GET_PRE_EXEC,
       ROWS_PROCESSED / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) ROWS_PRE_EXEC,
       ROWS_PROCESSED / DECODE (FETCHES, 0, 1, FETCHES) ROWS_PRE_FETCHES,
       (APPLICATION_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 APP_WAIT_PRE,
       (CONCURRENCY_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CON_WAIT_PER,
       (CLUSTER_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CLU_WAIT_PER,
       (USER_IO_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 USER_ID_WAIT_PER,
       PLSQL_EXEC_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) PLSQL_WAIT_PER,
       JAVA_EXEC_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) JAVA_WAIT_PER,SQL_PROFILE
  FROM v$sqlarea
where sql_id = '&&sqlid';

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | information from v$sql                 |
PROMPT +------------------------------------------------------------------------+
PROMPT

SELECT trim(EXECUTIONS) EXECUTIONS,
       plan_hash_value,
       child_number c,
       PARSING_SCHEMA_NAME username,
       (CPU_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CPU_PRE_EXEC,
       (ELAPSED_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 ELA_PRE_EXEC,
       DISK_READS / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) DISK_PRE_EXEC,
       BUFFER_GETS / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) GET_PRE_EXEC,
       ROWS_PROCESSED / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) ROWS_PRE_EXEC,
       ROWS_PROCESSED / DECODE (FETCHES, 0, 1, FETCHES) ROWS_PRE_FETCHES,
       (APPLICATION_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 APP_WAIT_PRE,
       (CONCURRENCY_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CON_WAIT_PER,
       (CLUSTER_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 CLU_WAIT_PER,
       (USER_IO_WAIT_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS))/1000 USER_ID_WAIT_PER,
--       PLSQL_EXEC_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) PLSQL_WAIT_PER,
--       JAVA_EXEC_TIME / DECODE (EXECUTIONS, 0, 1, EXECUTIONS) JAVA_WAIT_PER,
       substr(FIRST_LOAD_TIME,6,10)||'.'||substr(LAST_LOAD_TIME,6,10) f_l_time
--       ,sql_profile
  from v$sql
 where sql_id = '&&sqlid'
 order by 3;
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | information from awr                                    |
PROMPT +------------------------------------------------------------------------+
PROMPT
/* Formatted on 20181221 by CQY */
SELECT distinct
s.snap_id ,
s.instance_number,
PLAN_HASH_VALUE,
to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
SQL.executions_delta,
SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio,
--SQL.ccwait_delta,
(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime_s ,
(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime_s,
SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_row,
SQL.sql_profile
FROM
dba_hist_sqlstat SQL,dba_hist_snapshot s
WHERE
SQL.dbid =(select dbid from v$database)
and s.snap_id = SQL.snap_id
and sql.instance_number = s.instance_number 
AND sql_id in ('&&sqlid')
order by s.snap_id;



prompt
prompt ****************************************************************************************
prompt SQL WAIT HIST
prompt ****************************************************************************************
break on program
SELECT substr(PROGRAM,1,30) PROGRAM,EVENT, SUM(CNT) TOTAL, WAIT_CLASS
  FROM (SELECT DECODE(SESSION_STATE,
                      'ON CPU',
                      DECODE(SESSION_TYPE, 'BACKGROUND', 'BCPU', 'CPU'),
                      EVENT) EVENT,
               REPLACE(TRANSLATE(DECODE(SESSION_STATE,
                                        'ON CPU',
                                        DECODE(SESSION_TYPE,
                                               'BACKGROUND',
                                               'BCPU',
                                               'CPU'),
                                        WAIT_CLASS),
                                 ' $',
                                 '____'),
                       '/') WAIT_CLASS,
               PROGRAM,
               1 CNT
          FROM V$ACTIVE_SESSION_HISTORY
         WHERE SQL_ID = '&&sqlid'
           AND SAMPLE_TIME >= SYSDATE - 4 / 24
           AND SAMPLE_TIME <= SYSDATE)
 GROUP BY EVENT, WAIT_CLASS, PROGRAM
 ORDER BY PROGRAM,TOTAL DESC;

prompt
prompt ****************************************************************************************
prompt OBJECT SIZE
prompt ****************************************************************************************
break on owner on segment_name
/* Formatted on 2016/3/10 10:06:06 (QP5 v5.256.13226.35510) */
--WITH t
--     AS (SELECT /*+ materialize */
--                DISTINCT OBJECT_OWNER, OBJECT_NAME
--           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
--                   FROM V$SQL_PLAN
--                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
--                 UNION ALL
--                 SELECT OBJECT_OWNER, OBJECT_NAME
--                   FROM DBA_HIST_SQL_PLAN
--                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL)),
--     tt
--     AS (SELECT /*+materialize  no_merge */
--                DISTINCT table_owner, table_name
--           FROM dba_indexes
--          WHERE (owner, index_name) IN (SELECT object_owner, object_name
--                                          FROM t)),
--     t_index
--     AS (  SELECT /*+ materialize merge  */
--                 owner,
--                  segment_name,
--                  segment_type,
--                  TRUNC (SUM (bytes / 1024 / 1024)) s_size,
--                  '***' i_index
--             FROM (SELECT /*+  */
--                         NVL (u.name, 'SYS') owner,
--                          o.name segment_name,
--                          so.object_type segment_type,
--                          s.blocks * ts.blocksize bytes
--                     FROM sys.user$ u,
--                          sys.obj$ o,
--                          sys.ts$ ts,
--                          sys.sys_objects so,
--                          sys.seg$ s,
--                          sys.file$ f
--                    WHERE     s.file# = so.header_file
--                          AND s.block# = so.header_block
--                          AND s.ts# = so.ts_number
--                          AND s.ts# = ts.ts#
--                          AND o.obj# = so.object_id
--                          AND o.owner# = u.user#(+)
--                          AND s.type# = so.segment_type_id
--                          AND o.type# = so.object_type_id
--                          AND s.ts# = f.ts#
--                          AND s.file# = f.relfile#) a
--            WHERE (owner, segment_name) IN (SELECT table_owner, table_name
--                                              FROM tt)
--         GROUP BY a.owner, a.segment_type, a.segment_name),
--     t_table
--     AS (  SELECT /*+ materialize merge */
--                 owner,
--                  segment_name,
--                  segment_type,
--                  TRUNC (SUM (bytes / 1024 / 1024)) s_size
--             FROM (SELECT /*+  */
--                         NVL (u.name, 'SYS') owner,
--                          o.name segment_name,
--                          so.object_type segment_type,
--                          s.blocks * ts.blocksize bytes
--                     FROM sys.user$ u,
--                          sys.obj$ o,
--                          sys.ts$ ts,
--                          sys.sys_objects so,
--                          sys.seg$ s,
--                          sys.file$ f
--                    WHERE     s.file# = so.header_file
--                          AND s.block# = so.header_block
--                          AND s.ts# = so.ts_number
--                          AND s.ts# = ts.ts#
--                          AND o.obj# = so.object_id
--                          AND o.owner# = u.user#(+)
--                          AND s.type# = so.segment_type_id
--                          AND o.type# = so.object_type_id
--                          AND s.ts# = f.ts#
--                          AND s.file# = f.relfile#) a
--            WHERE (a.owner, a.segment_name) IN (SELECT object_owner,
--                                                       object_name
--                                                  FROM t)
--         GROUP BY owner, segment_type, segment_name)
--  SELECT t_table.owner,
--            (SELECT t_index.i_index
--               FROM t_index
--              WHERE     t_index.owner = t_table.owner
--                    AND t_index.segment_name = t_table.segment_name
--                    AND t_index.segment_type = t_table.segment_type)
--         || t_table.segment_name
--            segment_name,
--         t_table.segment_type,
--         t_table.s_size
--    FROM t_table
--ORDER BY owner, segment_name, segment_type
--/
--

/* Formatted on 2016/3/10 12:20:48 (QP5 v5.256.13226.35510) */
/* Formatted on 2018/4/26 14:32:54 (QP5 v5.300) */
WITH t
     AS (SELECT /*+ materialize */
                DISTINCT OBJECT_OWNER, OBJECT_NAME
           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM V$SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                 UNION ALL
                 SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM DBA_HIST_SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL)),
     tt
     AS (SELECT /*+materialize  no_merge */
                DISTINCT table_owner, table_name
           FROM (SELECT table_owner, table_name
                   FROM dba_indexes
                  WHERE (owner, index_name) IN
                            (SELECT object_owner, object_name
                               FROM t)
                 UNION
                 SELECT owner, table_name
                   FROM dba_tables
                  WHERE (owner, table_name) IN
                            (SELECT object_owner, object_name
                               FROM t)))
  SELECT owner,
         segment_name,
         segment_type,
         TRUNC (SUM (bytes / 1024 / 1024)) s_size
    FROM (SELECT owner,
                    (SELECT '***'
                       FROM tt
                      WHERE     a.owner = tt.table_owner
                            AND a.segment_name = tt.table_name)
                 || segment_name
                     segment_name,
                 segment_type,
                 bytes
            FROM (SELECT owner,
                         segment_name,
                         segment_type,
                           DECODE (BITAND (segment_flags, 131072),
                                   131072, blocks,
                                   (DECODE (BITAND (segment_flags, 1),
                                            1, DBMS_SPACE_ADMIN.segment_number_blocks (
                                                   tablespace_id,
                                                   relative_fno,
                                                   header_block,
                                                   segment_type_id,
                                                   buffer_pool_id,
                                                   segment_flags,
                                                   segment_objd,
                                                   blocks),
                                            blocks)))
                         * blocksize
                             bytes
                    FROM (SELECT NVL (u.name, 'SYS')   OWNER,
                                 o.name                SEGMENT_NAME,
                                 so.object_type        SEGMENT_TYPE,
                                 s.type#               SEGMENT_TYPE_ID,
                                 ts.ts#                TABLESPACE_ID,
                                 ts.name               TABLESPACE_NAME,
                                 ts.blocksize          BLOCKSIZE,
                                 f.file#               HEADER_FILE,
                                 s.block#              HEADER_BLOCK,
                                 s.blocks * ts.blocksize BYTES,
                                 s.blocks              BLOCKS,
                                 s.file#               RELATIVE_FNO,
                                 s.cachehint           BUFFER_POOL_ID,
                                 NVL (s.spare1, 0)     SEGMENT_FLAGS,
                                 o.dataobj#            SEGMENT_OBJD
                            FROM sys.user$      u,
                                 sys.obj$       o,
                                 sys.ts$        ts,
                                 sys.sys_objects so,
                                 sys.seg$       s,
                                 sys.file$      f
                           WHERE     s.file# = so.header_file
                                 AND s.block# = so.header_block
                                 AND s.ts# = so.ts_number
                                 AND s.ts# = ts.ts#
                                 AND o.obj# = so.object_id
                                 AND o.owner# = u.user#(+)
                                 AND s.type# = so.segment_type_id
                                 AND o.type# = so.object_type_id
                                 AND s.ts# = f.ts#
                                 AND s.file# = f.relfile#)) a
           WHERE (a.owner, a.segment_name) IN (SELECT object_owner, object_name
                                                 FROM t))
GROUP BY owner, segment_type, segment_name
ORDER BY owner, segment_name
/

prompt
prompt ****************************************************************************************
prompt TABLES
prompt ****************************************************************************************
break on owner
/* Formatted on 2015/5/6 22:38:10 (QP5 v5.240.12305.39446) */
WITH t
     AS (SELECT /*+ materialize */
               DISTINCT OBJECT_OWNER, OBJECT_NAME
           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM V$SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                 UNION ALL
                 SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM DBA_HIST_SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL))
  SELECT a.owner,
         a.TABLE_NAME,
         -- TABLESPACE_NAME,
         a.LOGGING||'.'||a.TEMPORARY l_t,
         a.BUFFER_POOL,
         LTRIM (a.DEGREE) DEGREE,
         a.PARTITIONED,
         a.NUM_ROWS,
         a.BLOCKS,
         a.EMPTY_BLOCKS,
         --a.AVG_SPACE,
         --a.AVG_ROW_LEN,
         trunc((a.blocks*tp.block_size)/1024/1024) block_size,
         trunc((a.AVG_ROW_LEN*a.NUM_ROWS)/1024/1024) avg_size,
--        STALE_STATS,
         a.LAST_ANALYZED
    FROM DBA_TABLES a
--     , dba_tab_statistics b
        ,dba_tablespaces tp
   WHERE     (a.OWNER, a.TABLE_NAME) IN
                (SELECT table_owner, table_name
                   FROM dba_indexes
                  WHERE (owner, index_name) IN (SELECT * FROM t)
                 UNION ALL
                 SELECT * FROM t)
--         AND a.owner = b.owner(+)
--         AND a.table_name = b.table_name(+)
         and a.tablespace_name=tp.tablespace_name
ORDER BY owner, table_name;
clear breaks;

prompt
prompt ****************************************************************************************
prompt TABLE COLUMNS
prompt ****************************************************************************************
break on owner on table_name

col column_id for 999 heading 'Col|Id'
col d_type for a15 heading 'Column|Date Type'
col num_distinct for 9999999999 heading 'NUM|DISTINCT'
col num_buckets for 9999 heading 'BUCK'
WITH t AS
(SELECT /*+ materialize */DISTINCT OBJECT_OWNER, OBJECT_NAME
          FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM V$SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL
                UNION ALL
                SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM DBA_HIST_SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL))
SELECT OWNER,
       TABLE_NAME,
       COLUMN_NAME,
       data_type || '(' || data_length || ')' d_type,
       NULLABLE,
       DENSITY,
       NUM_NULLS,
       num_distinct,
       NUM_BUCKETS,
       AVG_COL_LEN,
       sample_size,
       substr(HISTOGRAM,0,5) HISTOGRAM,
       LAST_ANALYZED
  FROM DBA_TAB_COLS tb
 WHERE (OWNER, TABLE_NAME) IN
       (SELECT table_owner,table_name FROM dba_indexes
         WHERE (owner,index_name) IN (SELECT * FROM t)
        UNION ALL SELECT * FROM t)
 ORDER BY owner,table_name,COLUMN_ID;
clear breaks;
prompt
prompt ****************************************************************************************
prompt INDEX STATUS
prompt ****************************************************************************************
break on OWNER on INDEX_NAME
WITH t
     AS (SELECT /*+ materialize */
                DISTINCT OBJECT_OWNER, OBJECT_NAME
           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM V$SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                 UNION ALL
                 SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM DBA_HIST_SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL)),
     tt
     AS (SELECT /*+ materialize */
               i.OWNER,
                i.INDEX_NAME,
                i.status,
                PARTITIONED
           FROM DBA_INDEXES i
          WHERE     (i.TABLE_OWNER, i.TABLE_NAME) IN (SELECT table_owner,
                                                             table_name
                                                        FROM dba_indexes
                                                       WHERE (owner,
                                                              index_name) IN (SELECT *
                                                                                FROM t)
                                                      UNION ALL
                                                      SELECT * FROM t)
                AND i.status NOT IN ('VALID'))
SELECT OWNER,
       INDEX_NAME,
       '' PARTITION_NAME,
       '' SUBPARTITION_NAME,
       status
  FROM tt
 WHERE tt.PARTITIONED = 'NO'
UNION ALL
SELECT p.INDEX_OWNER,
       p.INDEX_NAME,
       PARTITION_NAME,
       '' SUBPARTITION_NAME,
       p.status
  FROM dba_ind_partitions p
 WHERE     (p.INDEX_OWNER, p.INDEX_NAME) IN (SELECT index_owner, INDEX_NAME
                                               FROM tt
                                              WHERE tt.PARTITIONED = 'YES')
       AND p.status NOT IN ('USABLE')
UNION ALL
SELECT p.INDEX_OWNER,
       p.INDEX_NAME,
       PARTITION_NAME,
       SUBPARTITION_NAME,
       p.status
  FROM dba_ind_subpartitions p
 WHERE     (p.INDEX_OWNER, p.INDEX_NAME) IN (SELECT index_owner, INDEX_NAME
                                               FROM tt
                                              WHERE tt.PARTITIONED = 'YES')
       AND p.status NOT IN ('USABLE')
ORDER BY 1,2,3,4
/
prompt
prompt ****************************************************************************************
prompt INDEX INFO
prompt ****ucptdvs "UNIQUENESS COMPRESSION PARTITIONED TEMPORARY  VISIBILITY SEGMENT_CREATED"**
prompt ****************************************************************************************
break on table_owner on table_name on index_name on ucpt
--WITH t AS
--(SELECT /*+ materialize */DISTINCT OBJECT_OWNER, OBJECT_NAME
--          FROM (SELECT OBJECT_OWNER, OBJECT_NAME
--                  FROM V$SQL_PLAN
--                 WHERE SQL_ID = '&&sqlid'
--                   AND OBJECT_NAME IS NOT NULL
--                UNION ALL
--                SELECT OBJECT_OWNER, OBJECT_NAME
--                  FROM DBA_HIST_SQL_PLAN
--                 WHERE SQL_ID = '&&sqlid'
--                   AND OBJECT_NAME IS NOT NULL))
--SELECT A.TABLE_OWNER,
--       A.TABLE_NAME,
--       A.INDEX_NAME,
--       UNIQUENESS,
--       COLUMN_NAME,
--       COLUMN_POSITION,
--       DESCEND
--  FROM DBA_INDEXES A, DBA_IND_COLUMNS B
-- WHERE (A.OWNER, A.table_name) IN
--       (SELECT table_owner,table_name FROM dba_indexes
--         WHERE (owner,index_name) IN (SELECT * FROM t)
--        UNION ALL SELECT * FROM t)
--   AND A.OWNER = B.INDEX_OWNER
--   AND A.INDEX_NAME = B.INDEX_NAME
--   order by table_owner,table_name,index_name,COLUMN_POSITION;

               WITH t
                    AS (SELECT /*+ materialize */
                               DISTINCT OBJECT_OWNER, OBJECT_NAME
                          FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                                  FROM V$SQL_PLAN
                                 WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                                UNION ALL
                                SELECT OBJECT_OWNER, OBJECT_NAME
                                  FROM DBA_HIST_SQL_PLAN
                                 WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL))
                 SELECT A.TABLE_OWNER,
                        A.TABLE_NAME,
                        A.INDEX_NAME,
                           DECODE (A.UNIQUENESS,  'UNIQUE', 'U',  'NONUNIQUE', 'N',  'O')
                        || DECODE (A.COMPRESSION,  'ENABLED', 'E',  'DISABLED', 'N',  'O')
                        || DECODE (A.PARTITIONED,  'YES', 'Y',  'NO', 'N',  'O')
                        || DECODE (A.TEMPORARY,  'Y', 'Y',  'N', 'N',  'O')
                        || DECODE (A.DROPPED,  'YES', 'Y',  'NO', 'N',  'O')
&_VERSION_11            || DECODE (A.VISIBILITY,  'VISIBLE', 'V',  'INVISIBLE', 'I',  'O')
&_VERSION_11            || DECODE (A.SEGMENT_CREATED,  'YES', 'Y',  'NO', 'N',  'O')
                           ucptdvs,
                        B.COLUMN_NAME,
                        B.COLUMN_POSITION,
                        B.DESCEND
                   FROM DBA_INDEXES A, DBA_IND_COLUMNS B
                  WHERE     (A.OWNER, A.table_name) IN (SELECT table_owner, table_name
                                                          FROM dba_indexes
                                                         WHERE (owner, index_name) IN (SELECT *
                                                                                         FROM t)
                                                        UNION ALL
                                                        SELECT * FROM t)
                        AND A.OWNER = B.INDEX_OWNER
                        AND A.INDEX_NAME = B.INDEX_NAME
               ORDER BY table_owner,
                        table_name,
                        index_name,
                        COLUMN_POSITION
/
clear breaks;

prompt
prompt ****************************************************************************************
prompt PARTITION INDEX
prompt ****************************************************************************************
prompt
break on owner on name
/* Formatted on 2016/8/24 15:04:44 (QP5 v5.256.13226.35510) */
WITH t
     AS (SELECT /*+ materialize */
                DISTINCT OBJECT_OWNER, OBJECT_NAME
           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM V$SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                 UNION ALL
                 SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM DBA_HIST_SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL))
  SELECT a.owner,
         a.name index_name,
         b.partitioning_type,
         b.subpartitioning_type,
         b.partition_count,
         b.def_subpartition_count,
         b.partitioning_key_count,
         b.LOCALITY,
         b.ALIGNMENT,
         a.COLUMN_NAME,
         a.COLUMN_POSITION
    FROM sys.DBA_PART_KEY_COLUMNS a, sys.dba_part_indexes b
   WHERE     a.name = b.index_name
         AND (b.owner, b.index_name) IN (SELECT owner, index_name
                                           FROM dba_indexes
                                          WHERE (table_owner, table_name) IN (SELECT table_owner,
                                                                                     table_name
                                                                                FROM dba_indexes
                                                                               WHERE (owner,
                                                                                      index_name) IN (SELECT *
                                                                                                        FROM t)
                                                                              UNION ALL
                                                                              SELECT *
                                                                                FROM t))
         AND a.owner = b.owner
ORDER BY a.owner,a.name,a.column_position
/
prompt ****************************************************************************************
prompt INDEX STATS
prompt ****************************************************************************************
col DENSITY                               heading "DENSITY"                 for 999,999,999
col owner                                 heading 'TABLE|OWNER'             for a15
col name                                  heading 'TABLE|NAME'              for a20
col COLUMN_NAME                           heading 'PARTITION|COLUMN NAME'   for a15
col COLUMN_POSITION                       heading 'COLUMN|POSITION'         for 99
col partition_name                        heading 'PARTITION|NAME'          for a20
col HIGH_VALUE                            heading 'HIGH_VALUE'              for  a15
col HIGH_VALUE_LENGTH                     heading 'HIGH_VALUE|LENGTH'       for 99
col tablespace_name                       heading 'TABLESPACE|NAME'         for a15
col num_rows                              heading 'NUM_ROWS'                for 9999999999
col blocks                                heading 'BLOCKS'                  for 9999999
col EMPTY_BLOCKS for 999 heading 'EMPTY|BLOCKS'
col l_time for a19 heading 'LAST TIME|ANALYZED'
COL AVG_SPACE FOR 999999
col SUBPARTITION_COUNT for 99 heading 'SUBPARTITION|COUNT'
col compression for a11
col t_size for a10 heading 'PARTITION|SIZE_KB'
col partitioning_type for a10 heading 'PARTITION|TYPE'
col subpartitioning_type for a10 heading 'SUBPART|TYPE'
col partition_count for 99999 heading 'PART|COUNT'
col def_subpartition_count for 9999 heading 'SUBPART|COUNT'
col partitioning_key_count for 99 heading 'PARTITION|KEY COUNT'
BREAK ON OWNER on table_name

/* Formatted on 2016/8/24 16:01:28 (QP5 v5.256.13226.35510) */
WITH t
     AS (SELECT /*+ materialize */
                DISTINCT OBJECT_OWNER, OBJECT_NAME
           FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM V$SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL
                 UNION ALL
                 SELECT OBJECT_OWNER, OBJECT_NAME
                   FROM DBA_HIST_SQL_PLAN
                  WHERE SQL_ID = '&&sqlid' AND OBJECT_NAME IS NOT NULL))
  SELECT t.OWNER,
         t.table_name,
         t.INDEX_NAME,
         t.LOGGING,
            DECODE (b.LOCALITY,  'LOCAL', 'L',  'GLOBAL', 'G')
         || '|'
         || DECODE (b.ALIGNMENT,  'PREFIXED', 'PRE',  'NON_PREFIXED', 'NO')
            index_local,
         trim(t.BLEVEL) BLEV,
         t.LEAF_BLOCKS,
         t.DISTINCT_KEYS,
         t.NUM_ROWS,
         t.AVG_LEAF_BLOCKS_PER_KEY,
         t.AVG_DATA_BLOCKS_PER_KEY,
         t.CLUSTERING_FACTOR,
         TRIM (t.degree) degree,
         t.LAST_ANALYZED
    FROM DBA_INDEXES T, dba_part_indexes b
   WHERE     (t.TABLE_OWNER, t.TABLE_NAME) IN (SELECT table_owner, table_name
                                                 FROM dba_indexes
                                                WHERE (owner, index_name) IN (SELECT *
                                                                                FROM t)
                                               UNION ALL
                                               SELECT * FROM t)
         AND t.owner = b.owner(+)
         AND t.INDEX_NAME = b.INDEX_NAME(+)
ORDER BY 1
/
clear breaks;
prompt
prompt ****************************************************************************************
prompt PARTITION TABLE
prompt ****************************************************************************************

WITH t AS
(SELECT /*+ materialize */DISTINCT OBJECT_OWNER, OBJECT_NAME
          FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM V$SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL
                UNION ALL
                SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM DBA_HIST_SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL))
SELECT a.owner,
       a.name,
       b.partitioning_type,
       b.subpartitioning_type,
       b.partition_count,
       b.def_subpartition_count,
       b.partitioning_key_count,
       a.COLUMN_NAME,
       a.COLUMN_POSITION
  FROM sys.DBA_PART_KEY_COLUMNS a, sys.dba_part_tables b
 WHERE a.name = b.table_name
   AND (a.owner, a.name) in (SELECT table_owner, table_name
                               FROM dba_indexes
                              WHERE (owner, index_name) IN (SELECT * FROM t)
                             UNION ALL
                             SELECT * FROM t)
   AND a.owner = b.owner
 ORDER BY a.NAME, a.COLUMN_POSITION
/

prompt
prompt ****************************************************************************************
prompt display every partition  info
prompt ****************************************************************************************
break on table_name
WITH t AS
(SELECT /*+ materialize */DISTINCT OBJECT_OWNER, OBJECT_NAME
          FROM (SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM V$SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL
                UNION ALL
                SELECT OBJECT_OWNER, OBJECT_NAME
                  FROM DBA_HIST_SQL_PLAN
                 WHERE SQL_ID = '&&sqlid'
                   AND OBJECT_NAME IS NOT NULL))
SELECT table_name ,PARTITION_NAME,
       HIGH_VALUE,
       HIGH_VALUE_LENGTH,
       TABLESPACE_NAME,
       NUM_ROWS,
       BLOCKS,
       round(blocks * 8 / 1024, 2) || 'KB' t_size,
       EMPTY_BLOCKS,
       to_char(LAST_ANALYZED, 'yyyy-mm-dd') l_time,
       AVG_SPACE,
       SUBPARTITION_COUNT,
       COMPRESSION
  FROM sys.DBA_TAB_PARTITIONS
 WHERE (table_owner, table_name) in
       (SELECT table_owner, table_name
          FROM dba_indexes
         WHERE (owner, index_name) IN (SELECT * FROM t)
        UNION ALL
        SELECT * FROM t)
 ORDER BY table_name,PARTITION_POSITION
/
clear breaks
undefine sqlid;