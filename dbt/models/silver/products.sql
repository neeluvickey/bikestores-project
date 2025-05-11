{{ 
    config(
        materialized='view', 
        alias='products',
        unique_key='product_id',
        schema='silver_sch',
        description='Traansfomed product data with standardized names and prices.',
    )
}}

with products as (
    select * from {{ source('bronze_model', 'products') }}
),
brands as (
    select * from {{ source('bronze_model', 'brands') }}
),
categories as (
    select * from {{ source('bronze_model', 'categories') }}
),

final as (
    select 
        p.product_id,
        trim(p.product_name) as product_name,
        b.brand_id,
        trim(b.brand_name) as brand_name,
        c.category_id,
        trim(c.category_name) as category_name,
        p.model_year,
        cast(p.list_price as decimal(10,2)) as list_price
    from products p
    join brands b on p.brand_id = b.brand_id
    join categories c on p.category_id = c.category_id
)

select * from final
