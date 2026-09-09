-- 1. VIEW DIMENSI PELANGGAN (vw_dim_customers)
CREATE OR REPLACE VIEW public.vw_dim_customers AS
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM public.customers;

-- 2. VIEW DIMENSI PRODUK (vw_dim_products)
CREATE OR REPLACE VIEW public.vw_dim_products AS
SELECT 
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized') AS product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM public.products p
LEFT JOIN public.product_category_translation t 
    ON p.product_category_name = t.product_category_name;

-- 3. VIEW DIMENSI PENJUAL (vw_dim_sellers)
CREATE OR REPLACE VIEW public.vw_dim_sellers AS
WITH seller_unique_reviews AS (
    -- 1. Deduplikasi ulasan level order agar tidak ganda akibat multi-item
    SELECT DISTINCT
        oi.seller_id,
        oi.order_id,
        r.review_score
    FROM public.order_items oi
    JOIN public.order_reviews r 
        ON oi.order_id = r.order_id
    JOIN public.orders o 
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
),
seller_stats AS (
    -- 2. Hitung statistik rating & penentuan rating tier per seller
    SELECT 
        seller_id,
        COUNT(order_id) AS total_reviews,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        CASE
            WHEN AVG(review_score) >= 4.5 THEN 'Excellent (4.5 - 5.0)'
            WHEN AVG(review_score) >= 4.0 THEN 'Good (4.0 - 4.49)'
            WHEN AVG(review_score) >= 3.0 THEN 'At Risk (3.0 - 3.99)'
            ELSE 'Critical (< 3.0)'
        END AS rating_tier
    FROM seller_unique_reviews
    GROUP BY seller_id
)
SELECT 
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    COALESCE(st.total_reviews, 0) AS total_reviews,
    COALESCE(st.avg_review_score, 0) AS avg_review_score,
    COALESCE(st.rating_tier, 'No Reviews') AS rating_tier
FROM public.sellers s
LEFT JOIN seller_stats st 
    ON s.seller_id = st.seller_id;

-- 4. VIEW FAKTA PENJUALAN (vw_fact_sales)
CREATE VIEW public.vw_fact_sales AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_purchase_timestamp::date AS order_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    
    -- Metrik Keuangan
    oi.price AS revenue,
    oi.freight_value,
    
    -- Metrik Pengiriman
    CASE 
        WHEN o.order_delivered_customer_date IS NOT NULL 
        THEN (o.order_delivered_customer_date::date - o.order_purchase_timestamp::date)
        ELSE NULL 
    END AS delivery_days,
    
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late,
    
    CASE 
        WHEN o.order_delivered_customer_date IS NOT NULL THEN
            CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
                ELSE 'On Time'
            END
        ELSE 'In Transit'
    END AS delivery_status,
    
    -- Mengambil Ulasan Terbaru Pelanggan (Angka Murni 1 - 5)
    r.review_score

FROM public.order_items oi
INNER JOIN public.orders o 
    ON oi.order_id = o.order_id
LEFT JOIN (
    SELECT DISTINCT ON (order_id) 
        order_id, 
        review_score 
    FROM public.order_reviews 
    ORDER BY order_id, review_answer_timestamp DESC
) r ON o.order_id = r.order_id;