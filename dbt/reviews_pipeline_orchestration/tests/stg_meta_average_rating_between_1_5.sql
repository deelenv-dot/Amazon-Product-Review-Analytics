{{ config(severity='warn') }}

select
    average_rating
from {{ ref('stg_meta') }}
where average_rating is not null
  and (average_rating < 1 or average_rating > 5)
