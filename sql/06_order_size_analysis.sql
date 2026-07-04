-- ============================================================
-- 06. ORDER SIZE ANALYSIS
-- Tujuan: Menganalisis ukuran order (jumlah item) dan
--         hubungannya dengan perilaku belanja
-- ============================================================

-- Statistik umum ukuran order
SELECT
    MIN(jumlah_item) AS min_item,
    MAX(jumlah_item) AS max_item,
    ROUND(AVG(jumlah_item), 2) AS avg_item,
    MEDIAN(jumlah_item) AS median_item
FROM (
    SELECT order_id, COUNT(*) AS jumlah_item
    FROM order_products_prior
    GROUP BY order_id
) t;


-- Distribusi ukuran order (kelompok)
SELECT
    CASE
        WHEN jumlah_item <= 5 THEN '1. Kecil (1-5 item)'
        WHEN jumlah_item <= 10 THEN '2. Sedang (6-10 item)'
        WHEN jumlah_item <= 20 THEN '3. Besar (11-20 item)'
        WHEN jumlah_item <= 30 THEN '4. Sangat Besar (21-30 item)'
        ELSE '5. Ekstra Besar (>30 item)'
    END AS kategori_ukuran,
    COUNT(*) AS jumlah_order
FROM (
    SELECT order_id, COUNT(*) AS jumlah_item
    FROM order_products_prior
    GROUP BY order_id
) t
GROUP BY kategori_ukuran
ORDER BY kategori_ukuran;


-- Hubungan ukuran order dengan reorder rate (pola U-shape)
SELECT
    CASE
        WHEN jumlah_item <= 5 THEN '1. Kecil (1-5 item)'
        WHEN jumlah_item <= 10 THEN '2. Sedang (6-10 item)'
        WHEN jumlah_item <= 20 THEN '3. Besar (11-20 item)'
        WHEN jumlah_item <= 30 THEN '4. Sangat Besar (21-30 item)'
        ELSE '5. Ekstra Besar (>30 item)'
    END AS kategori_ukuran,
    COUNT(*) AS total_item,
    ROUND(AVG(reordered) * 100, 2) AS avg_reorder_rate_persen
FROM (
    SELECT
        op.order_id,
        op.reordered,
        COUNT(*) OVER (PARTITION BY op.order_id) AS jumlah_item
    FROM order_products_prior op
) t
GROUP BY kategori_ukuran
ORDER BY kategori_ukuran;


-- Ukuran order berdasarkan hari (apakah weekend order lebih besar?)
SELECT
    o.order_dow,
    ROUND(AVG(t.jumlah_item), 2) AS avg_item_per_order
FROM orders o
JOIN (
    SELECT order_id, COUNT(*) AS jumlah_item
    FROM order_products_prior
    GROUP BY order_id
) t ON o.order_id = t.order_id
GROUP BY o.order_dow
ORDER BY o.order_dow;
