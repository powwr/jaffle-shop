{{ config(materialized='view') }}

with source_products as (
    select *
    from {{ ref('stg_products') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by product_id
            order by product_id
        ) as rn
    from source_products
)

select * exclude (rn)
from ranked
where rn = 1
