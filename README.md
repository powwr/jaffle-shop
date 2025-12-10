# Powwr Jaffle Shop Challenge — Setup (dbt + DuckDB)

This README explains how to set up the local environment, configure dbt to use DuckDB, and load the project's default seed data.

This Project is a folk of the std dbt repo https://github.com/dbt-labs/jaffle-shop

## Prerequisites
- Git
- Python 3.9+
- Poetry
- dbt-core and dbt-duckdb (installed via Poetry or pip)

## Quick setup (recommended)
1. Clone the repo and enter it:
   ```bash
   git clone https://github.com/pwr-philarmstrong/jaffle-shop.git
   cd jaffle-shop
   ```

2. Install Poetry (if not installed):
   ```bash
   pip install --user poetry
   ```
   (or follow https://python-poetry.org/docs/#installation)

3. Install project dependencies:
   ```bash
   poetry install
   poetry self add poetry-plugin-shell
   ```

4. Activate the virtual environment (optional):
   ```bash
   
   poetry shell
   ```
   Or prefix commands with `poetry run` (e.g., `poetry run dbt debug`)


## Configure dbt to use DuckDB
- Create or update your dbt profiles file at `%USERPROFILE%\.dbt\profiles.yml` (Windows) or `~/.dbt/profiles.yml` (macOS / Linux).
- Example minimal `profiles.yml` for this project or copy from sample_profiles.yml:

```yaml
# Example: ~/.dbt/profiles.yml
default:
  outputs:        
    local:
      type: duckdb
      path: "jaffle-shop-challenge.duckdb"
      threads: 1
      keep_open: true
  target: local
```

## Verify dbt setup
- ```bash
  dbt debug
  ```
- You should see connection success for the DuckDB target.

## Load default data (seed) and build
1. Seed the project (this loads the default CSV/seed data used by the models):
   ```bash
   dbt seed --full-refresh --vars '{"load_source_data": true}'
   ```

2. Build the project (runs models, tests, analyses as configured):
   ```bash
   dbt build
   ```


