{{ config(severity='warn') }}

select
    rating
from {{ ref('stg_reviews') }}
where rating is not null
  and (rating < 1 or rating > 5)
