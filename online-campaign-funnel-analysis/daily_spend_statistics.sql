/*
Objective:
Evaluate daily advertising spend distribution.

Context:
Campaign performance analysis across paid channels.

Dataset:
facebook_ads_basic_daily
google_ads_basic_daily
*/

SELECT
    ad_date,
    AVG(spend) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM facebook_ads_basic_daily
GROUP BY ad_date
ORDER BY ad_date;

--Google için: Günlük ortalama, maksimum ve minimum spend

SELECT
    ad_date,
    AVG(spend) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM google_ads_basic_daily
GROUP BY ad_date
ORDER BY ad_date;
