-- Review Analysis

-- Q19 Bagaimana distribusi review score?
SELECT
	review_score,
	COUNT(*) AS total_review,
	ROUND(100.0 * COUNT(*)/ (SELECT COUNT(*)FROM order_reviews),2 ) AS percentage
FROM order_reviews
GROUP BY 1
ORDER BY 1;

-- Q20 Kategori Produk dengan Tingkat Kepuasan Terbaik/Terendah
WITH order_category AS (
    SELECT DISTINCT
        oi.order_id,
        p.product_category_name
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
),

category_reviews AS (
    SELECT
        oc.order_id,
        oc.product_category_name,
        r.review_id,
        r.review_score
    FROM order_category oc
    JOIN order_reviews r
        ON oc.order_id = r.order_id
)
SELECT
    COALESCE(pct.product_category_name_english,'unknown') AS category,
    COUNT(DISTINCT cr.review_id) AS total_reviews,
    ROUND(AVG(cr.review_score),2) AS avg_review_score
FROM category_reviews cr
LEFT JOIN product_category_translation pct
    ON cr.product_category_name =
       pct.product_category_name
GROUP BY
    pct.product_category_name_english
HAVING COUNT(DISTINCT cr.review_id) >= 100
ORDER BY
    avg_review_score DESC;