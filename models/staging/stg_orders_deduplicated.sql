{{ config(materialized='view') }}

with source_orders as (
    select *
    from {{ ref('stg_orders') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by ordered_at desc nulls last
        ) as rn
    from source_orders
)

select * exclude (rn)
from ranked
where rn = 1
