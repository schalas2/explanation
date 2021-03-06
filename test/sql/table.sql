\set ECHO none
\set QUIET 1
BEGIN;
\t
SET IntervalStyle = 'postgres';
\i sql/explanation.sql

-- Need to mock md5() so that it emits known values, so the tests will pass.
CREATE SCHEMA mock;

CREATE TEMPORARY SEQUENCE md5seq;
CREATE TEMPORARY TABLE md5s (
    md5 TEXT,
    id  INTEGER DEFAULT NEXTVAL('md5seq')
);

INSERT INTO md5s VALUES
('029dde3a3c872f0c960f03d2ecfaf5ee'),
('3e4c4968cee7653037613c234a953be1'),
('dd3d1b1fb6c70be827075e01b306250c'),
('037a8fe70739ed1be6a3006d0ab80c82'),
('2c4e922dc19ce9f01a3bf08fbd76b041'),
('709b2febd8e560dd8830f4c7277c3758'),
('9dd89be09ea07a1000a21cbfc09121c7'),
('8dc3d35ab978f6c6e46f7927e7b86d21'),
('3d7c72f13ae7571da70f434b5bc9e0af');

CREATE FUNCTION mock.md5(TEXT) RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE
    rec md5s;
BEGIN
    SELECT * INTO rec FROM md5s WHERE id = (SELECT MIN(id) FROM md5s);
     DELETE FROM md5s WHERE id = rec.id;
     RETURN rec.md5;
END;
$$;

SET client_min_messages = warning;
SET log_min_messages = warning;
SET search_path = mock,public,pg_catalog;

CREATE TEMPORARY TABLE plans (
    node_id               TEXT PRIMARY KEY,
    parent_id             TEXT REFERENCES plans(node_id),
    node_type             TEXT NOT NULL,
    total_runtime         INTERVAL,
    strategy              TEXT,
    operation             TEXT,
    startup_cost          FLOAT,
    total_cost            FLOAT,
    plan_rows             FLOAT,
    plan_width            INTEGER,
    actual_startup_time   INTERVAL,
    actual_total_time     INTERVAL,
    actual_rows           FLOAT,
    actual_loops          FLOAT,
    parent_relationship   TEXT,
    sort_key              TEXT[],
    sort_method           TEXT[],
    sort_space_used       BIGINT,
    sort_space_type       TEXT,
    join_type             TEXT,
    join_filter           TEXT,
    hash_cond             TEXT,
    relation_name         TEXT,
    alias                 TEXT,
    scan_direction        TEXT,
    index_name            TEXT,
    index_cond            TEXT,
    recheck_cond          TEXT,
    tid_cond              TEXT,
    merge_cond            TEXT,
    subplan_name          TEXT,
    function_name         TEXT,
    function_call         TEXT,
    filter                TEXT,
    one_time_filter       TEXT,
    command               TEXT,
    shared_hit_blocks     BIGINT,
    shared_read_blocks    BIGINT,
    shared_written_blocks BIGINT,
    local_hit_blocks      BIGINT,
    local_read_blocks     BIGINT,
    local_written_blocks  BIGINT,
    temp_read_blocks      BIGINT,
    temp_written_blocks   BIGINT,
    output                TEXT[],
    hash_buckets          BIGINT,
    hash_batches          BIGINT,
    original_hash_batches BIGINT,
    peak_memory_usage     BIGINT,
    schema                TEXT,
    cte_name              TEXT,       
    triggers              trigger_plan[]
);

RESET client_min_messages;
RESET log_min_messages;

INSERT INTO plans
SELECT * FROM parse_node($$     <Plan>
       <Node-Type>Aggregate</Node-Type>
       <Strategy>Sorted</Strategy>
       <Startup-Cost>258.13</Startup-Cost>
       <Total-Cost>262.31</Total-Cost>
       <Plan-Rows>4</Plan-Rows>
       <Plan-Width>324</Plan-Width>
       <Actual-Startup-Time>0.121</Actual-Startup-Time>
       <Actual-Total-Time>0.121</Actual-Total-Time>
       <Actual-Rows>0</Actual-Rows>
       <Actual-Loops>1</Actual-Loops>
       <Plans>
         <Plan>
           <Node-Type>Sort</Node-Type>
           <Parent-Relationship>Outer</Parent-Relationship>
           <Startup-Cost>258.13</Startup-Cost>
           <Total-Cost>258.14</Total-Cost>
           <Plan-Rows>4</Plan-Rows>
           <Plan-Width>324</Plan-Width>
           <Actual-Startup-Time>0.117</Actual-Startup-Time>
           <Actual-Total-Time>0.117</Actual-Total-Time>
           <Actual-Rows>0</Actual-Rows>
           <Actual-Loops>1</Actual-Loops>
           <Sort-Key>
             <Item>d.name</Item>
             <Item>d.version</Item>
             <Item>d.abstract</Item>
             <Item>d.description</Item>
             <Item>d.relstatus</Item>
             <Item>d.owner</Item>
             <Item>d.sha1</Item>
             <Item>d.meta</Item>
           </Sort-Key>
           <Sort-Method>quicksort</Sort-Method>
           <Sort-Space-Used>25</Sort-Space-Used>
           <Sort-Space-Type>Memory</Sort-Space-Type>
           <Plans>
             <Plan>
               <Node-Type>Nested Loop</Node-Type>
               <Parent-Relationship>Outer</Parent-Relationship>
               <Join-Type>Left</Join-Type>
               <Startup-Cost>16.75</Startup-Cost>
               <Total-Cost>258.09</Total-Cost>
               <Plan-Rows>4</Plan-Rows>
               <Plan-Width>324</Plan-Width>
               <Actual-Startup-Time>0.009</Actual-Startup-Time>
               <Actual-Total-Time>0.009</Actual-Total-Time>
               <Actual-Rows>0</Actual-Rows>
               <Actual-Loops>1</Actual-Loops>
               <Join-Filter>(semver_cmp(d.version, dt.version) = 0)</Join-Filter>
               <Plans>
                 <Plan>
                   <Node-Type>Hash Join</Node-Type>
                   <Parent-Relationship>Outer</Parent-Relationship>
                   <Join-Type>Inner</Join-Type>
                   <Startup-Cost>16.75</Startup-Cost>
                   <Total-Cost>253.06</Total-Cost>
                   <Plan-Rows>4</Plan-Rows>
                   <Plan-Width>292</Plan-Width>
                   <Actual-Startup-Time>0.009</Actual-Startup-Time>
                   <Actual-Total-Time>0.009</Actual-Total-Time>
                   <Actual-Rows>0</Actual-Rows>
                   <Actual-Loops>1</Actual-Loops>
                   <Hash-Cond>(de.distribution = d.name)</Hash-Cond>
                   <Join-Filter>(semver_cmp(d.version, de.dist_version) = 0)</Join-Filter>↵
                   <Plans>
                     <Plan>
                       <Node-Type>Seq Scan</Node-Type>
                       <Parent-Relationship>Outer</Parent-Relationship>
                       <Relation-Name>distribution_extensions</Relation-Name>
                       <Alias>de</Alias>
                       <Startup-Cost>0.00</Startup-Cost>
                       <Total-Cost>15.10</Total-Cost>
                       <Plan-Rows>510</Plan-Rows>
                       <Plan-Width>128</Plan-Width>
                       <Actual-Startup-Time>0.008</Actual-Startup-Time>
                       <Actual-Total-Time>0.008</Actual-Total-Time>
                       <Actual-Rows>0</Actual-Rows>
                       <Actual-Loops>1</Actual-Loops>
                     </Plan>
                     <Plan>
                       <Node-Type>Hash</Node-Type>
                       <Parent-Relationship>Inner</Parent-Relationship>
                       <Startup-Cost>13.00</Startup-Cost>
                       <Total-Cost>13.00</Total-Cost>
                       <Plan-Rows>300</Plan-Rows>
                       <Plan-Width>228</Plan-Width>
                       <Actual-Startup-Time>0.000</Actual-Startup-Time>
                       <Actual-Total-Time>0.000</Actual-Total-Time>
                       <Actual-Rows>0</Actual-Rows>
                       <Actual-Loops>0</Actual-Loops>
                       <Plans>
                         <Plan>
                           <Node-Type>Seq Scan</Node-Type>
                           <Parent-Relationship>Outer</Parent-Relationship>
                           <Relation-Name>distributions</Relation-Name>
                           <Alias>d</Alias>
                           <Startup-Cost>0.00</Startup-Cost>
                           <Total-Cost>13.00</Total-Cost>
                           <Plan-Rows>300</Plan-Rows>
                           <Plan-Width>228</Plan-Width>
                           <Actual-Startup-Time>0.000</Actual-Startup-Time>
                           <Actual-Total-Time>0.000</Actual-Total-Time>
                           <Actual-Rows>0</Actual-Rows>
                           <Actual-Loops>0</Actual-Loops>
                         </Plan>
                       </Plans>
                     </Plan>
                   </Plans>
                 </Plan>
                 <Plan>
                   <Node-Type>Index Scan</Node-Type>
                   <Parent-Relationship>Inner</Parent-Relationship>
                   <Scan-Direction>NoMovement</Scan-Direction>
                   <Index-Name>distribution_tags_pkey</Index-Name>
                   <Relation-Name>distribution_tags</Relation-Name>
                   <Alias>dt</Alias>
                   <Startup-Cost>0.00</Startup-Cost>
                   <Total-Cost>0.46</Total-Cost>
                   <Plan-Rows>3</Plan-Rows>
                   <Plan-Width>96</Plan-Width>
                   <Actual-Startup-Time>0.000</Actual-Startup-Time>
                   <Actual-Total-Time>0.000</Actual-Total-Time>
                   <Actual-Rows>0</Actual-Rows>
                   <Actual-Loops>0</Actual-Loops>
                   <Index-Cond>(d.name = dt.distribution)</Index-Cond>
                 </Plan>
               </Plans>
             </Plan>
           </Plans>
         </Plan>
         <Plan>
           <Node-Type>Function Scan</Node-Type>
           <Parent-Relationship>SubPlan</Parent-Relationship>
           <Subplan-Name>SubPlan 1</Subplan-Name>
           <Function-Name>unnest</Function-Name>
           <Alias>g</Alias>
           <Startup-Cost>0.00</Startup-Cost>
           <Total-Cost>1.00</Total-Cost>
           <Plan-Rows>100</Plan-Rows>
           <Plan-Width>32</Plan-Width>
           <Actual-Startup-Time>0.000</Actual-Startup-Time>
           <Actual-Total-Time>0.000</Actual-Total-Time>
           <Actual-Rows>0</Actual-Rows>
           <Actual-Loops>0</Actual-Loops>
           <Filter>(x IS NOT NULL)</Filter>
         </Plan>
       </Plans>
     </Plan>
$$, NULL, '14.35 ms', ARRAY[ROW('Harry', 'Melissa', 'users', '00:00:00.000234', 14)::trigger_plan]);

SELECT * FROM plans;

ROLLBACK;
