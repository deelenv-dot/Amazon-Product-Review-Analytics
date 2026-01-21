

select
    rating_number
from CAPSTONE_AMAZON_DB.CAPSTONE_AMAZON_STG.stg_meta
where rating_number is not null
  and rating_number < 0