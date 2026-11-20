-- Insert sample data for testing the DataTrust database.
-- All records are fictional and used for demonstration.


-- Insert fictional company departments.

INSERT INTO "departments" ("department_name")
VALUES
    ('Data Governance'),
    ('Information Technology'),
    ('Finance'),
    ('Marketing');



-- Insert fictional employees assigned to departments.

INSERT INTO "employees"
    ("first_name", "last_name", "email", "department_id")
VALUES
    ('Alex', 'Morgan', 'alex.morgan@example.com', 1),
    ('Emma', 'Wilson', 'emma.wilson@example.com', 1),
    ('Daniel', 'Brown', 'daniel.brown@example.com', 1),
    ('Sophia', 'Taylor', 'sophia.taylor@example.com', 2),
    ('James', 'Anderson', 'james.anderson@example.com', 2),
    ('Olivia', 'Thomas', 'olivia.thomas@example.com', 2),
    ('William', 'Jackson', 'william.jackson@example.com', 3),
    ('Mia', 'White', 'mia.white@example.com', 3),
    ('Noah', 'Harris', 'noah.harris@example.com', 3),
    ('Ava', 'Martin', 'ava.martin@example.com', 4),
    ('Ethan', 'Thompson', 'ethan.thompson@example.com', 4),
    ('Isabella', 'Garcia', 'isabella.garcia@example.com', 4);



-- Insert fictional data sources monitored by DataTrust.

INSERT INTO "data_sources"
    ("source_name", "source_type", "description")
VALUES
    ('CRM Database', 'PostgreSQL',
     'Stores customer profiles and contact information'),
    ('Sales Database', 'MySQL',
     'Stores sales orders and transaction records'),
    ('Inventory Database', 'PostgreSQL',
     'Stores product and inventory information'),
    ('HR Database', 'SQLite',
     'Stores employee and payroll information'),
    ('Finance Reports', 'Excel',
     'Stores financial reports and budget data');



-- Insert business domains for classifying data assets.

INSERT INTO "data_domains"
    ("domain_name", "description")
VALUES
    ('Customer', 'Customer information and relationships'),
    ('Finance', 'Financial transactions and reporting'),
    ('Product', 'Products, pricing, and inventory'),
    ('Human Resources', 'Employee and workforce information');


-- Insert data assets and link them to sources and domains.

INSERT INTO "data_assets"
    ("asset_name", "source_id", "domain_id", "description")
VALUES
    ('Customers', 1, 1, 'Customer master records'),
    ('Customer Contacts', 1, 1, 'Customer contact details'),
    ('Customer Addresses', 1, 1, 'Customer address records'),
    ('Sales Orders', 2, 2, 'Customer sales orders'),
    ('Transactions', 2, 2, 'Sales transaction history'),
    ('Payments', 2, 2, 'Payment records'),
    ('Products', 3, 3, 'Product catalog'),
    ('Inventory', 3, 3, 'Product stock levels'),
    ('Product Prices', 3, 3, 'Product pricing data'),
    ('Employees', 4, 4, 'Employee master records'),
    ('Payroll', 4, 4, 'Employee salary information'),
    ('Financial Reports', 5, 2, 'Financial reporting data');



-- Insert data quality rules for monitoring data assets.

INSERT INTO "quality_rules"
    ("asset_id", "rule_name", "rule_type", "description")
VALUES
    (1, 'Customer email is required', 'Completeness',
     'Every customer must have an email address'),

    (1, 'Customer email must be unique', 'Uniqueness',
     'Customer email addresses must not be duplicated'),

    (1, 'Customer email format is valid', 'Validity',
     'Customer emails must follow an accepted format'),

    (2, 'Contact phone is required', 'Completeness',
     'Every contact must have a phone number'),

    (3, 'Customer address is complete', 'Completeness',
     'Required address fields must not be missing'),

    (4, 'Order total is accurate', 'Accuracy',
     'Order totals must match the sum of order items'),

    (4, 'Order date is valid', 'Validity',
     'Order dates must follow valid date rules'),

    (5, 'Transaction amount is positive', 'Validity',
     'Transaction amounts must be greater than zero'),

    (5, 'Transaction references are unique', 'Uniqueness',
     'Every transaction must have a unique reference'),

    (6, 'Payment matches transaction', 'Consistency',
     'Payments must match their related transactions'),

    (7, 'Product name is required', 'Completeness',
     'Every product must have a name'),

    (8, 'Inventory quantity is non-negative', 'Validity',
     'Inventory quantities cannot be negative'),

    (9, 'Product price is positive', 'Validity',
     'Product prices must be greater than zero'),

    (10, 'Employee email is unique', 'Uniqueness',
     'Employee email addresses must not be duplicated'),

    (10, 'Employee records are current', 'Timeliness',
     'Employee records must be updated within the required period'),

    (11, 'Salary is non-negative', 'Validity',
     'Employee salaries cannot be negative'),

    (12, 'Financial report totals are accurate', 'Accuracy',
     'Report totals must reconcile with source data'),

    (12, 'Financial reports are submitted on time', 'Timeliness',
     'Financial reports must be submitted before the deadline');



-- Insert fictional data quality check results.
-- Completed checks contain record counts.
-- Failed executions contain NULL record counts.

INSERT INTO "quality_checks"
    ("rule_id", "check_date", "total_records",
     "failed_records", "status")
VALUES
    -- Customer quality checks
    (1, '2026-10-01 09:00:00', 1000, 35, 'Completed'),
    (2, '2026-10-01 09:10:00', 1000, 12, 'Completed'),
    (3, '2026-10-01 09:20:00', 1000, 48, 'Completed'),

    -- Customer contacts and addresses
    (4, '2026-10-02 09:00:00', 850, 27, 'Completed'),
    (5, '2026-10-02 09:10:00', 900, 41, 'Completed'),

    -- Sales orders
    (6, '2026-10-03 09:00:00', 2500, 65, 'Completed'),
    (7, '2026-10-03 09:10:00', 2500, 18, 'Completed'),

    -- Transactions
    (8, '2026-10-04 09:00:00', 3200, 84, 'Completed'),
    (9, '2026-10-04 09:10:00', 3200, 21, 'Completed'),

    -- Payment consistency
    (10, '2026-10-05 09:00:00', 2900, 73, 'Completed'),

    -- Products, inventory and prices
    (11, '2026-10-06 09:00:00', 600, 9, 'Completed'),
    (12, '2026-10-06 09:10:00', 600, 14, 'Completed'),
    (13, '2026-10-06 09:20:00', 600, 22, 'Completed'),

    -- Employees and payroll
    (14, '2026-10-07 09:00:00', 400, 3, 'Completed'),
    (15, '2026-10-07 09:10:00', 400, 16, 'Completed'),
    (16, '2026-10-07 09:20:00', 400, 5, 'Completed'),

    -- Financial reports
    (17, '2026-10-08 09:00:00', 120, 7, 'Completed'),
    (18, '2026-10-08 09:10:00', 120, 11, 'Completed'),

    -- Second monitoring cycle
    (1, '2026-11-01 09:00:00', 1100, 20, 'Completed'),
    (2, '2026-11-01 09:10:00', 1100, 8, 'Completed'),
    (3, '2026-11-01 09:20:00', 1100, 30, 'Completed'),
    (4, '2026-11-02 09:00:00', 920, 18, 'Completed'),
    (5, '2026-11-02 09:10:00', 950, 25, 'Completed'),
    (6, '2026-11-03 09:00:00', 2700, 42, 'Completed'),
    (7, '2026-11-03 09:10:00', 2700, 11, 'Completed'),
    (8, '2026-11-04 09:00:00', 3500, 55, 'Completed'),
    (9, '2026-11-04 09:10:00', 3500, 13, 'Completed'),

    -- Technical execution failure
    (10, '2026-11-05 09:00:00', NULL, NULL, 'Failed'),

    -- Second cycle continued
    (11, '2026-11-06 09:00:00', 650, 4, 'Completed'),
    (12, '2026-11-06 09:10:00', 650, 9, 'Completed'),
    (13, '2026-11-06 09:20:00', 650, 12, 'Completed'),
    (14, '2026-11-07 09:00:00', 420, 2, 'Completed'),
    (15, '2026-11-07 09:10:00', 420, 8, 'Completed'),
    (16, '2026-11-07 09:20:00', 420, 3, 'Completed'),
    (17, '2026-11-08 09:00:00', 130, 4, 'Completed'),

    -- Technical execution failure
    (18, '2026-11-08 09:10:00', NULL, NULL, 'Failed'),

    -- Additional monitoring checks
    (1, '2026-11-10 09:00:00', 1150, 15, 'Completed'),
    (8, '2026-11-10 09:10:00', 3600, 48, 'Completed'),
    (10, '2026-11-10 09:20:00', 3100, 39, 'Completed'),
    (13, '2026-11-10 09:30:00', 680, 7, 'Completed');



-- Insert fictional data quality issues detected
-- during completed quality checks.

INSERT INTO "data_issues"
    ("check_id", "issue_description",
     "record_reference", "severity", "status")
VALUES
    -- Customer data issues
    (1, 'Customer email address is missing',
     'customer_id=101', 'High', 'Open'),

    (2, 'Duplicate customer email detected',
     'customer_id=205', 'Medium', 'Open'),

    (3, 'Customer email has an invalid format',
     'customer_id=310', 'Low', 'Open'),

    (4, 'Customer contact phone is missing',
     'contact_id=120', 'Medium', 'Open'),

    (5, 'Customer address is incomplete',
     'address_id=450', 'Medium', 'Open'),

    -- Sales and transaction issues
    (6, 'Order total does not match order items',
     'order_id=5001', 'Critical', 'Open'),

    (7, 'Sales order contains an invalid date',
     'order_id=5020', 'High', 'Open'),

    (8, 'Transaction amount is negative',
     'transaction_id=8001', 'Critical', 'Open'),

    (9, 'Duplicate transaction reference detected',
     'transaction_id=8015', 'High', 'Open'),

    (10, 'Payment amount does not match transaction',
     'payment_id=3001', 'Critical', 'Open'),

    -- Product and inventory issues
    (11, 'Product name is missing',
     'product_id=201', 'Medium', 'Open'),

    (12, 'Inventory quantity is negative',
     'inventory_id=305', 'High', 'Open'),

    (13, 'Product price is zero',
     'product_id=220', 'High', 'Open'),

    -- Employee and payroll issues
    (14, 'Duplicate employee email detected',
     'employee_id=150', 'Medium', 'Open'),

    (15, 'Employee record has not been updated',
     'employee_id=175', 'Low', 'Open'),

    (16, 'Employee salary is negative',
     'payroll_id=601', 'Critical', 'Open'),

    -- Financial reporting issues
    (17, 'Financial report totals do not reconcile',
     'report_id=701', 'Critical', 'Open'),

    (18, 'Financial report submitted after deadline',
     'report_id=715', 'Medium', 'Open'),

    -- Issues detected during November checks
    (19, 'Customer email is missing in new records',
     'customer_id=1105', 'High', 'Open'),

    (20, 'Duplicate customer email found in November',
     'customer_id=1120', 'Medium', 'Open'),

    (21, 'Invalid email format in updated customer',
     'customer_id=1140', 'Low', 'Open'),

    (22, 'New customer contact has no phone',
     'contact_id=950', 'Medium', 'Open'),

    (23, 'Recently added customer address incomplete',
     'address_id=980', 'Low', 'Open'),

    (24, 'Sales order total calculation mismatch',
     'order_id=6100', 'Critical', 'Open'),

    (25, 'Invalid order date detected in November',
     'order_id=6120', 'High', 'Open'),

    (26, 'Negative transaction amount detected',
     'transaction_id=9200', 'Critical', 'Open'),

    (27, 'Duplicate transaction reference in sales',
     'transaction_id=9250', 'High', 'Open'),

    -- Additional quality issues
    (29, 'Product catalog contains unnamed product',
     'product_id=450', 'Medium', 'Open'),

    (31, 'Product price violates pricing rules',
     'product_id=480', 'High', 'Open'),

    (37, 'Customer email missing in latest check',
     'customer_id=1200', 'High', 'Open');



-- Insert fictional incidents for managing data quality issues.
-- All incidents initially have Open status.

INSERT INTO "incidents"
    ("issue_id", "assigned_to", "opened_at", "status")
VALUES
    -- Customer incidents
    (1, 1, '2026-10-01 10:00:00', 'Open'),
    (2, 2, '2026-10-01 10:30:00', 'Open'),
    (3, 3, '2026-10-01 11:00:00', 'Open'),
    (4, 4, '2026-10-02 10:00:00', 'Open'),
    (5, 5, '2026-10-02 11:00:00', 'Open'),

    -- Sales and transaction incidents
    (6, 6, '2026-10-03 10:00:00', 'Open'),
    (7, 1, '2026-10-03 11:00:00', 'Open'),
    (8, 2, '2026-10-04 10:00:00', 'Open'),
    (9, 3, '2026-10-04 11:00:00', 'Open'),
    (10, 4, '2026-10-05 10:00:00', 'Open'),

    -- Product and inventory incidents
    (11, 5, '2026-10-06 10:00:00', 'Open'),
    (12, 6, '2026-10-06 11:00:00', 'Open'),
    (13, 7, '2026-10-06 12:00:00', 'Open'),

    -- Employee and payroll incidents
    (14, 8, '2026-10-07 10:00:00', 'Open'),
    (15, 9, '2026-10-07 11:00:00', 'Open'),
    (16, 10, '2026-10-07 12:00:00', 'Open'),

    -- Financial reporting incidents
    (17, 11, '2026-10-08 10:00:00', 'Open'),
    (18, 12, '2026-10-08 11:00:00', 'Open'),

    -- November incidents
    (19, 1, '2026-11-01 10:00:00', 'Open'),
    (20, NULL, '2026-11-01 11:00:00', 'Open');



-- Insert fictional incident activity history.
-- Each update references an existing incident and employee.

INSERT INTO "incident_updates"
    ("incident_id", "employee_id", "update_description", "created_at")
VALUES
    -- Incident 1
    (1, 1, 'Investigation started for missing customer emails', '2026-10-01 10:15:00'),
    (1, 2, 'Identified missing email values in customer records', '2026-10-01 11:30:00'),
    (1, 1, 'Prepared a correction plan for affected records', '2026-10-01 14:00:00'),

    -- Incident 2
    (2, 2, 'Started duplicate email investigation', '2026-10-01 10:45:00'),
    (2, 3, 'Identified duplicated customer profiles', '2026-10-01 12:00:00'),
    (2, 2, 'Reviewed possible duplicate removal strategy', '2026-10-01 15:00:00'),

    -- Incident 3
    (3, 3, 'Started email format validation', '2026-10-01 11:15:00'),
    (3, 1, 'Identified invalid email patterns', '2026-10-01 13:00:00'),
    (3, 3, 'Proposed an email validation rule improvement', '2026-10-01 16:00:00'),

    -- Incident 4
    (4, 4, 'Investigating missing customer phone numbers', '2026-10-02 10:15:00'),
    (4, 5, 'Found incomplete contact data imports', '2026-10-02 12:30:00'),
    (4, 4, 'Recommended import validation improvements', '2026-10-02 15:00:00'),

    -- Incident 5
    (5, 5, 'Started customer address data review', '2026-10-02 11:15:00'),
    (5, 6, 'Identified missing postal codes and cities', '2026-10-02 13:00:00'),
    (5, 5, 'Prepared address correction requirements', '2026-10-02 16:00:00'),

    -- Incident 6
    (6, 6, 'Investigating sales order calculation errors', '2026-10-03 10:15:00'),
    (6, 1, 'Detected mismatches between orders and line items', '2026-10-03 12:00:00'),
    (6, 6, 'Identified calculation logic requiring correction', '2026-10-03 15:00:00'),

    -- Incident 7
    (7, 1, 'Started invalid sales order date investigation', '2026-10-03 11:15:00'),
    (7, 2, 'Found inconsistent date formatting in source data', '2026-10-03 13:00:00'),
    (7, 1, 'Recommended date validation controls', '2026-10-03 16:00:00'),

    -- Incident 8
    (8, 2, 'Started negative transaction amount investigation', '2026-10-04 10:15:00'),
    (8, 3, 'Identified incorrect transaction adjustments', '2026-10-04 12:00:00'),
    (8, 2, 'Prepared a transaction correction proposal', '2026-10-04 15:00:00'),

    -- Incident 9
    (9, 3, 'Started duplicate transaction reference analysis', '2026-10-04 11:15:00'),
    (9, 4, 'Identified duplicate reference generation', '2026-10-04 13:00:00'),
    (9, 3, 'Proposed transaction reference uniqueness validation', '2026-10-04 16:00:00'),

    -- Incident 10
    (10, 4, 'Investigating payment reconciliation mismatch', '2026-10-05 10:15:00'),
    (10, 5, 'Identified payment matching discrepancies', '2026-10-05 12:00:00'),
    (10, 4, 'Prepared payment reconciliation recommendations', '2026-10-05 15:00:00'),

    -- Incident 11
    (11, 5, 'Started product catalog review', '2026-10-06 10:15:00'),
    (11, 6, 'Identified products with missing names', '2026-10-06 12:00:00'),

    -- Incident 12
    (12, 6, 'Started inventory quantity investigation', '2026-10-06 11:15:00'),
    (12, 7, 'Found invalid negative stock quantities', '2026-10-06 13:00:00'),

    -- Incident 13
    (13, 7, 'Started product pricing review', '2026-10-06 12:15:00'),
    (13, 8, 'Identified invalid product price records', '2026-10-06 14:00:00'),

    -- Incident 14
    (14, 8, 'Started duplicate employee email review', '2026-10-07 10:15:00'),
    (14, 9, 'Found repeated employee contact information', '2026-10-07 12:00:00'),

    -- Incident 15
    (15, 9, 'Started employee data freshness analysis', '2026-10-07 11:15:00'),
    (15, 10, 'Identified outdated employee information', '2026-10-07 13:00:00'),

    -- Incident 16
    (16, 10, 'Investigating negative payroll values', '2026-10-07 12:15:00'),
    (16, 11, 'Identified incorrect payroll adjustments', '2026-10-07 14:00:00'),

    -- Incident 17
    (17, 11, 'Started financial reconciliation investigation', '2026-10-08 10:15:00'),
    (17, 12, 'Found financial report reconciliation differences', '2026-10-08 12:00:00'),

    -- Incident 18
    (18, 12, 'Started financial reporting deadline review', '2026-10-08 11:15:00'),
    (18, 1, 'Identified delays in report submission process', '2026-10-08 13:00:00'),

    -- Incident 19
    (19, 1, 'Started November customer email completeness review', '2026-11-01 10:15:00'),
    (19, 2, 'Identified newly imported customer records with missing emails', '2026-11-01 12:00:00'),

    -- Incident 20
    (20, 3, 'Reviewed unassigned duplicate customer email incident', '2026-11-01 11:15:00'),
    (20, 3, 'Recommended assigning an owner for further investigation', '2026-11-01 13:00:00');



-- Align fictional issue detection timestamps
-- with their associated quality check execution dates.

UPDATE "data_issues"
SET "detected_at" = (
    SELECT "qc"."check_date"
    FROM "quality_checks" AS "qc"
    WHERE "qc"."check_id" = "data_issues"."check_id"
);



-- Set realistic incident statuses for demonstration.

UPDATE "incidents"
SET "status" = 'In Progress'
WHERE "incident_id" IN (3, 8, 17);

-- Resolve selected incidents and trigger issue resolution.

UPDATE "incidents"
SET
    "status" = 'Resolved',
    "resolved_at" = CASE "incident_id"
        WHEN 11 THEN '2026-10-06 15:00:00'
        WHEN 12 THEN '2026-10-06 16:00:00'
        WHEN 14 THEN '2026-10-07 16:00:00'
        WHEN 15 THEN '2026-10-07 17:00:00'
        WHEN 18 THEN '2026-10-08 15:30:00'
    END,
    "resolution_description" = 'Sample incident resolved after investigation'
WHERE "incident_id" IN (11, 12, 14, 15, 18);



