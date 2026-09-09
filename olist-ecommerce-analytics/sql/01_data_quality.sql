-- ============================================================
-- OLIST E-COMMERCE ANALYTICS
-- DATA QUALITY CHECK
-- Database : olist_analytics
-- ============================================================


-- ============================================================
-- 1. CHECK TOTAL ROWS SETIAP TABLE
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'product_category_translation', COUNT(*)
FROM product_category_translation

ORDER BY table_name;


-- ============================================================
-- 2. CHECK NULL VALUES
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 Customers
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS customer_id_filled,
    COUNT(customer_unique_id) AS customer_unique_id_filled,
    COUNT(customer_zip_code_prefix) AS zip_code_filled,
    COUNT(customer_city) AS city_filled,
    COUNT(customer_state) AS state_filled
FROM customers;


-- ------------------------------------------------------------
-- 2.2 Orders
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(customer_id) AS customer_id_filled,
    COUNT(order_status) AS order_status_filled,
    COUNT(order_purchase_timestamp) AS purchase_date_filled,
    COUNT(order_approved_at) AS approved_date_filled,
    COUNT(order_delivered_carrier_date) AS carrier_date_filled,
    COUNT(order_delivered_customer_date) AS delivered_date_filled,
    COUNT(order_estimated_delivery_date) AS estimated_date_filled
FROM orders;


-- ------------------------------------------------------------
-- 2.3 Order Items
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(order_item_id) AS order_item_id_filled,
    COUNT(product_id) AS product_id_filled,
    COUNT(seller_id) AS seller_id_filled,
    COUNT(shipping_limit_date) AS shipping_limit_filled,
    COUNT(price) AS price_filled,
    COUNT(freight_value) AS freight_value_filled
FROM order_items;


-- ------------------------------------------------------------
-- 2.4 Order Payments
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(payment_sequential) AS payment_sequential_filled,
    COUNT(payment_type) AS payment_type_filled,
    COUNT(payment_installments) AS installments_filled,
    COUNT(payment_value) AS payment_value_filled
FROM order_payments;


-- ------------------------------------------------------------
-- 2.5 Order Reviews
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(review_id) AS review_id_filled,
    COUNT(order_id) AS order_id_filled,
    COUNT(review_score) AS review_score_filled,
    COUNT(review_comment_title) AS comment_title_filled,
    COUNT(review_comment_message) AS comment_message_filled,
    COUNT(review_creation_date) AS creation_date_filled,
    COUNT(review_answer_timestamp) AS answer_timestamp_filled
FROM order_reviews;


-- ------------------------------------------------------------
-- 2.6 Products
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(product_id) AS product_id_filled,
    COUNT(product_category_name) AS category_filled,
    COUNT(product_name_lenght) AS name_length_filled,
    COUNT(product_description_lenght) AS description_length_filled,
    COUNT(product_photos_qty) AS photos_qty_filled,
    COUNT(product_weight_g) AS weight_filled,
    COUNT(product_length_cm) AS length_filled,
    COUNT(product_height_cm) AS height_filled,
    COUNT(product_width_cm) AS width_filled
FROM products;


-- ------------------------------------------------------------
-- 2.7 Sellers
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(seller_id) AS seller_id_filled,
    COUNT(seller_zip_code_prefix) AS zip_code_filled,
    COUNT(seller_city) AS city_filled,
    COUNT(seller_state) AS state_filled
FROM sellers;


-- ============================================================
-- 3. CHECK DUPLICATES
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 Duplicate customer_id
-- ------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3.2 Duplicate customer_unique_id
-- ------------------------------------------------------------

SELECT
    customer_unique_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3.3 Duplicate order_id
-- ------------------------------------------------------------

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3.4 Duplicate product_id
-- ------------------------------------------------------------

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3.5 Duplicate seller_id
-- ------------------------------------------------------------

SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ------------------------------------------------------------
-- 3.6 Duplicate order_reviews
-- ------------------------------------------------------------
-- review_id pada Olist tidak selalu unik.
-- Oleh karena itu kita cek kombinasi review_id + order_id.

SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 4. CHECK INVALID VALUES
-- ============================================================


-- ------------------------------------------------------------
-- 4.1 Review score harus berada antara 1 sampai 5
-- ------------------------------------------------------------

SELECT *
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;


-- ------------------------------------------------------------
-- 4.2 Price tidak boleh negatif atau nol
-- ------------------------------------------------------------

SELECT *
FROM order_items
WHERE price <= 0;


-- ------------------------------------------------------------
-- 4.3 Freight value tidak boleh negatif
-- ------------------------------------------------------------

SELECT *
FROM order_items
WHERE freight_value < 0;


-- ------------------------------------------------------------
-- 4.4 Payment value tidak boleh negatif
-- ------------------------------------------------------------

SELECT *
FROM order_payments
WHERE payment_value < 0;


-- ------------------------------------------------------------
-- 4.5 Payment installments tidak boleh kurang dari 1
-- ------------------------------------------------------------

SELECT *
FROM order_payments
WHERE payment_installments < 1;


-- ------------------------------------------------------------
-- 4.6 Product weight tidak boleh negatif
-- ------------------------------------------------------------

SELECT *
FROM products
WHERE product_weight_g < 0;


-- ------------------------------------------------------------
-- 4.7 Product dimensions tidak boleh negatif
-- ------------------------------------------------------------

SELECT *
FROM products
WHERE product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;


-- ============================================================
-- 5. CHECK REFERENTIAL INTEGRITY
-- ============================================================


-- ------------------------------------------------------------
-- 5.1 Orders tanpa customer
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ------------------------------------------------------------
-- 5.2 Order items tanpa order
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ------------------------------------------------------------
-- 5.3 Order items tanpa product
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ------------------------------------------------------------
-- 5.4 Order items tanpa seller
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- ------------------------------------------------------------
-- 5.5 Payments tanpa order
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ------------------------------------------------------------
-- 5.6 Reviews tanpa order
-- ------------------------------------------------------------

SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ------------------------------------------------------------
-- 5.7 Product translation tanpa product category
-- ------------------------------------------------------------

SELECT
    pct.product_category_name
FROM product_category_name_translation pct
LEFT JOIN products p
    ON pct.product_category_name =
       p.product_category_name
WHERE p.product_category_name IS NULL;


-- ============================================================
-- 6. CHECK DATE CONSISTENCY
-- ============================================================


-- ------------------------------------------------------------
-- 6.1 Approved date sebelum purchase date
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_purchase_approval_date
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;


-- ------------------------------------------------------------
-- 6.2 Carrier delivery sebelum purchase
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_carrier_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp;


-- ------------------------------------------------------------
-- 6.3 Customer delivery sebelum purchase
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_customer_delivery_date
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;


-- ------------------------------------------------------------
-- 6.4 Customer delivery sebelum carrier delivery
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_delivery_sequence
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date <
      order_delivered_carrier_date;


-- ------------------------------------------------------------
-- 6.5 Estimated delivery sebelum purchase
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_estimated_delivery_date
FROM orders
WHERE order_estimated_delivery_date <
      order_purchase_timestamp;


-- ============================================================
-- 7. CHECK ORDER STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- ============================================================
-- 8. CHECK REVIEW SCORE DISTRIBUTION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 9. CHECK PAYMENT TYPE
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_type
ORDER BY total_payments DESC;


-- ============================================================
-- 10. CHECK PRODUCT CATEGORY
-- ============================================================

SELECT
    COUNT(*) AS total_products,
    COUNT(product_category_name) AS products_with_category,
    COUNT(*) - COUNT(product_category_name)
        AS products_without_category
FROM products;


-- ============================================================
-- 11. CHECK ORDER ITEMS PER ORDER
-- ============================================================

SELECT
    order_id,
    COUNT(*) AS total_items
FROM order_items
GROUP BY order_id
ORDER BY total_items DESC
LIMIT 10;


-- ============================================================
-- 12. CHECK MULTIPLE PAYMENTS PER ORDER
-- ============================================================

SELECT
    order_id,
    COUNT(*) AS payment_count
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC
LIMIT 10;


-- ============================================================
-- 13. CHECK MULTIPLE REVIEWS PER ORDER
-- ============================================================

SELECT
    order_id,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC
LIMIT 10;


-- ============================================================
-- 14. SUMMARY CHECK
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM order_payments) AS order_payments,
    (SELECT COUNT(*) FROM order_reviews) AS order_reviews,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sellers) AS sellers,
    (SELECT COUNT(*) FROM geolocation) AS geolocation,
    (SELECT COUNT(*) FROM product_category_name_translation)
        AS category_translation;