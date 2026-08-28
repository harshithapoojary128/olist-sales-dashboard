--Monthly revenue trend:
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    SUM(p.payment_value) AS revenue
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

--Top 10 product categories by revenue:
SELECT 
    pr.product_category_name,
    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS num_orders
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--Customer segmentation :
SELECT 
    o.customer_id,
    COUNT(o.order_id) AS order_count,
    SUM(p.payment_value) AS total_spent,
    NTILE(4) OVER (ORDER BY SUM(p.payment_value) DESC) AS spend_quartile
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY o.customer_id;

--Average delivery delay vs review score:
SELECT 
    r.review_score,
    AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400) AS avg_delay_days
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;