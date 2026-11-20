-- DataTrust: Data Quality & Governance Management System
-- Database schema for SQLite.
-- Defines tables, indexes, views, and triggers.

-- Represent departments responsible for
-- managing data quality and governance.

CREATE TABLE IF NOT EXISTS "departments" (
    "department_id" INTEGER PRIMARY KEY,
    "department_name" TEXT NOT NULL UNIQUE
);

-- Represent employees responsible for
-- managing data quality incidents.

CREATE TABLE IF NOT EXISTS "employees" (
    "employee_id" INTEGER PRIMARY KEY,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "department_id" INTEGER NOT NULL,
    FOREIGN KEY ("department_id")
        REFERENCES "departments"("department_id")
);


-- Represent data sources monitored by DataTrust.

CREATE TABLE IF NOT EXISTS "data_sources" (
    "source_id" INTEGER PRIMARY KEY,
    "source_name" TEXT NOT NULL UNIQUE,
    "source_type" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- Represent business domains used to categorize data assets.

CREATE TABLE IF NOT EXISTS "data_domains" (
    "domain_id" INTEGER PRIMARY KEY,
    "domain_name" TEXT NOT NULL UNIQUE,
    "description" TEXT
);


-- Represent data assets belonging to data sources
-- and business domains.

CREATE TABLE IF NOT EXISTS "data_assets" (
    "asset_id" INTEGER PRIMARY KEY,
    "asset_name" TEXT NOT NULL,
    "source_id" INTEGER NOT NULL,
    "domain_id" INTEGER NOT NULL,
    "description" TEXT,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("source_id")
        REFERENCES "data_sources"("source_id"),
    FOREIGN KEY ("domain_id")
        REFERENCES "data_domains"("domain_id"),
    UNIQUE ("source_id", "asset_name")
);


-- Represent data quality rules assigned to data assets.

CREATE TABLE IF NOT EXISTS "quality_rules" (
    "rule_id" INTEGER PRIMARY KEY,
    "asset_id" INTEGER NOT NULL,
    "rule_name" TEXT NOT NULL,
    "rule_type" TEXT NOT NULL CHECK (
        "rule_type" IN (
            'Completeness',
            'Accuracy',
            'Consistency',
            'Validity',
            'Uniqueness',
            'Timeliness'
        )
    ),
    "description" TEXT NOT NULL,
    "is_active" INTEGER NOT NULL DEFAULT 1
        CHECK ("is_active" IN (0, 1)),
    FOREIGN KEY ("asset_id")
        REFERENCES "data_assets"("asset_id"),
    UNIQUE ("asset_id", "rule_name")
);



-- Store execution results of data quality rules.

CREATE TABLE IF NOT EXISTS "quality_checks" (
    "check_id" INTEGER PRIMARY KEY,
    "rule_id" INTEGER NOT NULL,
    "check_date" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "total_records" INTEGER,
    "failed_records" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Completed'
        CHECK ("status" IN ('Completed', 'Failed')),
    FOREIGN KEY ("rule_id")
        REFERENCES "quality_rules"("rule_id"),
    CHECK (
        "total_records" IS NULL
        OR "total_records" >= 0
    ),
    CHECK (
        "failed_records" IS NULL
        OR "failed_records" >= 0
    ),
    CHECK (
        ("status" = 'Completed'
            AND "total_records" IS NOT NULL
            AND "failed_records" IS NOT NULL
            AND "failed_records" <= "total_records")
        OR
        ("status" = 'Failed'
            AND "total_records" IS NULL
            AND "failed_records" IS NULL)
    )
);


-- Represent data quality issues detected during checks.

CREATE TABLE IF NOT EXISTS "data_issues" (
    "issue_id" INTEGER PRIMARY KEY,
    "check_id" INTEGER NOT NULL,
    "issue_description" TEXT NOT NULL,
    "record_reference" TEXT,
    "severity" TEXT NOT NULL
        CHECK ("severity" IN (
            'Low',
            'Medium',
            'High',
            'Critical'
        )),
    "status" TEXT NOT NULL DEFAULT 'Open'
        CHECK ("status" IN (
            'Open',
            'In Progress',
            'Resolved'
        )),
    "detected_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("check_id")
        REFERENCES "quality_checks"("check_id")
);



-- Represent incidents created to resolve data quality issues.

CREATE TABLE IF NOT EXISTS "incidents" (
    "incident_id" INTEGER PRIMARY KEY,
    "issue_id" INTEGER NOT NULL UNIQUE,
    "assigned_to" INTEGER,
    "opened_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved_at" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open'
        CHECK ("status" IN (
            'Open',
            'In Progress',
            'Resolved'
        )),
    "resolution_description" TEXT,
    FOREIGN KEY ("issue_id")
        REFERENCES "data_issues"("issue_id"),
    FOREIGN KEY ("assigned_to")
        REFERENCES "employees"("employee_id"),
    CHECK (
        ("status" = 'Resolved'
            AND "resolved_at" IS NOT NULL)
        OR
        ("status" != 'Resolved'
            AND "resolved_at" IS NULL)
    ),
    CHECK (
        "resolved_at" IS NULL
        OR "resolved_at" >= "opened_at"
    )
);



-- Store the history of updates made to data quality incidents.

CREATE TABLE IF NOT EXISTS "incident_updates" (
    "update_id" INTEGER PRIMARY KEY,
    "incident_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "update_description" TEXT NOT NULL,
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("incident_id")
        REFERENCES "incidents"("incident_id"),
    FOREIGN KEY ("employee_id")
        REFERENCES "employees"("employee_id")
);



-- Optimize lookups of data assets by business domain.
CREATE INDEX IF NOT EXISTS "idx_data_assets_domain"
ON "data_assets" ("domain_id");

-- Optimize lookups of quality rules by asset.
CREATE INDEX IF NOT EXISTS "idx_quality_rules_asset"
ON "quality_rules" ("asset_id");

-- Optimize quality check history by rule and date.
CREATE INDEX IF NOT EXISTS "idx_quality_checks_rule_date"
ON "quality_checks" ("rule_id", "check_date");

-- Optimize issue lookups by quality check.
CREATE INDEX IF NOT EXISTS "idx_data_issues_check"
ON "data_issues" ("check_id");

-- Optimize filtering issues by severity and status.
CREATE INDEX IF NOT EXISTS "idx_data_issues_severity_status"
ON "data_issues" ("severity", "status");

-- Optimize incident lookups by assigned employee and status.
CREATE INDEX IF NOT EXISTS "idx_incidents_assigned_status"
ON "incidents" ("assigned_to", "status");

-- Optimize incident history lookups.
CREATE INDEX IF NOT EXISTS "idx_incident_updates_incident_date"
ON "incident_updates" ("incident_id", "created_at");



-- Summarize data quality results for each data asset.

CREATE VIEW IF NOT EXISTS "data_quality_summary" AS
SELECT
    "da"."asset_id",
    "da"."asset_name",
    "ds"."source_name",
    "dd"."domain_name",
    COUNT("qc"."check_id") AS "total_checks",
    SUM("qc"."total_records") AS "total_records_checked",
    SUM("qc"."failed_records") AS "total_failed_records",
    ROUND(
        SUM("qc"."total_records" - "qc"."failed_records") * 100.0
        / NULLIF(SUM("qc"."total_records"), 0),
        2
    ) AS "quality_score"
FROM "data_assets" AS "da"
JOIN "data_sources" AS "ds"
    ON "da"."source_id" = "ds"."source_id"
JOIN "data_domains" AS "dd"
    ON "da"."domain_id" = "dd"."domain_id"
LEFT JOIN "quality_rules" AS "qr"
    ON "da"."asset_id" = "qr"."asset_id"
LEFT JOIN "quality_checks" AS "qc"
    ON "qr"."rule_id" = "qc"."rule_id"
    AND "qc"."status" = 'Completed'
GROUP BY
    "da"."asset_id",
    "da"."asset_name",
    "ds"."source_name",
    "dd"."domain_name";



-- Summarize unresolved data quality issues by asset.

CREATE VIEW IF NOT EXISTS "open_issues_summary" AS
SELECT
    "da"."asset_id",
    "da"."asset_name",
    "ds"."source_name",
    COUNT("di"."issue_id") AS "open_issues",
    SUM(
        CASE
            WHEN "di"."severity" = 'Critical' THEN 1
            ELSE 0
        END
    ) AS "critical_issues"
FROM "data_assets" AS "da"
JOIN "data_sources" AS "ds"
    ON "da"."source_id" = "ds"."source_id"
JOIN "quality_rules" AS "qr"
    ON "da"."asset_id" = "qr"."asset_id"
JOIN "quality_checks" AS "qc"
    ON "qr"."rule_id" = "qc"."rule_id"
JOIN "data_issues" AS "di"
    ON "qc"."check_id" = "di"."check_id"
WHERE "di"."status" != 'Resolved'
GROUP BY
    "da"."asset_id",
    "da"."asset_name",
    "ds"."source_name";



-- Provide an overview of incidents and assigned employees.

CREATE VIEW IF NOT EXISTS "incident_management_summary" AS
SELECT
    "i"."incident_id",
    "di"."issue_description",
    "di"."severity",
    "i"."status",
    "e"."first_name" || ' ' || "e"."last_name"
        AS "assigned_employee",
    "i"."opened_at",
    "i"."resolved_at",
    ROUND(
        (julianday("i"."resolved_at") -
         julianday("i"."opened_at")) * 24,
        2
    ) AS "resolution_hours"
FROM "incidents" AS "i"
JOIN "data_issues" AS "di"
    ON "i"."issue_id" = "di"."issue_id"
LEFT JOIN "employees" AS "e"
    ON "i"."assigned_to" = "e"."employee_id";



-- Automatically resolve a data issue when its
-- associated incident is marked as resolved.

CREATE TRIGGER IF NOT EXISTS "trg_auto_resolve_issue"
AFTER UPDATE OF "status" ON "incidents"
FOR EACH ROW
WHEN NEW."status" = 'Resolved'
    AND OLD."status" != 'Resolved'
BEGIN
    UPDATE "data_issues"
    SET "status" = 'Resolved'
    WHERE "issue_id" = NEW."issue_id";
END;


-- Prevent resolved incidents from being reopened.

CREATE TRIGGER IF NOT EXISTS "trg_prevent_resolved_incident_reopen"
BEFORE UPDATE OF "status" ON "incidents"
FOR EACH ROW
WHEN OLD."status" = 'Resolved'
    AND NEW."status" != 'Resolved'
BEGIN
    SELECT RAISE(
        ABORT,
        'Resolved incidents cannot be reopened'
    );
END;


-- Prevent modification of completed quality check results.

CREATE TRIGGER IF NOT EXISTS "trg_prevent_completed_check_update"
BEFORE UPDATE ON "quality_checks"
FOR EACH ROW
WHEN OLD."status" = 'Completed'
BEGIN
    SELECT RAISE(
        ABORT,
        'Completed quality checks cannot be modified'
    );
END;


