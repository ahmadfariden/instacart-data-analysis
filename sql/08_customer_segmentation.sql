-- ============================================================
-- 08. CUSTOMER SEGMENTATION (RFE ANALYSIS)
-- Tujuan: Mengelompokkan customer berdasarkan Recency, Frequency,
--         dan Engagement (proxy Monetary karena tidak ada data harga)
-- ============================================================

WITH customer_metrics AS (
    SELECT
        o.user_id,
        COUNT(DISTINCT o.order_id) AS frequency,
        AVG(t.jumlah_item) AS avg_item_per_order
    FROM orders o
    JOIN (
        SELECT order_id, COUNT(*) AS jumlah_item
        FROM order_products_prior
        GROUP BY order_id
    ) t ON o.order_id = t.order_id
    GROUP BY o.user_id
),
recency_data AS (
    SELECT
        user_id,
        days_since_prior_order AS recency_hari,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_number DESC) AS rn
    FROM orders
),
combined AS (
    SELECT
        cm.user_id,
        cm.frequency,
        r.recency_hari,
        cm.avg_item_per_order
    FROM customer_metrics cm
    JOIN recency_data r ON cm.user_id = r.user_id AND r.rn = 1
),
scored AS (
    SELECT
        user_id,
        frequency,
        recency_hari,
        avg_item_per_order,
        -- Recency kecil (baru belanja) -> harus dapat skor tinggi -> urutkan DESC
        NTILE(5) OVER (ORDER BY recency_hari DESC) AS r_score,
        -- Frequency besar (sering belanja) -> harus dapat skor tinggi -> urutkan ASC
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        -- Item banyak -> harus dapat skor tinggi -> urutkan ASC
        NTILE(5) OVER (ORDER BY avg_item_per_order ASC) AS e_score
    FROM combined
),
final_segment AS (
    SELECT
        *,
        (r_score + f_score + e_score) AS total_score
    FROM scored
)
SELECT
    CASE
        WHEN total_score >= 13 THEN '1. Champions'
        WHEN total_score >= 10 THEN '2. Loyal Customers'
        WHEN total_score >= 7 THEN '3. Regular'
        WHEN total_score >= 5 THEN '4. At Risk'
        ELSE '5. Lost/Dormant'
    END AS segment,
    COUNT(*) AS jumlah_customer,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(recency_hari), 2) AS avg_recency,
    ROUND(AVG(avg_item_per_order), 2) AS avg_item
FROM final_segment
GROUP BY segment
ORDER BY segment;
