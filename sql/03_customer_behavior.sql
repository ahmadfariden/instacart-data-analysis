-- ============================================================
-- 03. CUSTOMER BEHAVIOR ANALYSIS
-- Tujuan: Memahami pola belanja pelanggan - frekuensi, interval,
--         dan loyalitas (reorder rate)
-- ============================================================

-- Top 10 customer dengan order terbanyak
SELECT
    user_id,
    COUNT(order_id) AS total_order
FROM orders
GROUP BY user_id
ORDER BY total_order DESC
LIMIT 10;


-- Statistik umum frekuensi order per customer
SELECT
    MIN(total_order) AS min_order,
    MAX(total_order) AS max_order,
    ROUND(AVG(total_order), 2) AS avg_order,
    MEDIAN(total_order) AS median_order
FROM (
    SELECT user_id, COUNT(order_id) AS total_order
    FROM orders
    GROUP BY user_id
) t;


-- Rata-rata interval antar belanja (repurchase cycle)
SELECT
    ROUND(AVG(days_since_prior_order), 2) AS avg_interval_hari,
    MIN(days_since_prior_order) AS min_interval,
    MAX(days_since_prior_order) AS max_interval
FROM orders
WHERE days_since_prior_order IS NOT NULL;


-- Distribusi interval belanja per kategori
SELECT
    CASE
        WHEN days_since_prior_order <= 7 THEN '1. Mingguan (<=7 hari)'
        WHEN days_since_prior_order <= 14 THEN '2. Dua Mingguan (8-14 hari)'
        WHEN days_since_prior_order <= 21 THEN '3. Tiga Mingguan (15-21 hari)'
        WHEN days_since_prior_order <= 30 THEN '4. Bulanan (22-30 hari)'
        ELSE '5. Lebih dari sebulan'
    END AS kategori_interval,
    COUNT(*) AS jumlah_order
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY kategori_interval
ORDER BY kategori_interval;


-- Overall reorder rate (loyalitas produk)
SELECT
    COUNT(*) AS total_item,
    SUM(reordered) AS total_reorder,
    ROUND(SUM(reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior;
