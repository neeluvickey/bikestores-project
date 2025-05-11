{{ 
    config(
        materialized='view',
        alias='fact_sales',
        description='Sales fact table with order details, item details, and calculated net sales amount.',
    ) 
}}

with orders as (
    select * from {{ ref('orders') }}
),
order_items as (
    select * from {{ source('bronze_model', 'order_items') }}
)

select
    o.order_id,
    oi.item_id as order_item_id,
    cast(to_char(o.order_date, 'YYYYMMDD') as int) as order_date_id,
    o.customer_id,
    o.store_id,
    o.staff_id,
    oi.product_id,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price * (1 - oi.discount)) as net_sales_amount,
    o.order_status,
    o.days_to_ship
from orders o
join order_items oi on o.order_id = oi.order_id
