
/* Formatted on 2016/11/1 11:43:13 (QP5 v5.256.13226.35510) */
SET ECHO OFF
SET LINES 300 SERVEROUTPUT ON PAGES 10000 VERIFY OFF HEADING ON
undefine sqlid;
DECLARE
   i_plan_putout        VARCHAR2 (3000);
   i_plan_output_last   VARCHAR2 (3000) := ' ';
   i_ash_output         VARCHAR2 (3000);
   i_length             NUMBER;
BEGIN
   FOR c_plan_output
      IN (WITH htz
               AS (SELECT SQL_ID,
                          CHILD_NUMBER,
                          PLAN_HASH_VALUE,
                          '' FORMAT
                     FROM v$sql
                    WHERE sql_id = '&&sqlid'),
               htz_pw
               AS (SELECT t.*,
                          ROW_NUMBER ()
                          OVER (
                             PARTITION BY sql_id,
                                          sql_child_number,
                                          sql_plan_line_id
                             ORDER BY tcount DESC)
                             event_order
                     FROM (  SELECT sql_id,
                                    sql_child_number,
                                    sql_plan_line_id,
                                    event,
                                    COUNT (*) tcount,
                                       ROUND (
                                            (ratio_to_report (COUNT (*))
                                                OVER ())
                                          * 100,
                                          2)
                                    || '%'
                                       pct
                               FROM (SELECT a.sql_id,
                                            a.sql_child_number,
                                            a.sql_plan_line_id,
                                            a.sql_plan_hash_value,
                                            DECODE (
                                               a.SESSION_STATE,
                                               'ON CPU', DECODE (
                                                            a.SESSION_TYPE,
                                                            'BACKGROUND', 'BCPU',
                                                            'CPU'),
                                               EVENT)
                                               EVENT
                                       FROM v$active_session_history a
                                      WHERE a.sql_id = '&&sqlid')
                           GROUP BY sql_id,
                                    sql_child_number,
                                    sql_plan_line_id,
                                    sql_plan_hash_value,
                                    event) t),
               cdhtz
               AS (SELECT sql_id,
                          child_number,
                          n,
                          plan_table_output -- get plan line id from plan_table output
                                           ,
                          CASE
                             WHEN REGEXP_LIKE (
                                     plan_table_output,
                                     '^[|][*]? *([0-9]+) *[|].*[|]$')
                             THEN
                                REGEXP_REPLACE (
                                   plan_table_output,
                                   '^[|][*]? *([0-9]+) *[|].*[|]$',
                                   '\1')
                          END
                             SQL_PLAN_LINE_ID
                     FROM (SELECT ROWNUM n,
                                  plan_table_output,
                                  SQL_ID,
                                  CHILD_NUMBER
                             FROM htz,
                                  TABLE (
                                     DBMS_XPLAN.display_cursor (
                                        htz.SQL_ID,
                                        htz.CHILD_NUMBER,
                                        htz.FORMAT))))
            SELECT plan_table_output,
                   CASE
                      WHEN f.tcount > 0
                      THEN
                            SUBSTR (event, 1, 25)
                         || '('
                         || tcount
                         || ')('
                         || pct
                         || ')'
                   END
                      cast_info,
                   f.SQL_PLAN_LINE_ID
              FROM cdhtz e, htz_pw f
             WHERE     e.sql_id = f.sql_id(+)
                   AND e.child_number = f.sql_child_number(+)
                   AND e.sql_plan_line_id = f.sql_plan_line_id(+)
          ORDER BY e.sql_id, e.child_number, e.n)
   LOOP
      IF (c_plan_output.plan_table_output <> i_plan_output_last)
      THEN
         IF (c_plan_output.cast_info IS NOT NULL)
         THEN
            DBMS_OUTPUT.put_line (
                  c_plan_output.plan_table_output
               || RPAD (c_plan_output.cast_info, 37)
               || '|');
         ELSE
            DBMS_OUTPUT.put_line (c_plan_output.plan_table_output);
            i_plan_output_last := c_plan_output.plan_table_output;
         END IF;

         i_plan_output_last := c_plan_output.plan_table_output;
      ELSE
         IF (c_plan_output.cast_info IS NOT NULL)
         THEN
            SELECT LENGTH (i_plan_output_last) INTO i_length FROM DUAL;

            DBMS_OUTPUT.put_line (
                  '|'
               || LPAD (' ', i_length - 2)
               || '|'
               || RPAD (c_plan_output.cast_info, 37)
               || '|');
         ELSE
            DBMS_OUTPUT.put_line (c_plan_output.plan_table_output);
         END IF;
      END IF;
   END LOOP;
END;
/

