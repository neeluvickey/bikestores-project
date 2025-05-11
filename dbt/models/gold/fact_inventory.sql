{{ 
    config(
        materialized='view',
        alias='fact_inventory',
        unique_key='product_id',
        description='Inventory fact table with product details, store details, and calculated inventory value.',
    ) 
}}

with stocks as (
    select * from {{ source('bronze_model', 'stocks') }}
),
products as (
    select * from {{ ref('products') }}
)

select
    cast(to_char(current_date, 'YYYYMMDD') as int) as snapshot_date_id,
    i.product_id,
    i.store_id,
    i.quantity,
    p.list_price,
    (i.quantity * p.list_price) as inventory_value
from stocks i
join products p on i.product_id = p.product_id
