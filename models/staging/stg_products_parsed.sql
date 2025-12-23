{{ config(materialized='view') }}

with source_products as (
    select *
    from {{ ref('stg_products_deduplicated') }}
)

select
    *,
    regexp_extract(product_id, '^([A-Z]+)-([0-9]+)$', 1) as sku_category,
    regexp_extract(product_id, '^([A-Z]+)-([0-9]+)$', 2) as sku_number
from source_products
