/*
Objective:
Find the ad set (Google + Facebook) with the longest continuous run of days
with impressions, and report the streak duration.

Context:
Identify consistently active ad sets to support campaign continuity analysis.

Dataset:
facebook_ads_basic_daily + facebook_adset
google_ads_basic_daily
*/
 
 WITH all_ads_data AS (
    -- 1) Facebook + adset_name
    SELECT
        CAST(fabd.ad_date AS date) AS ad_date,
        fa.adset_name,
        fabd.impressions
    FROM facebook_ads_basic_daily AS fabd
    LEFT JOIN facebook_adset AS fa
        ON fabd.adset_id = fa.adset_id

    UNION ALL

    -- 2) Google + adset_name (zaten tabloda var)
    SELECT
        CAST(gabd.ad_date AS date) AS ad_date,
        gabd.adset_name,
        gabd.impressions
    FROM google_ads_basic_daily AS gabd
),

-- 3) Her adset’in gösterim aldığı günleri tekilleştir (aynı gün için tek satır)
adset_days AS (
    SELECT
        ad_date,
        adset_name
    FROM all_ads_data
    WHERE adset_name IS NOT NULL
      AND impressions > 0          -- gerçekten gösterim aldığı günler
    GROUP BY
        ad_date,
        adset_name
),

-- 4) Her adset içinde tarih sıralı row_number
adset_days_with_rn AS (
    SELECT
        adset_name,
        ad_date,
        ROW_NUMBER() OVER (
            PARTITION BY adset_name
            ORDER BY ad_date
        ) AS rn
    FROM adset_days
),

-- 5) Ardışık serileri belirlemek için “grup anahtarı”
streaks AS (
    SELECT
        adset_name,
        ad_date,
        (ad_date::date - (rn::int * INTERVAL '1 day')) AS streak_group
    FROM adset_days_with_rn
),

-- 6) Her streak grubu için başlangıç, bitiş ve uzunluk
streak_summary AS (
    SELECT
        adset_name,
        MIN(ad_date) AS streak_start,
        MAX(ad_date) AS streak_end,
        COUNT(*)    AS streak_length
    FROM streaks
    GROUP BY
        adset_name,
        streak_group
)

-- 7) En uzun kesintisiz gösterim serisine sahip adset'i getir
SELECT
    adset_name,
    streak_start,
    streak_end,
    streak_length
FROM streak_summary
ORDER BY streak_length DESC
LIMIT 1;
