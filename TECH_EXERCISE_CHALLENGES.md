# Jaffle Shop Data Engineering Technical Exercise

## How we expect you to approach this

Please treat this exercise as a timebox.

* **Timebox:** we recommend you timebox your work to 2–3 hours, unless you feel you would like to spend more time.
* **Minimum expectation:** complete Level 1 (Challenges 1.1 and 1.2).
* Then choose one or two additional challenges from Levels 2–5 that best show your strengths (**_doing more is optional if you have time_**).
* Bonus items are genuinely optional. We do not expect you to complete everything.
* We care most about your approach: how you frame the problem, make assumptions, prioritise, and communicate trade-offs.
* When your timebox ends, stop. Add a short note on what you would do next with more time.
* If setup/tooling issues get in the way, tell us what happened. We don't want environment setup to be the exercise.
* If anything is unclear in the brief, reply with questions — we’re happy to clarify.

---

Welcome to the Jaffle Shop Data Engineering technical exercise! This document outlines a series of escalating challenges designed to assess your skills in data engineering, SQL, dbt, and data architecture.

**Target Roles:** Data Engineer, Senior Data Engineer

**Time Estimate:** 2-3 hours (timebox)

**Prerequisites:**
- Familiarity with dbt and SQL
- Understanding of data modeling concepts
- Comfort with command-line tools and Git
- A visualisation tool like PowerBI

---

## Project Overview

The Jaffle Shop is a fictional e-commerce business selling specialty jaffles (Belgian waffles) and beverages. The project uses:
- **DuckDB** for data warehousing
- **dbt** for data transformation and testing

Current state:
- Raw seed data in DuckDB
- Staging models
- Mart models
- Existing tests and unit tests

---

## Challenge Structure

Start with Level 1. After that, pick the area that best shows your strengths. Some challenges build on others; if you skip ahead, mock inputs as needed and explain your assumptions.

---

# LEVEL 1: FOUNDATIONS (SQL & dbt Basics)

> **This is the baseline expectation.** Please complete both challenges in this level.

## Challenge 1.1: Data Quality - Deduplication Using CTEs and Window Functions

**Difficulty:** Beginner-Intermediate

**Objective:** Identify and remove duplicate records in seed data using SQL

> **Note:** We've provided schema definitions in `models/silver/silver_models.yml` that describe the expected columns and tests for `stg_orders_deduplicated`. Your task is to implement the SQL model that satisfies these contracts.

**Background:**
The raw seed data contains intentional duplicates to simulate real-world data quality issues. The order and product data contain exact duplicates that need to be cleaned.

**Task:**
1. **Analyze:** Query the `raw_orders` source to identify duplicate records using window functions (ROW_NUMBER or RANK)
   - How many duplicates exist?
   - Are they exact duplicates or near-duplicates?

2. **Create a staging model:** Create `stg_orders_deduplicated.sql`
   - Use CTEs to structure your logic
   - Implement a solution to exclude duplicates
   - Keep only the latest occurrence of each duplicate group if possible
   - Test: Add a generic test to ensure no duplicate order IDs exist in the output
   - Make use of the deduplicated version in other models

3. **Bonus:**
   - Do the same for `stg_products_deduplicated.sql`
   - Document edge cases: What if ordering matters? How would you preserve the "correct" record if there were subtle differences?
   - Make use of the deduplicated version in other models

**Expected Output:**
- Clean staging models with no duplicates
- A working unique test that validates the deduplication logic
- SQL query documentation (comments) explaining your window function approach

---

## Challenge 1.2: Complex SQL - Regex Pattern Matching

**Difficulty:** Beginner-Intermediate

**Objective:** Extract data using regular expressions (to be unit tested later)

> **Note:** We've provided schema definitions in `models/silver/silver_models.yml` that describe the expected columns and tests for `stg_products_parsed`. Your task is to implement the SQL model that satisfies these contracts.

**Background:**
Product SKUs follow a pattern: `[CATEGORY]-[NUMBER]` (e.g., `JAF-001`, `BEV-002`). You need to extract these components for downstream analysis.

**Task:**
1. **Create a new model:** `models/staging/stg_products_parsed.sql`
   - Extract the category from the SKU using regex (JAF, BEV, etc.) Duckdb has regex functions
   - Extract the numeric portion from the SKU

**Expected Output:**
- Parsed product model with extracted categories and numbers
- Comments explaining regex patterns used
- (Note: You will add Unit Tests for this logic in Challenge 3.2)

---

# LEVEL 2: ARCHITECTURE & ADVANCED dbt (Medallion Pattern)

## Challenge 2.1: Medallion Architecture & Project Tagging

**Difficulty:** Intermediate

**Objective:** Configure the project for Medallion architecture using `dbt_project.yml` configuration

**Background:**
The medallion architecture (Bronze/Silver/Gold) is partially configured in `dbt_project.yml`, but the folder structure is incomplete.

**Task:**
1. **Create the missing folder structure:**
   - The `models/bronze` and `models/gold` folders need to be created (`.gitkeep` placeholders exist)

2. **Migrate models to the appropriate layers:**
   - Migrate the legacy `staging` models to the `silver` folder (rename/refactor as needed)
   - Migrate the `marts` models to the `gold` folder

3. **Verify your changes work:**
   - Run `dbt run --select tag:silver` and confirm models build correctly
   - Run `dbt run --select tag:gold` and confirm models build correctly

**Expected Output:**
- Updated `dbt_project.yml` with folder-level tag configuration
- At least one model in Silver/Gold layers demonstrating the auto-tagging
- Ability to build by layer using tag selectors

---

## Challenge 2.2: Incremental Materialization

**Difficulty:** Intermediate

**Objective:** Implement an incremental model for efficiency

**Background:**
As data grows, full refreshes become too slow. We need to process only new or changed records.

**Task:**

1. **Create an incremental model:** `models/silver/silver_orders_incremental.sql`
   - Base this on your orders data.
   - Configure it as `materialized='incremental'`.
   - Define a `unique_key` to handle updates.
   - Implement the `is_incremental()` logic to filter for new records (e.g., based on order date or ingestion time).

2. **Document:**
   - Add comments explaining your incremental strategy (how you handle late-arriving data or updates).

**Expected Output:**
- One working incremental model
- Correct `is_incremental()` logic
- All tests passing

---

## Challenge 2.3: Surrogate Key Macro Implementation

**Difficulty:** Intermediate

**Objective:** Build a reusable macro for generating surrogate keys without hashing

**Background:**
Your organization requires surrogate keys that are human-readable and debuggable (not hashed). The existing `cents_to_dollars` macro shows the pattern for custom macros.

**Task:**

1. **Create macro:** `macros/generate_text_surrogate_key.sql`
   - Accepts multiple column names as input
   - Concatenates values with a separator (e.g., `||`)
   - Produces a deterministic, reproducible key
   - Does NOT hash the result (keeps it readable)
   - Handles NULL values gracefully (e.g., convert to 'NULL_VALUE' string)
   - Example usage: `{{ generate_text_surrogate_key(['customer_id', 'order_date']) }}`
     → `'50a2d1c4-d788-4498-a6f7|2024-09-01'`

2. **Use the macro in models:**
   - Create `int_customer_order_key.sql`
   - Use the macro to generate `customer_order_key` from `[customer_id, order_date]`
   - Use the macro to generate `customer_product_key` from `[customer_id, product_id]`

3. **Add error handling:**
   - Macro should handle edge cases (empty strings)

4. **Test:**
   - Create a test that validates surrogate keys are consistent (same inputs = same output)
   - Test that different inputs produce different keys

**Expected Output:**
- Working macro in `macros/` directory
- Models using the macro successfully
- Documentation and examples
- Tests validating key generation

---

# LEVEL 3: DATA CONTRACTS & UNIT TESTS

## Challenge 3.1: Implement dbt Contracts

**Difficulty:** Intermediate-Advanced

**Objective:** Define and enforce data contracts for Gold layer models

**Background:**
Data contracts ensure that downstream consumers (BI tools, APIs) have guaranteed column names, types, and nullability. They serve as an interface contract between the data team and data consumers.

**Task:**

1. **Add contracts to models:**
   - For Gold layer models, add enforced contracts

2. **Test contract enforcement:**
   - Modify a model temporarily to return wrong column types
   - Verify that dbt fails with a contract violation error
   - Revert the change

**Expected Output:**
- Models with enforced contracts in YAML
- All models build successfully with contracts enabled
- Documentation explaining contract benefits

---

## Challenge 3.2: Unit Tests for Logic

**Difficulty:** Advanced

**Objective:** Add dbt unit tests to validate your Regex parsing logic

**Background:**
In Challenge 1.2, you wrote regex to parse SKUs. Now, we need to guarantee this logic works for various edge cases using dbt's Unit Testing framework (available in dbt Core 1.8+).

**Task:**

1. **Add Unit Tests to `stg_products_parsed`:**
   - Define a unit test in your `schema.yml` (or `models.yml`).
   - **Mock inputs:** Create a few mock rows for `raw_products` (or the upstream source).
     - Case 1: Standard SKU (e.g., 'JAF-001') -> Expect Category 'JAF', Number '001'
     - Case 2: Different length (e.g., 'BEV-10') -> Expect Category 'BEV', Number '10'
     - Case 3: Edge case (e.g., 'FOOD-999')
   - **Expect output:** Define what the columns should look like after parsing.

2. **Run the unit tests:**
   - Execute: `dbt test --select stg_products_parsed,test_type:unit`
   - Verify all tests pass.

**Expected Output:**
- Unit test definition in YAML
- Passing tests verifying your regex logic

---

# LEVEL 4: ADVANCED SQL & DATA EXTRACTION

## Challenge 4.1: JSON Extraction from Nested Audit Logs

**Difficulty:** Advanced

**Objective:** Extract and analyze data from JSON-embedded audit logs

**Background:**
The `raw_order_audit_log` seed contains order audit events in JSON format. Each row contains event metadata and a JSON payload with nested order event details. You need to extract, transform, and analyze this nested data.

**Task:**

1. **Analyze the audit log structure:**
   - The raw_order_audit_log table contains:
     - event_id: Unique identifier
     - order_id: Associated order
     - event_timestamp: When the event occurred
     - event_type: Type of audit event (created, updated, cancelled, etc.)
     - event_payload: JSON field with event-specific data
   - Example payload structure:
     ```json
     {
       "order_id": "9bed808a-5074-4dfb-b1eb-388e2e60a6da",
       "previous_status": "pending",
       "new_status": "shipped",
       "changed_by": "system",
       "changes": {
         "status": {"old": "pending", "new": "shipped"},
         "ship_date": {"old": null, "new": "2024-09-05"}
       }
     }
     ```

2. **Create extraction model:** `stg_order_audit_events.sql`
   - Extract event_id, order_id, event_timestamp, event_type
   - Extract top-level JSON fields: previous_status, new_status, changed_by. Duckdb has json functions.
   - Unnest the "changes" object into separate rows (one per changed field)
   - For each change, extract: field_name, old_value, new_value
   - Example output row:
     ```
     order_id | field_name | old_value | new_value | event_timestamp
     =========|============|===========|===========|=================
     9bed...  | status     | pending   | shipped   | 2024-09-05 10:00
     ```

3. **Create analysis model:** `int_order_change_audit.sql`
   - Aggregate audit events to show order change history
   - For each order, show a timeline of changes
   - Include change frequency metrics (how many times was each order modified?)
   - Identify orders that changed status multiple times

4. **Test the extraction:**
   - Create tests validating:
     - No NULL order_ids in extracted data
     - event_payload contains valid JSON (handle parse errors gracefully)
     - All changes are captured in unnested output

5. **Bonus:**
   - Create a model that flags suspicious patterns:
     - Orders cancelled after being shipped
     - Orders with more than 5 status changes
     - Orders updated by non-system actors
   - Use `try_cast` or error handling to manage malformed JSON

**Expected Output:**
- Extraction model flattening nested JSON
- Analysis model with audit insights
- Tests for JSON parsing and data quality
- Comments explaining JSON extraction logic
- Documentation of assumptions (e.g., handling of NULL values in JSON)

---

# LEVEL 5: QUALITY & GOVERNANCE

## Challenge 5.1: SQL-Based Data Quality Test

**Difficulty:** Intermediate

**Objective:** Build a SQL-based test to validate complex business rules

**Background:**
Beyond generic tests (not_null, unique), complex business rules require custom validation. For example, "ensure order total = subtotal + tax" requires custom logic. Creating a SQL test allows you to implement sophisticated data quality checks.

**Task:**

1. **Create a SQL test:** `order_math_validation.sql`
   - Write SQL that validates: `order_total = subtotal + tax_paid` for all orders
   - Include a tolerance parameter for rounding (default: $0.01)
   - Return only rows that FAIL the validation
   - Include diagnostic information:
     ```sql
     SELECT
       order_id,
       subtotal,
       tax_paid,
       order_total,
       (subtotal + tax_paid) AS calculated_total,
       ABS(order_total - (subtotal + tax_paid)) AS variance
     FROM stg_orders
     WHERE ABS(order_total - (subtotal + tax_paid)) > 0.01
     ```
   - If query returns rows, the test FAILS (data quality issue found)
   - If query returns empty result, test PASSES (all math is correct)

2. **Bonus: Log Test Results to a Table**
   - Setup dbt to log the result of this test in a table

3. **Add the test to dbt:**
   - Apply as a `singular` test in your dbt configuration
   - Run: `dbt test --select order_math_validation`
   - Verify test passes in clean state

4. **Document the test:**
   - Add comments explaining tolerance parameter
   - Document expected behavior and failure cases
   - Include examples of what would cause the test to fail

5. **Test your test:**
   - Run test in clean state (should pass)
   - Manually corrupt a row (change order_total incorrectly)
   - Re-run test and verify it catches the issue
   - Check the failure logging table for the bad record
   - Revert the change

**Expected Output:**
- Singular SQL test
- Test passes on clean data
- Bonus: Failure logging model that captures bad records
- Documentation of test logic and tolerances
- Demonstration of test catching a data quality issue

---

## Challenge 5.2: BI Reporting (Core + Bonus)

**Difficulty:** Intermediate

**Objective:** Create a basic BI visualization to demonstrate end-to-end data delivery

**Background:**
Data Engineering doesn't stop at the database. We need to ensure data is usable for analytics.

**Task (Core):**

1. **Prepare Data:**
   - Ensure you have a `gold.orders` or similar final table ready.
   - Create a simple `dim_date` table (SQL dbt model or a PowerBI DAX table) to support time-series analysis.

2. **Build One Key Visualization:**
   - Connect a BI tool (Power BI Desktop, Tableau Public, or even Excel/Google Sheets) to your DuckDB or exported data.
   - Create a **Sales Trend Over Time** chart:
     - X-Axis: Date (Month/Week)
     - Y-Axis: Total Sales
   - Take a screenshot of this visualization and save it as `bi_report_screenshot.png`.

**Task (Bonus - Optional but Recommended):**

1. **Full Dashboard:**
   - Add **Top Products by Revenue** (Bar chart).
   - Add **Customer Segmentation** (Pie/Donut chart).
   - Add interactive filters (Date Slicer, Product Category).

2. **DAX/Calculations:**
   - Implement explicit measures for `Total Sales`, `Order Count`, and `Average Order Value`.

**Expected Output:**
- `bi_report_screenshot.png` showing at least the Sales Trend.
- (Bonus) A `.pbix` file or link to a more complete dashboard.

---

## Submission guide

Please include:
* What you completed (and what you chose not to complete within the timebox).
* How to run your work (the commands we should use to validate the parts you touched).
* Any assumptions you made and why.
* Any trade-offs or concerns you'd raise if this were going into production.
* What you would do next with more time.

## Validation guidance

* It's enough for the models/tests you worked on to run cleanly.
* You don't need to make the entire project perfect end-to-end if that isn't what you prioritised.

---

# HINTS & TIPS

## General Approach
1. Start with Level 1 - these build your SQL and dbt fundamentals
2. Don't skip documentation - it's part of your evaluation
3. Test frequently: `dbt run`, `dbt test`, `dbt build`
4. Use `dbt compile` to debug Jinja errors
5. Check `target/compiled/` for compiled SQL

## Debugging
- `dbt debug` - Verify dbt setup and DuckDB connection
- `dbt parse` - Check YAML syntax errors
- `dbt run --select model_name --debug` - Verbose output
- Check DuckDB file directly: `duckdb jaffle-shop-challenge.duckdb`


## Resources
- [dbt documentation](https://docs.getdbt.com) — dbt core docs and best practices.
- [DuckDB SQL documentation](https://duckdb.org/docs/sql/introduction) — DuckDB intro and SQL reference.
- [dbt unit tests](https://docs.getdbt.com/docs/build/unit-tests) — dbt's unit testing guide.
- [dbt contracts](https://docs.getdbt.com/docs/collaborate/contracts) — data contract docs.
- Visual Studio Code (IDE): https://code.visualstudio.com/ — lightweight, extensible editor. Useful extensions: Python, SQL, and dbt helper extensions (e.g., dbt Power User).
- DuckDB Studio / UI: https://duckdb.org/docs/tools/duckdb_studio — UI for exploring DuckDB files and running ad-hoc queries.
- Poetry (dependency manager): https://python-poetry.org/ — used here for Python and dbt dependency management.
- Jaffle Shop (official dbt demo repo): https://github.com/dbt-labs/jaffle_shop — canonical example to reference.
- DuckDB regex functions: https://duckdb.org/docs/sql/functions/regexp — reference for REGEXP-related functions used for SKU parsing and pattern extraction.
- DuckDB JSON functions: https://duckdb.org/docs/sql/functions/json — reference for JSON_EXTRACT, JSON_PARSE, and other JSON helpers used for audit log extraction.

---

**Good luck! This exercise assesses your ability to design, implement, and validate data pipelines—core skills for any data engineer.**
