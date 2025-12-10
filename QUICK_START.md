# Tech Test Setup & Quick Start Guide

Welcome to the Jaffle Shop Data Engineering Tech Test! This guide will help you get started.

## Setup Steps

### 1. Install Dependencies
```bash
poetry install
poetry self add poetry-plugin-shell
```

### 2. Configure dbt Profile
Ensure your `~/.dbt/profiles.yml` has:
```yaml
default:
  outputs:
    local:
      type: duckdb
      path: "jaffle-shop-challenge.duckdb"
      threads: 1
      keep_open: true
  target: local
```

### 3. Seed the Data
```bash
dbt seed --full-refresh --vars '{"load_source_data": true}'
```

### 4. Verify Setup
```bash
dbt debug
dbt parse
```

## Project Structure

```
jaffle-shop/
├── TECH_TEST_CHALLENGES.md     <- **START HERE** - All challenge details
├── TESTING_STRATEGY.md          <- Document your testing approach
├── dbt_project.yml              <- Main dbt configuration
├── models/
│   ├── bronze/                  <- Direct source mappings (new)
│   ├── silver/                  <- Business logic & enrichment (new)
│   ├── gold/                    <- Analysis-ready data (new)
│   ├── staging/                 <- Legacy staging layer
│   └── marts/                   <- Legacy mart layer
├── macros/
│   ├── cents_to_dollars.sql     <- Example macro
│   └── generate_text_surrogate_key.sql  <- Challenge 2.3 template
├── data-tests/
│   └── generic/                 <- Custom test macros
├── seeds/
│   └── jaffle-data/             <- CSV seed files (with intentional duplicates)
└── dbt_packages/                <- External packages (audit_helper, dbt_date, dbt_utils)
```

## Current State

The project builds successfully but has **2 intentional failing tests** (duplicate products and orders):
- `unique_stg_orders_order_id` ❌
- `unique_stg_products_product_id` ❌

These failures are expected! Challenge 1.1 asks you to fix them.

## Key Technologies

| Component | Technology |
|-----------|-----------|
| Data Warehouse | DuckDB (embedded SQLite alternative) |
| Transformation | dbt (data build tool) |
| Language | SQL + Jinja templating |
| Version Control | Git |

## Useful dbt Commands

```bash
# Parse YAML and check syntax
dbt parse

# Run models in specific layer
dbt run --select tag:bronze
dbt run --select tag:silver
dbt run --select tag:gold

# Run all tests
dbt test

# Run specific test
dbt test --select model_name

# Run unit tests only
dbt test --select "test_type:unit"

# Build entire project (seeds + models + tests)
dbt build

# Compile models without running
dbt compile

# Debug with verbose output
dbt run --select model_name --debug

# View compiled SQL
cat target/compiled/jaffle_shop/models/.../model_name.sql
```

## Challenge Approach

1. **Read** `TECH_TEST_CHALLENGES.md` carefully - each challenge has detailed instructions
2. **Start with Level 1** - SQL fundamentals before architectural patterns
3. **Test frequently** - Run `dbt build` after each model
4. **Document your work** - Add comments explaining your approach
5. **Reference errors** - Check `target/compiled/` for compiled SQL if debugging

## Accessing the Database

If you want to query the database directly:

```bash
# Start DuckDB REPL
duckdb jaffle-shop-challenge.duckdb

# In DuckDB:
SELECT * FROM bronze.raw_customers LIMIT 10;
SELECT * FROM staging.stg_orders LIMIT 10;
```

## Challenge Checklist Template

Keep track of what you've completed:

```markdown
## Progress Tracking

### Level 1: Foundations
- [ ] Challenge 1.1: Deduplication (CTEs, window functions)
- [ ] Challenge 1.2: Regex parsing (pattern matching)

### Level 2: Architecture & Advanced dbt
- [ ] Challenge 2.1: Medallion architecture
- [ ] Challenge 2.2: Multiple materializations
- [ ] Challenge 2.3: Surrogate key macro

### Level 3: Data Contracts & Unit Tests
- [ ] Challenge 3.1: dbt contracts
- [ ] Challenge 3.2: Unit tests

### Level 4: Advanced SQL & Data Extraction
- [ ] Challenge 4.1: SCD Type 2 with date ranges
- [ ] Challenge 4.2: JSON extraction

### Level 5: Quality & Governance
- [ ] Challenge 5.1: Custom data quality tests
- [ ] Challenge 5.2: Testing strategy documentation
```

## Troubleshooting

### "Could not find profile"
Ensure `profiles.yml` is in `~/.dbt/` and has correct path to `jaffle-shop-challenge.duckdb`

### "Compilation errors in Jinja"
Use `dbt parse` to get better error messages. Check `target/compiled/` for compiled SQL.

### "Tests are failing"
This is expected! Use `dbt test --select test_name --debug` to see what's wrong.

### "Template syntax errors"
The challenge template files intentionally have incomplete code. Follow the inline comments (marked with `TODO`) to complete them.

## Tips for Success

1. **Read the comments** in template models - they contain hints
2. **Test incrementally** - Don't build all at once, test after each change
3. **Use the sandbox** - This is your chance to learn without production pressure
4. **Documentation matters** - Comments and YAML descriptions are part of your evaluation
5. **Edge cases** - Think about NULLs, empty sets, boundary conditions
6. **Performance** - Simple, readable SQL beats complex one-liners

## Resources

- [dbt Documentation](https://docs.getdbt.com)
- [DuckDB SQL Guide](https://duckdb.org/docs/sql/introduction)
- [dbt Unit Tests](https://docs.getdbt.com/docs/build/unit-tests)
- [dbt Contracts](https://docs.getdbt.com/docs/collaborate/contracts)
- [Regex Patterns](https://www.regular-expressions.info/) (for Challenge 1.2)

---

**Ready to begin?** Open `TECH_TEST_CHALLENGES.md` and start with Challenge 1.1!

Good luck! 🚀
