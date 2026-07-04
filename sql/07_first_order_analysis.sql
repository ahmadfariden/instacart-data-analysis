-- ============================================================
-- 07. FIRST ORDER VS REPEAT ORDER BEHAVIOR
-- Tujuan: Mengidentifikasi produk "starter" dan tingkat
--         konversinya menjadi repeat purchase
-- ============================================================

-- Produk terpopuler di order pertama customer
SELECT
    p.product_name,
    COUNT(*) AS total_dibeli_di_order_pertama
FROM order_products_prior op
JOIN orders o ON op.order_id = o.order_id
JOIN products p ON op.product_id = p.product_id
WHERE o.order_number = 1
GROUP BY p.product_name
ORDER BY total_dibeli_di_order_pertama DESC
LIMIT 15;


-- Conversion rate: dari first purchase ke repeat purchase
-- (Perbaikan dari circular logic - total_first_buyers dihitung
--  terpisah dari data yang sudah difilter repurchase)
WITH first_order_products AS (
    SELECT DISTINCT o.user_id, op.product_id
    FROM order_products_prior op
    JOIN orders o ON op.order_id = o.order_id
    WHERE o.order_number = 1
),
total_first_buyers AS (
    SELECT product_id, COUNT(DISTINCT user_id) AS total_user_beli_pertama
    FROM first_order_products
    GROUP BY product_id
),
repurchased AS (
    SELECT DISTINCT fop.product_id, fop.user_id
    FROM first_order_products fop
    JOIN orders o2 ON fop.user_id = o2.user_id AND o2.order_number > 1
    JOIN order_products_prior op2 ON o2.order_id = op2.order_id AND op2.product_id = fop.product_id
)
SELECT
    p.product_name,
    tfb.total_user_beli_pertama,
    COUNT(DISTINCT r.user_id) AS total_user_beli_lagi,
    ROUND(COUNT(DISTINCT r.user_id) * 100.0 / tfb.total_user_beli_pertama, 2) AS conversion_rate_persen
FROM total_first_buyers tfb
LEFT JOIN repurchased r ON tfb.product_id = r.product_id
JOIN products p ON tfb.product_id = p.product_id
WHERE tfb.total_user_beli_pertama >= 500
GROUP BY p.product_name, tfb.total_user_beli_pertama
ORDER BY conversion_rate_persen DESC
LIMIT 20;


-- Produk yang "butuh waktu" (rata-rata order number saat pertama dibeli)
SELECT
    p.product_name,
    COUNT(*) AS total_pembelian,
    ROUND(AVG(o.order_number), 2) AS avg_order_number_pertama_beli
FROM order_products_prior op
JOIN orders o ON op.order_id = o.order_id
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 5000
ORDER BY avg_order_number_pertama_beli DESC
LIMIT 15;
