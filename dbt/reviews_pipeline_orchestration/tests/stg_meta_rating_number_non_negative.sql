{{ config(severity='warn') }}

select
    rating_number
from {{ ref('stg_meta') }}
where rating_number is not null
  and rating_number < 0
