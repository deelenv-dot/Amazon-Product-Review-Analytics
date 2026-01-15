with source_data as (
    select
        coalesce(raw, value) as raw_variant
    from {{ source('capstone_raw', 'CAPSTONE_AMAZON_REVIEWS_EXT') }}
)

select
    raw_variant:rating::float as rating,
    raw_variant:title::string as title,
    raw_variant:text::string as text,
    raw_variant:images as images,
    raw_variant:asin::string as asin,
    raw_variant:parent_asin::string as parent_asin,
    raw_variant:user_id::string as user_id,
    case
        when raw_variant:timestamp::number >= 1000000000000000000 then raw_variant:timestamp::number / 1000000000
        when raw_variant:timestamp::number >= 1000000000000000 then raw_variant:timestamp::number / 1000000
        when raw_variant:timestamp::number >= 1000000000000 then raw_variant:timestamp::number / 1000
        else raw_variant:timestamp::number
    end as review_timestamp,
    raw_variant:verified_purchase::boolean as verified_purchase,
    raw_variant:helpful_vote::number as helpful_vote
from source_data
