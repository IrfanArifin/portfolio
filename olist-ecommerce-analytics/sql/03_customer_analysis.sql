-- Customer Analysis

-- Q6 Berapa jumlah customer?
SELECT COUNT(DISTINCT customer_unique_id) AS total_customer
FROM customers;

-- Q7 Berapa repeat order customer dan repeat purchase rate?
WITH customer_order AS
	(SELECT 
		c.customer_unique_id,
		COUNT(DISTINCT o.order_id) AS total_order
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY 1
	ORDER BY 2 DESC)
SELECT
	COUNT(*) AS total_customer,
	COUNT(*) FILTER (WHERE total_order > 1) AS repeat_order,
	(100.0 * COUNT(*) FILTER (WHERE total_order > 1)/COUNT(*)) AS repeat_purchase_rate
FROM customer_order;

-- Q8 Berapa rata-rata revenue customer?
WITH customer_order AS(
	SELECT 
		c.customer_unique_id,
		SUM(oi.price) AS total_revenue
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	JOIN order_items oi
		ON o.order_id = oi.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY 1
	ORDER BY 2 DESC
	)
SELECT AVG(total_revenue) AS rata_rata_revenue_per_customer
FROM customer_order;

-- Q9 Siapa 10 customer dengan revenue terbesar? 
SELECT
	c.customer_unique_id,
	COUNT(DISTINCT oi.order_id) AS total_order,
	SUM(oi.price) AS total_revenue
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Q10 State mana yang memiliki customer terbanyak?
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY 1
ORDER BY 2 DESC;