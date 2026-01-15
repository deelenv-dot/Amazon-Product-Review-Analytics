with source_data as (
    select
        coalesce(raw, value) as raw_variant
    from {{ source('capstone_raw', 'CAPSTONE_AMAZON_META_EXT') }}
)

select
    raw_variant:main_category::string as main_category,
    raw_variant:title::string as title,
    raw_variant:average_rating::float as average_rating,
    raw_variant:rating_number::number as rating_number,
    raw_variant:features as features,
    raw_variant:description as description,
    raw_variant:price::float as price,
    raw_variant:images as images,
    raw_variant:videos as videos,
    raw_variant:store::string as store,
    raw_variant:categories as categories,
    raw_variant:details as details,
    raw_variant:parent_asin::string as parent_asin,
    raw_variant:bought_together as bought_together
from source_data
