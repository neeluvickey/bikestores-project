{{ 
    config(
        materialized='view',
        alias='orders',
        unique_key='order_id',
        schema='silver_sch',
        description='Transformed order data with store and staff details.',
    )
}}

with orders as (
    select * from {{ source('bronze_model', 'orders') }}
),
stores as (
    select * from {{ source('bronze_model', 'stores') }}
),
staffs as (
    select * from {{ source('bronze_model', 'staffs') }}
),

final as (
    select 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.store_id,
        s.store_name,
        o.staff_id,
        st.first_name as staff_first_name,
        st.last_name as staff_last_name,
        datediff(day, o.order_date, coalesce(o.shipped_date, current_date())) as days_to_ship
    from orders o
    join stores s on o.store_id = s.store_id
    join staffs st on o.staff_id = st.staff_id
)

select * from final
