# Jaffle Shop Data Engineering Tech Test Challenges

Welcome to the Jaffle Shop Data Engineering Tech Test! This document outlines a series of escalating challenges designed to assess your skills in data engineering, SQL, dbt, and data architecture.

**Target Roles:** Data Engineer, Senior Data Engineer

**Time Estimate:** 5-7 hours for intermediate candidates, 3-4 hours for senior candidates

**Prerequisites:**
- Familiarity with dbt and SQL
- Understanding of data modeling concepts
- Comfort with command-line tools and Git

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

Challenges are organized by difficulty level and topic area. You should complete them in order, as they build on each other.

---

# LEVEL 1: FOUNDATIONS (SQL & dbt Basics)

## Challenge 1.1: Data Quality - Deduplication Using CTEs and Window Functions

**Difficulty:** Beginner-Intermediate

**Objective:** Identify and remove duplicate records in seed data using SQL

**Background:**
The raw seed data contains intentional duplicates to simulate real-world data quality issues. The order and product data contain exact duplicates that need to be cleaned.

**Task:**
1. **Analyze:** Query the `raw_orders` source to identify duplicate records using window functions (ROW_NUMBER or RANK)
   - How many duplicates exist?
   - Are they exact duplicates or near-duplicates?

2. **Create a staging model:** Create `stg_orders_deduplicated.sql`
   - Use CTEs to structure your logic
   - Implement a a solution to exclude duplicates
   - Keep only the latest occurrence of each duplicate group if possible 
   - Test: Add a generic test to ensure no duplicate order IDs exist in the output
   - Make use for the deduplicated version in other models

3. **Bonus:** 
   - Do the same for `stg_products_deduplicated.sql`
   - Document edge cases: What if ordering matters? How would you preserve the "correct" record if there were subtle differences?
   - Make use for the deduplicated version in other models
  
**Expected Output:**
- Clean staging models with no duplicates
- A working unique test that validates the deduplication logic
- SQL query documentation (comments) explaining your window function approach

---

## Challenge 1.2: Complex SQL - Regex Pattern Matching

**Difficulty:** Beginner-Intermediate

**Objective:** Extract and validate data using regular expressions

**Background:**
Product SKUs follow a pattern: `[CATEGORY]-[NUMBER]` (e.g., `JAF-001`, `BEV-002`). The product descriptions contain various formats of information that need to be extracted.

**Task:**
1. **Create a new model:** `models/staging/stg_products_parsed.sql`
   - Extract the category from the SKU using regex (JAF, BEV, etc.) Duckdb has regex functions
   - Extract the numeric portion from the SKU

2. **Add validation:**
   - Use `accepted_values` test for category field
   - Validate that numeric SKU is always 3 digits using regex in a custom test or query

3. **Bonus Challenge:**
   - Identify products with specific keywords in descriptions (e.g., "ghost pepper", "organic")
   - Create a product classification (Premium, Standard, Beverage) based on pattern matching

**Expected Output:**
- Parsed product model with extracted categories and ingredients
- Working YAML tests validating extracted values
- Comments explaining regex patterns used

---

# LEVEL 2: ARCHITECTURE & ADVANCED dbt (Medallion Pattern)

## Challenge 2.1: Medallion Architecture Implementation

**Difficulty:** Intermediate

**Objective:** Restructure the project to follow the Medallion architecture with proper model tagging

**Background:**
The current project has staging and marts layers, but they need to be reorganized into an explicit Bronze → Silver → Gold medallion pattern with proper governance tags.

**Task:**
1. **Restructure the folder hierarchy:**

2. **Migrate existing models:**
   - Move current models and add tagging for the layer

3. **Test the architecture:**
   - Run dbt models for each layer using the tags

**Expected Output:**
- Reorganized model folders following medallion pattern
- Updated dbt_project.yml with layer configurations
- All models execute without errors
- Ability to build by layer using tag selectors

---

## Challenge 2.2: Multiple Materializations

**Difficulty:** Intermediate

**Objective:** Implement models using different dbt materializations for specific use cases

**Background:**
Different model purposes require different materialization strategies. Understanding when to use views, tables, ephemeral models, and incremental models is crucial for optimization.

**Task:**

1. **Create models with specific materializations:**

   a. Ensure we have an example of each of the 4 main materializations in the dbt project.
      - For an incremental mode ensure we can process only new/changed orders and define unique_key and strategy

1. **Document materialization choices:**
   - Add comments to each model explaining why that materialization was chosen
   - Include performance considerations

2. **Test the models:**
   - Verify all materializations work correctly
   - Run `dbt run` and check that schemas contain expected objects (tables vs views)
   - Verify ephemeral model is compiled into its dependents

**Expected Output:**
- Four models using different materializations
- Model YAML with configuration documentation
- Comments explaining materialization strategy
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
   - Macro should raise an error if no columns are provided
   - Macro should handle edge cases (empty strings, special characters)

4. **Document the macro:**
   - Include Jinja comments explaining parameters and usage
   - Provide example outputs

5. **Test:**
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
   - For an Gold level Models add enforced models

2. **Test contract enforcement:**
   - Modify a model temporarily to return wrong column types
   - Verify that dbt fails with a contract violation error
   - Revert the change

**Expected Output:**
- Models with enforced contracts in YAML
- All models build successfully with contracts enabled
- Documentation explaining contract benefits

---

## Challenge 3.2: Unit Tests for Business Logic

**Difficulty:** Intermediate-Advanced

**Objective:** Add dbt unit tests to validate complex business logic

**Background:**
The project has existing unit tests for some models. Unit tests verify individual model logic without external dependencies, making them fast and reliable.

**Task:**

1. **Create a new model with business logic:** `int_customer_segment.sql`
   - Segment customers into tiers based on lifetime value:
     - Gold: lifetime_value >= $10,000
     - Silver: lifetime_value >= $5,000 and < $10,000
     - Bronze: lifetime_value < $5,000
   - Include order frequency metric (orders_count)
   - Calculate churn risk (no orders in last 90 days)

2. **Create unit tests in model YAML:**
   - Test case 1: Customer with high lifetime value should be Gold tier
   - Test case 2: Customer with no orders should be Bronze tier
   - Test case 3: Customer with recent order should not be marked as churned
   - Test case 4: Null lifetime_value should be handled gracefully

3. **Test edge cases:**
   - NULL values
   - Boundary conditions (exactly $10,000)
   - Missing data
   - Zero orders

4. **Run the unit tests:**
   - Execute: `dbt test --select model_name,test_type:unit`
   - Verify all tests pass

5. **Document the logic:**
   - Add SQL comments explaining segmentation thresholds
   - Note: Why those thresholds? What business rules drive them?

**Expected Output:**
- Model with segmentation logic
- 4+ unit tests in YAML
- All tests passing
- Documentation of business rules

---

# LEVEL 4: ADVANCED SQL & DATA EXTRACTION

## Challenge 4.1: Date Range Variables & SCD Type 2

**Difficulty:** Advanced

**Objective:** Build adjust the std orders model that uses date range variables

**Background:**
We may want to be able to rebuild a subset of data based on command line imports

**Task:**

1. **Adjust the stg_orders_deduplicated:** `stg_orders_deduplicated.sql`
   - Use dbt variables to define analysis date range:
     - `var('start_date')`: Beginning of data (default: '2024-09-01')
     - `var('end_date')`: End of data (default: current date)

2. **Implement incremental loading:**
   - Process only records within the date range
   - Use variables in the WHERE clause:


3. **Test with different date ranges:**
   - Run: `dbt run --select stg_orders_deduplicated --vars '{"start_date": "2024-09-01", "end_date": "2024-10-01"}'`
   - Verify results change based on date range

**Expected Output:**
- Model runs for a limited date range

---

## Challenge 4.2: JSON Extraction from Nested Audit Logs

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

**Difficulty:** Advanced

**Objective:** Build a SQL-based test to validate complex business rules

**Background:**
Beyond generic tests (not_null, unique), complex business rules require custom validation. For example, "ensure order total = subtotal + tax" requires custom logic. Creating a SQL test allows you to implement sophisticated data quality checks.

**Task:**

1. **Create a SQL test:** `data-tests/order_math_validation.sql`
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
   - Create a model: `data-tests/stg_order_math_failures.sql`
   - This model captures failed validation records:
     ```sql
     SELECT
       CURRENT_TIMESTAMP AS test_run_timestamp,
       'order_math_validation' AS test_name,
       order_id,
       subtotal,
       tax_paid,
       order_total,
       (subtotal + tax_paid) AS calculated_total,
       ABS(order_total - (subtotal + tax_paid)) AS variance
     FROM stg_orders
     WHERE ABS(order_total - (subtotal + tax_paid)) > 0.01
     ```
   - This creates an audit trail of data quality issues over time
   - Use this table to monitor test health and identify recurring issues

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
- Singular SQL test in `data-tests/`
- Test passes on clean data
- Bonus: Failure logging model that captures bad records
- Documentation of test logic and tolerances
- Demonstration of test catching a data quality issue

---

## Challenge 5.2: Data Visualization & Business Intelligence Reporting

**Difficulty:** Intermediate

**Objective:** Create a BI report using gold layer data to visualize business metrics

**Background:**
The gold layer contains cleaned, business-ready data. Visualizing this data helps stakeholders understand performance, trends, and key metrics. BI tools connect directly to your data warehouse to create interactive dashboards.

**Task:**

1. **Prepare Data for BI (if required):**
   - If your BI tool cannot connect directly to DuckDB, export gold layer tables:
     ```bash
     # Option A: Use DuckDB CLI
     duckdb jaffle-shop-challenge.duckdb -c "COPY (SELECT * FROM gold.orders) TO 'data/orders.parquet' (FORMAT PARQUET)"
     duckdb jaffle-shop-challenge.duckdb -c "COPY (SELECT * FROM gold.customers) TO 'data/customers.parquet' (FORMAT PARQUET)"
     ```
   - Export to CSV if Parquet not supported
   - **Note:** Only export if your BI tool requires it. Prefer direct DuckDB connections when possible.

2. **Build a Date Dimension Model:** 
   - Create a comprehensive date dimension for time-based analysis
   - You can use a SQL dbt model or DAX table
   - Include:
     - date_key (primary key)
     - date, year, month, quarter, day_of_week
     - is_weekend
   - Span: Full range of orders (e.g., 2024-09-01 to present)
   - Example rows:
     ```
     date_key | date       | year | month | quarter | day_of_week | is_weekend | 
     =========|============|======|=======|=========|=============|============|
     20240901 | 2024-09-01 | 2024 | 9     | Q3      | Sunday      | true       |
     20240902 | 2024-09-02 | 2024 | 9     | Q3      | Monday      | false      |
     ```

3. **Identify Facts and Dimensions:**
   - **Fact Tables** (measurable events):
     - `orders` - Individual transactions with amounts and dates
     - `order_items` - Line items with quantities and prices
   - **Dimension Tables** (descriptive attributes):
     - `dim_date` - Time periods
     - `dim_customers` - Customer attributes (segment, lifetime_value, etc.)
     - `dim_products` - Product attributes (category, price, etc.)
     - `dim_locations` (if applicable) - Store/location info

4. **Create a BI Report (Power BI Preferred, or alternative):**

   **Option A: Power BI (Preferred)**
   - Create a `.pbix` file or Power BI Desktop report
   - Import data:
     - If DuckDB connector available: Connect directly to DuckDB
     - Otherwise: Import exported Parquet/CSV files
   - Set up relationships
   - Create DAX measures (see below)
   - Build visualizations

   **Option B: Alternative BI Tools**
   - Looker Studio, Tableau, Superset, or similar
   - Same data model and relationships apply

5. **Implement DAX Measures (Power BI):**
   - or similar calculation in the tool of choice 
   -- Total Sales
   -- Order Count
   -- Average Order Value
   -- Customer Count

6. **Build Visualizations (at least 3):**
   - **1. Sales Trend Over Time**
     - Line chart: Date (X-axis) vs Total Sales (Y-axis)
     - Filtered by date range using slicer
   - **2. Top Products by Revenue**
     - Bar chart: Product name vs Revenue
     - Sorted descending, top 10
   - **3. Customer Segmentation**
     - Pie/donut chart: Customer segment vs Count
     - Or: Segment vs Revenue
   - **4. Bonus: Orders by Day of Week**
     - Column chart: Day of week vs Order count

7. **Add Interactive Filters:**
   - Date range slicer (from dim_date)
   - Product category filter
   - Customer segment filter
   - Store/location filter (if applicable)
   - Ensure filters work across all visualizations

8. **Document the Report:**
   - Include a cover page with:
     - Report name and purpose
     - Key metrics definitions
     - Filter instructions
   - Add tooltips to visualizations explaining metrics
   - Include data refresh information
   - Note any data quality assumptions

9.  **Bonus Enhancements:**
   -  Add measure for Month-over-Month Growth

   - Add KPI cards showing:
     - Total sales (current period)
     - Order count (current period)
     - Average order value
   - Create a drill-down: Click product → see individual orders
   - Add a date comparison (MoM)

**Expected Output:**
- Date dimension
- Power BI report (`.pbix` file) or equivalent BI tool report containing:
  - Proper data relationships and schema
  - 3+ visualizations
  - 5+ DAX measures or equivalent calculated fields
  - Interactive filters and slicers
  - Documentation and clear labeling
- Brief documentation explaining report structure and key insights

---

# CHALLENGE SUBMISSION CHECKLIST

Complete these challenges in order. As you work, verify:

- [ ] **Challenge 1.1** - Deduplication models created and deduplicated data verified
- [ ] **Challenge 1.2** - Regex parsing model created with validation tests
- [ ] **Challenge 2.1** - Models reorganized into Bronze/Silver/Gold with tags
- [ ] **Challenge 2.2** - Multiple materialization models created and working
- [ ] **Challenge 2.3** - Surrogate key macro implemented and used in models
- [ ] **Challenge 3.1** - Data contracts enforced on Gold models
- [ ] **Challenge 3.2** - Unit tests written for business logic
- [ ] **Challenge 4.1** - Date range variables implemented in models
- [ ] **Challenge 4.2** - JSON extraction from audit logs completed
- [ ] **Challenge 5.1** - SQL data quality test created and passing
- [ ] **Challenge 5.2** - BI report created with visualizations and measures

## Final Validation

After completing challenges, verify:

```bash
# Run full build
dbt build

# Run specific layers
dbt run --select tag:bronze
dbt run --select tag:silver
dbt run --select tag:gold

# Run all tests
dbt test

# Check unit tests
dbt test --select "test_type:unit"

# Check data quality tests
dbt test --select "order_math_validation"
```

All commands should execute without errors.

**Time Breakdown by Level:**
- **Level 1 (Challenges 1.1-1.2):** 1-1.5 hours
- **Level 2 (Challenges 2.1-2.3):** 1.5-2 hours
- **Level 3 (Challenges 3.1-3.2):** 1-1.5 hours
- **Level 4 (Challenges 4.1-4.2):** 1.5-2 hours
- **Level 5 (Challenges 5.1-5.2):** 1-1.5 hours
- **Total:** 5-7 hours (intermediate), 3-4 hours (senior)

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
- [dbt documentation](https://docs.getdbt.com)
- [DuckDB SQL documentation](https://duckdb.org/docs/sql/introduction)
- [dbt unit tests](https://docs.getdbt.com/docs/build/unit-tests)
- [dbt contracts](https://docs.getdbt.com/docs/collaborate/contracts)

---

**Good luck! This challenge tests your ability to design, implement, and validate data pipelines—core skills for any data engineer.**
