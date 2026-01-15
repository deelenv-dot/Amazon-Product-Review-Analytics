with reviews as (
    select
        r.parent_asin,
        store,
        review_timestamp,
        rating
    from {{ ref('stg_reviews') }} r
    left join {{ ref('stg_meta') }} m
      on r.parent_asin = m.parent_asin
    where r.verified_purchase = true
),

final as (
    select
        store,
        date_part('year', to_timestamp(review_timestamp)) as review_year,
        avg(rating) as avg_rating,
        count(*) as total_ratings
    from reviews
    group by store, review_year
)

select * from final
