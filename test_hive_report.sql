-- Tests for the hive report. Stop at the first failed check, so it is not
-- followed by PASS lines that make the run look fine.
.bail on

-- Run the report twice: the second run proves the DROP ... IF EXISTS lines work.
-- The checks below read the report's own views, so they test its real queries.
.read hive_report.sql
.read hive_report.sql

-- Every check must store 1. A 0 breaks the CHECK rule and stops the tests.
CREATE TEMP TABLE checks (name TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO checks VALUES ('table has 12 inspections after two runs',
  (SELECT COUNT(*) FROM inspections) = 12);

INSERT INTO checks VALUES ('hive A averages 6 (counts 4 and 8)',
  (SELECT AVG(varroa_count) FROM inspections WHERE hive_id = 'A') = 6);

INSERT INTO checks VALUES ('HAVING keeps only hives A and C',
  (SELECT group_concat(hive_id, ',') FROM (
     SELECT hive_id FROM infested_hives ORDER BY hive_id)) = 'A,C');

INSERT INTO checks VALUES ('flagged averages are 6.0 and 12.0',
  (SELECT group_concat(avg_varroa, ',') FROM (
     SELECT avg_varroa FROM infested_hives ORDER BY hive_id)) = '6.0,12.0');

INSERT INTO checks VALUES ('hive D averages exactly 5 and is not flagged',
  (SELECT AVG(varroa_count) FROM inspections WHERE hive_id = 'D') = 5
  AND 'D' NOT IN (SELECT hive_id FROM infested_hives));

INSERT INTO checks VALUES ('overall average varroa count is 6',
  (SELECT AVG(varroa_count) FROM inspections) = 6);

INSERT INTO checks VALUES ('subquery finds inspections 2, 6, 8 and 10',
  (SELECT group_concat(id, ',') FROM (
     SELECT id FROM above_average_inspections ORDER BY id)) = '2,6,8,10');

INSERT INTO checks VALUES ('inspection 7 equals the average and is not listed',
  (SELECT varroa_count FROM inspections WHERE id = 7) = 6
  AND 7 NOT IN (SELECT id FROM above_average_inspections));

.headers off
SELECT 'PASS: ' || name FROM checks;
SELECT 'ALL ' || COUNT(*) || ' CHECKS PASSED' FROM checks;
