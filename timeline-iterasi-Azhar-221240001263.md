## ✅📊 Progress Iterasi (Detail & Terperinci)

---

### Iterasi Minggu ke-1 – Fondasi, Autentikasi & Profil Pengguna

| Task                                                                                                      | Status |
| --------------------------------------------------------------------------------------------------------- | ------ |
| 1. Setup project Flutter dengan struktur folder & dependensi (appwrite)                                   | ✅      |
| 2. Setup Appwrite: buat semua collections (profiles, products, orders, order\_items)                      | ✅      |
| 3. Buat Unique Index pada field username di collection profiles                                           | ✅      |
| 4. Implementasi fungsi registrasi (account.create) dengan input (email, password, nama)                   | ✅      |
| 5. Buat logic untuk membuat dokumen di profiles (dengan username, phone\_number, role) setelah registrasi | ✅      |
| 6. Implementasi fungsi login (account.createEmailPasswordSession) dan logout (account.deleteSession)      | ✅      |
| 7. Buat logic routing: setelah login, periksa role dari profiles & arahkan ke halaman sesuai              | ✅      |

**Total task = 7**
**Task selesai = 7**
**Persentase progress = (7/7) × 100% = 100%**

---

### Iterasi Minggu ke-2 – Halaman Admin: Manajemen Produk (CRUD)

| Task                                                                            | Status |
| ------------------------------------------------------------------------------- | ------ |
| 1. Buat halaman profile untuk Admin dan customer dengan tombol logout           | ✅      |
| 2. Buat halaman daftar produk untuk Admin dengan tombol Aksi (Edit, Hapus)      | ✅      |
| 3. Buat Form untuk menambah & mengedit produk (nama, deskripsi, harga, stok)    | ✅      |
| 4. Implementasi logic Create, Update, dan Delete untuk dokumen di products      | ✅      |
| 5. Implementasi fungsi upload gambar ke Appwrite Storage saat menambah produk   | ✅      |
| 6. Buat preview gambar yang diunggah sebelum dikirim ke Appwrite Storage        | ✅      |
| 7. Tampilkan gambar produk yang sudah disimpan pada halaman daftar produk Admin | ✅      |

**Total task = 7**
**Task selesai = 7**
**Persentase progress = (7/7) × 100% ≈ 100%**

---

### Iterasi Minggu ke-3 – Halaman Customer: Katalog & Keranjang Belanja

| Task                                                                        | Status |
| --------------------------------------------------------------------------- | ------ |
| 1. Buat service untuk mengambil (fetch) data dari collection products       | ✅      |
| 2. Tampilkan daftar produk di UI dengan gambar, nama, dan harga             | ✅      |
| 3. Implementasi state management untuk keranjang belanja (local state)      | ✅      |
| 4. Tambahkan fungsionalitas "Tambah ke Keranjang" & "Ubah Kuantitas"        | ✅      |
| 5. Buat halaman Keranjang Belanja untuk menampilkan ringkasan & total harga | ✅      |

**Total task = 5**
**Task selesai = 5**
**Persentase progress = (5/5) × 100% = 100%**

---

### Iterasi Minggu ke-4 – Proses Checkout & Pembuatan Pesanan

| Task                                                                                                      | Status |
| --------------------------------------------------------------------------------------------------------- | ------ |
| 1. Implementasi fungsi "Checkout" dari halaman keranjang                                                  | ❌      |
| 2. Langkah 1 Checkout: Buat dokumen baru di orders dengan status 'pending' dan totalPrice 0               | ❌      |
| 3. Langkah 2 Checkout: Loop setiap item di keranjang & buat dokumen baru di order\_items                  | ❌      |
| 4. Langkah 3 Checkout: Hitung total harga dari semua order\_items, lalu update field totalPrice di orders | ❌      |
| 5. Kosongkan keranjang belanja setelah semua proses berhasil                                              | ❌      |
| 6. Tampilkan notifikasi atau dialog bahwa pesanan berhasil dibuat                                         | ❌      |

**Total task = 6**
**Task selesai = 0**
**Persentase progress = (0/6) × 100% = 0%**

---

### Iterasi Minggu ke-5 – Dashboard Admin & Riwayat Customer

| Task                                                                                     | Status |
| ---------------------------------------------------------------------------------------- | ------ |
| 1. Buat halaman daftar pesanan masuk untuk Admin, tampilkan orderId, totalPrice, status  | ❌      |
| 2. Buat halaman detail pesanan Admin: tampilkan detail order\_items (produk, qty, harga) | ❌      |
| 3. Implementasi fungsi untuk mengubah status pesanan (pending -> processed) pada Admin   | ❌      |
| 4. Buat halaman "Riwayat Pesanan Saya" untuk Customer                                    | ❌      |
| 5. Ambil dan tampilkan data pesanan milik Customer yang sedang login                     | ❌      |

**Total task = 5**
**Task selesai = 0**
**Persentase progress = (0/5) × 100% = 0%**

---

### Iterasi Minggu ke-6 – Pengujian, Polishing, & Finalisasi

| Task                                                                                            | Status |
| ----------------------------------------------------------------------------------------------- | ------ |
| 1. Lakukan pengujian alur Customer (registrasi -> login -> pesan -> lihat riwayat)              | ❌      |
| 2. Lakukan pengujian alur Admin (login -> tambah produk -> lihat detail pesanan -> ubah status) | ❌      |
| 3. Tambahkan feedback visual (loading indicator, snackbar) di semua proses async                | ❌      |
| 4. Perbaiki semua bug kritis dan masalah UI/UX yang ditemukan saat pengujian                    | ❌      |
| 5. Buat build rilis untuk Android (.apk) dan persiapkan untuk build iOS                         | ❌      |

**Total task = 5**
**Task selesai = 0**
**Persentase progress = (0/5) × 100% = 0%**

---

📌 **Catatan:**

* Tanda ✅ berarti sudah selesai
* Tanda ❌ berarti belum selesai
* Progress dapat diperbarui setiap akhir minggu untuk melacak kemajuan proyek
