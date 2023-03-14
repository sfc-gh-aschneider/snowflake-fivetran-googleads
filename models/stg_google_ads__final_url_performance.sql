with source as (

    select *
    from {{ ref('stg_google_ads__final_url_performance_tmp') }}

),

renamed as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_ads__final_url_performance_tmp')),
                staging_columns=get_final_url_performance_columns()
            )
        }}

    from source

), 

url_fields as (

    select
        *,
        {{ dbt_utils.split_part('final_url', "'?'", 1) }} as base_url,
        {{ dbt_utils.get_url_host('final_url') }} as url_host,
        '/' || {{ dbt_utils.get_url_path('final_url') }} as url_path,
        {{ dbt_utils.get_url_parameter('final_url', 'utm_source') }} as utm_source,
        {{ dbt_utils.get_url_parameter('final_url', 'utm_medium') }} as utm_medium,
        {{ dbt_utils.get_url_parameter('final_url', 'utm_campaign') }} as utm_campaign,
        {{ dbt_utils.get_url_parameter('final_url', 'utm_content') }} as utm_content,
        {{ dbt_utils.get_url_parameter('final_url', 'utm_term') }} as utm_term
    from renamed

), surrogate_key as (

    select
        *,
        {{ dbt_utils.surrogate_key(['date_day','campaign_id','ad_group_id','final_url']) }} as final_url_performance_id
    from url_fields

)

select * from surrogate_key