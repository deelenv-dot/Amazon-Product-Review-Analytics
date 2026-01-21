

select
    rating
from CAPSTONE_AMAZON_DB.CAPSTONE_AMAZON_STG.stg_reviews
where rating is not null
  and (rating < 1 or rating > 5)