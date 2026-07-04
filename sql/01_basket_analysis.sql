-- ============================================================
-- 01. BASKET ANALYSIS (Market Basket / Lift Score)
-- Tujuan: Mengidentifikasi kombinasi produk yang paling sering
--         dibeli bersamaan, menggunakan Lift Score untuk
--         menghindari bias produk populer.
-- ============================================================

-- ITERASI 1: Raw Frequency Count (BIAS - didominasi produk populer)
SELECT
    p1.product_name AS produk_a,
    p2.product_name AS produk_b,
    COUNT(*) AS frekuensi_bareng
FROM order_products_prior op1
JOIN order_products_prior op2
    ON op1.order_id = op2.order_id
    AND op1.product_id < op2.product_id
JOIN products p1 ON op1.product_id = p1.product_id
JOIN products p2 ON op2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY frekuensi_bareng DESC
LIMIT 10;


-- ITERASI 2 & 3: Lift Score dengan threshold tuning
-- Lift Score mengukur seberapa kuat hubungan 2 produk dibanding
-- jika mereka dibeli secara independen (acak).
-- Lift > 1 = ada hubungan nyata; makin tinggi, makin kuat.

WITH product_pair_count AS (
    SELECT
        op1.product_id AS product_a,
        op2.product_id AS product_b,
        COUNT(*) AS pair_count
    FROM order_products_prior op1
    JOIN order_products_prior op2
        ON op1.order_id = op2.order_id
        AND op1.product_id < op2.product_id
    GROUP BY op1.product_id, op2.product_id
    HAVING COUNT(*) >= 3000  -- threshold final setelah tuning (500 -> 3000)
),
product_count AS (
    SELECT product_id, COUNT(*) AS total_count
    FROM order_products_prior
    GROUP BY product_id
),
total_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total FROM order_products_prior
)
SELECT
    p1.product_name AS produk_a,
    p2.product_name AS produk_b,
    ppc.pair_count AS frekuensi_bareng,
    ROUND(
        (ppc.pair_count * 1.0 / t.total) /
        ((pc1.total_count * 1.0 / t.total) * (pc2.total_count * 1.0 / t.total)),
        2
    ) AS lift_score
FROM product_pair_count ppc
JOIN product_count pc1 ON ppc.product_a = pc1.product_id
JOIN product_count pc2 ON ppc.product_b = pc2.product_id
JOIN products p1 ON ppc.product_a = p1.product_id
JOIN products p2 ON ppc.product_b = p2.product_id
CROSS JOIN total_orders t
ORDER BY lift_score DESC
LIMIT 20;
