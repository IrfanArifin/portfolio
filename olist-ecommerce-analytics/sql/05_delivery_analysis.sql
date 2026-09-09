-- Delivery Analysis

-- Q15 Berapa rata-rata waktu pengiriman?
SELECT ROUND(AVG(EXTRACT(EPOCH FROM(order_delivered_customer_date - order_purchase_timestamp))/86400),2) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Q16 Berapa persentase order yang terlambat?
SELECT 
	COUNT(*) AS total_delivered_order,
	COUNT(*)FILTER(WHERE order_delivered_customer_date > order_estimated_delivery_date) AS late_order,
	ROUND(100.0 * COUNT(*)FILTER(WHERE order_delivered_customer_date > order_estimated_delivery_date)/ COUNT(*), 2) AS late_delivery_rate
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- Q17 State mana yang memiliki tingkat keterlambatan tertinggi?
SELECT 
	c.customer_state,
	COUNT(*) AS total_delivered_order,
	COUNT(*)FILTER(WHERE order_delivered_customer_date > order_estimated_delivery_date) AS late_order,
	ROUND(100.0 * COUNT(*)FILTER(WHERE order_delivered_customer_date > order_estimated_delivery_date)/ COUNT(*), 2) AS late_delivery_rate
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC;

-- Q18 Apakah keterlambatan berhubungan dengan review score?
WITH order_review AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS total_order,
    ROUND(AVG(orv.review_score),2) AS avg_review
FROM orders o
JOIN order_review orv
    ON o.order_id = orv.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY 1;