{{ 
    config(
        materialized='view',
        alias='dim_product',
        unique_key='product_id',
        description='Product dimension view with product details and price segments.',
    ) 
}}

{%- set price_segments = [
    {'max_price': 500, 'segment': 'Budget'},
    {'min_price': 500, 'max_price': 1000, 'segment': 'Mid-Range'},
    {'min_price': 1000, 'segment': 'Premium'}
] -%}

with products as (
    select * from {{ ref('products') }}
)

select
    p.product_id,
    p.product_name,
    p.brand_id,
    p.brand_name,
    p.category_id,
    p.category_name,
    p.model_year,
    p.list_price,
    -- case
    --     when p.list_price < 500 then 'Budget'
    --     when p.list_price between 500 and 1000 then 'Mid-Range'
    --     else 'Premium'
    -- end as price_segment
    CASE
        {% for segment in price_segments %}
            {% if segment.get('min_price') and segment.get('max_price') %}
                WHEN p.list_price >= {{ segment.min_price }} AND p.list_price < {{ segment.max_price }} THEN '{{ segment.segment }}'
            {% elif segment.get('max_price') %}
                WHEN p.list_price < {{ segment.max_price }} THEN '{{ segment.segment }}'
            {% elif segment.get('min_price') %}
                WHEN p.list_price >= {{ segment.min_price }} THEN '{{ segment.segment }}'
            {% endif %}
        {% endfor %}
        ELSE 'Unknown'
    END AS price_segment
from products p
