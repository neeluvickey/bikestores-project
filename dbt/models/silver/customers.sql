{{ 
    config(
        materialized='view',
        alias='customers',
        unique_key='customer_id',
        description='Transformed customer data with standardized phone and zip code formats.',
    ) 
}}

with source as (
    select * from {{ source('bronze_model', 'customers') }}
),

final as (
    select 
        customer_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        case 
            when phone is null then 'Unknown'
            else regexp_replace(phone, '[^0-9]', '')
        end as standardized_phone,
        trim(email) as email,
        trim(street) as street,
        trim(city) as city,
        trim(state) as state,
        case 
            when zip_code rlike '^\\d{5}(-\\d{4})?$' then zip_code
            else null
        end as zip_code
    from source
)

select * from final
