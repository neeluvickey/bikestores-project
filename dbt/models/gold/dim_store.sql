{{ 
    config(
        materialized='view',
        alias='dim_store',
        unique_key='store_id',
        description='Store dimension view with store details and contact information.',
    ) 
}}

with stores as (
    select * from {{ source('bronze_model', 'stores') }}
)

select
    s.store_id,
    s.store_name,
    s.phone,
    s.email,
    s.street,
    s.city,
    s.state,
    s.zip_code
from stores s
