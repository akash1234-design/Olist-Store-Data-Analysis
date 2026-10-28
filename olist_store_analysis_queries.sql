-- ==========================================================
-- Project: Olist E-Commerce Data Analysis
-- Tech Stack: MySQL
-- ==========================================================

USE olist_store;

-- ----------------------------------------------------------
-- KPI 1: Weekday vs Weekend Payment Statistics
-- ----------------------------------------------------------
SELECT 
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY day_type;

-- ----------------------------------------------------------
-- KPI 2: Total Orders with Review Score 5 & Paid by Credit Card
-- ----------------------------------------------------------
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE r.review_score = 5 
  AND p.payment_type = 'credit_card';

-- ----------------------------------------------------------
-- KPI 3: Average Delivery Days for 'pet_shop' Category
-- ----------------------------------------------------------
SELECT 
    p.product_category_name,
    ROUND(AVG(DATEDIFF(
        STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'),
        STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
    )), 1) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name;

-- ----------------------------------------------------------
-- KPI 4: Average Price and Payment Values for São Paulo Customers
-- ----------------------------------------------------------
SELECT 
    c.customer_city,
    ROUND(AVG(i.price), 2) AS avg_product_price,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE c.customer_city = 'sao paulo'
GROUP BY c.customer_city;

-- ----------------------------------------------------------
-- KPI 5: Relationship Between Shipping Days and Review Score
-- ----------------------------------------------------------
SELECT 
    r.review_score,
    ROUND(AVG(DATEDIFF(
        STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'),
        STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
    )), 1) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;