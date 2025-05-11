{{ 
    config(
        materialized='view', 
        alias='dim_customer',
        unique_key='customer_id',
        description='Customer dimension view with standardized phone and zip code formats, and region classification.',
    ) 
}}

{%- set region_mapping = {
    'Northeast': ['NY', 'NJ', 'CT'],
    'West': ['CA', 'OR', 'WA']
} -%}

with customers as (
    select * from {{ ref('customers') }}
)

select
    customer_id,
    first_name,
    last_name,
    standardized_phone,
    email,
    street,
    city,
    state,
    zip_code,
    -- case
    --     when state in ('NY', 'NJ', 'CT') then 'Northeast'
    --     when state in ('CA', 'OR', 'WA') then 'West'
    --     -- Add more regions as needed
    --     else 'Other'
    -- end as region
    CASE
        {% for region, states in region_mapping.items() %}
            WHEN state IN ('{{ states | join("', '") }}') THEN '{{ region }}'
        {% endfor %}
        ELSE 'Other'
    END AS region
from customers
