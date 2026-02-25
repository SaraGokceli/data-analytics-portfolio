/*
Objective:
Find the campaign with the highest total weekly value (record week and value).

Context:
Identify the single best-performing campaign-week combination across Google and Facebook.

Dataset:
facebook_ads_basic_daily + facebook_campaign
google_ads_basic_daily
*/

WITH fb AS (
    SELECT
        fabd.ad_date,
        'facebook' AS source,
        fc.campaign_name,
        fabd.value
    FROM facebook_ads_basic_daily AS fabd
    LEFT JOIN facebook_campaign AS fc
        ON fabd.campaign_id = fc.campaign_id
),

gl AS (
    SELECT
        gabd.ad_date,
        'google' AS source,
        gabd.campaign_name,
        gabd.value
    FROM google_ads_basic_daily AS gabd
),

all_ads AS (
    SELECT * FROM fb
    UNION ALL
    SELECT * FROM gl
),

weekly_campaign_value AS (
    SELECT
        DATE_TRUNC('week', ad_date)::date AS week_start,  -- haftanın başlangıç tarihi
        source,
        campaign_name,
        SUM(value) AS total_value
    FROM all_ads
    GROUP BY
        DATE_TRUNC('week', ad_date)::date,
        source,
        campaign_name
),

ranked AS (
    SELECT
        week_start,
        source,
        campaign_name,
        total_value,
        RANK() OVER (ORDER BY total_value DESC) AS rnk
    FROM weekly_campaign_value
)

SELECT
    week_start,
    source,
    campaign_name,
    total_value AS record_value
FROM ranked
WHERE rnk = 1;
