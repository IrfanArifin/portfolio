-- Sales Performance

-- Q1. Berapa total revenue(pendapatan) yang dihasilkan dari order yang berhasil?
SELECT 
	SUM(price) AS revenue 
FROM order_items oi
JOIN orders o
	ON oi.order_id=o.order_id
WHERE o.order_status='delivered';

-- Q2. Bagaimana tren revenue dari waktu ke waktu?
SELECT
    DATE_TRUNC('month',o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- Q3. Bagaimana tren jumlah order setiap bulan?
SELECT
    DATE_TRUNC('month',order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- Q4. Berapa Average Order Value (AOV)?
SELECT 
	ROUND(SUM(oi.price)/COUNT(DISTINCT o.order_id),2) AS average_order_value 
FROM order_items oi
JOIN orders o
	ON oi.order_id=o.order_id
WHERE o.order_status='delivered';

-- Q5. Negara bagian mana yang menghasilkan revenue terbesar?
SELECT 
	c.customer_state, 
	SUM(oi.price) AS revenue, 
	COUNT(DISTINCT o.order_id) AS total_order, 
	COUNT(DISTINCT c.customer_unique_id) AS total_customer
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 2 DESC;
