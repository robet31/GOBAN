# PRD Goban

## 1. Ringkasan Produk

Goban adalah marketplace layanan bengkel dan bantuan kendaraan berbasis lokasi. Pengguna dapat menemukan bengkel, memesan bantuan darurat ke lokasi, membayar melalui aplikasi, melacak pekerjaan, dan memberi ulasan. Penyedia layanan dapat berupa mitra bengkel, teknisi mandiri, atau pemilik mitra yang juga bekerja sebagai teknisi.

Dokumen ini mendefinisikan kebutuhan produk dan alur pengguna. Pilihan tech stack tidak dibahas dalam PRD ini.

## 2. Tujuan Produk

- Membantu pengguna memperoleh bantuan kendaraan yang relevan, transparan, dan cepat.
- Memungkinkan bengkel/mitra mengelola layanan, teknisi, order, harga, dan pendapatan.
- Memungkinkan teknisi menerima serta menyelesaikan pekerjaan lapangan dengan alur aman.
- Membuat biaya jasa, sparepart, dan biaya platform dapat disetujui serta diaudit.
- Mendukung layanan malam hari hanya dari mitra/teknisi yang aktif dan bersedia menerima emergency order.

## 3. Ruang Lingkup MVP

### Termasuk

- Kategori kendaraan motor dan mobil pribadi.
- Peta bengkel dan teknisi aktif.
- Pencarian dan filter penyedia layanan.
- Order panggilan segera dan booking bengkel.
- Layanan darurat ringan, jasa bengkel ringan, dan towing.
- Mitra dengan teknisi internal.
- Teknisi mandiri.
- Pemilik mitra yang dapat mengambil order sebagai teknisi.
- Pembayaran online, invoice, biaya platform, dan pembayaran tunai opsional.
- Persetujuan digital atas tambahan jasa atau sparepart.
- Pelacakan status order dan lokasi teknisi ketika order aktif.
- Rating, review, pembatalan, dan sengketa dasar.
- Dashboard administrasi untuk verifikasi serta moderasi.
- Estimasi biaya terperinci, OTP kedatangan, dan bukti pekerjaan.
- Booking slot bengkel, ketersediaan real-time, serta tiket garansi.
- Reminder servis, mode darurat aman, bengkel favorit, promo terkontrol, dan paket servis.

### Tidak Termasuk pada MVP

- Perbaikan mesin besar di lokasi.
- Perbaikan transmisi, rem berat, airbag, atau kelistrikan kompleks.
- Layanan kendaraan listrik bertegangan tinggi.
- Penjualan stok sparepart oleh Goban.
- Chat suara/video dan panggilan VoIP.
- Kendaraan berat, bus, alat berat, dan sistem fleet perusahaan.
- Langganan servis berkala.
- Program loyalitas/poin.
- Garasi kendaraan tersimpan sebagai fitur khusus; data kendaraan minimal tetap dikumpulkan saat membuat order.

## 4. Peran Pengguna

| Peran | Deskripsi | Kemampuan inti |
|---|---|---|
| User | Pemilik/pengguna kendaraan yang membutuhkan layanan | Cari, order, bayar, lacak, chat, review |
| Mitra | Pemilik atau pengelola bengkel | Kelola usaha, layanan, teknisi, order, pendapatan |
| Teknisi | Pelaksana pekerjaan lapangan atau bengkel | Online, terima tugas, diagnosis, ajukan biaya, selesaikan order |
| Admin | Tim internal Goban | Verifikasi, moderasi, sengketa, konfigurasi, monitoring |

Satu akun dapat memiliki lebih dari satu kapabilitas. Contohnya pemilik bengkel dapat memiliki profil Mitra dan Teknisi sekaligus.

## 5. Kategori Kendaraan dan Layanan

### Kategori kendaraan

| Fase | Kategori | Status |
|---|---|---|
| MVP | Motor dan skuter | Aktif |
| MVP | Mobil pribadi: hatchback, sedan, MPV, SUV | Aktif |
| Lanjutan | Pickup, blind van, minibus, kendaraan niaga ringan | Setelah validasi operasional |
| Lanjutan | Truk dan bus | Setelah mitra dan SOP khusus tersedia |
| Di luar scope | Alat berat | Tidak tersedia |

### Layanan panggilan MVP

| Kendaraan | Layanan |
|---|---|
| Motor | Tambal ban, ganti ban, ganti aki, ganti oli, diagnosis mogok ringan, towing motor |
| Mobil | Tambal ban, bantuan ban serep, ganti ban, jump-start, ganti aki, ganti oli, diagnosis mogok ringan, towing mobil |

### Layanan booking bengkel MVP

- Servis berkala.
- Penggantian oli, ban, aki, busi, dan rantai.
- Pemeriksaan rem ringan.
- Pemeriksaan AC mobil.
- Pemeriksaan kelistrikan dasar.
- Spooring/balancing bila mitra menyediakannya.

### Batasan keselamatan

Order harus dialihkan ke towing atau booking bengkel apabila kerusakan membutuhkan pembongkaran mesin, perbaikan rem berat, transmisi, airbag, sistem bahan bakar berbahaya, kelistrikan kompleks, atau berada di lokasi yang tidak aman.

## 6. Aturan Bisnis Utama

### Harga dan sparepart

- Harga awal memuat biaya panggilan dan jasa dasar.
- Harga sparepart tidak termasuk dalam harga awal, kecuali dinyatakan secara eksplisit.
- Sparepart disediakan oleh mitra/teknisi, bukan oleh Goban.
- Teknisi wajib mengajukan merek, kondisi, jumlah, harga, dan garansi sparepart sebelum pemasangan.
- User harus menyetujui revisi biaya di aplikasi sebelum teknisi memulai pekerjaan tambahan.
- Invoice akhir harus memisahkan biaya panggilan, jasa, sparepart, biaya platform, dan biaya pembayaran.

### Pembayaran dan pendapatan

- Pembayaran online menggunakan gateway pembayaran yang terintegrasi dengan Goban.
- Platform membebankan biaya platform tetap, misalnya Rp1.000 per transaksi online.
- Platform dapat memotong komisi penyedia layanan dari biaya jasa dan biaya panggilan, misalnya 6%.
- Harga dan biaya gateway harus dikonfirmasi sebelum user membayar.
- Pembayaran tunai hanya dapat diaktifkan oleh admin/mitra sesuai kebijakan area. Komisi atas order tunai harus tetap dapat ditagih kepada mitra.

### Tanggung jawab

- Mitra/teknisi bertanggung jawab terhadap stok, keaslian, kesesuaian, garansi, dan pemasangan sparepart.
- Goban menyimpan invoice, bukti persetujuan, status pembayaran, dan bukti order untuk membantu penyelesaian sengketa.
- Goban tidak menjamin ketersediaan sparepart sebelum mitra/teknisi mengonfirmasinya.

### Layanan malam

- Mitra/teknisi mengatur jam operasi normal dan pilihan `Emergency Online`.
- Hanya penyedia layanan yang online serta mengaktifkan layanan malam yang menerima order emergency.
- Tarif malam atau emergency harus ditampilkan sebelum user membuat order.
- Layanan malam dibatasi pada pekerjaan aman: ban, aki, jump-start, ganti oli ringan, dan towing.
- Sistem dapat memperluas radius pencarian apabila tidak ada penyedia yang menerima order.

## 7. Status Sistem

### Status order

| Status | Arti |
|---|---|
| draft | User sedang mengisi detail order |
| waiting | Order dibuat dan menunggu penyedia layanan |
| assigned | Mitra telah menerima order dan menugaskan teknisi |
| accepted | Teknisi menerima dan akan menuju lokasi/siap melayani |
| arrived | Teknisi tiba dan menunggu verifikasi user |
| diagnosing | Teknisi melakukan pemeriksaan |
| awaiting_approval | Menunggu persetujuan biaya tambahan dari user |
| ongoing | Pekerjaan sedang dilakukan |
| completion_pending | Teknisi mengajukan penyelesaian dan menunggu konfirmasi user |
| completed | Pekerjaan telah dinyatakan selesai |
| cancelled | Order dibatalkan |
| disputed | Ada keluhan atau sengketa aktif |

### Status pembayaran

| Status | Arti |
|---|---|
| unpaid | Belum ada pembayaran |
| pending | Menunggu hasil pembayaran gateway |
| paid | Pembayaran berhasil diterima |
| held | Dana ditahan sampai pekerjaan selesai/masa komplain |
| settled | Dana bersih sudah tersedia untuk mitra/teknisi |
| failed | Pembayaran gagal |
| expired | Waktu pembayaran habis |
| refunded | Dana dikembalikan ke user |

## 8. Flow Global Pertama Kali Membuka Aplikasi

```text
[Launch]
  -> [Splash]
  -> Apakah sesi login tersedia?
     -> Tidak: [Onboarding] -> [Masuk/Daftar]
     -> Ya: baca kapabilitas akun dan lanjut ke dashboard sesuai peran
  -> User baru: [Pilih Peran Awal]
     -> User: [Izin Lokasi] -> [Beranda Peta]
     -> Mitra: [Registrasi Mitra] -> [Menunggu Verifikasi]
     -> Teknisi: [Registrasi Teknisi] -> [Menunggu Verifikasi]
```

Peran awal tidak bersifat permanen. User dapat mengajukan penambahan kapabilitas Mitra atau Teknisi dari halaman profil.

## 9. PRD User

### Persona dan tujuan

User adalah pemilik kendaraan yang ingin mencari bengkel, memesan bantuan sekarang, atau membuat janji servis. Targetnya adalah mendapatkan penyedia layanan yang sesuai dengan kendaraan, lokasi, kebutuhan, harga, dan waktu yang tersedia.

### Navigasi utama User

```text
Beranda Peta | Order Saya | Notifikasi | Profil
```

### Daftar layar User

| ID | Layar | Tujuan | Fitur utama |
|---|---|---|---|
| U-01 | Splash | Memeriksa sesi dan konfigurasi awal | Logo, pemeriksaan sesi, fallback koneksi |
| U-02 | Onboarding | Menjelaskan manfaat aplikasi | Peta layanan, bantuan darurat, harga transparan, lanjut |
| U-03 | Masuk/Daftar | Membuat atau mengakses akun | Email/nomor telepon, kata sandi, Google opsional, syarat layanan |
| U-04 | Pilih Peran | Memilih penggunaan awal | Saya butuh layanan, saya punya bengkel, saya teknisi |
| U-05 | Izin Lokasi | Meminta lokasi dengan alasan jelas | Izinkan saat digunakan, isi lokasi manual, penjelasan privasi |
| U-06 | Beranda Peta | Menemukan layanan terdekat | Peta, marker, pencarian, filter, tombol darurat, tambah lokasi |
| U-07 | Filter | Mempersempit hasil | Kendaraan, layanan, jarak, rating, buka sekarang, emergency, harga |
| U-08 | Detail Mitra/Teknisi | Menilai penyedia layanan | Rating, layanan, harga dasar, jam, jarak, ulasan, tombol pesan |
| U-09 | Pilih Kendaraan | Menentukan kendaraan pada order | Motor/mobil, tipe, merek/model opsional, bahan bakar, nomor polisi opsional |
| U-10 | Pilih Layanan | Memilih kebutuhan | Daftar layanan sesuai kategori, mode sekarang/booking, deskripsi |
| U-11 | Detail Kendala | Memberi konteks teknisi | Foto, keterangan, kondisi kendaraan, lokasi aman/tidak aman |
| U-12 | Konfirmasi Lokasi | Menetapkan titik layanan | Titik peta, alamat, patokan, kontak di lokasi |
| U-13 | Ringkasan Order | Memeriksa harga estimasi | Biaya panggilan, jasa, catatan sparepart, tarif malam, metode bayar |
| U-14 | Pembayaran | Membayar order online | QRIS/VA/e-wallet, total final, status pembayaran |
| U-15 | Mencari Teknisi | Menunggu penerimaan order | Status pencarian, perluas radius, batalkan, estimasi respons |
| U-16 | Tracking Order | Memantau teknisi dan status | Peta, ETA perkiraan, status, chat, telepon, batalkan, bantuan |
| U-17 | Persetujuan Tambahan | Menyetujui jasa/sparepart tambahan | Detail produk, merek, kondisi, harga, garansi, setuju/tolak |
| U-18 | Konfirmasi Selesai | Menyatakan hasil pekerjaan | Ringkasan invoice, foto bukti, laporkan masalah |
| U-19 | Rating & Review | Menilai layanan | Rating, komentar, laporan masalah |
| U-20 | Riwayat Order | Melihat order masa lalu | Filter status/tanggal, detail invoice, review, bantuan |
| U-21 | Chat Order | Berkomunikasi dalam konteks order | Teks, foto, template pesan, status baca |
| U-22 | Notifikasi | Membaca pembaruan penting | Status order, pembayaran, promosi opsional |
| U-23 | Profil | Mengelola data akun | Profil, kendaraan tersimpan, alamat, metode pembayaran, bantuan |
| U-24 | Tambah Titik Bengkel | Mengusulkan lokasi bengkel | Nama, kategori, titik, foto, nomor telepon, status moderasi |
| U-25 | Bantuan/Sengketa | Mengajukan masalah | Kategori keluhan, bukti, status penanganan |

### Flow User: order panggilan segera

```text
[U-06 Beranda Peta]
  -> tekan "Butuh Bantuan Sekarang"
  -> [U-09 Pilih Kendaraan]
  -> [U-10 Pilih Layanan]
  -> [U-11 Detail Kendala]
  -> [U-12 Konfirmasi Lokasi]
  -> sistem menghitung kandidat, harga awal, dan tarif malam bila ada
  -> [U-13 Ringkasan Order]
  -> [U-14 Pembayaran] bila pembayaran online diwajibkan
  -> [U-15 Mencari Teknisi]
  -> teknisi menerima order
  -> [U-16 Tracking Order]
  -> teknisi tiba dan user memberi OTP
  -> teknisi melakukan diagnosis
  -> [U-17 Persetujuan Tambahan] bila jasa/sparepart berubah
  -> pekerjaan dimulai
  -> [U-18 Konfirmasi Selesai]
  -> [U-19 Rating & Review]
  -> [U-20 Riwayat Order]
```

### Flow User: booking bengkel

```text
[U-06 Beranda Peta]
  -> pilih marker mitra
  -> [U-08 Detail Mitra]
  -> tekan "Buat Janji"
  -> [U-09 Pilih Kendaraan]
  -> [U-10 Pilih Layanan]
  -> pilih slot tanggal dan waktu
  -> [U-13 Ringkasan Order]
  -> bayar deposit bila ditetapkan mitra
  -> order berstatus accepted setelah mitra menyetujui
  -> user datang ke bengkel
  -> diagnosis, persetujuan tambahan, pengerjaan, invoice, review
```

### Flow User: malam hari

```text
[U-06 Beranda Peta] pada jam emergency
  -> filter otomatis "Buka Sekarang" dan "Emergency"
  -> user memilih layanan aman
  -> order disebarkan ke penyedia layanan yang Emergency Online
  -> tidak ada penerima dalam batas waktu
     -> perluas radius
     -> tawarkan towing
     -> tampilkan saran keselamatan dan kontak darurat bila dibutuhkan
```

### Requirement pengalaman User

- Harga awal dan komponen harga selalu terlihat sebelum pembayaran.
- Pernyataan bahwa sparepart bukan stok Goban ditampilkan pada ringkasan order dan persetujuan tambahan.
- Nomor pribadi teknisi tidak ditampilkan sebelum order diterima.
- Chat internal adalah jalur utama untuk bukti komunikasi; WhatsApp hanya fallback setelah order diterima dan atas persetujuan user.
- Lokasi teknisi hanya terlihat untuk order aktif milik user tersebut.
- User dapat membatalkan sesuai kebijakan dan dapat mengajukan sengketa dari detail order.

## 10. PRD Mitra

### Persona dan tujuan

Mitra adalah pemilik atau pengelola bengkel. Mitra ingin mendapat order baru, mengelola daftar layanan, memantau teknisi internal, serta mengetahui pendapatan dan biaya platform secara transparan.

### Navigasi utama Mitra

```text
Dashboard | Order | Teknisi | Usaha | Keuangan
```

### Daftar layar Mitra

| ID | Layar | Tujuan | Fitur utama |
|---|---|---|---|
| M-01 | Registrasi Mitra | Mengajukan akun usaha | Data pemilik, nama usaha, lokasi, dokumen, rekening |
| M-02 | Pilih Layanan & Kategori | Mendefinisikan kemampuan bengkel | Motor/mobil, layanan, harga dasar, layanan panggilan |
| M-03 | Jam Operasional | Menentukan kesiapan melayani | Jam normal, jam emergency, hari libur, tarif malam |
| M-04 | Menunggu Verifikasi | Menjelaskan status pengajuan | Status, dokumen kurang, perbaiki pengajuan |
| M-05 | Dashboard Mitra | Ringkasan usaha | Order hari ini, order aktif, omzet, rating, status buka |
| M-06 | Order Masuk | Memutuskan penerimaan order | Detail order, terima/tolak, assignment teknisi, batas waktu |
| M-07 | Detail Order | Mengelola order hingga selesai | Status, user, harga, chat, teknisi, pembayaran, sengketa |
| M-08 | Assignment Teknisi | Menugaskan pekerja | Daftar teknisi cocok, lokasi/status, beban kerja, pilih teknisi |
| M-09 | Manajemen Teknisi | Mengelola anggota bengkel | Undang, verifikasi internal, izin, komisi, status aktif |
| M-10 | Profil Usaha | Mengubah informasi bengkel | Foto, alamat, layanan, fasilitas, nomor bisnis |
| M-11 | Katalog Layanan | Mengatur layanan dan harga | Harga jasa, biaya panggilan, batas kendaraan, stok indikatif |
| M-12 | Jam & Emergency | Mengaktifkan kesiapsiagaan malam | Toggle emergency, tarif, radius malam, layanan yang tersedia |
| M-13 | Keuangan | Memantau pemasukan | Saldo, settlement, komisi platform, invoice, pencairan |
| M-14 | Analitik | Memahami performa usaha | Order, pembatalan, rating, layanan populer, respons |
| M-15 | Ulasan | Membaca dan membalas review | Rating, tanggapan, laporkan ulasan abusive |
| M-16 | Pengaturan | Mengatur akun dan notifikasi | Rekening, PIN, notifikasi, kebijakan, logout |

### Flow Mitra: pendaftaran sampai aktif

```text
[M-01 Registrasi Mitra]
  -> isi penanggung jawab dan data bengkel
  -> [M-02 Pilih Layanan & Kategori]
  -> [M-03 Jam Operasional]
  -> isi rekening dan unggah dokumen
  -> [M-04 Menunggu Verifikasi]
  -> admin menyetujui
  -> [M-05 Dashboard Mitra]
```

### Flow Mitra: order panggilan

```text
Order masuk ke [M-06 Order Masuk]
  -> mitra meninjau kendaraan, layanan, lokasi, harga, dan catatan user
  -> mitra menolak atau menerima
  -> bila menerima:
       -> [M-08 Assignment Teknisi]
       -> pilih teknisi internal
       -> atau "Saya Kerjakan" bila pemilik juga teknisi
  -> status order menjadi assigned/accepted
  -> mitra memantau pekerjaan dari [M-07 Detail Order]
  -> setelah completed dan pembayaran tervalidasi
       -> nilai bersih muncul pada [M-13 Keuangan]
```

### Requirement Mitra

- Mitra dapat menjual sparepart miliknya sendiri, tetapi wajib mencantumkan detailnya dalam penawaran order.
- Mitra melihat komisi platform dan biaya pembayaran secara terpisah.
- Mitra dapat mengatur pembagian internal untuk teknisi, tetapi Goban menyimpan nilai pembayaran final pada invoice.
- Mitra dapat mengaktifkan emergency hanya jika memiliki teknisi/owner yang tersedia.
- Mitra tidak dapat mengubah data invoice yang sudah dibayar tanpa persetujuan user atau proses refund resmi.

## 11. PRD Teknisi

### Persona dan tujuan

Teknisi adalah pelaksana layanan di bengkel atau lapangan. Teknisi membutuhkan order yang relevan, informasi kerusakan yang lengkap, navigasi menuju user, perlindungan saat bekerja, serta kepastian pendapatan.

### Navigasi utama Teknisi

```text
Beranda | Order | Riwayat | Pendapatan | Profil
```

### Daftar layar Teknisi

| ID | Layar | Tujuan | Fitur utama |
|---|---|---|---|
| T-01 | Registrasi Teknisi | Mengajukan akun teknisi | Identitas, keahlian, kendaraan operasional, dokumen |
| T-02 | Keahlian & Area | Menetapkan kemampuan layanan | Kategori kendaraan, layanan, radius, jadwal |
| T-03 | Afiliasi Mitra | Bergabung dengan bengkel | Kode undangan, daftar mitra, status persetujuan |
| T-04 | Menunggu Verifikasi | Memeriksa status akun | Dokumen kurang, perbaiki data |
| T-05 | Beranda Teknisi | Mengelola kesiapan kerja | Toggle online, order aktif, ringkasan pendapatan, jam kerja |
| T-06 | Order Masuk | Menerima atau menolak order | Countdown, lokasi kasar, layanan, estimasi nilai, alasan tolak |
| T-07 | Detail Tugas | Menjalankan order | Navigasi, status, chat, user, pembayaran, prosedur |
| T-08 | Tiba & Verifikasi | Mengonfirmasi kehadiran | Tombol tiba, OTP user, masalah lokasi |
| T-09 | Diagnosis | Mencatat hasil pemeriksaan | Checklist, foto, kerusakan, rekomendasi towing |
| T-10 | Penawaran Tambahan | Mengajukan biaya tambahan | Jasa, sparepart, merek, kondisi, harga, garansi, foto |
| T-11 | Pekerjaan Berjalan | Menandai pelaksanaan | Mulai, checklist keselamatan, chat, foto proses |
| T-12 | Selesaikan Pekerjaan | Menutup tugas dengan bukti | Foto akhir, catatan, ringkasan invoice |
| T-13 | Riwayat | Melihat order sebelumnya | Filter, detail, rating, komplain |
| T-14 | Pendapatan | Melihat hasil kerja | Pendapatan, komisi, settlement, order mitra/mandiri |
| T-15 | Profil & Ketersediaan | Mengatur akun | Keahlian, radius, jadwal, dokumen, emergency online |

### Flow Teknisi mandiri: menerima sampai selesai

```text
[T-05 Beranda Teknisi]
  -> aktifkan Online
  -> [T-06 Order Masuk]
  -> terima order
  -> [T-07 Detail Tugas]
  -> navigasi menuju lokasi
  -> [T-08 Tiba & Verifikasi] dengan OTP user
  -> [T-09 Diagnosis]
  -> [T-10 Penawaran Tambahan] jika perlu jasa/sparepart lain
  -> user menyetujui
  -> [T-11 Pekerjaan Berjalan]
  -> [T-12 Selesaikan Pekerjaan]
  -> user mengonfirmasi/review
  -> [T-14 Pendapatan] menampilkan nilai bersih
```

### Flow Teknisi internal Mitra

```text
Mitra menerima order
  -> Mitra menugaskan teknisi
  -> teknisi menerima notifikasi tugas
  -> teknisi menerima atau menolak sesuai izin mitra
  -> teknisi menjalankan flow pekerjaan yang sama
  -> pendapatan tercatat sebagai order mitra
  -> pembagian pendapatan mengikuti pengaturan internal mitra
```

### Requirement Teknisi

- Teknisi hanya mendapat order sesuai keahlian, kategori kendaraan, area, dan status online.
- Teknisi wajib menggunakan status `tiba`, `diagnosis`, `ongoing`, dan `selesai` untuk order lapangan.
- Teknisi wajib menggunakan penawaran digital untuk tambahan biaya.
- Teknisi dapat menandai lokasi tidak aman dan meminta order dialihkan ke towing.
- Teknisi tidak dapat melihat detail pembayaran sensitif selain informasi yang diperlukan untuk pekerjaan dan pendapatan.
- Lokasi teknisi hanya dibagikan saat menerima dan menjalankan order aktif.

## 12. PRD Admin

### Tujuan

Admin menjaga kualitas marketplace, menyetujui mitra/teknisi, memoderasi lokasi dan review, menangani sengketa, serta mengatur kebijakan operasional.

### Daftar layar Admin

| ID | Layar | Tujuan | Fitur utama |
|---|---|---|---|
| A-01 | Login Admin | Akses aman admin | Login, MFA bila tersedia |
| A-02 | Dashboard | Melihat kondisi platform | User, mitra, order, GMV, pending verification, sengketa |
| A-03 | Verifikasi Mitra | Menilai pengajuan bengkel | Dokumen, lokasi, layanan, approve/reject, catatan |
| A-04 | Verifikasi Teknisi | Menilai pengajuan teknisi | Identitas, keahlian, dokumen, approve/reject |
| A-05 | Monitor Order | Memantau semua order | Filter status, lokasi, user, mitra, pembayaran, timeline |
| A-06 | Sengketa & Refund | Menangani keluhan | Bukti chat/foto, keputusan, refund, hold settlement |
| A-07 | Moderasi Lokasi | Menilai titik bengkel usulan | Validasi data, approve/reject, duplikasi |
| A-08 | Moderasi Review | Menangani konten abusive | Sembunyikan, pulihkan, keputusan |
| A-09 | Keuangan | Mengawasi uang platform | Settlement, fee, komisi, refund, rekonsiliasi |
| A-10 | Konfigurasi | Mengatur parameter bisnis | Kategori, layanan, harga minimum, komisi, radius, tarif malam |
| A-11 | Pengguna & Akses | Mengelola akun | Suspend, ban, reset verifikasi, audit log |

## 13. Flow Pembayaran, Sparepart, dan Settlement

```text
User menyetujui ringkasan harga awal
  -> Backend membuat tagihan pembayaran
  -> Gateway mengonfirmasi pembayaran
  -> Order ditandai paid/held
  -> Teknisi melakukan diagnosis
  -> Jika ada biaya tambahan:
       -> teknisi mengajukan rincian jasa/sparepart
       -> user menyetujui atau menolak
       -> sistem memperbarui invoice/tagihan sesuai kebijakan
  -> Pekerjaan selesai
  -> user mengonfirmasi atau masa komplain berakhir
  -> dana diselesaikan ke mitra/teknisi
  -> platform mencatat biaya platform dan komisi
```

### Contoh invoice

```text
Biaya panggilan                         Rp25.000
Jasa ganti aki                           Rp50.000
Aki 35 Ah, merek dan kondisi disetujui Rp720.000
Biaya platform                           Rp1.000
Biaya payment gateway                    Rp5.000
-------------------------------------------------
Total                                    Rp801.000
```

## 14. Chat, Komunikasi, dan Privasi

- Chat internal aktif otomatis setelah order diterima.
- Chat mendukung teks, foto, lokasi order, dan template pesan.
- Pesan order disimpan sebagai bukti sengketa sesuai kebijakan retensi data.
- Nomor telepon pribadi tidak ditampilkan sebelum order diterima.
- Tombol WhatsApp dapat menjadi fallback setelah order diterima dan dengan persetujuan user, tetapi perubahan harga tetap harus dibuat di aplikasi.
- Informasi lokasi presisi user dan teknisi dibatasi hanya untuk pihak yang terlibat dalam order aktif dan admin berwenang.

## 15. Notifikasi

| Kejadian | Penerima | Kanal minimum |
|---|---|---|
| Order dibuat | Kandidat mitra/teknisi | Push dan in-app |
| Order diterima/ditolak | User | Push dan in-app |
| Teknisi ditugaskan | Teknisi dan user | Push dan in-app |
| Teknisi hampir tiba/tiba | User | Push dan in-app |
| Penawaran tambahan | User | Push, in-app, penanda urgent |
| Pembayaran berhasil/gagal | User dan mitra | Push dan in-app |
| Order selesai | User, mitra, teknisi | Push dan in-app |
| Review/komplain baru | Mitra/admin | Push dan in-app |

## 16. Pembatalan dan Sengketa

| Situasi | Keputusan awal |
|---|---|
| User membatalkan sebelum order diterima | Gratis |
| Teknisi membatalkan sebelum mulai bergerak | User tidak dikenakan biaya; performa teknisi dicatat |
| User membatalkan setelah teknisi bergerak | Biaya perjalanan dapat berlaku jika aturan dan bukti lokasi terpenuhi |
| Teknisi tidak datang | User menerima refund sesuai pembayaran; teknisi/mitra mendapat penalti |
| Pekerjaan tidak dapat dilakukan | Biaya diagnosis/panggilan hanya bila disetujui user |
| User mempermasalahkan harga atau kualitas | Settlement ditahan; admin memeriksa bukti |

## 17. Metrik Keberhasilan MVP

- Waktu rata-rata order dibuat sampai diterima.
- Persentase order yang berhasil ditugaskan.
- Waktu kedatangan teknisi.
- Persentase order selesai tanpa sengketa.
- Tingkat pembatalan oleh user dan penyedia layanan.
- Rating rata-rata mitra/teknisi.
- Persentase persetujuan biaya tambahan.
- Nilai transaksi kotor, komisi platform, dan biaya refund.
- Retensi user dan mitra dalam 30 hari.

## 18. Fitur Produk yang Disetujui

### 1. Estimasi biaya transparan

- Ringkasan order menampilkan biaya panggilan, jasa dasar, tarif malam, biaya platform, biaya gateway, dan total.
- Sparepart tidak termasuk kecuali secara eksplisit sudah ada dalam paket.
- Revisi harga hanya dapat diajukan teknisi/mitra dari order aktif dan harus disetujui user.
- Invoice akhir menyimpan semua komponen biaya dan persetujuannya.

### 2. OTP kedatangan teknisi

- Sistem membuat OTP unik setelah order diterima.
- User memberikan OTP hanya saat teknisi benar-benar tiba di lokasi.
- Teknisi memasukkan OTP untuk mengubah status dari `accepted` menjadi `arrived`.
- Bila OTP tidak cocok atau user tidak dapat ditemukan, teknisi memilih alasan masalah lokasi dan menghubungi user lewat chat order.

### 3. Bukti pekerjaan

- Teknisi mengunggah foto kondisi sebelum pekerjaan bila relevan.
- Teknisi mengunggah foto hasil pekerjaan dan catatan penyelesaian.
- Teknisi mencatat checklist layanan dan sparepart yang dipasang.
- Bukti disimpan pada detail order untuk user, mitra, teknisi, dan admin saat sengketa.

### 4. Ketersediaan dan jam operasional real-time

- Mitra mengatur jam operasional reguler, hari libur, dan jam emergency.
- Teknisi mengatur status online/offline serta kesiapan menerima order.
- User melihat badge `Buka`, `Tutup`, `Emergency`, atau `Tidak tersedia`.
- Order panggilan hanya dikirim kepada penyedia layanan yang benar-benar tersedia.

### 5. Booking slot bengkel

- Mitra mengatur slot waktu, durasi layanan, dan kapasitas kendaraan per slot.
- User memilih layanan, kendaraan, tanggal, dan slot yang tersedia.
- Mitra dapat menerima, menolak, atau mengusulkan perubahan jadwal.
- Sistem mengirim pengingat sebelum jadwal booking.

### 6. Garansi jasa dan sparepart

- Mitra menentukan ketentuan garansi per layanan atau produk.
- Detail garansi tampil sebelum user menyetujui penawaran dan pada invoice akhir.
- User dapat membuat tiket garansi dari riwayat order selama masa garansi masih aktif.
- Admin dapat menahan settlement atau membantu mediasi bila tiket menjadi sengketa.

### 7. Reminder servis

- User dapat mengaktifkan pengingat ganti oli, cek ban, cek aki, atau servis berkala.
- Pengingat didasarkan pada tanggal order terakhir; input kilometer dapat ditambahkan kemudian.
- Notifikasi mengarahkan user ke bengkel favorit atau pencarian bengkel terdekat.
- User dapat menonaktifkan setiap jenis pengingat dari pengaturan notifikasi.

### 8. Mode darurat aman

- User memilih konteks lokasi: rumah, parkiran, jalan umum, atau lokasi tidak aman.
- Aplikasi menampilkan panduan keselamatan sesuai kondisi, seperti menyalakan hazard atau berpindah ke tempat aman bila memungkinkan.
- Sistem memprioritaskan mitra/teknisi `Emergency Online` dan layanan towing bila kerusakan tidak aman dikerjakan di lokasi.
- Teknisi berhak menolak lokasi berisiko serta meminta order dialihkan ke towing.

### 9. Favorit dan langganan bengkel

- User dapat menandai mitra atau teknisi sebagai favorit setelah melihat profil atau menyelesaikan order.
- Daftar favorit tersedia di profil dan saat membuat order berikutnya.
- User dapat memilih mitra favorit terlebih dahulu; bila tidak tersedia, sistem menawarkan penyedia terdekat.
- Fitur ini tidak menjamin ketersediaan atau harga khusus tanpa program promo/paket yang aktif.

### 10. Promo terkontrol

- Admin membuat promo berdasarkan kota, layanan, kategori kendaraan, waktu, atau mitra tertentu.
- Promo hanya dapat diterapkan pada komponen harga yang ditentukan, misalnya jasa atau biaya panggilan.
- Diskon sparepart hanya dapat digunakan bila mitra menyetujuinya.
- Ringkasan order dan invoice menunjukkan nilai diskon serta pihak yang menanggung promo.

### 11. Paket servis

- Mitra dapat membuat paket layanan, misalnya ganti oli + pemeriksaan rem ringan + cek aki.
- Paket menyebutkan item yang termasuk, harga, durasi, kategori kendaraan, dan ketentuan sparepart.
- User dapat memesan paket sebagai booking bengkel atau layanan panggilan bila mitra mengaktifkannya.
- Perubahan di luar item paket harus diajukan sebagai tambahan biaya yang memerlukan persetujuan user.

### Ditunda

- Garasi kendaraan dengan data spesifikasi lengkap.
- Program loyalitas, poin, atau penukaran hadiah.

## 19. Spesifikasi Flow Fitur per Role

Bagian ini adalah sumber acuan implementasi fitur yang disetujui. Sebuah aksi hanya boleh mengubah status bila aktor memiliki hak akses terhadap order tersebut. Semua perubahan penting dicatat pada timeline order.

### 19.1 Estimasi harga dan persetujuan tambahan

#### Data yang wajib tersimpan

- Harga jasa dasar dan biaya panggilan saat order dibuat.
- Tarif emergency/malam jika berlaku.
- Biaya platform, diskon, dan biaya gateway.
- Setiap versi penawaran tambahan, pembuat, waktu, alasan, dan status persetujuan.
- Item sparepart: nama, merek, kondisi, jumlah, harga satuan, garansi, dan foto opsional.

#### Flow User

```text
User membuka Ringkasan Order
  -> melihat estimasi awal dan catatan bahwa sparepart belum termasuk
  -> menyetujui dan membuat order
  -> setelah diagnosis, menerima notifikasi penawaran tambahan
  -> membuka detail item dan total baru
  -> memilih Setujui, Tolak, atau Hubungi Teknisi melalui chat
  -> Setujui: order kembali dapat dikerjakan; invoice versi baru aktif
  -> Tolak: teknisi melanjutkan pekerjaan awal, menawarkan alternatif, atau merekomendasikan towing/booking
```

#### Flow Teknisi

```text
Status order = diagnosing
  -> teknisi memilih "Ajukan Biaya Tambahan"
  -> menambah jasa atau sparepart beserta bukti pendukung
  -> sistem memvalidasi harga, jumlah, dan alasan
  -> status order = awaiting_approval
  -> user menyetujui: teknisi menerima notifikasi dan dapat menekan "Mulai Pekerjaan"
  -> user menolak: teknisi tidak dapat memasang item yang ditolak
```

#### Flow Mitra dan Admin

- Mitra dapat mengajukan atau meninjau penawaran dari teknisi internal, tetapi tidak dapat mengubah penawaran yang sudah disetujui user.
- Admin dapat melihat seluruh versi penawaran saat menangani sengketa, tanpa dapat mengedit histori asli.
- Admin dapat memberi batas harga minimum/maksimum per layanan untuk mendeteksi harga tidak wajar.

#### Validasi dan fallback

- Penawaran tidak boleh diajukan sebelum status `arrived` atau `diagnosing`.
- Penawaran kedaluwarsa bila user tidak merespons dalam batas waktu yang dikonfigurasi; order kembali ke `diagnosing`.
- Bila payment tambahan diperlukan, pekerjaan tambahan hanya boleh dimulai setelah pembayaran tambahan tervalidasi atau user memilih pembayaran tunai yang diizinkan.
- Setiap persetujuan harus menyimpan waktu, nominal, dan versi penawaran yang disetujui.

### 19.2 OTP kedatangan teknisi

#### Flow User

```text
Order diterima
  -> aplikasi membuat OTP enam digit dan menyimpannya pada Tracking Order
  -> user tidak membagikan OTP melalui chat sebelum teknisi ada di lokasi
  -> teknisi tiba, user memverifikasi identitas dasar
  -> user menyebutkan OTP
  -> aplikasi menampilkan status "Teknisi telah tiba"
```

#### Flow Teknisi

```text
Teknisi sampai di titik order
  -> tekan "Saya Tiba"
  -> memasukkan OTP dari user
  -> OTP valid: status accepted menjadi arrived
  -> OTP tidak valid: tampilkan percobaan tersisa dan tombol "Tidak menemukan user"
```

#### Flow Mitra dan Admin

- Mitra melihat waktu tiba teknisi dan dapat meninjau kegagalan OTP dari detail order.
- Admin dapat melihat audit OTP untuk sengketa, tetapi tidak melihat nilai OTP mentah setelah order selesai.

#### Validasi dan fallback

- OTP berlaku satu kali dan hanya selama order aktif.
- Batas percobaan harus membatasi percobaan acak.
- Jika user tidak dapat menerima OTP karena perangkat bermasalah, user dapat meminta verifikasi alternatif melalui chat; admin/mitra tidak boleh membagikan OTP secara bebas.
- Jika teknisi menandai user tidak ditemukan, user menerima notifikasi dan waktu tunggu pembatalan dimulai.

### 19.3 Bukti pekerjaan dan checklist

#### Flow Teknisi

```text
Status order = arrived
  -> teknisi mengambil foto kondisi awal bila relevan
  -> teknisi memilih checklist layanan sesuai jenis order
  -> pekerjaan dilakukan
  -> teknisi mengambil foto hasil akhir dan menulis catatan hasil
  -> teknisi menekan "Ajukan Penyelesaian"
  -> status order = completion_pending bila konfirmasi user diwajibkan
```

#### Flow User

```text
User menerima notifikasi pekerjaan selesai
  -> membuka ringkasan hasil, checklist, foto, dan invoice
  -> memilih "Konfirmasi Selesai" atau "Ada Masalah"
  -> Konfirmasi Selesai: order menjadi completed
  -> Ada Masalah: order menjadi disputed dan user mengisi alasan/bukti
```

#### Flow Mitra dan Admin

- Mitra dapat melihat bukti pekerjaan order miliknya dan meminta teknisi melengkapi bukti sebelum settlement.
- Admin dapat menggunakan foto, checklist, dan timeline sebagai bukti sengketa.

#### Validasi dan fallback

- Foto bersifat wajib untuk layanan yang berhubungan dengan pemasangan sparepart, ban, aki, atau towing; admin dapat mengatur daftar layanan yang wajib bukti.
- Jika kamera/perangkat bermasalah, teknisi dapat memberi alasan; mitra/admin dapat meninjau manual.
- Bukti tidak dapat dihapus setelah order selesai, tetapi dapat diberi catatan koreksi yang terekam.

### 19.4 Ketersediaan real-time dan jam operasi

#### Flow Mitra

```text
Mitra membuka Jam & Emergency
  -> mengatur jam reguler per hari
  -> menentukan hari libur dan jam emergency
  -> memilih layanan yang tersedia pada emergency
  -> mengatur radius dan tarif emergency
  -> menyimpan perubahan
  -> profil publik memperbarui badge ketersediaan
```

#### Flow Teknisi

```text
Teknisi membuka Beranda
  -> memilih Online
  -> sistem memeriksa akun verified, area, layanan, dan tidak ada order konflik
  -> status tersedia diperbarui
  -> teknisi memilih Offline atau menyelesaikan order aktif
```

#### Flow User

- User melihat status `Buka`, `Tutup`, `Emergency`, dan `Teknisi tersedia` di peta serta halaman detail.
- Filter `Buka Sekarang` dan `Emergency` hanya menampilkan kandidat yang dapat menerima order saat itu.

#### Validasi dan fallback

- Mitra tidak dapat menyalakan emergency bila tidak ada pemilik/teknisi yang tersedia.
- Teknisi dengan order aktif tidak menerima order panggilan baru kecuali kapasitasnya diatur lebih dari satu.
- Jika status lokasi teknisi tidak diperbarui dalam interval yang ditentukan, sistem dapat menandai teknisi tidak tersedia untuk matching baru tanpa membatalkan order aktif.

### 19.5 Booking slot bengkel

#### Flow Mitra

```text
Mitra membuka Pengaturan Slot
  -> memilih layanan yang dapat dibooking
  -> menetapkan durasi dan kapasitas setiap slot
  -> menentukan jadwal reguler, hari libur, dan batas waktu booking
  -> slot tersedia tampil pada profil mitra
```

#### Flow User

```text
User membuka Detail Mitra
  -> memilih "Buat Janji"
  -> memilih kendaraan, layanan, tanggal, dan slot
  -> melihat harga/deposit serta kebijakan pembatalan
  -> membuat booking
  -> mitra menerima atau mengusulkan ulang jadwal
  -> user menerima notifikasi konfirmasi
  -> user datang dan menunjukkan kode booking
  -> order diproses dengan diagnosis, penawaran tambahan, dan invoice biasa
```

#### Flow Teknisi dan Admin

- Teknisi mitra melihat agenda kerja dan order booking yang ditugaskan kepadanya.
- Admin dapat mengatur batas pembatalan dan melihat konflik kapasitas, tetapi tidak mengubah slot mitra secara langsung kecuali ada tindakan moderasi.

#### Validasi dan fallback

- Slot tidak boleh dipesan setelah melewati batas waktu yang ditetapkan mitra.
- Kapasitas berkurang secara atomik saat booking dibuat agar satu slot tidak terjual berlebihan.
- Jika mitra menolak, deposit yang sudah dibayar harus dibatalkan atau dikembalikan sesuai kebijakan.
- Jika user terlambat, status booking menjadi `no_show` setelah masa toleransi dan mengikuti aturan pembatalan.

### 19.6 Garansi jasa dan sparepart

#### Flow Mitra

```text
Mitra mengatur Katalog Layanan atau Produk
  -> menambahkan durasi garansi, syarat, dan pengecualian
  -> ketentuan tampil saat user memesan atau menyetujui sparepart
  -> ketentuan dikunci pada invoice order yang selesai
```

#### Flow User

```text
User membuka Riwayat Order
  -> memilih order dengan garansi aktif
  -> tekan "Ajukan Garansi"
  -> memilih masalah, menambahkan deskripsi/foto, dan mengirim tiket
  -> mitra menerima tiket
  -> mitra menyetujui inspeksi, menawarkan solusi, atau menolak dengan alasan
  -> user menerima hasil atau meneruskan sebagai sengketa
```

#### Flow Teknisi dan Admin

- Teknisi menerima tugas inspeksi garansi bila ditugaskan mitra.
- Admin memediasi bila mitra dan user tidak sepakat, dan dapat menahan settlement pada order terkait jika masih dalam aturan yang berlaku.

#### Validasi dan fallback

- Tiket hanya dapat dibuat sebelum masa garansi berakhir.
- Garansi tidak otomatis berarti refund; hasilnya bisa inspeksi, perbaikan ulang, penggantian, atau penolakan beralasan.
- Ketentuan garansi versi awal tetap menjadi acuan meskipun mitra kemudian mengubah katalog umum.

### 19.7 Reminder servis

#### Flow User

```text
Setelah order layanan berkala selesai
  -> aplikasi menawarkan "Aktifkan Reminder"
  -> user memilih jenis reminder dan interval tanggal
  -> sistem menyimpan preferensi notifikasi
  -> saat jatuh tempo, user menerima reminder
  -> user memilih booking mitra favorit, mencari bengkel, atau mengabaikan reminder
```

#### Flow Mitra, Teknisi, dan Admin

- Mitra dapat menentukan layanan mana yang menawarkan reminder default, tetapi tidak dapat mengirim spam di luar preferensi user.
- Teknisi tidak dapat mengakses pengaturan reminder user.
- Admin mengatur batas frekuensi, opt-out, dan template notifikasi.

#### Validasi dan fallback

- User dapat menonaktifkan reminder per kendaraan atau per jenis layanan.
- Tidak ada reminder bila user belum menyetujui notifikasi non-transaksional.
- Reminder harus mengarahkan ke tindakan jelas, bukan hanya pesan promosi.

### 19.8 Mode darurat aman

#### Flow User

```text
User memilih "Butuh Bantuan Sekarang"
  -> memilih kondisi lokasi: rumah, parkiran, jalan umum, atau tidak aman
  -> memilih jenis kendala dan mengunggah foto bila aman dilakukan
  -> aplikasi menampilkan panduan keselamatan sesuai kondisi
  -> sistem hanya menampilkan layanan yang layak dikerjakan di lokasi
  -> user membuat order emergency
  -> jika tidak ada kandidat, sistem menawarkan perluas radius atau towing
```

#### Flow Teknisi dan Mitra

- Teknisi menerima penanda konteks keamanan sebelum mengambil order.
- Teknisi dapat menolak pekerjaan jika lokasi atau jenis kerusakan tidak aman.
- Mitra menentukan layanan emergency yang siap dilayani, kendaraan operasional, radius, dan tarif malam.

#### Flow Admin

- Admin mengatur kategori kerusakan yang harus dialihkan ke towing/booking.
- Admin meninjau laporan keselamatan dan dapat menonaktifkan akun yang berulang kali melanggar SOP.

#### Validasi dan fallback

- Aplikasi tidak boleh memberi instruksi perbaikan teknis yang berbahaya kepada user.
- Jika user menandai lokasi tidak aman, chat menampilkan template keselamatan dan tombol kontak darurat lokal yang dapat dikonfigurasi per wilayah.
- Status order tidak menggantikan layanan polisi, ambulans, atau layanan darurat resmi.

### 19.9 Favorit dan langganan bengkel

#### Flow User

```text
User membuka Detail Mitra/Teknisi atau order selesai
  -> tekan ikon Favorit
  -> penyedia tersimpan pada Profil > Favorit
  -> saat membuat order baru, user dapat memilih penyedia favorit
  -> sistem memeriksa layanan, jam, radius, dan status online
  -> tersedia: order dikirimkan langsung sesuai kebijakan
  -> tidak tersedia: user melihat alternatif terdekat
```

#### Flow Mitra, Teknisi, dan Admin

- Mitra/teknisi melihat jumlah favorit secara agregat, tanpa melihat identitas user yang menandai favorit.
- Admin dapat menghapus hubungan favorit hanya untuk penanganan penghapusan akun atau pelanggaran data.

#### Validasi dan fallback

- Favorit tidak otomatis memberi prioritas terhadap order emergency bila penyedia tidak aktif.
- User dapat menghapus favorit kapan saja.

### 19.10 Promo terkontrol

#### Flow Admin

```text
Admin membuat promo
  -> menentukan nama/kode, periode, kuota, area, target pengguna, layanan, dan mitra
  -> menentukan penanggung diskon: platform atau mitra
  -> menetapkan komponen yang boleh didiskon
  -> menerbitkan promo
  -> sistem memvalidasi kelayakan saat checkout
  -> admin memantau penggunaan, biaya, dan penyalahgunaan
```

#### Flow Mitra dan User

- Mitra dapat menyetujui promo yang ditanggung mitra sebelum dipublikasikan.
- User memasukkan kode promo atau memilih promo yang tersedia di Ringkasan Order.
- Sistem menampilkan alasan bila promo tidak valid, misalnya kuota habis, layanan tidak sesuai, atau belum memenuhi nilai minimum.
- Invoice menampilkan diskon dan penanggung biaya promo.

#### Validasi dan fallback

- Promo tidak dapat mendiskon sparepart kecuali mitra menyetujuinya.
- Satu order hanya dapat memakai satu promo kecuali admin menandai promo dapat digabung.
- Promo dihitung ulang pada server saat pembuatan order agar tidak dapat dimanipulasi dari aplikasi.

### 19.11 Paket servis

#### Flow Mitra

```text
Mitra membuka Katalog Paket
  -> membuat paket dengan nama, kendaraan, layanan, durasi, harga, dan masa berlaku
  -> memilih item yang termasuk dan item yang tidak termasuk
  -> menentukan apakah paket tersedia untuk booking, panggilan, atau keduanya
  -> menerbitkan paket setelah validasi admin bila diperlukan
```

#### Flow User

```text
User membuka profil mitra atau pencarian paket
  -> memilih paket sesuai kendaraan
  -> membaca item termasuk, estimasi durasi, syarat, dan sparepart yang tidak termasuk
  -> memilih booking atau panggilan jika tersedia
  -> checkout menggunakan alur order biasa
  -> teknisi menjalankan checklist paket
  -> item di luar paket harus diajukan sebagai biaya tambahan
```

#### Flow Teknisi dan Admin

- Teknisi melihat checklist paket dan tidak dapat menandai semua item selesai tanpa mengisi bukti yang diwajibkan.
- Admin dapat memoderasi paket yang memiliki deskripsi menyesatkan atau harga tidak wajar.

#### Validasi dan fallback

- Harga paket dikunci ketika user checkout.
- Paket tidak dapat digunakan jika kendaraan atau layanan tidak sesuai syarat paket.
- Jika item paket tidak dapat dikerjakan, teknisi harus memilih alasan dan mitra menawarkan solusi, penjadwalan ulang, atau refund parsial sesuai kebijakan.

## 20. Flow Implementasi untuk Development

Bagian ini menjelaskan urutan pembangunan produk tanpa menetapkan bahasa, framework, vendor, atau infrastruktur.

### 20.1 Urutan pembangunan

| Tahap | Hasil yang harus selesai | Dependensi bisnis |
|---|---|---|
| 1. Fondasi akun | Login, profil, kapabilitas role, verifikasi dasar, izin akses | Aturan role dan dokumen |
| 2. Master operasional | Kategori kendaraan, layanan, area, harga dasar, jam operasi, status online | Konfigurasi admin |
| 3. Marketplace | Peta/listing, filter, profil mitra/teknisi, favorit | Data mitra/teknisi verified |
| 4. Order inti | Buat order, matching, terima/tolak, assignment, status order, timeline | Tahap 1-3 |
| 5. Pelaksanaan aman | Tracking aktif, chat order, OTP, diagnosis, bukti kerja | Order inti |
| 6. Harga dan pembayaran | Penawaran tambahan, invoice versi, payment status, settlement | Order inti dan aturan komisi |
| 7. Booking dan paket | Slot, kapasitas, deposit, paket servis | Mitra, katalog layanan, pembayaran |
| 8. Pasca-layanan | Garansi, sengketa, review, reminder | Invoice dan bukti kerja |
| 9. Growth terkontrol | Promo dan analitik operasional | Checkout dan konfigurasi admin |

### 20.2 Flow pengembangan order inti

```text
Developer menyelesaikan definisi status order
  -> buat validasi transisi status berdasarkan role
  -> buat timeline/audit untuk setiap transisi
  -> buat create order dengan harga dasar server-side
  -> buat matching kandidat sesuai layanan, area, jam, dan online status
  -> buat proses penerimaan atomik agar satu order hanya memiliki satu penerima
  -> buat assignment mitra ke teknisi
  -> buat notifikasi setiap transisi
  -> uji skenario berhasil, ditolak, timeout, dan dibatalkan
```

### 20.3 Aturan perubahan status untuk developer

| Status asal | Status tujuan | Aktor yang diizinkan | Syarat |
|---|---|---|---|
| draft | waiting | User | Detail order dan harga awal valid |
| waiting | accepted | Teknisi mandiri | Kandidat valid; belum ada penerima lain |
| waiting | assigned | Mitra | Mitra menerima order dan menugaskan teknisi internal yang valid |
| assigned | accepted | Teknisi ditugaskan | Teknisi menerima tugas |
| accepted | arrived | Teknisi | OTP valid atau prosedur fallback disetujui |
| arrived | diagnosing | Teknisi | Kehadiran tercatat |
| diagnosing | awaiting_approval | Teknisi/mitra | Penawaran tambahan valid |
| awaiting_approval | diagnosing | User | Penawaran ditolak/kedaluwarsa |
| awaiting_approval | ongoing | User + sistem | Penawaran disetujui dan pembayaran valid bila wajib |
| diagnosing | ongoing | Teknisi | Tidak ada biaya tambahan |
| ongoing | completion_pending | Teknisi | Bukti kerja minimum lengkap |
| completion_pending | completed | User/sistem | User mengonfirmasi atau masa komplain berakhir |
| status aktif | cancelled | Pihak berwenang | Sesuai kebijakan pembatalan |
| status aktif/selesai | disputed | User/admin | Alasan dan bukti minimum tersedia |

### 20.4 Implementasi harga dan pembayaran

```text
Developer membuat katalog harga dasar
  -> hitung estimasi hanya di sisi server
  -> simpan snapshot harga ke order
  -> buat versi penawaran tambahan yang tidak dapat diubah setelah dikirim
  -> buat persetujuan user sebagai event terpisah
  -> buat invoice dari snapshot harga + penawaran yang disetujui
  -> terima status pembayaran hanya dari sumber pembayaran tepercaya
  -> buat settlement setelah completion/masa komplain
```

Aturan penting:

- Aplikasi klien tidak boleh menjadi sumber kebenaran nominal harga, diskon, pembayaran, atau komisi.
- Harga order lama tidak boleh berubah ketika mitra mengubah katalog harga baru.
- Setiap refund, hold, dan settlement harus menambah event audit, bukan mengubah transaksi lama tanpa histori.

### 20.5 Implementasi fitur per sprint

| Sprint | Fitur | Definition of Done ringkas |
|---|---|---|
| 1 | Akun, role, profil, verifikasi | Hak akses role diuji; akun gabungan Mitra+Teknisi didukung |
| 2 | Katalog, jam, online status, listing | Hanya penyedia verified dan tersedia yang tampil pada matching |
| 3 | Buat/terima/assign order | Tidak ada dua teknisi yang dapat menerima satu order |
| 4 | Tracking, chat, OTP, emergency | Lokasi dibatasi pada order aktif; OTP dan fallback terdokumentasi |
| 5 | Diagnosis, penawaran, bukti kerja | Tambahan biaya tidak bisa dikerjakan tanpa persetujuan user |
| 6 | Pembayaran, invoice, settlement | Status pembayaran tervalidasi; nilai bersih dapat direkonsiliasi |
| 7 | Booking, slot, paket servis | Kapasitas slot tidak oversell; paket memiliki checklist dan harga snapshot |
| 8 | Garansi, sengketa, review, reminder | Tiket hanya untuk order/garansi valid; user dapat opt-out reminder |
| 9 | Favorit, promo, analitik | Promo tervalidasi pada checkout; data agregat tersedia untuk admin |

### 20.6 Skenario pengujian minimum

- User membuat order motor dan satu teknisi menerima order dengan sukses.
- Dua teknisi mencoba menerima order yang sama pada waktu hampir bersamaan; hanya satu yang berhasil.
- Mitra menerima order lalu menugaskan teknisi internal.
- Pemilik mitra mengambil order sendiri sebagai teknisi.
- User menyetujui dan menolak penawaran sparepart.
- OTP valid, OTP salah, user tidak ditemukan, dan pembatalan setelah teknisi bergerak.
- Teknisi menyelesaikan order dengan bukti wajib dan tanpa bukti wajib.
- Booking slot terakhir dipesan dua user secara bersamaan.
- Promo valid, promo kedaluwarsa, dan promo yang tidak memenuhi syarat.
- Tiket garansi dibuat sebelum dan sesudah masa garansi.
- User menonaktifkan reminder dan tidak lagi menerima notifikasi reminder.
- Order emergency tidak menemukan teknisi dan dialihkan menjadi towing/alternatif.

### 20.7 Artefak yang harus disiapkan developer

- Diagram state order dan pembayaran.
- Matriks role-permission untuk setiap layar serta aksi.
- Katalog kategori kendaraan, layanan, batasan keselamatan, dan harga dasar.
- Template notifikasi untuk setiap event penting.
- Kontrak data invoice, penawaran tambahan, bukti kerja, garansi, promo, dan booking.
- Daftar audit event yang wajib dicatat.
- Test case unit, integrasi, dan end-to-end berdasarkan skenario minimum.

## 21. Risiko dan Mitigasi

| Risiko | Mitigasi |
|---|---|
| Dua teknisi mengambil satu order | Acceptance harus atomik; hanya satu penerima valid |
| Harga sparepart tidak transparan | Persetujuan digital dan invoice terpisah |
| Transaksi pindah ke luar aplikasi | Chat internal, invoice resmi, perlindungan sengketa, biaya platform rendah |
| Teknisi datang ke lokasi tidak aman | Konfirmasi lokasi aman, tombol bantuan, hak teknisi menolak |
| Tidak ada teknisi malam hari | Emergency Online, perluasan radius, towing fallback |
| Mitra tidak menyediakan stok yang dijanjikan | Stok hanya indikatif; konfirmasi teknisi wajib sebelum pemasangan |
| User mengira Goban menjual sparepart | Disclosure pada checkout, penawaran tambahan, invoice, dan kebijakan |

## 22. Keputusan Produk yang Diperlukan Sebelum Implementasi

- Kota/wilayah peluncuran pertama.
- Apakah pembayaran tunai tersedia pada MVP.
- Apakah pembayaran awal penuh, deposit, atau setelah diagnosis.
- Persentase komisi final dan pihak yang menanggung biaya gateway.
- Batas radius dan tarif panggilan per kategori kendaraan.
- Kebijakan pembatalan setelah teknisi bergerak.
- Masa tunggu sebelum dana mitra diselesaikan.
- Ketentuan garansi jasa dan sparepart oleh mitra/teknisi.
- Model onboarding dan verifikasi mitra/teknisi.

## 23. Template Pengalaman Aplikasi dan UI Foundation

Bagian ini adalah template pengalaman lintas layar. Ia melengkapi daftar layar dan flow pada Bagian 9-19, bukan mengganti status bisnis, hak akses, atau aturan order yang sudah ditetapkan.

### 23.1 Sasaran UX dan token visual

Sasaran pengalaman produk:

- User dapat meminta bantuan atau membuat booking tanpa harus memahami istilah bengkel; informasi keselamatan, ketersediaan, harga, dan langkah berikutnya selalu terlihat sebelum komitmen dibuat.
- Mitra dan Teknisi dapat mengambil keputusan operasional cepat tanpa menyembunyikan konsekuensi, batas waktu, atau bukti yang diperlukan.
- Semua tindakan yang mengubah uang, status order, lokasi, atau persetujuan memiliki ringkasan yang dapat diperiksa kembali, status proses, dan hasil yang eksplisit.
- Kondisi jaringan lemah, lokasi tidak tersedia, dokumen gagal diunggah, dan data kosong harus tetap memberi jalur kerja atau pemulihan yang jelas.

| Token | Nilai | Penggunaan semantik |
|---|---|---|
| `color.primary` | `#2E7D32` | Aksi utama, status tersedia/aktif, identitas aplikasi |
| `color.secondary` | `#F57C00` | CTA darurat, perhatian pada biaya atau tindakan yang perlu diputuskan |
| `color.success` | `#4CAF50` | Order selesai, pembayaran berhasil, verifikasi berhasil |
| `color.warning` | `#FFC107` | Menunggu, batas waktu, dokumen/persetujuan yang perlu dilengkapi |
| `color.error` | `#F44336` | Gagal, dibatalkan, sengketa, atau tindakan berisiko |
| `color.background` | `#FFFFFF` | Latar halaman utama |
| `color.surface` | `#F5F5F5` | Latar grup konten, kartu sekunder, skeleton |

- Tipografi memakai satu keluarga sans-serif yang mendukung Bahasa Indonesia. Gunakan skala semantik: `display` untuk angka/status penting, `title` untuk judul layar dan kartu, `body` untuk informasi operasional, serta `label` untuk tombol, chip, dan metadata. Ukuran teks isi minimum 14 sp dan tinggi baris harus mendukung teks dua sampai tiga baris tanpa terpotong.
- Spasi memakai skala `4, 8, 12, 16, 24, 32` dp. Jarak tepi konten mobile standar 16 dp; area padat seperti tabel desktop dapat memakai 24 dp.
- Radius memakai `8 dp` untuk field/chip kecil, `12 dp` untuk kartu dan modal, serta `16 dp` untuk bottom sheet. Jangan memakai radius dekoratif yang mengaburkan hierarki tindakan.
- Elevasi hanya membedakan lapisan interaktif: `0` untuk halaman, rendah untuk kartu, sedang untuk app bar/bottom sheet mengambang, dan tinggi hanya untuk dialog kritis. Warna status selalu disertai teks, ikon, atau label.
- Tombol primer hanya satu per konteks utama. Tombol sekunder berbentuk outline/tonal, sedangkan tindakan destruktif wajib memakai konfirmasi dan alasan bila berdampak pada order atau akun.

### 23.2 Alur masuk aplikasi

Urutan masuk yang menjadi acuan untuk U-01 sampai U-05 serta registrasi M-01/T-01:

```text
[Native splash singkat]
  -> [Bootstrap: sesi, konfigurasi minimum, dan konektivitas]
  -> sesi valid?
       -> Tidak: onboarding hanya bila belum pernah selesai
                 -> Masuk/Daftar
                 -> pilih kapabilitas awal
       -> Ya: muat profil, kapabilitas, verifikasi, dan order aktif
  -> edukasi izin yang relevan
  -> prompt OS hanya setelah user memilih aksi yang membutuhkan izin
  -> profil/registrasi belum lengkap?
       -> lanjutkan langkah terakhir yang belum selesai
       -> lengkap: tujuan sesuai kapabilitas dan status verifikasi
  -> profil lengkap: tujuan role dan order aktif bila ada
```

- Native splash menampilkan identitas Goban maksimal selama bootstrap awal; tidak menjadi layar promosi atau menahan pengguna jika data lokal sudah cukup.
- Bootstrap memeriksa versi aplikasi minimum, konfigurasi darurat, sesi, dan konektivitas. Jika sesi masih valid, aplikasi tidak menampilkan layar masuk lagi.
- Returning user dengan order aktif diprioritaskan ke detail/tracking order yang relevan; selain itu, User menuju U-06, Teknisi menuju T-05 atau T-07 bila ada tugas aktif, Mitra menuju M-05 atau M-07 bila ada order yang membutuhkan tindakan, dan Admin menuju A-02.
- Returning user dengan kapabilitas lebih dari satu melihat kapabilitas terakhir yang digunakan dan kontrol pindah kapabilitas di profil/menu akun. Perpindahan tidak boleh menyembunyikan order aktif dari kapabilitas lain.
- Onboarding pertama terdiri dari tiga layar: (1) cari bengkel dan bantuan berdasarkan lokasi, (2) bantuan darurat dengan harga serta status yang dapat dilacak, (3) persetujuan digital untuk biaya tambahan dan bukti pekerjaan. Setiap layar memiliki `Lewati`, indikator progres, dan CTA `Mulai` pada layar terakhir.
- Masuk/Daftar menjelaskan metode yang tersedia, tautan syarat/kebijakan, pemulihan akun, dan status proses. Pilihan role/capability setelah autentikasi menggunakan bahasa tujuan: `Butuh layanan`, `Kelola bengkel`, dan `Saya teknisi`; akun dapat menambah kapabilitas nanti sesuai Bagian 4 dan 8.
- Sebelum prompt OS, tampilkan explainer singkat yang menyatakan manfaat, data yang digunakan, dan alternatif. Lokasi diminta saat membuka peta, mengonfirmasi titik, atau teknisi mengaktifkan Online; notifikasi diminta setelah pengguna memahami manfaat status order/reminder; kamera diminta saat memilih unggah foto/dokumen. Jangan meminta ketiga izin secara berurutan saat launch.
- Jika lokasi ditolak/tidak tersedia, User tetap dapat mencari dengan kota/alamat, memilih titik di peta, atau memakai lokasi terakhir yang diberi label. Matching/order membutuhkan konfirmasi titik sebelum dikirim. Teknisi tidak dapat Online untuk order lapangan tanpa lokasi yang cukup, tetapi tetap dapat melihat riwayat/profil dan tugas non-lokasi.
- Jika belum login, peta/listing dapat ditampilkan secara terbatas bila kebijakan produk mengizinkan, dengan lokasi manual sebagai fallback; pembuatan order, favorit, chat, pembayaran, dan notifikasi mengarahkan ke autentikasi lalu kembali ke aksi semula.

### 23.3 Template layar bersama

| Template | Tujuan | Konten dan aksi utama | State dan fallback |
|---|---|---|---|
| Splash/bootstrap | Memulai aplikasi tanpa membingungkan pengguna | Logo ringkas, indikator proses bila bootstrap melewati waktu respons normal | Jika offline, lanjutkan dengan cache yang aman dan banner offline; jika versi diblokir, tampilkan template maintenance/update |
| Onboarding carousel | Menjelaskan nilai inti pada penggunaan pertama | Tiga manfaat pada §23.2, progres, `Lewati`, `Berikutnya`, `Mulai` | Preferensi selesai disimpan; pengguna dapat membukanya lagi dari Bantuan tanpa mengulang otomatis |
| Auth | Akses atau pembuatan akun | Masuk, daftar, pemulihan, validasi field langsung, syarat layanan | Error kredensial tidak mengungkap keberadaan akun; simpan input aman dan beri `Coba lagi` |
| Permission explainer | Meminta izin secara kontekstual | Alasan izin, data yang dipakai, CTA `Lanjutkan`, `Nanti`, dan alternatif yang tersedia | Jika ditolak permanen, jelaskan cara membuka Pengaturan OS dan jangan memblokir fitur yang tidak membutuhkan izin tersebut |
| Banner offline | Memberi tahu keterbatasan jaringan tanpa menutupi pekerjaan | Status offline, waktu sinkronisasi terakhir, CTA `Coba sambungkan` bila relevan | Aksi perubahan kritis dinonaktifkan atau diantrikan dengan label yang jelas; data cache tidak diberi kesan real-time |
| Loading/skeleton | Menunjukkan struktur saat data utama dimuat | Skeleton menyerupai kartu/peta/list aktual, bukan spinner penuh halaman untuk muatan sebagian | Setelah waktu tunggu wajar, tampilkan pesan proses dan tombol muat ulang; pertahankan konten lama bila masih valid |
| Empty state | Menjelaskan mengapa daftar belum berisi dan tindakan berikutnya | Judul spesifik, satu alasan, satu CTA, misalnya cari bengkel atau aktifkan filter lebih luas | Bedakan data benar-benar kosong, filter terlalu sempit, dan akun belum memenuhi syarat |
| Error/retry | Memulihkan kegagalan request, upload, atau data | Pesan yang menjelaskan dampak, CTA `Coba lagi`, dan jalur bantuan jika perlu | Jangan hapus input/formulir; tampilkan ID referensi untuk error transaksi atau sengketa |
| Notification center | Menyatukan event operasional dan non-transaksional | Filter Belum dibaca/Order/Pembayaran/Booking/Promo, waktu, deep link, tandai dibaca | Event penting tetap ada sampai ditindak atau kedaluwarsa; promo mengikuti preferensi notifikasi |
| Maintenance/update blocking | Melindungi keamanan dan kompatibilitas | Alasan singkat, versi diperlukan atau waktu pemeliharaan, CTA update/ulang | Tidak menampilkan data atau tindakan sensitif bila versi dipaksa diperbarui; sediakan status layanan/bantuan bila ada gangguan |

### 23.4 Shell dan navigasi per role

Template ini menggunakan ID layar yang sudah ada; tidak membuat jalur navigasi baru yang bertentangan.

| Role/shell | Struktur layar | Aksi utama dan kondisi |
|---|---|---|
| User mobile | Bottom navigation tetap: `Beranda Peta (U-06)`, `Order Saya (U-20)`, `Notifikasi (U-22)`, `Profil (U-23)`. App bar kontekstual memuat pencarian/filter pada peta dan back navigation pada flow transaksi. | CTA `Butuh Bantuan Sekarang` selalu terlihat pada U-06 sebagai tindakan darurat; `Tambah Titik` adalah aksi sekunder. U-06 menampilkan marker/list skeleton, empty state untuk hasil filter, dan fallback lokasi manual. Flow U-09 sampai U-19 memakai progres langkah, ringkasan yang tetap dapat ditinjau, serta CTA tunggal sesuai status. |
| Teknisi mobile | Bottom navigation tetap: `Beranda (T-05)`, `Order (T-06/T-07)`, `Riwayat (T-13)`, `Pendapatan (T-14)`, `Profil (T-15)`. | Toggle Online hanya aktif jika akun verified, izin/lokasi tersedia untuk kerja lapangan, jadwal/area valid, dan tidak ada konflik order. Saat ada tugas aktif, shell menonjolkan T-07 dan melindungi dari navigasi yang dapat mengganggu status/lokasi. T-06 memiliki countdown, alasan tolak, skeleton order baru, empty state saat tidak ada tawaran, dan error yang tidak otomatis mengubah Online. |
| Mitra responsive | Desktop/tablet memakai sidebar: `Dashboard (M-05)`, `Order (M-06/M-07)`, `Teknisi (M-08/M-09)`, `Usaha (M-10-M12)`, `Keuangan (M-13)`, dengan Analitik/Ulasan/Pengaturan di menu sekunder. Mobile dapat memakai daftar prioritas dan bottom sheet aksi, bukan tabel yang dipadatkan. | M-05 menampilkan ringkasan dan order yang memerlukan keputusan; M-06/M-08 memakai layout master-detail pada layar lebar. Status verifikasi M-04, daftar kosong, loading tabel/kartu, error sinkronisasi, dan state tanpa teknisi tersedia harus eksplisit. Aksi terima/assign menampilkan deadline, kandidat, serta dampak status. |
| Admin web | Sidebar persisten: Dashboard (A-02), verifikasi (A-03/A-04), order (A-05), sengketa (A-06), moderasi (A-07/A-08), keuangan (A-09), konfigurasi (A-10), pengguna (A-11). Header memuat pencarian, notifikasi, dan akun admin. | Setiap daftar memakai filter yang dapat dibagikan melalui URL, pagination, loading skeleton, empty state sesuai filter, dan error retry. Halaman detail memakai panel bukti/timeline yang tidak dapat diedit. Aksi approve, refund, suspend, dan perubahan konfigurasi wajib menampilkan dampak, alasan, konfirmasi, serta audit trail. |

### 23.5 Micro UX bernilai tinggi

- Booking: tampilkan kartu booking pada U-20 dan notifikasi pengingat pada interval yang dikonfigurasi, berisi waktu, lokasi, kode booking, kebijakan keterlambatan, serta CTA navigasi atau ubah jadwal bila masih diizinkan. Ini melengkapi flow §19.5.
- Darurat: CTA `Butuh Bantuan Sekarang` memakai `color.secondary`, menampilkan konteks keselamatan sebelum form, dan tidak bersaing dengan CTA transaksi lain. Bila kandidat tidak ada, tampilkan urutan fallback perluas radius, towing, dan kontak darurat lokal sesuai §19.8.
- Harga: U-13, U-14, U-17, M-07, dan T-10 harus selalu membedakan biaya panggilan, jasa, sparepart, tarif malam, diskon, biaya platform, dan biaya pembayaran. Label `Estimasi` atau `Total final` wajib sesuai tahap; sparepart tidak boleh tampak sebagai stok Goban.
- Persetujuan sparepart: U-17 menunjukkan foto bila tersedia, merek, kondisi, jumlah, harga satuan, garansi, alasan, total perubahan, dan konsekuensi `Tolak`. CTA `Setujui` memerlukan konfirmasi nominal/versi; status menunggu, kedaluwarsa, gagal bayar, atau ditolak tetap dapat dilihat di timeline sesuai §19.1.
- OTP dan bukti: U-16/T-08 menampilkan pengingat jangan membagikan OTP sebelum teknisi tiba, input enam digit dengan status percobaan, dan jalur masalah lokasi. T-09 sampai T-12 menampilkan checklist bukti wajib, izin kamera kontekstual, progres unggahan, unggah ulang, serta alasan bila bukti tidak dapat dibuat sesuai §19.2-§19.3.
- Timeline status: U-16, M-07, T-07, dan A-05 menampilkan status order berurutan, pembuat event, waktu, dan alasan bila ada penolakan/pembatalan. Status saat ini tidak boleh hanya dibedakan warna.
- Tracking: bila lokasi teknisi tidak live, peta menunjukkan label `Lokasi terakhir diperbarui [waktu]`, indikator koneksi, dan tidak menghitung ETA seolah-olah real-time. Keterbatasan ini tidak mengubah aturan lokasi pada §19.4.
- Chat order: U-21/T-07/M-07 menyediakan quick reply aman seperti `Saya sudah tiba`, `Saya sedang menuju lokasi`, `Mohon kirim patokan`, dan template keselamatan. Harga, approval, dan OTP tidak dapat diselesaikan hanya melalui chat; tampilkan CTA ke layar resmi terkait.
- Favorit, garansi, promo, dan reminder: ikon Favorit memberi status tersimpan dan undo singkat; tiket garansi menampilkan sisa masa garansi serta invoice acuan; promo menampilkan kelayakan dan penanggung diskon sebelum checkout; reminder memberi `Booking`, `Cari bengkel`, atau `Matikan pengingat`, bukan CTA promosi ambigu. Semua mengikuti flow §19.6, §19.7, §19.9, dan §19.10.

### 23.6 Kriteria penerimaan responsif, aksesibilitas, dan kualitas

- Seluruh aplikasi memenuhi WCAG 2.2 level AA: rasio kontras teks dan kontrol memadai, informasi tidak hanya bergantung pada warna, label/error form terbaca, dan perubahan status penting diumumkan ke teknologi bantu.
- Target sentuh minimum `44 x 44` dp/px; ruang antar target mencegah salah tekan terutama pada map, toggle Online, CTA emergency, dan persetujuan nominal.
- Semua ikon interaktif mempunyai nama semantik; gambar bukti memiliki deskripsi atau metadata konteks; status chip menggabungkan teks, ikon, dan warna; urutan fokus/logis disediakan untuk pembaca layar.
- Web Admin dan dashboard Mitra mendukung keyboard penuh: fokus terlihat, skip link/landmark, modal menjebak fokus dengan benar, Escape menutup dialog non-kritis, tabel dapat dioperasikan tanpa pointer, dan tooltip tidak menjadi satu-satunya sumber informasi.
- Hormati preferensi reduced motion; animasi marker, skeleton, transisi, dan countdown tidak boleh menjadi satu-satunya indikator perubahan atau menghalangi interaksi.
- Gunakan Bahasa Indonesia untuk UI, format Rupiah tanpa pecahan secara konsisten, zona waktu lokal area layanan, serta teks yang tahan terhadap nama usaha/alamat/deskripsi panjang melalui wrapping, truncation yang dapat dibuka, dan layout tidak overflow.
- Mobile harus mendukung layar kecil dan perubahan orientasi tanpa CTA tertutup keyboard/safe area. Dashboard memakai breakpoint untuk mengubah tabel menjadi kartu/detail, bukan mengecilkan teks di bawah batas keterbacaan.
- Semua daftar dan peta memiliki state loading, kosong, error, dan data lama/offline bila relevan. Request berulang tidak boleh menghasilkan duplikasi order, persetujuan, atau upload.
- Upload foto/dokumen menampilkan ukuran/batas file sebelum unggah, progres per file, gagal/ulang/batal, dan status final. Form tetap dapat dikoreksi tanpa kehilangan field lain.

### 23.7 Inventaris layar dan urutan delivery UI

Inventaris ringkas per role:

| Kelompok | Layar |
|---|---|
| Bersama | U-01 s.d. U-05, pusat notifikasi/template bersama, maintenance/update, offline, loading, empty, error |
| User | U-06 s.d. U-25 |
| Mitra | M-01 s.d. M-16 |
| Teknisi | T-01 s.d. T-15 |
| Admin | A-01 s.d. A-11 |

Urutan delivery UI mengikuti Bagian 20 dan menjadi Definition of Done visual:

| Fase UI | Cakupan | Ketergantungan |
|---|---|---|
| 1. Foundation | Token, shell auth/bootstrap, onboarding, permission explainer, loading/error/empty/offline | Tahap 1 Bagian 20 |
| 2. Marketplace | U-06 sampai U-13, profil/detail provider, shell Mitra/Teknisi dasar, state lokasi manual | Tahap 2-3 |
| 3. Order aktif | U-14 sampai U-18, T-05 sampai T-12, M-06 sampai M-08, timeline, chat, OTP, tracking | Tahap 4-6 |
| 4. Operasional dan booking | M-09 sampai M-16, booking, slot, paket, dashboard responsif | Tahap 7 |
| 5. Pasca-layanan dan kontrol | Riwayat, review, garansi, sengketa, reminder, promo, notifikasi, Admin A-02 sampai A-11 | Tahap 8-9 |

Setiap fase hanya dianggap selesai bila state normal, loading, kosong, error, offline bila relevan, aksesibilitas, dan layar kecil/lebar telah diuji untuk alur yang dikirimkan.

## 24. Tech Stack Open Source dan Gratis

### 24.1 Prinsip pemilihan

- Seluruh komponen inti dapat dijalankan pada server milik sendiri.
- Pilih proyek berlisensi open source yang jelas dan aktif dipelihara.
- Hindari ketergantungan pada BaaS berbayar atau free tier yang dapat berubah.
- Aplikasi harus hemat baterai: lokasi dan realtime hanya aktif ketika benar-benar dibutuhkan.
- Peta harus hemat data: gunakan vector tile, cache area yang sering dipakai, dan jangan memuat marker yang tidak terlihat.

Catatan: perangkat iOS mengharuskan pengiriman notifikasi melalui Apple Push Notification service (APNs), dan pembayaran online membutuhkan penyelenggara pembayaran berizin. Keduanya adalah integrasi eksternal yang tidak dapat sepenuhnya digantikan oleh software open source.

### 24.2 Arsitektur yang direkomendasikan

```text
[Flutter App: Android / iOS / Web]
  |
  +-- REST API + WebSocket
  |      |
  |      +-- Go API service
  |      +-- PostgreSQL + PostGIS
  |      +-- Keycloak (identity dan role)
  |      +-- MinIO (foto, dokumen, bukti kerja)
  |      +-- ntfy (notifikasi self-hosted)
  |
  +-- MapLibre + self-hosted vector tiles
         |
         +-- Martin tile server + data OpenStreetMap

[Admin Web]
  -> Flutter Web dari codebase yang sama, dengan route dan role Admin
```

### 24.3 Aplikasi client

| Kebutuhan | Pilihan | Lisensi | Kegunaan |
|---|---|---|---|
| Cross-platform app | Flutter dan Dart | BSD-3-Clause | Satu codebase Android, iOS, dan web |
| Routing | go_router | BSD-3-Clause | Navigasi dan proteksi route berdasarkan role |
| State management | flutter_riverpod | MIT | State autentikasi, order, peta, dan UI async |
| HTTP API | Dio | MIT | Request API, interceptor token, upload file |
| Model immutable opsional | freezed + json_serializable | MIT / BSD-3-Clause | Model request/response yang aman dan konsisten |
| WebSocket | web_socket_channel | BSD-3-Clause | Status order, chat, dan lokasi order aktif |
| Peta MVP raster | flutter_map + latlong2 | BSD-3-Clause | Implementasi peta cepat dan ringan |
| Peta produksi vector | MapLibre Native/Flutter binding | BSD-2-Clause | Vector tile hemat data dan gaya peta fleksibel |
| Lokasi perangkat | geolocator | MIT | Lokasi user dan teknisi dengan mode hemat baterai |
| Permission | permission_handler | MIT | Izin lokasi, kamera, dan notifikasi |
| Penyimpanan lokal | drift + SQLite | MIT / public domain | Cache order, preferensi, dan data offline kecil |
| Secret lokal | flutter_secure_storage | BSD-3-Clause | Menyimpan token sesi dengan aman |
| Kamera/foto | image_picker | BSD-3-Clause | Foto kerusakan, bukti pekerjaan, dan dokumen |
| Notifikasi lokal | flutter_local_notifications | BSD-3-Clause | Pengingat servis dan notifikasi saat app aktif |
| Format Rupiah/tanggal | intl | BSD-3-Clause | Format Indonesia yang konsisten |
| Buka telepon/navigasi | url_launcher | BSD-3-Clause | Telepon dan tautan navigasi sebagai fallback |

Tidak semua library harus dipasang sejak awal. MVP dapat dimulai dengan Flutter, Riverpod, go_router, Dio, flutter_map, geolocator, WebSocket, dan image_picker.

### 24.4 Backend self-hosted

| Kebutuhan | Pilihan | Lisensi | Kegunaan |
|---|---|---|---|
| Bahasa backend | Go | BSD-3-Clause | Hemat resource, satu binary, concurrency baik untuk realtime |
| HTTP router | chi | MIT | REST API dan middleware yang kecil |
| Database | PostgreSQL | PostgreSQL License | Data utama transaksi dan audit |
| Geospatial | PostGIS | GPL-2.0-or-later | Pencarian mitra/teknisi terdekat dan area layanan |
| PostgreSQL driver | pgx | MIT | Akses database dan transaksi atomik |
| Database migration | goose | MIT | Versi schema database yang dapat diaudit |
| Identity provider | Keycloak | Apache-2.0 | Login, OIDC, role, reset password, MFA bila diperlukan |
| Object storage | MinIO | AGPL-3.0 | Foto order, dokumen teknisi, dan bukti pekerjaan |
| Realtime event | WebSocket native Go | BSD-3-Clause | Channel order, chat, status, dan tracking aktif |
| Message broker saat scale | NATS | Apache-2.0 | Fan-out event realtime dan pekerjaan asynchronous |
| Push self-hosted | ntfy | Apache-2.0 | Notifikasi berbasis topic untuk Android/web dan integrasi server |
| API contract | OpenAPI | Apache-2.0 | Kontrak API untuk aplikasi, admin, dan testing |

Untuk MVP, message broker tidak wajib. Tambahkan NATS hanya saat satu service realtime tidak lagi cukup atau ketika ada lebih dari satu instance backend.

### 24.5 Peta, routing, dan penghematan data

| Kebutuhan | Pilihan | Lisensi | Catatan |
|---|---|---|---|
| Data peta | OpenStreetMap | ODbL | Wajib menampilkan attribution sesuai ketentuan OSM |
| Render peta | MapLibre | BSD-2-Clause | Vector map untuk kualitas baik dengan data lebih kecil |
| Membuat vector tiles | Planetiler | Apache-2.0 | Membuat data tile dari extract OSM wilayah target |
| Menyajikan vector tiles | Martin | MIT | Tile server ringan untuk PMTiles/MBTiles/PostGIS |
| Routing self-hosted | Valhalla | MIT | Rute dan estimasi perjalanan ketika dibutuhkan |
| Geocoding self-hosted | Nominatim | GPL-2.0-or-later | Pencarian/reverse geocoding, wajib diberi cache dan rate limit |

Aturan peta dan lokasi:

- Awal MVP dapat memakai `flutter_map` dengan tile sederhana untuk wilayah terbatas.
- Untuk produksi, gunakan MapLibre dengan tile vector wilayah operasi sendiri agar tidak bergantung pada public tile server.
- Jangan gunakan public tile server OpenStreetMap untuk traffic produksi tinggi.
- Cache hasil geocoding; jangan melakukan reverse geocoding setiap peta bergeser.
- Lokasi teknisi dikirim hanya pada order `accepted`, `arrived`, `diagnosing`, atau `ongoing`.
- Gunakan interval adaptif: 10-15 detik saat bergerak dan lebih lambat saat diam; berhenti total saat order berakhir atau teknisi offline.
- Marker dimuat berdasarkan viewport dan dikelompokkan ketika zoom rendah.

### 24.6 Keamanan, observability, dan operasional

| Kebutuhan | Pilihan | Lisensi | Kegunaan |
|---|---|---|---|
| Reverse proxy dan TLS | Caddy | Apache-2.0 | HTTPS otomatis, reverse proxy, rate limit dasar |
| Container | Docker Engine + Compose | Apache-2.0 | Menjalankan service secara konsisten |
| Monitoring metrics | Prometheus | Apache-2.0 | Metrik API, database, realtime, dan server |
| Dashboard monitoring | Grafana OSS | AGPL-3.0 | Visualisasi metrics dan alert |
| Error tracking | GlitchTip | MIT | Alternatif open source untuk error tracking aplikasi |
| Backup database/storage | pg_dump + restic | PostgreSQL License / BSD-2-Clause | Backup terjadwal serta pemulihan data |
| Source control/CI self-hosted opsional | Forgejo | GPL-3.0 | Git, issue, dan CI melalui runner terpisah |

Persyaratan operasional minimum:

- HTTPS wajib untuk semua aplikasi dan API.
- Backup PostgreSQL harian serta uji restore rutin.
- MinIO harus memakai bucket privat untuk KTP, SIM, STNK, dan bukti sensitif.
- Dokumen identitas tidak boleh disajikan melalui URL publik.
- Semua aksi pembayaran, perubahan harga, approval, settlement, dan refund harus masuk audit log.
- Password, private key, token, dan konfigurasi rahasia hanya berada pada environment variable/secret manager, bukan source code.

### 24.7 Integrasi yang bukan sepenuhnya open source

| Kebutuhan | Opsi | Alasan dan kebijakan |
|---|---|---|
| Payment gateway Indonesia | Penyedia pembayaran berizin | Pembayaran QRIS, VA, e-wallet, dan kartu membutuhkan pihak berizin; gateway biasanya mengenakan biaya per transaksi |
| Push iOS | Apple APNs melalui ntfy atau provider notifikasi | APNs adalah layanan platform Apple dan wajib untuk push notification iOS |
| Push Android reliable saat background | ntfy dengan integrasi distributor Android atau FCM | Pengiriman background Android dapat memakai infrastruktur Google; FCM gratis tetapi bukan open source |
| SMS OTP | Provider SMS berbayar | SMS memiliki biaya operator; untuk MVP utamakan email/password atau OIDC |

Prinsipnya: seluruh data inti, API, realtime, peta, file, dan identitas dapat self-hosted. Komponen pihak ketiga hanya digunakan saat regulasi pembayaran atau sistem operasi perangkat memang mewajibkannya.

### 24.8 Deployment minimum

```text
Satu VPS Linux
  -> Caddy
  -> Go API + WebSocket
  -> PostgreSQL + PostGIS
  -> Keycloak
  -> MinIO
  -> ntfy
  -> Martin tile server
  -> Prometheus + Grafana
```

Resource awal yang realistis untuk demo/internal testing adalah VPS 4 vCPU dan 8 GB RAM. Untuk menjalankan tile server, geocoding, routing, dan semua observability pada server yang sama, kebutuhan RAM serta storage akan meningkat. Software-nya gratis dan open source; server, domain, bandwidth, backup object storage, serta payment gateway tidak selalu gratis.

### 24.9 Urutan implementasi stack

```text
1. Flutter app + Go API + PostgreSQL/PostGIS
2. Role/identity, katalog layanan, dan order state machine
3. WebSocket untuk status order; HTTP biasa untuk data non-realtime
4. MinIO untuk upload bukti kerja dan dokumen
5. Payment gateway + webhook tervalidasi
6. ntfy/APNs/FCM sesuai platform target
7. MapLibre/vector tiles setelah flow order stabil
8. Prometheus, Grafana, backup, dan hardening sebelum pilot publik
```

### 24.10 Dependency audit sebelum rilis

- Kunci versi package pada lockfile.
- Periksa lisensi package dan dependency transitive sebelum rilis.
- Hindari library dengan lisensi komersial atau source-available jika target proyek mensyaratkan open source penuh.
- Simpan daftar dependency, versi, lisensi, dan fungsi pada dokumen `THIRD_PARTY_NOTICES` sebelum rilis publik.
