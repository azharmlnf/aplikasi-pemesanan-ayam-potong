## ❌✅📊 Progress Iterasi (Detail & Terperinci)

---

### Iterasi Minggu ke-1 – Setup & Autentikasi Dasar

| Task                                                                                                  | Status |
| ----------------------------------------------------------------------------------------------------- | ------ |
| 1. Setup project Flutter dengan struktur folder dan dependensi dasar                                  | ✅      |
| 2. Setup Appwrite backend: konfigurasi auth & database collections                                    | ✅      |
| 3. Buat koleksi database di Appwrite: `users` (gabungkan profil & auth minimal data)                  | ✅      |
| 4. Buat koleksi database di Appwrite: `meetings`                                                      | ✅      |
| 5. Buat koleksi database di Appwrite: `notes`                                                         | ✅      |
| 6. Implementasi fungsi registrasi user baru dengan `account.create` (input email, password, username) | ✅      |
| 7. Implementasi fungsi login dengan `account.createEmailSession` (email + password)                   | ✅      |
| 8. Validasi input pada form registrasi dan login (email format, password kuat, username unik)         | ❌      |
| 9. Simpan data `email` dan `username` sebagai atribut tambahan pada dokumen `users`                   | ❌      |

**Total task = 9**
**Task selesai = 7**
**Persentase progress = (7/9) × 100% ≈ 77.78%**

---

### Iterasi Minggu ke-2 – Halaman Customer: Katalog & Keranjang

| Task                                                                                      | Status |
| ----------------------------------------------------------------------------------------- | ------ |
| 1. Desain UI halaman utama Customer untuk menampilkan daftar produk                       | ❌      |
| 2. Buat service untuk mengambil (fetch) data dari collection `products`                   | ❌      |
| 3. Tampilkan daftar produk di UI dengan gambar, nama, dan harga                           | ❌      |
| 4. Implementasi state management untuk keranjang belanja (local state atau provider/bloc) | ❌      |
| 5. Tambahkan fungsionalitas "Tambah ke Keranjang" pada setiap produk                      | ❌      |
| 6. Buat halaman Keranjang Belanja untuk menampilkan ringkasan & total harga               | ❌      |

**Total task = 6**
**Task selesai = 0**
**Persentase progress = (0/6) × 100% = 0%**

---

### Iterasi Minggu ke-3 – Checkout & Riwayat Pesanan

| Task                                                                                      | Status |
| ----------------------------------------------------------------------------------------- | ------ |
| 1. Implementasi fungsi Checkout dari halaman keranjang                                    | ❌      |
| 2. Buat dokumen baru di collection `orders` berdasarkan keranjang & status awal `pending` | ❌      |
| 3. Kosongkan keranjang belanja setelah pesanan berhasil dibuat                            | ❌      |
| 4. Tampilkan notifikasi atau dialog bahwa pesanan berhasil dibuat                         | ❌      |
| 5. Buat halaman "Riwayat Pesanan Saya" untuk customer                                     | ❌      |
| 6. Ambil dan tampilkan daftar pesanan berdasarkan `userId` customer yang login            | ❌      |

**Total task = 6**
**Task selesai = 0**
**Persentase progress = (0/6) × 100% = 0%**

---

### Iterasi Minggu ke-4 – Admin: Manajemen Produk (CRUD)

| Task                                                                                    | Status |
| --------------------------------------------------------------------------------------- | ------ |
| 1. Desain UI halaman Dashboard Admin dengan navigasi ke Produk & Pesanan                | ❌      |
| 2. Buat halaman daftar produk untuk Admin dengan tombol Aksi (Edit, Hapus)              | ❌      |
| 3. Buat form untuk menambah dan mengedit produk (nama, deskripsi, harga, stok)          | ❌      |
| 4. Implementasi upload gambar produk ke Appwrite Storage                                | ❌      |
| 5. Implementasi fungsi Create, Read, Update, dan Delete dokumen pada koleksi `products` | ❌      |

**Total task = 5**
**Task selesai = 0**
**Persentase progress = (0/5) × 100% = 0%**

---

### Iterasi Minggu ke-5 – Admin: Manajemen Pesanan

| Task                                                                            | Status |
| ------------------------------------------------------------------------------- | ------ |
| 1. Buat halaman daftar pesanan masuk untuk Admin                                | ❌      |
| 2. Ambil dan tampilkan semua data dari collection `orders`                      | ❌      |
| 3. Implementasi fungsi untuk mengubah status pesanan (`pending` -> `processed`) | ❌      |
| 4. Tambahkan feedback visual seperti loading indicator saat proses berlangsung  | ❌      |
| 5. Tambahkan penanganan error (contoh: tampilkan snackbar saat login gagal)     | ❌      |

**Total task = 5**
**Task selesai = 0**
**Persentase progress = (0/5) × 100% = 0%**

---

### Iterasi Minggu ke-6 – Pengujian & Rilis

| Task                                                                                        | Status |
| ------------------------------------------------------------------------------------------- | ------ |
| 1. Pengujian alur Customer (registrasi -> login -> pilih produk -> checkout -> riwayat)     | ❌      |
| 2. Pengujian alur Admin (login -> tambah produk -> lihat pesanan -> ubah status)            | ❌      |
| 3. Perbaikan bug kritis yang ditemukan selama pengujian end-to-end                          | ❌      |
| 4. Refactor dan clean up kode: konsistensi penamaan, hapus unused imports, komentar penting | ❌      |
| 5. Buat build rilis Android (.apk) dan persiapkan dokumentasi/manual deployment             | ❌      |

**Total task = 5**
**Task selesai = 0**
**Persentase progress = (0/5) × 100% = 0%**

---

📌 **Catatan:** Tanda ✅ berarti sudah selesai, ❌ berarti belum selesai. Progress diperbarui setiap akhir minggu untuk melacak kemajuan proyek secara objektif dan transparan.
