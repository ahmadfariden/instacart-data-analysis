-- ============================================================
-- 04. DEPARTMENT & AISLE POPULARITY
-- Tujuan: Mengidentifikasi kategori produk paling laris dan
--         paling "sticky" (sering di-reorder)
-- ============================================================

-- Department terlaris
SELECT
    d.department,
    COUNT(*) AS total_terjual
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY total_terjual DESC
LIMIT 15;


-- Aisle terlaris (lebih spesifik dari department)
SELECT
    a.aisle,
    COUNT(*) AS total_terjual
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY total_terjual DESC
LIMIT 15;


-- Department dengan reorder rate tertinggi ("sticky")
SELECT
    d.department,
    COUNT(*) AS total_order,
    SUM(op.reordered) AS total_reorder,
    ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
HAVING COUNT(*) >= 10000
ORDER BY reorder_rate_persen DESC
LIMIT 15;


-- Department dengan reorder rate terendah ("discovery zone")
SELECT
    d.department,
    COUNT(*) AS total_order,
    ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_persen
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
HAVING COUNT(*) >= 10000
ORDER BY reorder_rate_persen ASC
LIMIT 15;
