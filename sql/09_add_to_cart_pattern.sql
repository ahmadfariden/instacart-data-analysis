-- ============================================================
-- 09. ADD-TO-CART ORDER PATTERN
-- Tujuan: Menganalisis urutan produk dimasukkan ke keranjang
--         dalam satu sesi belanja ("shopping journey")
-- ============================================================

-- Produk yang paling sering jadi item pertama di cart
SELECT
    p.product_name,
    COUNT(*) AS total_jadi_item_pertama
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
WHERE op.add_to_cart_order = 1
GROUP BY p.product_name
ORDER BY total_jadi_item_pertama DESC
LIMIT 15;


-- Produk yang dimasukkan paling awal (rata-rata posisi cart terkecil)
SELECT
    p.product_name,
    COUNT(*) AS total_dibeli,
    ROUND(AVG(op.add_to_cart_order), 2) AS avg_posisi_cart
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 5000
ORDER BY avg_posisi_cart ASC
LIMIT 15;


-- Produk yang dimasukkan paling akhir (kemungkinan "recipe-driven purchase")
SELECT
    p.product_name,
    COUNT(*) AS total_dibeli,
    ROUND(AVG(op.add_to_cart_order), 2) AS avg_posisi_cart
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 5000
ORDER BY avg_posisi_cart DESC
LIMIT 15;


-- Pola per department (urutan "shopping journey")
SELECT
    d.department,
    ROUND(AVG(op.add_to_cart_order), 2) AS avg_posisi_cart,
    COUNT(*) AS total_item
FROM order_products_prior op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_posisi_cart ASC;
