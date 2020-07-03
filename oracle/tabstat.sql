set echo off
set scan on
set lines 220
set pages 1000
set verify off
set feedback off
set termout off
column uservar new_value Table_Owner noprint
select user uservar from dual;
set termout on
column TABLE_NAME heading "Tables owned by &Table_Owner" format a30
undefine table_name
undefine owner
accept owner prompt 'Please enter Name of Table Owner: '
accept table_name  prompt 'Please enter Table Name : '
column TABLE_NAME heading "Table|Name" format a30
column PARTITION_NAME heading "Partition|Name" format a14
column NUM_ROWS heading "Number|of Rows" format 9,999,999,990
column BLOCKS heading "Blocks" format 999,999,990,99
column EMPTY_BLOCKS heading "Empty|Blocks" format 999,999,990

column AVG_SPACE heading "Average|Space" format 9,990
column CHAIN_CNT heading "Chain|Count" format 999,990
column AVG_ROW_LEN heading "Average|Row Len" format 9,990
column COLUMN_NAME  heading "Column|Name" format a30
column NULLABLE heading Null|able format a4
column NUM_DISTINCT heading "Distinct|Values" format 999,999,990
column NUM_NULLS heading "Number|Nulls" format 999,999,990
column NUM_BUCKETS heading "Number|Buckets" format 990
column DENSITY heading "Density" format 9.99999999
column INDEX_NAME heading "Index|Name" format a30
column BLEV heading "BLV" format 90
column LEAF_BLOCKS heading "Leaf|Blks" format 999,999,999
column DISTINCT_KEYS heading "Distinct|Keys" format 9,999,999,990
column AVG_LEAF_BLOCKS_PER_KEY heading "AV|LEA" format 99,990
column AVG_DATA_BLOCKS_PER_KEY heading "Av|Data" format 99,990
column CLUSTERING_FACTOR heading "Cluster|Factor" format 999,999,990
column COLUMN_POSITION heading "Col|Pos" format 990
column col heading "Column|Details" format a24
column COLUMN_LENGTH heading "Col|Len" format 9,990
column GLOBAL_STATS heading "Global|Stats" format a6
column USER_STATS heading "User|Stats" format a6
column SAMPLE_SIZE heading "Sample|Size" format 9,999,999,990
column to_char(t.last_analyzed,'MM-DD-YYYY') heading "Date|MM-DD-YYYY" format a10
column HISTOGRAM for a10

prompt
prompt **********************************************************
prompt                        Table Level
prompt **********************************************************
prompt
select
    TABLE_NAME,
    NUM_ROWS,
    BLOCKS,
    EMPTY_BLOCKS,
    CHAIN_CNT,
    AVG_ROW_LEN,
    GLOBAL_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from all_tables t
where
    owner = upper(nvl('&&Owner',user))
and table_name = upper('&&Table_name')
/
select
    COLUMN_NAME,
    NUM_DISTINCT,
    DENSITY,
    NUM_BUCKETS,
    NUM_NULLS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from all_tab_columns t
where
    table_name = upper('&Table_name')
and owner = upper(nvl('&Owner',user))
/

select
    INDEX_NAME,
    BLEVEL BLev,
    LEAF_BLOCKS,
    DISTINCT_KEYS,
    NUM_ROWS,
    AVG_LEAF_BLOCKS_PER_KEY,
    AVG_DATA_BLOCKS_PER_KEY,
    CLUSTERING_FACTOR,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    all_indexes t
where
    table_name = upper('&Table_name')
and table_owner = upper(nvl('&Owner',user))
/
break on index_name
select /*+ first_rows use_nl(i,t)*/
    i.INDEX_NAME,
    i.COLUMN_NAME,
    i.COLUMN_POSITION,
    decode(t.DATA_TYPE,
           'NUMBER',t.DATA_TYPE||'('||
           decode(t.DATA_PRECISION,
                  null,t.DATA_LENGTH||')',
                  t.DATA_PRECISION||','||t.DATA_SCALE||')'),
                  'DATE',t.DATA_TYPE,
                  'LONG',t.DATA_TYPE,
                  'LONG RAW',t.DATA_TYPE,
                  'ROWID',t.DATA_TYPE,
                  'MLSLABEL',t.DATA_TYPE,
                  t.DATA_TYPE||'('||t.DATA_LENGTH||')') ||' '||
           decode(t.nullable,
                  'N','NOT NULL',
                  'n','NOT NULL',
                  NULL) col
from
    all_ind_columns i,
    all_tab_columns t
where i.index_owner=t.owner and
    i.table_name = upper('&Table_name')
and i.index_owner = upper(nvl('&Owner',user))
and i.table_name = t.table_name
and i.column_name = t.column_name
order by index_name,column_position
/
