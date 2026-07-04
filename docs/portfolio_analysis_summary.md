# Instacart Market Basket Analysis — Portofolio Project

**Data Analyst:** Ahmad Farid
**Dataset:** Instacart Market Basket Analysis (Kaggle) — Real-world dataset
**Tools:** SQL (DuckDB)
**Skala Data:** ~37.3 juta baris (6 tabel relasional: orders, order_products_prior, order_products_train, products, aisles, departments)

---

## Ringkasan Dataset

| Tabel | Jumlah Baris |
|---|---|
| orders | 3.421.083 |
| order_products_prior | 32.434.489 |
| order_products_train | 1.384.617 |
| products | 49.688 |
| aisles | 134 |
| departments | 21 |

Dataset ini adalah data anonim real dari lebih dari 200.000 pengguna Instacart, aplikasi grocery delivery di Amerika Serikat.

---

## 1. Basket Analysis (Market Basket / Lift Score)

**Tujuan:** Mengidentifikasi kombinasi produk yang paling sering dibeli bersamaan.

**Metodologi (Iteratif):**
| Iterasi | Pendekatan | Masalah/Insight |
|---|---|---|
| 1 | Raw frequency count | Bias ke produk terpopuler (Banana mendominasi semua kombinasi) |
| 2 | Lift score, threshold rendah (≥500) | Lift score meledak tidak natural (700-1700) karena low-frequency bias |
| 3 | Lift score, threshold tinggi (≥3000) | Hasil representatif dan actionable |

**Temuan Utama (Threshold ≥3000):**
- Kategori **yogurt** mendominasi 65% dari top 20 kombinasi produk dengan lift score tertinggi (Icelandic Skyr, Total 2% Greek series, dll)
- Pola **sparkling water multi-flavor** (Kiwi Sandia + Blackberry Cucumber, Lemon + Grapefruit)
- Pola substitusi: Soda + Zero Calorie Cola (lift 41.67)
- Kombinasi buah komplementer: Clementines + Apples (lift 33.23)

**Insight Bisnis:**
> Konsumen menunjukkan pola "multi-flavor purchasing" — kecenderungan membeli beberapa varian rasa dari produk line yang sama dalam satu transaksi, terutama pada kategori yogurt dan minuman. Strategi bundling "Variety Pack" berpotensi meningkatkan average order value karena pola ini sudah terjadi secara organik.

---

## 2. Time Pattern Analysis

**Tujuan:** Mengidentifikasi pola waktu (jam dan hari) belanja pelanggan.

**Temuan — Pola Jam:**
- Order sepi jam 00:00-05:00 (5.474 - 22.758 order)
- Naik tajam mulai jam 06:00-08:00
- **Jam sibuk utama: 09:00-16:00**, konsisten di angka 270-290 ribu order/jam
- **Puncak tertinggi: jam 10:00** (288.418 order)

**Temuan — Pola Hari:**
| order_dow | Total Order |
|---|---|
| 0 (kemungkinan Minggu) | 600.905 (tertinggi) |
| 1 (kemungkinan Senin) | 587.478 |
| 4 (kemungkinan Kamis) | 426.339 (terendah) |

**Insight Bisnis:**
> Pola belanja menunjukkan "office-hours shopping behavior" dengan puncak di jam 10:00-15:00, mengindikasikan mayoritas transaksi terjadi saat jam kerja/istirahat siang. Hari Minggu-Senin menjadi periode restocking utama rumah tangga. Rekomendasi: alokasi delivery slot dan personal shopper terbanyak difokuskan pada jam 09:00-16:00 di hari Minggu-Senin.

---

## 3. Customer Behavior Analysis

**Tujuan:** Memahami pola belanja pelanggan secara individual — frekuensi, interval, dan loyalitas.

**Temuan — Frekuensi Order:**
| Statistik | Nilai |
|---|---|
| Min order per user | 4 |
| Max order per user | 100 (capped by dataset) |
| Rata-rata | 16.59 order |
| Median | 10 order |

Distribusi right-skewed — ada kelompok kecil "power user" yang menarik rata-rata ke atas.

**Temuan — Interval Belanja:**
| Kategori | Jumlah Order | Persentase |
|---|---|---|
| Mingguan (≤7 hari) | 1.620.033 | **50.7%** |
| Dua Mingguan (8-14 hari) | 735.651 | 23.0% |
| Tiga Mingguan (15-21 hari) | 307.027 | 9.6% |
| Bulanan (22-30 hari) | 552.163 | 17.3% |

**Temuan — Reorder Rate Keseluruhan:** **58.97%** dari semua item yang dibeli adalah produk yang sama dengan pembelian sebelumnya.

**Insight Bisnis:**
> Dengan reorder rate 58.97% dan 50.7% customer berbelanja lagi dalam seminggu, Instacart memiliki basis customer yang sangat loyal dengan pola belanja rutin/habitual. Fitur "Quick Reorder" atau "Buy It Again" berpotensi sangat efektif meningkatkan retention. Strategi marketing sebaiknya fokus pada convenience & consistency dibanding discovery produk baru.

---

## 4. Department & Aisle Popularity

**Tujuan:** Mengidentifikasi kategori produk paling laris dan paling "sticky" (sering di-reorder).

**Department Terlaris:**
1. Produce — 9.479.291 (hampir 2x lipat department kedua)
2. Dairy Eggs — 5.414.016
3. Snacks — 2.887.550

**Department dengan Reorder Rate Tertinggi ("Sticky"):**
| Department | Reorder Rate |
|---|---|
| Dairy Eggs | 67.0% |
| Beverages | 65.35% |
| Produce | 64.99% |

**Department dengan Reorder Rate Terendah ("Discovery Zone"):**
| Department | Reorder Rate |
|---|---|
| Personal Care | 32.11% (terendah) |
| Pantry | 34.67% |
| International | 36.92% |

**Insight Bisnis:**
> Dairy Eggs, Beverages, dan Produce adalah tulang punggung retensi Instacart — volume tinggi DAN reorder rate tinggi. Personal Care dan International punya reorder rate rendah meski volume order besar — customer di kategori ini masih "mencari" produk yang cocok, membuka peluang rekomendasi produk personalisasi dan promo trial-size.

---

## 5. Reorder Analysis per Produk

**Tujuan:** Mengidentifikasi produk individual dengan reorder rate tertinggi dan terendah.

**Produk dengan Reorder Rate Tertinggi:** Didominasi (13 dari 20) oleh **produk susu** dalam berbagai varian, dengan reorder rate konsisten **83-86%**.

**Produk Paling Sering Di-reorder (Volume Absolut):**
1. Banana — 398.609 kali reorder
2. Bag of Organic Bananas — 315.913 kali reorder

**Produk dengan Reorder Rate Terendah:** Seluruh 20 produk terbawah adalah **rempah-rempah/bumbu kering** (nutmeg, cumin, ginger, cayenne pepper, paprika, dll), reorder rate hanya **3.5% - 9.6%**.

**Insight Bisnis (Temuan Utama Proyek):**
> **Pola "Perishability Drives Reorder"** — terdapat korelasi kuat antara daya tahan produk (shelf life) dan reorder rate. Produk perishable (susu, buah segar) punya reorder rate 80%+ karena cepat habis/basi, sementara produk non-perishable (rempah, bumbu kering) punya reorder rate di bawah 10% karena sekali beli bisa dipakai lama. Strategi "subscribe & save" paling efektif untuk kategori perishable, sementara kategori rempah lebih cocok untuk strategi "bundle sekali beli banyak".

---

## 6. Order Size Analysis

**Tujuan:** Menganalisis ukuran order (jumlah item) dan hubungannya dengan perilaku belanja.

**Statistik Umum:**
| Statistik | Nilai |
|---|---|
| Min | 1 item |
| Max | 145 item |
| Rata-rata | 10.09 item |
| Median | 8 item |

**Distribusi Ukuran Order:**
| Kategori | Persentase |
|---|---|
| Kecil (1-5 item) | 30.9% |
| Sedang (6-10 item) | 30.9% |
| Besar (11-20 item) | 28.1% |
| Sangat Besar (21-30 item) | 7.3% |
| Ekstra Besar (>30 item) | 2.0% |

**Temuan Kunci — Pola U-Shape Reorder Rate:**
| Kategori | Reorder Rate |
|---|---|
| Kecil (1-5) | 62.22% (tertinggi) |
| Besar (11-20) | 58.01% (terendah) |
| Ekstra Besar (>30) | 61.1% |

**Temuan — Ukuran Order per Hari:** Hari 0 (Minggu) punya rata-rata item tertinggi (11.13), mengonfirmasi pola "belanja mingguan besar" di akhir pekan.

**Insight Bisnis:**
> Pola "Dual Purpose Shopping" — (1) top-up shopping (order kecil, reorder rate tinggi, tersebar di hari kerja) untuk kebutuhan mendadak, dan (2) stocking-up shopping (order besar, terkonsentrasi di hari Minggu, reorder rate juga tinggi) untuk restock mingguan rutin. Rekomendasi: fitur "Quick Add" untuk top-up di hari kerja, fitur "Weekly Restock List" untuk pola belanja besar di akhir pekan.

---

## 7. First Order vs Repeat Order Behavior

**Tujuan:** Mengidentifikasi produk yang menjadi "starter product" dan tingkat konversinya menjadi repeat purchase.

**Produk Terpopuler di Order Pertama:**
1. Banana — 29.534
2. Bag of Organic Bananas — 19.158
3. Organic Strawberries — 16.464

**Conversion Rate Tertinggi (dari first purchase ke repeat purchase):** Didominasi produk susu (82-89%) dan Banana (88.61%).

**Produk yang "Butuh Waktu" (rata-rata baru dicoba di order ke-23-25):** Milk Chocolate Almonds, Gold Potato, Organic Plain Greek Yogurt, Blood Oranges.

**Insight Bisnis:**
> Pola "First Impression Matters" — Banana dan produk susu bukan cuma populer secara volume, tapi punya conversion rate tertinggi (82-89%) ketika menjadi bagian dari first purchase, mengindikasikan produk ini adalah "gateway products". Rekomendasi: prioritaskan produk-produk ini di halaman onboarding/welcome screen customer baru.

---

## 8. Customer Segmentation (RFE Analysis)

**Tujuan:** Mengelompokkan customer berdasarkan Recency, Frequency, dan Engagement (proxy untuk Monetary karena dataset tidak memiliki data harga).

**Metodologi:** Skor 1-5 (NTILE) untuk masing-masing dimensi Recency, Frequency, rata-rata item per order — dijumlahkan menjadi total_score (3-15), lalu dikelompokkan menjadi 5 segmen.

**Hasil Segmentasi:**
| Segmen | Jumlah Customer | % | Avg Frequency | Avg Recency | Avg Item |
|---|---|---|---|---|---|
| 1. Champions | 24.459 | 11.9% | 37.67 | 5.8 hari | 14.92 |
| 2. Loyal Customers | 66.234 | 32.2% | 20.82 | 11.06 hari | 11.34 |
| 3. Regular | 73.158 | 35.6% | 9.42 | 20.28 hari | 9.62 |
| 4. At Risk | 30.114 | 14.6% | 5.86 | 26.47 hari | 6.18 |
| 5. Lost/Dormant | 12.244 | 6.0% | 3.99 | 29.6 hari | 3.82 |

**Insight Bisnis:**
> Segmentasi RFE mengungkap pola linear yang sangat konsisten — Champions (11.9%) dan Loyal Customers (32.2%) merepresentasikan basis pelanggan paling bernilai, sementara At Risk dan Lost/Dormant (20.6% gabungan, ~42.000 customer) menunjukkan tanda-tanda churn dengan recency mendekati batas maksimum dataset.
>
> **Rekomendasi per segmen:**
> - Champions: program loyalitas VIP, early access promo
> - Loyal Customers: insentif "one more order" untuk naik ke Champions
> - Regular: kampanye engagement untuk meningkatkan frekuensi
> - At Risk: kampanye re-engagement aktif sebelum churn total
> - Lost/Dormant: win-back campaign dengan insentif besar

---

## 9. Add-to-Cart Order Pattern

**Tujuan:** Menganalisis urutan produk dimasukkan ke keranjang dalam satu sesi belanja ("shopping journey").

**Item Pertama di Cart:** Banana (110.916 kali), Bag of Organic Bananas (78.988 kali).

**Produk Dimasukkan Paling Awal (posisi 1-4):** Didominasi minuman & snack ringan (Zero Calorie Cola, Drinking Water, Mineral Water, Soda, Popcorn) — kemungkinan "grab-and-go items".

**Produk Dimasukkan Paling Akhir (posisi 10-11):** Didominasi bahan masakan spesifik (Marinara Pasta Sauce, Green Lentils, Ranch Dressing, Taco Seasoning) — kemungkinan "recipe-driven purchases".

**Pola per Department:**
| Urutan | Department | Avg Posisi |
|---|---|---|
| Tercepat | Alcohol | 5.43 |
| ... | Beverages | 6.98 |
| ... | Dairy Eggs | 7.5 |
| ... | Produce | 8.02 |
| Terakhir | Babies | 10.58 |

**Insight Bisnis:**
> Pola "Shopping Journey" mengikuti struktur konsisten: dimulai dari kebutuhan pokok cepat (alcohol, beverages, dairy), dilanjutkan produk segar (produce, bakery), diakhiri bahan masakan spesifik dan kategori khusus (babies, international). Rekomendasi: tampilkan kategori "cepat" di quick access aplikasi, sementara kategori "recipe-driven" ditempatkan di fitur Meal Planning atau rekomendasi berbasis resep.

---

## Kesimpulan Keseluruhan

Sembilan analisis di atas mengungkap gambaran menyeluruh tentang perilaku belanja pelanggan Instacart:

1. **Produk fresh (terutama Banana)** konsisten menjadi "anchor product" di hampir semua dimensi analisis — basket analysis, reorder rate, starter product, hingga item pertama di cart.
2. **Perishability adalah prediktor kuat reorder rate** — produk yang cepat basi (susu, buah) jauh lebih sering di-reorder dibanding produk tahan lama (rempah-rempah).
3. **Pola waktu belanja** mengikuti "office-hours behavior" dengan puncak Minggu-Senin jam 10:00-15:00.
4. **Basis customer sangat loyal** (reorder rate 58.97%, 50.7% belanja mingguan), namun segmentasi RFE menunjukkan ~20% customer berada dalam risiko churn.
5. **Shopping journey terstruktur** — dari kebutuhan pokok di awal sesi hingga bahan masakan spesifik di akhir sesi.

**Skill yang diterapkan:** SQL (JOIN multi-tabel, CTE, Window Functions — ROW_NUMBER, NTILE, PARTITION BY, Subqueries, Aggregate Functions, Statistical calculation/Lift Score), metodologi RFE Segmentation, iterative query refinement (basket analysis threshold tuning), debugging query logic (circular logic fix pada conversion rate analysis).
