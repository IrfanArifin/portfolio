-- Seller Analysis

-- 21 Berapa jumlah seller?
SELECT COUNT(DISTINCT seller_id) AS total_seller FROM sellers;

-- 22. Berapa rata-rata revenue per Seller?
WITH rata_rata AS(
	SELECT 
		SUM(oi.price) AS total_revenue,
		COUNT(DISTINCT s.seller_id) AS total_seller
	FROM order_items oi
	JOIN sellers s
		ON oi.seller_id = s.seller_id
	JOIN orders o
		ON o.order_id = oi.order_id
	WHERE o.order_status = 'delivered'
)
SELECT 
	ROUND(total_revenue/total_seller, 2) AS avg_revenue_seller
FROM rata_rata;

-- 23. Bagaimana tren jumlah seller aktif per bulan, apakah bertambah atau menyusut?
SELECT
    DATE_TRUNC('month',o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT s.seller_id) AS seller
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN sellers s
	ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- 24. Siapa 10 Seller dengan revenue terbesar?
SELECT 
	DISTINCT(s.seller_id) AS seller,
	COUNT(DISTINCT o.order_id) AS total_order,
	SUM(oi.price) AS revenue
FROM sellers s
JOIN order_items oi
	ON s.seller_id = oi.seller_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- 25. State mana yang memiliki seller terbanyak?
SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY 1
ORDER BY 2 DESC;

-- 26. Berapa banyak seller berdasarkan distribusi rating
WITH seller_unique_reviews AS (
    -- 1. Deduplikasi agar 1 order hanya dihitung 1 ulasan per seller
    SELECT DISTINCT
        oi.seller_id,
        oi.order_id,
        r.review_score
    FROM order_items oi
    JOIN order_reviews r 
        ON oi.order_id = r.order_id
    JOIN orders o 
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
),
seller_summary AS (
    -- 2. Hitung rata-rata rating per seller dengan filter threshold
    SELECT 
        seller_id,
        COUNT(order_id) AS total_reviews,
        AVG(review_score) AS avg_review_score
    FROM seller_unique_reviews
    GROUP BY seller_id
    HAVING COUNT(order_id) >= 0 -- Batas threshold (bisa diganti 10, 50, atau 100)
),
seller_tiers AS (
    -- 3. Pengelompokan ke Rating Tier
    SELECT
        seller_id,
        avg_review_score,
        CASE
            WHEN avg_review_score >= 4.5 THEN 'Excellent (4.5 - 5.0)'
            WHEN avg_review_score >= 4.0 THEN 'Good (4.0 - 4.49)'
            WHEN avg_review_score >= 3.0 THEN 'At Risk (3.0 - 3.99)'
            ELSE 'Critical (< 3.0)'
        END AS rating_tier,
        CASE
            WHEN avg_review_score >= 4.5 THEN 1
            WHEN avg_review_score >= 4.0 THEN 2
            WHEN avg_review_score >= 3.0 THEN 3
            ELSE 4
        END AS sort_order
    FROM seller_summary
)
-- 4. Agregasi akhir untuk Donut Chart
SELECT 
    rating_tier,
    COUNT(seller_id) AS total_sellers,
    ROUND(COUNT(seller_id) * 100.0 / SUM(COUNT(seller_id)) OVER(), 2) AS percentage
FROM seller_tiers
GROUP BY rating_tier, sort_order
ORDER BY sort_order;