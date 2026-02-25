/*
Objective:
Identify the campaign with the largest month-over-month increase in reach.

Context:
Detect campaigns with the strongest growth momentum by comparing monthly reach totals.

Dataset:
facebook_ads_basic_daily + facebook_campaign
google_ads_basic_daily
*/
WITH fb AS (
    SELECT
        fabd.ad_date,
        fc.campaign_name,
        fabd.reach
    FROM facebook_ads_basic_daily AS fabd
    LEFT JOIN facebook_campaign AS fc
        ON fabd.campaign_id = fc.campaign_id
),

gl AS (
    SELECT
        gabd.ad_date,
        gabd.campaign_name,
        gabd.reach
    FROM google_ads_basic_daily AS gabd
),

all_ads AS (
    SELECT * FROM fb
    UNION ALL
    SELECT * FROM gl
),

-- 1) Kampanya bazında aylık toplam reach
monthly_reach AS (
    SELECT
        DATE_TRUNC('month', ad_date)::date AS month_start,
        campaign_name,
        SUM(reach) AS total_reach
    FROM all_ads
    WHERE campaign_name IS NOT NULL
    GROUP BY DATE_TRUNC('month', ad_date)::date, campaign_name
),

-- 2) Bir önceki ay ile karşılaştırma (LAG)
reach_with_diff AS (
    SELECT
        campaign_name,
        month_start,
        total_reach,
        LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY month_start) AS prev_month_reach
    FROM monthly_reach
),

-- 3) Artış hesaplama
reach_increase AS (
    SELECT
        campaign_name,
        month_start,
        total_reach,
        prev_month_reach,
        (total_reach - prev_month_reach) AS reach_diff
    FROM reach_with_diff
    WHERE prev_month_reach IS NOT NULL    -- ilk aylar karşılaştırılamaz
)

-- 4) En büyük artış yaşayan kampanya
SELECT
    campaign_name,
    month_start,
    reach_diff AS reach_increase
FROM reach_increase
ORDER BY reach_diff DESC
LIMIT 1;
