{% macro refresh_external_tables() %}
  {% set db = target.database %}
  {% set schema = target.schema %}

  {% do run_query("ALTER EXTERNAL TABLE " ~ db ~ "." ~ schema ~ ".CAPSTONE_AMAZON_REVIEWS_EXT REFRESH") %}
  {% do run_query("ALTER EXTERNAL TABLE " ~ db ~ "." ~ schema ~ ".CAPSTONE_AMAZON_META_EXT REFRESH") %}
{% endmacro %}
