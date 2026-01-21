

select
    average_rating
from CAPSTONE_AMAZON_DB.CAPSTONE_AMAZON_STG.stg_meta
where average_rating is not null
  and (average_rating < 1 or average_rating > 5)