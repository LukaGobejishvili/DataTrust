-- DataTrust: Data Quality & Governance Management System
-- Common SQL queries used to monitor data quality,
-- investigate issues, and manage incidents.
--
-- The queries below demonstrate typical database operations.


-- Query 1: Calculate the overall data quality score
-- across all successfully completed checks.

SELECT
    COUNT(*) AS "completed_checks",
    SUM("total_records") AS "records_checked",
    SUM("failed_records") AS "failed_records",
    ROUND(
        SUM("total_records" - "failed_records") * 100.0
        / NULLIF(SUM("total_records"), 0),
        2
    ) AS "quality_score"
FROM "quality_checks"
WHERE "status" = 'Completed';



-- Query 2: Find data assets with the lowest quality scores.

SELECT
    "asset_name",
    "source_name",
    "domain_name",
    "total_checks",
    "quality_score"
FROM "data_quality_summary"
WHERE "quality_score" IS NOT NULL
ORDER BY "quality_score" ASC;



-- Query 3: Identify unresolved critical data quality issues
-- and the data assets affected by them.

SELECT
    "di"."issue_id",
    "di"."issue_description",
    "di"."severity",
    "di"."status",
    "da"."asset_name",
    "ds"."source_name",
    "di"."detected_at"
FROM "data_issues" AS "di"
JOIN "quality_checks" AS "qc"
    ON "di"."check_id" = "qc"."check_id"
JOIN "quality_rules" AS "qr"
    ON "qc"."rule_id" = "qr"."rule_id"
JOIN "data_assets" AS "da"
    ON "qr"."asset_id" = "da"."asset_id"
JOIN "data_sources" AS "ds"
    ON "da"."source_id" = "ds"."source_id"
WHERE "di"."severity" = 'Critical'
    AND "di"."status" != 'Resolved'
ORDER BY "di"."detected_at" DESC;



-- Query 4: Count data quality issues by severity level.

SELECT
    "severity",
    COUNT(*) AS "total_issues"
FROM "data_issues"
GROUP BY "severity"
ORDER BY
    CASE "severity"
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END;



-- Query 5: Identify data sources with the highest
-- number of unresolved data quality issues.

SELECT
    "ds"."source_name",
    COUNT("di"."issue_id") AS "total_open_issues",
    SUM(
        CASE
            WHEN "di"."severity" = 'Critical' THEN 1
            ELSE 0
        END
    ) AS "critical_issues"
FROM "data_sources" AS "ds"
JOIN "data_assets" AS "da"
    ON "ds"."source_id" = "da"."source_id"
JOIN "quality_rules" AS "qr"
    ON "da"."asset_id" = "qr"."asset_id"
JOIN "quality_checks" AS "qc"
    ON "qr"."rule_id" = "qc"."rule_id"
JOIN "data_issues" AS "di"
    ON "qc"."check_id" = "di"."check_id"
WHERE "di"."status" != 'Resolved'
GROUP BY "ds"."source_id", "ds"."source_name"
HAVING COUNT("di"."issue_id") > 0
ORDER BY "total_open_issues" DESC;



-- Query 6: Analyze employee workload based on
-- assigned and unresolved incidents.

SELECT
    "e"."employee_id",
    "e"."first_name" || ' ' || "e"."last_name"
        AS "employee_name",
    "d"."department_name",
    COUNT("i"."incident_id") AS "total_incidents",
    COUNT(
        CASE
            WHEN "i"."status" != 'Resolved'
            THEN 1
        END
    ) AS "unresolved_incidents"
FROM "employees" AS "e"
JOIN "departments" AS "d"
    ON "e"."department_id" = "d"."department_id"
LEFT JOIN "incidents" AS "i"
    ON "e"."employee_id" = "i"."assigned_to"
GROUP BY
    "e"."employee_id",
    "e"."first_name",
    "e"."last_name",
    "d"."department_name"
ORDER BY "unresolved_incidents" DESC;



-- Query 7: Retrieve the activity history of an incident.
-- Incident ID 1 is used as an example.

SELECT
    "iu"."incident_id",
    "iu"."created_at",
    "e"."first_name" || ' ' || "e"."last_name"
        AS "updated_by",
    "iu"."update_description"
FROM "incident_updates" AS "iu"
JOIN "employees" AS "e"
    ON "iu"."employee_id" = "e"."employee_id"
WHERE "iu"."incident_id" = 1
ORDER BY "iu"."created_at" ASC;



-- Query 8: Analyze monthly data quality trends
-- based on successfully completed quality checks.

SELECT
    strftime('%Y-%m', "check_date") AS "month",
    COUNT(*) AS "completed_checks",
    SUM("total_records") AS "records_checked",
    SUM("failed_records") AS "failed_records",
    ROUND(
        SUM("total_records" - "failed_records") * 100.0
        / NULLIF(SUM("total_records"), 0),
        2
    ) AS "quality_score"
FROM "quality_checks"
WHERE "status" = 'Completed'
GROUP BY strftime('%Y-%m', "check_date")
ORDER BY "month";



-- Query 9: Rank data assets by quality score
-- within each business domain.

SELECT
    "domain_name",
    "asset_name",
    "quality_score",
    RANK() OVER (
        PARTITION BY "domain_name"
        ORDER BY "quality_score" DESC
    ) AS "quality_rank"
FROM "data_quality_summary"
WHERE "quality_score" IS NOT NULL
ORDER BY "domain_name", "quality_rank";



-- Query 10: Compare October and November data quality
-- using a Common Table Expression (CTE).

WITH "monthly_quality" AS (
    SELECT
        "da"."asset_id",
        "da"."asset_name",
        strftime('%Y-%m', "qc"."check_date") AS "month",
        ROUND(
            SUM("qc"."total_records" - "qc"."failed_records") * 100.0
            / NULLIF(SUM("qc"."total_records"), 0),
            2
        ) AS "quality_score"
    FROM "data_assets" AS "da"
    JOIN "quality_rules" AS "qr"
        ON "da"."asset_id" = "qr"."asset_id"
    JOIN "quality_checks" AS "qc"
        ON "qr"."rule_id" = "qc"."rule_id"
    WHERE "qc"."status" = 'Completed'
    GROUP BY
        "da"."asset_id",
        "da"."asset_name",
        strftime('%Y-%m', "qc"."check_date")
)
SELECT
    "asset_name",
    MAX(CASE WHEN "month" = '2026-10'
        THEN "quality_score" END) AS "october_score",
    MAX(CASE WHEN "month" = '2026-11'
        THEN "quality_score" END) AS "november_score",
    ROUND(
        MAX(CASE WHEN "month" = '2026-11'
            THEN "quality_score" END)
        -
        MAX(CASE WHEN "month" = '2026-10'
            THEN "quality_score" END),
        2
    ) AS "score_change"
FROM "monthly_quality"
GROUP BY "asset_id", "asset_name"
ORDER BY "score_change" DESC;



-- Query 11: Find assets whose quality scores exceed
-- the unweighted average of all asset quality scores.

SELECT
    "asset_name",
    "domain_name",
    "quality_score"
FROM "data_quality_summary"
WHERE "quality_score" > (
    SELECT AVG("quality_score")
    FROM "data_quality_summary"
    WHERE "quality_score" IS NOT NULL
)
ORDER BY "quality_score" DESC;



-- Query 12: Retrieve the latest quality check
-- for every quality rule using ROW_NUMBER().

WITH "ranked_checks" AS (
    SELECT
        "qr"."rule_name",
        "qc"."check_id",
        "qc"."check_date",
        "qc"."status",
        "qc"."total_records",
        "qc"."failed_records",
        ROW_NUMBER() OVER (
            PARTITION BY "qc"."rule_id"
            ORDER BY "qc"."check_date" DESC,
                     "qc"."check_id" DESC
        ) AS "row_num"
    FROM "quality_checks" AS "qc"
    JOIN "quality_rules" AS "qr"
        ON "qc"."rule_id" = "qr"."rule_id"
)
SELECT
    "rule_name",
    "check_date",
    "status",
    "total_records",
    "failed_records"
FROM "ranked_checks"
WHERE "row_num" = 1
ORDER BY "rule_name";



-- CRUD demonstration: run all changes in a transaction.
-- ROLLBACK at the end preserves the original data.

BEGIN TRANSACTION;

-- Query 13: Register a new data source.

INSERT INTO "data_sources"
    ("source_name", "source_type", "description")
VALUES
    ('Analytics Warehouse Demo', 'PostgreSQL',
     'Temporary data source for demonstrating CRUD operations');



-- Query 14: Update the description of a data source.

UPDATE "data_sources"
SET "description" = 'Updated description for CRUD testing'
WHERE "source_name" = 'Analytics Warehouse Demo';



-- Query 15: Resolve an incident.
-- The trigger automatically resolves its associated issue.

UPDATE "incidents"
SET
    "status" = 'Resolved',
    "resolved_at" = '2026-11-02 10:00:00',
    "resolution_description" = 'Missing customer emails corrected'
WHERE "incident_id" = 1
    AND "status" = 'Open';



-- Query 16: Delete the temporary data source.

DELETE FROM "data_sources"
WHERE "source_name" = 'Analytics Warehouse Demo';



-- Verify that the incident and its issue were resolved.

SELECT
    "i"."incident_id",
    "i"."status" AS "incident_status",
    "di"."status" AS "issue_status"
FROM "incidents" AS "i"
JOIN "data_issues" AS "di"
    ON "i"."issue_id" = "di"."issue_id"
WHERE "i"."incident_id" = 1;

-- Undo the demonstration changes.

ROLLBACK;
