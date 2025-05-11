-- This macro generates a schema name based on the node's path.
{% macro generate_schema_name(custom_schema_name, node) %}
    {% if custom_schema_name is not none %}
        {{ custom_schema_name }}
    {% elif 'silver' in node.path | lower %}
        silver_sch
    {% elif 'gold' in node.path | lower %}
        gold_sch
    {% else %}
        {{ target.schema | default('silver_sch') }}
    {% endif %}
{% endmacro %}