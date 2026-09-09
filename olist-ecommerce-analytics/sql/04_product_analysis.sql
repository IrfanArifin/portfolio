-- Product Analysis

-- Q11 Kategori mana yang menghasilkan revenue terbesar?
SELECT 
	COALESCE(pct.product_category_name_english, 'unknown') AS category,
	SUM(oi.price) AS total_revenue
FROM products p
LEFT JOIN product_category_translation pct 
	ON pct.product_category_name = p.product_category_name
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 2 DESC;

-- Q12 Produk apa yang paling banyak terjual?
SELECT
    p.product_id,
    COALESCE(pct.product_category_name_english,'unknown') AS category,
    COUNT(*) AS item_terjual
FROM product_category_translation pct
RIGHT JOIN products p
	ON pct.product_category_name = p.product_category_name
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

-- Q13 Produk apa yang menghasilkan revenue terbesar?
SELECT
    p.product_id,
    COALESCE(pct.product_category_name_english,'unknown') AS category,
    SUM(oi.price) AS total_revenue,
	COUNT(*) AS items_sold
FROM product_category_translation pct
RIGHT JOIN products p
	ON pct.product_category_name = p.product_category_name
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

-- Q14 Kategori mana yang memiliki order terbanyak?
SELECT
    COALESCE(pct.product_category_name_english,'unknown') AS category,
	COUNT(DISTINCT oi.order_id) AS total_order
FROM product_category_translation pct
RIGHT JOIN products p
	ON pct.product_category_name = p.product_category_name
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 2 DESC;

