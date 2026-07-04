-- ============================================================
-- 02. TIME PATTERN ANALYSIS
-- Tujuan: Mengidentifikasi pola waktu (jam & hari) belanja pelanggan
-- ============================================================

-- Pola belanja per jam
SELECT
    order_hour_of_day,
    COUNT(*) AS total_order
FROM orders
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;


-- Pola belanja per hari (0-6, kemungkinan 0=Minggu berdasarkan pola volume)
SELECT
    order_dow,
    COUNT(*) AS total_order
FROM orders
GROUP BY order_dow
ORDER BY order_dow;


-- Kombinasi hari x jam (untuk heatmap)
SELECT
    order_dow,
    order_hour_of_day,
    COUNT(*) AS total_order
FROM orders
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;
