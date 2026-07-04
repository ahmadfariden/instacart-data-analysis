# Dokumentasi Proyek: Instacart Data Analysis (End-to-End Pipeline)

Dokumen ini merangkum seluruh proses yang telah dikerjakan — dari mengunduh data mentah, membangun database analitik, melakukan analisis SQL, memindahkan data ke database produksi, hingga membangun dashboard Power BI.

**Data Analyst:** Ahmad Farid
**Dataset:** Instacart Market Basket Analysis (Kaggle)
**Skala Data:** ~37.3 juta baris

---

## Tahap 1: Memperoleh Data Mentah

### 1.1 Sumber Data
Dataset diunduh dari Kaggle: **Instacart Market Basket Analysis** (`psparks/instacart-market-basket-analysis`), berupa data transaksi real dari aplikasi grocery delivery Instacart.

### 1.2 Proses Download
1. Membuat akun Kaggle
2. Mengakses halaman dataset, membuka tab **Data Explorer**
3. Mengklik tombol **Download** — memilih opsi **"Download dataset as zip"** (207 MB terkompresi)
4. Mengekstrak file zip ke folder lokal: `C:\Users\ahmad farid\Downloads\archive`

### 1.3 Isi Dataset (6 File CSV)
| File | Jumlah Baris |
|---|---|
| orders.csv | 3.421.083 |
| order_products__prior.csv | 32.434.489 |
| order_products__train.csv | 1.384.617 |
| products.csv | 49.688 |
| aisles.csv | 134 |
| departments.csv | 21 |

---

## Tahap 2: Membangun Database Analitik dengan DuckDB

### 2.1 Alasan Memilih DuckDB
DuckDB dipilih sebagai database analitik karena mampu menangani puluhan juta baris data tanpa perlu setup server database, cocok untuk eksplorasi dan pengembangan query yang cepat.

### 2.2 Instalasi & Setup
1. Membuka Command Prompt, masuk ke folder kerja: `C:\Users\ahmad farid\Downloads\duckdb`
2. Menjalankan `duckdb instacart.duckdb` untuk membuat database baru

### 2.3 Import 6 CSV ke DuckDB
Menggunakan fungsi `read_csv_auto()` untuk membuat tabel langsung dari file CSV:

```sql
CREATE TABLE orders AS SELECT * FROM read_csv_auto('C:\Users\ahmad farid\Downloads\archive\orders.csv');
CREATE TABLE order_products_prior AS SELECT * FROM read_csv_auto('...\order_products__prior.csv');
CREATE TABLE order_products_train AS SELECT * FROM read_csv_auto('...\order_products__train.csv');
CREATE TABLE products AS SELECT * FROM read_csv_auto('...\products.csv');
CREATE TABLE aisles AS SELECT * FROM read_csv_auto('...\aisles.csv');
CREATE TABLE departments AS SELECT * FROM read_csv_auto('...\departments.csv');
```

### 2.4 Verifikasi Data
Menjalankan `SELECT COUNT(*)` pada setiap tabel — seluruh jumlah baris **cocok 100%** dengan data sumber, memastikan tidak ada data yang rusak atau hilang saat proses import.

---

## Tahap 3: Analisis Data dengan SQL (9 Analisis)

Menggunakan DuckDB untuk menjalankan sembilan analisis mendalam:

1. **Basket Analysis (Lift Score)** — kombinasi produk yang sering dibeli bersamaan, dengan iterasi threshold (500 → 3000) untuk menghindari bias statistik
2. **Time Pattern Analysis** — pola belanja berdasarkan jam dan hari
3. **Customer Behavior Analysis** — frekuensi, interval, dan reorder rate keseluruhan
4. **Department & Aisle Popularity** — kategori produk terlaris dan tingkat "stickiness"
5. **Reorder Analysis per Produk** — produk individual dengan reorder rate tertinggi/terendah
6. **Order Size Analysis** — distribusi ukuran order dan korelasinya dengan reorder rate
7. **First Order vs Repeat Behavior** — produk "starter" dan tingkat konversinya
8. **Customer Segmentation (RFE)** — segmentasi 5 kelompok pelanggan menggunakan Recency, Frequency, Engagement
9. **Add-to-Cart Order Pattern** — urutan produk dimasukkan ke keranjang belanja

**Skill SQL yang digunakan:** JOIN multi-tabel, CTE, Window Functions (ROW_NUMBER, NTILE, PARTITION BY), Subqueries, Aggregate Functions, kalkulasi statistik (Lift Score), serta debugging logika query (perbaikan circular logic pada analisis conversion rate).

*(Detail lengkap tersedia di file `Portofolio_Instacart_Data_Analysis.md`)*

---

## Tahap 4: Memindahkan Data ke MySQL (via XAMPP)

### 4.1 Alasan Pemindahan
Data dipindahkan dari DuckDB (database analitik) ke MySQL (database produksi) agar dapat diakses oleh tools visualisasi seperti Power BI secara lebih standar, serta untuk konsistensi dengan proyek sebelumnya (dashboard gudang di CV).

### 4.2 Setup MySQL via XAMPP
1. Mengaktifkan modul MySQL di XAMPP Control Panel
2. Membuat database baru `instacart_db` melalui phpMyAdmin

### 4.3 Transfer Data via DuckDB MySQL Extension
Menggunakan ekstensi MySQL DuckDB untuk transfer langsung tanpa perantara CSV:

```sql
INSTALL mysql;
LOAD mysql;
ATTACH 'host=localhost user=root port=3306 db=instacart_db' AS mysql_db (TYPE mysql);

CREATE TABLE mysql_db.departments AS SELECT * FROM departments;
CREATE TABLE mysql_db.aisles AS SELECT * FROM aisles;
CREATE TABLE mysql_db.products AS SELECT * FROM products;
CREATE TABLE mysql_db.orders AS SELECT * FROM orders;
CREATE TABLE mysql_db.order_products_train AS SELECT * FROM order_products_train;
CREATE TABLE mysql_db.order_products_prior AS SELECT * FROM order_products_prior;
```

### 4.4 Verifikasi
Menjalankan `SELECT COUNT(*)` pada tabel MySQL — seluruh 6 tabel (total ~37,15 juta baris) berhasil dipindahkan dengan **integritas data 100%** (jumlah baris identik dengan sumber DuckDB).

---

## Tahap 5: Membangun Dashboard di Power BI

### 5.1 Keputusan Sumber Data
Setelah mengalami kendala koneksi MySQL-Power BI (error driver/connector), diputuskan untuk **mengimpor langsung dari file CSV asli** ke Power BI, demi efisiensi waktu.

### 5.2 Struktur Dashboard (6 Halaman)

| Halaman | Isi | Status |
|---|---|---|
| **1. Overview** | KPI Cards (Total Orders, Customers, Products, Reorder Rate), Top 5 Department, Top 5 Produk | ✅ Selesai |
| **2. Time Pattern** | Chart Order per Jam, Chart Order per Hari, Heatmap Matrix (Hari x Jam) | ✅ Selesai |
| **3. Product & Basket Analysis** | Product Terlaris, Department Popularity, Reorder Rate per Department, Tabel Basket Analysis (Lift Score) | ✅ Selesai |
| **4. Customer Behavior & Segmentation** | Donut Chart 5 Segmen Customer, Tabel Karakteristik per Segmen | ✅ Selesai |
| **5. Order Size & Shopping Journey** | *(Direncanakan)* | ⏳ Belum |
| **6. Business Insights & Recommendations** | *(Direncanakan)* | ⏳ Belum |

### 5.3 Teknik yang Digunakan di Power BI

**Membangun Relasi Antar Tabel**
Menghubungkan 6 tabel (orders, order_products_prior/train, products, aisles, departments) melalui kolom kunci (order_id, product_id, aisle_id, department_id) di Model View.

**Membuat Measure DAX**
```dax
Reorder Rate = 
FORMAT(
    DIVIDE(
        SUM(order_products__prior[reordered]),
        COUNTROWS(order_products__prior)
    ) * 100,
    "0.00"
) & "%"

Total Pembelian = COUNTROWS(order_products__prior)

Reorder Rate Numeric = 
DIVIDE(
    SUM(order_products__prior[reordered]),
    COUNTROWS(order_products__prior)
) * 100
```

**Export Data Analisis Lanjutan dari DuckDB**
Untuk visual yang membutuhkan hasil query kompleks (basket analysis dengan lift score, customer segmentation RFE), data diekspor dari DuckDB ke CSV menggunakan `COPY ... TO`, kemudian diimpor sebagai tabel tambahan di Power BI:
- `basket_analysis_export.csv` — hasil basket analysis (produk, lift score)
- `customer_segmentation_export2.csv` — hasil segmentasi RFE per customer

### 5.4 Kendala Teknis & Solusi (Troubleshooting)

Selama proses pembangunan dashboard, ditemukan dan diselesaikan beberapa masalah teknis:

| Masalah | Penyebab | Solusi |
|---|---|---|
| Sorting chart jam berantakan (10,11,15,14...) | Kolom `order_hour_of_day` bertipe teks, di-sort alfabetis bukan numerik | Membuat kolom bantuan numerik untuk **Sort by Column** |
| Angka desimal salah (lift_score 8111 bukan 81.11) | Locale mismatch — Power Query salah membaca titik desimal sebagai pemisah ribuan | Menggunakan **"Change Type" → "Using Locale" (English US)**, serta menghapus step "Changed Type" otomatis yang merusak data lebih dulu |
| Chart menampilkan angka seragam/salah tabel | Field diambil dari tabel referensi (products) bukan tabel transaksi (order_products_prior) | Memastikan field numerik selalu diambil dari tabel transaksi 32 juta baris |
| Measure tidak bisa didrag ke axis chart | Measure menggunakan `FORMAT()` menghasilkan teks, bukan angka murni | Membuat measure terpisah tanpa `FORMAT()` khusus untuk visual (`Reorder Rate Numeric`) |
| Data avg_item_per_order tampil "1.0" semua | *Ternyata bukan bug* — hanya kebetulan sampel 10 baris pertama tanpa `ORDER BY` berasal dari kelompok customer yang homogen | Diverifikasi dengan query `COUNT(DISTINCT ...)` yang menunjukkan 3.391 nilai unik — data valid |
| Field hilang dari panel Data setelah edit measure | Home table measure "nyasar" ke tabel lain saat dibuat sambil tabel berbeda sedang ter-select | Memindahkan measure ke tabel yang benar melalui properti "Home Table" |

---

## Ringkasan Pencapaian

1. **Data Pipeline End-to-End:** CSV mentah → DuckDB (analisis) → MySQL (produksi) → Power BI (visualisasi), dengan verifikasi integritas data di setiap tahap perpindahan
2. **9 Analisis SQL Mendalam** menggunakan teknik SQL tingkat menengah hingga mahir
3. **Dashboard Interaktif 4 Halaman** (dari target 6) dengan berbagai jenis visual: KPI card, bar chart, heatmap matrix, donut chart, dan tabel data
4. **Kemampuan Troubleshooting** — menyelesaikan berbagai masalah teknis nyata seperti locale mismatch, tipe data yang salah terdeteksi, dan kesalahan referensi tabel

**Tools yang dikuasai dalam proyek ini:** SQL (DuckDB), MySQL (XAMPP), Power BI (DAX, Power Query/M, Data Modeling), serta konsep data pipeline dan ETL sederhana.
