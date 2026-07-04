-- ============================================================
-- 05. REORDER ANALYSIS PER PRODUK
-- Tujuan: Mengidentifikasi produk individual dengan reorder rate
--         tertinggi dan terendah ("Perishability Drives Reorder")
-- ============================================================

-- Produk dengan reorder rate tertinggi
SELECT
    p.product_name,
    COUNT(*) AS total_order,
    SUM(op.reordered) AS total_reorder,
    ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 1000
ORDER BY reorder_rate_persen DESC
LIMIT 20;


-- Produk paling sering di-reorder (volume absolut)
SELECT
    p.product_name,
    COUNT(*) AS total_order,
    SUM(op.reordered) AS total_reorder,
    ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_reorder DESC
LIMIT 20;


-- Produk dengan reorder rate terendah ("produk sekali coba")
SELECT
    p.product_name,
    COUNT(*) AS total_order,
    ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 1000
ORDER BY reorder_rate_persen ASC
LIMIT 20;
