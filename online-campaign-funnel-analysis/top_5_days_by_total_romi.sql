/*
Objective:
Identify the top 5 days with the highest total ROMI across Google and Facebook.

Context:
Cross-channel campaign performance analysis to highlight peak efficiency days.

Dataset:
facebook_ads_basic_daily (ad_date, spend, value)
google_ads_basic_daily  (ad_date, spend, value)
*/

WITH fb AS (
    SELECT
        fabd.ad_date,
        fabd.spend,
        fabd.value
    FROM facebook_ads_basic_daily AS fabd
    LEFT JOIN facebook_adset AS fa
        ON fabd.adset_id = fa.adset_id
    LEFT JOIN facebook_campaign AS fc
        ON fabd.campaign_id = fc.campaign_id
),

gl AS (
    SELECT
        gabd.ad_date,
        gabd.spend,
        gabd.value
    FROM google_ads_basic_daily AS gabd
),

combined AS (
    SELECT * FROM fb
    UNION ALL
    SELECT * FROM gl
)

SELECT
    ad_date,
    ((SUM(value)::numeric - SUM(spend)::numeric) / SUM(spend)::numeric) * 100 AS romi
FROM combined
GROUP BY ad_date
HAVING SUM(spend) > 0
ORDER BY romi DESC
LIMIT 5;
