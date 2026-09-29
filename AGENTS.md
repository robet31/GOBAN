# Goban — AGENTS.md

Platform panggil teknisi & cari lokasi tambal ban / service motor.
**Target**: Android, iOS, Web (Flutter cross-platform).
**Status**: Pre-init (empty repo). **Lisensi**: MIT.

---

## 1. Pengguna & Fitur Matrix

| Fitur | Customer | Teknisi/Mitra | Admin |
| ------- | ---------- | --------------- | ------- |
| Registrasi & Login | Email/Phone/Google | Email/Phone + upload KTP/SIM/STNK | Internal only |
| Lihat peta + marker toko/teknisi | ✅ | ✅ (lihat order sekitar) | ✅ (monitoring) |
| Filter (jarak, rating, layanan, harga) | ✅ | — | — |
| Order teknisi real-time | ✅ | ✅ (terima/tolak) | ✅ (manage) |
| Tracking posisi teknisi live | ✅ | ✅ (share lokasi) | ✅ |
| Tambah titik toko baru (UGC) | ✅ | ✅ | ✅ (moderasi) |
| Rating & Review | ✅ | ✅ (balas) | ✅ (hapus abusive) |
| Riwayat order | ✅ | ✅ + pendapatan | ✅ (semua) |
| Chat customer↔teknisi | ✅ | ✅ | — |
| Notifikasi push | ✅ | ✅ | ✅ |

---

## 2. Tech Stack — Open Source & Gratis

### Stack Inti (Rekomendasi Utama) — Paling Cepat & Hemat Biaya

| Layer | Pilihan | Free Tier | Alternatif |
| ------- | --------- | ----------- | ------------ |
| **App** | Flutter (Dart) | Gratis 100% | React Native (Expo) |
| **Auth + DB + Realtime + Storage** | Supabase | 500MB DB, 1GB storage, 50K users | Appwrite, Firebase (proprietary) |
| **Maps** | flutter_map + OpenStreetMap tile | Gratis, no API key | MapLibre GL + OpenFreeMap |
| **Geocoding** | Nominatim (OSM) | 1 req/sec gratis | Photon (komoot.io) |
| **Routing / ETA** | OSRM demo server | Terbatas — skip di MVP | GraphHooster (self-host) |
| **Push Notifikasi** | ntfy.sh | Gratis, open source | OneSignal (free tier) |
| **Hosting Web (Admin)** | Vercel / Netlify | Gratis untuk static | Cloudflare Pages |
| **CI/CD** | GitHub Actions | 2000 min/bulan gratis | — |

### Stack Alternatif (Web-first / Non-Flutter)

| Layer | Pilihan | Kapan Dipakai |
| ------- | --------- | --------------- |
| Frontend | Next.js (React) / Nuxt.js (Vue) | Jika lebih suka web + PWA, SEO penting |
| Backend | Node.js + Express/Hono/Fastify | Jika butuh kustomisasi backend lebih bebas |
| Database | Neon (PostgreSQL serverless) | Gratis 500MB, cold starts lebih cepat dari Supabase |
| Realtime | Supabase Realtime / Socket.io | Jika tidak pakai Supabase |

### Pilihan Tile Server Map (Gratis, No API Key)

| Layanan | Format | Kelebihan |
| --------- | -------- | ----------- |
| **OpenFreeMap** | Vector tiles (.mvt) | Pakai langsung, tidak perlu register, style OSM Liberty |
| **OpenStreetMap tile** | Raster (.png) | Paling sederhana, pakai flutter_map default |
| **Protomaps** | PMTiles (1 file = seluruh dunia) | Host di GitHub Pages, kontrol penuh |
| **MapTiler** | Vector / Raster | Gratis untuk open source (perlu daftar) |
| **Self-host OpenMapTiles** | Vector tiles | Butuh server sendiri (VPS ~$5/bln) |

### Perbandingan Paket Maps

| Metode | Tanpa API Key? | Kustom Gaya? | Cocok Untuk |
| -------- | --------------- | -------------- | ------------- |
| OpenStreetMap tile (raster) | ✅ Ya | ❌ Tidak | MVP termudah |
| OpenFreeMap (vector) | ✅ Ya | ✅ Bisa via Maputnik | MVP + tampilan keren |
| Protomaps PMTiles | ✅ Ya | ✅ Total control | Produksi skala kecil-menengah |
| MapTiler | ✅ (OS) | ✅ Maputnik | Produksi gratis (OS license) |
| Self-host OpenMapTiles | ✅ | ✅ Total | Skala besar, butuh devops |

---

## 3. Arsitektur

```text
[Flutter App — Android / iOS / Web]
        │
        ├── Supabase Auth (login, register, session)
        ├── Supabase DB (PostgreSQL — data users, orders, dll)
        ├── Supabase Realtime (live order status, location share)
        ├── Supabase Storage (KTP, SIM, foto toko)
        ├── flutter_map + OpenFreeMap tile (peta)
        ├── Nominatim API (geocoding — cari alamat)
        └── ntfy.sh (push notification)

[Optional — Separate Backend]
        └── Node.js / Hono di Cloudflare Workers
            └── OSRM routing (hitung ETA)
            └── Matching algoritma (Haversine)
```

**Prinsip arsitektur untuk MVP**:

- Semua logic di client-side (Flutter) selama memungkinkan
- Supabase handles auth + DB + realtime langsung dari Flutter
- Backend terpisah hanya jika diperlukan (matching kompleks, rate limiting sensitive)
- Supabase Edge Functions sebagai alternatif backend minimal

---

## 4. Database Schema (Supabase / PostgreSQL)

### Tabel `users` (auto dari Supabase Auth + tambahan)

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- sama dengan auth.users
  email       TEXT UNIQUE NOT NULL,
  phone       TEXT UNIQUE,
  full_name   TEXT NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('customer','technician','admin')),
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

### Tabel `technician_profiles` (detail teknisi)

```sql
CREATE TABLE technician_profiles (
  id              UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  shop_name       TEXT,                      -- nama toko (nullable utk teknisi keliling)
  lat             DOUBLE PRECISION NOT NULL, -- lokasi
  lng             DOUBLE PRECISION NOT NULL,
  address         TEXT,
  services        TEXT[] NOT NULL DEFAULT '{}', -- ARRAY['tambal ban','ganti oli','servis mesin']
  price_estimate  INTEGER,                   -- harga dasar dalam Rupiah
  is_online       BOOLEAN DEFAULT false,
  is_verified     BOOLEAN DEFAULT false,      -- diverifikasi admin
  ktp_url         TEXT,                      -- storage path
  sim_url         TEXT,
  stnk_url        TEXT,
  shop_photo_url  TEXT,
  rating_avg      REAL DEFAULT 0,            -- dari rata-rata reviews
  total_orders    INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT now()
);
```

### Tabel `locations` (UGC — user-generated shop pins)

```sql
CREATE TYPE location_status AS ENUM ('pending','approved','rejected');

CREATE TABLE locations (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  lat         DOUBLE PRECISION NOT NULL,
  lng         DOUBLE PRECISION NOT NULL,
  category    TEXT NOT NULL CHECK (category IN ('tambal_ban','service_motor','kedua')),
  address     TEXT,
  phone       TEXT,
  photo_url   TEXT,
  added_by    UUID NOT NULL REFERENCES users(id),
  status      location_status DEFAULT 'pending',
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

### Tabel `orders`

```sql
CREATE TYPE order_status AS ENUM ('waiting','accepted','ongoing','completed','cancelled');

CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL REFERENCES users(id),
  technician_id   UUID REFERENCES users(id),         -- null sampai diterima teknisi
  service_type    TEXT NOT NULL,                      -- 'tambal ban','ganti oli','servis mesin','other'
  description     TEXT,                               -- detail kerusakan, optional
  status          order_status DEFAULT 'waiting',
  customer_lat    DOUBLE PRECISION NOT NULL,
  customer_lng    DOUBLE PRECISION NOT NULL,
  customer_address TEXT,
  price           INTEGER,                            -- dalam Rupiah
  payment_method  TEXT CHECK (payment_method IN ('cash','transfer')),
  distance_km     REAL,                               -- jarak customer ke teknisi
  created_at      TIMESTAMPTZ DEFAULT now(),
  accepted_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ
);
```

### Tabel `reviews`

```sql
CREATE TABLE reviews (
  id          SERIAL PRIMARY KEY,
  order_id    UUID NOT NULL REFERENCES orders(id) UNIQUE,
  reviewer_id UUID NOT NULL REFERENCES users(id),  -- customer yg review
  rating      INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

### Tabel `notifications`

```sql
CREATE TABLE notifications (
  id        SERIAL PRIMARY KEY,
  user_id   UUID NOT NULL REFERENCES users(id),
  title     TEXT NOT NULL,
  body      TEXT,
  data      JSONB,                 -- payload tambahan (order_id, dll)
  read      BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Tabel `chats` (opsional — fitur chat)

```sql
CREATE TABLE chats (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID NOT NULL REFERENCES orders(id),
  sender_id   UUID NOT NULL REFERENCES users(id),
  message     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

### Index penting

```sql
CREATE INDEX idx_technician_online ON technician_profiles (is_online, is_verified);
CREATE INDEX idx_locations_status ON locations (status);
CREATE INDEX idx_orders_customer ON orders (customer_id, status);
CREATE INDEX idx_orders_technician ON orders (technician_id, status);
CREATE INDEX idx_orders_created ON orders (created_at DESC);
CREATE INDEX idx_notifications_user ON notifications (user_id, read);
```

---

## 5. RLS Policies (Row Level Security)

### users

```sql
-- SELECT: own user only, admin all
((SELECT role FROM users WHERE id = auth.uid()) = 'admin') OR id = auth.uid()
-- UPDATE: own user only
id = auth.uid()
```

### technician_profiles

```sql
-- SELECT: public for online+verified, own profile always
(is_online = true AND is_verified = true) OR id = auth.uid()
-- INSERT: own profile only
id = auth.uid()
-- UPDATE: own profile only
id = auth.uid()
```

### locations

```sql
-- SELECT: approved by public, pending by admin/owner
(status = 'approved') OR added_by = auth.uid() OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
-- INSERT: any authenticated user
auth.role() = 'authenticated'
-- UPDATE/DELETE: admin only
(SELECT role FROM users WHERE id = auth.uid()) = 'admin'
```

### orders

```sql
-- SELECT: customer or assigned technician or admin
customer_id = auth.uid() OR technician_id = auth.uid() OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
-- INSERT: customer only
(SELECT role FROM users WHERE id = auth.uid()) = 'customer'
-- UPDATE: technician (accept/start/complete) or admin
technician_id = auth.uid() OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
```

### reviews

```sql
-- SELECT: anyone
true
-- INSERT: customer of completed order only
EXISTS (SELECT 1 FROM orders WHERE id = order_id AND customer_id = auth.uid() AND status = 'completed')
```

---

## 6. User Flows (Detailed)

### 6.1 Customer Flow

```text
[Open App] → [Splash / Auto-login check]
    ↓
[Main Map Screen]
    ├── Marker: toko tambal ban (icon ban)
    ├── Marker: teknisi online (icon orang, pulsing dot)
    └── Marker: crowdsourced location (icon pin)
    ↓
[User taps marker]
    ↓ BottomSheet muncul:
    ├── Nama toko/teknisi
    ├── Jarak (km)
    ├── Rating (bintang)
    ├── Estimasi harga
    └── Tombol "Pesan Sekarang"
    ↓
[Tap "Pesan Sekarang"]
    ↓
[Pilih Layanan] (modal)
    ├── Tambal Ban → Rp 15.000
    ├── Ganti Ban → Rp 30.000
    ├── Ganti Oli → Rp 45.000
    └── Servis Mesin → Rp 100.000 (harga estimasi)
    ↓
[Konfirmasi Lokasi]
    ├── GPS otomatis (tampilkan di peta)
    └── Atau geser pin / ketik alamat manual
    ↓
[Konfirmasi Order] (ringkasan)
    ├── Teknisi: nama + rating
    ├── Layanan: jenis
    ├── Lokasi: alamat
    ├── Estimasi: Rp XX.XXX
    ├── Metode bayar: Tunai / Transfer
    └── Tombol "Pesan"
    ↓
[Waiting Screen] — sistem mencari teknisi terdekat
    ├── Loading animasi
    └── Cancel order (jika terlalu lama)
    ↓
[Technician Accepted] — notifikasi + sugest
    └── [Tracking Screen]
        ├── Peta: posisi teknisi (update tiap 3-5 detik)
        ├── Info: nama teknisi, no HP, foto
        ├── ETA: estimasi waktu tiba (jika ada OSRM)
        └── Tombol "Hubungi" (buka chat / telepon)
    ↓
[Technician Arrived] — notifikasi
    └── Status berubah ke "Ongoing" (sedang diservis)
    ↓
[Technician Completes] — notifikasi
    └── [Pembayaran Screen]
        ├── Rincian biaya
        ├── Metode: Tunai / Transfer
        └── Tombol "Konfirmasi Selesai"
    ↓
[Review Screen]
    ├── Rating bintang (1-5)
    ├── Komentar (opsional)
    └── Tombol "Kirim"
```

### 6.2 Technician / Mitra Flow

```text
[Register]
    ├── Step 1: Data Diri (nama, no HP, email, password)
    ├── Step 2: Data Toko (nama toko, alamat, koordinat, jam buka)
    ├── Step 3: Upload Dokumen
    │   ├── Foto KTP
    │   ├── Foto SIM
    │   └── Foto STNK
    ├── Step 4: Pilih Layanan
    │   ├── ☑ Tambal Ban
    │   ├── ☑ Ganti Ban
    │   ├── ☑ Ganti Oli
    │   └── ☑ Servis Mesin
    ├── Step 5: Atur Tarif
    │   ├── Harga per layanan
    │   └── Biaya per km (opsional)
    └── [Verification Pending Screen]
        └── "Akun Anda sedang diverifikasi admin..."
            Estimasi: 1x24 jam
    ↓
[After Approved — Dashboard]
    ├── [Toggle Online/Offline] — besar, di tengah
    ├── [Daftar Order Masuk] (real-time)
    │   └── Tiap card:
    │       ├── Nama customer + jarak
    │       ├── Jenis layanan
    │       ├── Estimasi harga
    │       └── Tombol "Terima" / "Tolak"
    ├── [Order Aktif] (jika sedang mengerjakan)
    │   ├── Peta: lokasi customer + rute
    │   ├── Tombol "Mulai Servis"
    │   └── Tombol "Selesai"
    ├── [Riwayat Order]
    │   └── List order selesai + pendapatan
    └── [Profil]
        ├── Edit profil toko
        ├── Edit layanan
        ├── Statistik (total order, rating, pendapatan)
        └── Logout
```

### 6.3 UGC — Tambah Titik (Crowdsourced)

```text
[From Map Screen]
    ├── Tombol "+" (FAB) → "Tambah Titik Baru"
    ↓
[Form Tambah Titik]
    ├── Nama toko / tempat *
    ├── Kategori: Tambal Ban / Service Motor / Keduanya *
    ├── Pilih lokasi di peta (geser pin) *
    ├── Alamat (text, optional)
    ├── No telepon (optional)
    ├── Foto tempat (optional — upload ke Supabase Storage)
    └── Tombol "Kirim"
    ↓
[Pending Screen]
    └── "Titik Anda sedang direview admin. Biasanya selesai dalam 1x24 jam."
    ↓
[Approved] → notifikasi push → marker muncul di peta semua user
[Rejected] → notifikasi push + alasan penolakan
```

### 6.4 Admin Flow (Web Dashboard)

```text
[Login] — khusus role admin
    ↓
[Dashboard]
    ├── Card: Total Users
    ├── Card: Total Orders (hari ini)
    ├── Card: Pending Technicians (count)
    ├── Card: Pending Locations (count)
    │
    ├── [Menu: Verifikasi Teknisi]
    │   └── List teknisi pending → Lihat dokumen → Approve / Tolak + alasan
    │
    ├── [Menu: Moderasi Lokasi]
    │   └── List lokasi pending → Lihat detail → Publish / Hapus
    │
    ├── [Menu: Orders]
    │   └── List all orders → Filter status → Lihat detail
    │
    ├── [Menu: Users]
    │   └── List all users → Search → Ban / Unban
    │
    └── [Menu: Settings]
        ├── Harga default layanan
        ├── Radius maksimal pencarian teknisi
        └── Komisi platform (jika ada)
```

---

## 7. UI/UX Design Patterns

### 7.1 Tema

| Token | Warna | Hex | Penggunaan |
| ------- | ------- | ----- | ------------ |
| Primary | Hijau | `#2E7D32` | AppBar, tombol utama, status online |
| Secondary | Oranye | `#F57C00` | Tombol darurat, FAB, aksen |
| Success | Hijau terang | `#4CAF50` | Status completed, verified |
| Warning | Kuning | `#FFC107` | Status pending |
| Error | Merah | `#F44336` | Status cancelled, rejected |
| Background | Putih | `#FFFFFF` | Latar utama |
| Surface | Abu-abu | `#F5F5F5` | Card, bottom sheet |

### 7.2 Component Patterns

**Status Chip**:

- `waiting` → Chip grey / `Colors.grey`
- `accepted` → Chip blue / `Colors.blue`
- `ongoing` → Chip orange / `Colors.orange`
- `completed` → Chip green / `Colors.green`
- `cancelled` → Chip red / `Colors.red`

**Marker di Peta**:

- Toko tambal ban → icon `📍` atau custom marker hijau dengan icon ban
- Teknisi online → icon pulsing blue dot (animasi CSS/Flutter AnimationController)
- Crowdsourced → icon pin orange (berbeda dari toko resmi)
- Customer location → blue dot (standard)

**Loading Patterns**:

- Map screen shimmer → `shimmer` package untuk skeleton loading
- Order list shimmer → skeleton cards
- Actions → `CircularProgressIndicator(30px)`
- Full-screen loading → `ModalBarrier` + `CircularProgressIndicator`

**Price Display**:

- Selalu format Rupiah: `NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)`
- Contoh: `Rp 15.000`, `Rp 50.000`, `Rp 125.000`

### 7.3 Screen Layouts

**Home / Map Screen**:

```text
┌─────────────────────────────┐
│ [AppBar: Goban]    [Filter] │
├─────────────────────────────┤
│                             │
│     [MAP — full screen]     │
│                             │
│                             │
│         [FAB: +Tambah]      │
│                             │
├─────────────────────────────┤
│ [🗺] Map  [📋] Orders [👤] Profile │
└─────────────────────────────┘
```

**Maker Bottom Sheet** (Customer):

```text
┌─────────────────────────────┐
│  ─── drag indicator ───     │
│  [Foto]  Nama Toko          │
│          ⭐⭐⭐⭐ 4.2 (30)    │
│          📍 2.3 km           │
│          💰 Rp 15.000 - start│
│          🕐 Buka 08:00-20:00 │
│                             │
│  [+ Pesan Sekarang]         │
└─────────────────────────────┘
```

**Order Tracking Screen**:

```text
┌─────────────────────────────┐
│ ← Kembali     Tracking Order│
├─────────────────────────────┤
│                             │
│     [MAP — tech position]   │
│       ←→ [customer pos]     │
│    ETA: 5 menit (1.2 km)    │
│                             │
├─────────────────────────────┤
│  [👤 Foto] Budi (Teknisi)  │
│  ⭐ 4.5 · 50x order        │
│  [📞 Hubungi] [💬 Chat]    │
└─────────────────────────────┘
```

---

## 8. Flutter Directory Structure

```text
goban/
├── .env                          # SUPABASE_URL, SUPABASE_ANON_KEY
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # entry point: runApp + ProviderScope
│   ├── app.dart                  # MaterialApp.router + GoRouter
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData, colors, text styles
│   │   │   └── status_chip.dart      # Widget warna status order
│   │   ├── router/
│   │   │   ├── app_router.dart       # GoRouter config
│   │   │   └── routes.dart           # Route path constants
│   │   ├── constants/
│   │   │   ├── api_constants.dart    # Supabase URL, storage buckets
│   │   │   └── enums.dart            # Role, OrderStatus, PaymentMethod
│   │   ├── utils/
│   │   │   ├── haversine.dart        # Hitung jarak koordinat
│   │   │   ├── formatters.dart       # Rupiah format, date format
│   │   │   └── validators.dart       # Email, phone, form validation
│   │   └── widgets/
│   │       ├── app_bottom_nav.dart   # BottomNavigationBar
│   │       ├── loading_overlay.dart  # Full screen loading
│   │       ├── shimmer_loading.dart  # Skeleton loading
│   │       ├── status_badge.dart     # Chip status order
│   │       └── error_screen.dart     # Error + retry button
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── technician_profile.dart
│   │   ├── location_model.dart
│   │   ├── order_model.dart
│   │   ├── review_model.dart
│   │   └── notification_model.dart
│   │
│   ├── services/
│   │   ├── supabase_service.dart     # Supabase client singleton
│   │   ├── auth_service.dart         # Login, register, logout
│   │   ├── geocoding_service.dart    # Nominatim API wrapper
│   │   ├── notification_service.dart # ntfy.sh push
│   │   └── storage_service.dart      # Upload/download Supabase Storage
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── map_provider.dart
│   │   ├── order_provider.dart
│   │   ├── technician_provider.dart
│   │   └── location_provider.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   └── role_select_screen.dart
│       │   └── widgets/
│       │       └── auth_form.dart
│       │
│       ├── map/
│       │   ├── screens/
│       │   │   └── map_screen.dart
│       │   ├── widgets/
│       │   │   ├── map_widget.dart
│       │   │   ├── marker_detail_sheet.dart
│       │   │   └── filter_bar.dart
│       │   └── providers/
│       │       └── map_state.dart
│       │
│       ├── orders/
│       │   ├── screens/
│       │   │   ├── create_order_screen.dart
│       │   │   ├── order_tracking_screen.dart
│       │   │   ├── order_history_screen.dart
│       │   │   └── payment_screen.dart
│       │   └── widgets/
│       │       ├── order_card.dart
│       │       ├── service_selector.dart
│       │       └── review_form.dart
│       │
│       ├── technician/
│       │   ├── screens/
│       │   │   ├── technician_register_screen.dart
│       │   │   ├── technician_dashboard.dart
│       │   │   └── verification_pending_screen.dart
│       │   └── widgets/
│       │       ├── online_toggle.dart
│       │       ├── incoming_order_card.dart
│       │       └── document_uploader.dart
│       │
│       ├── profile/
│       │   ├── screens/
│       │   │   ├── profile_screen.dart
│       │   │   └── edit_profile_screen.dart
│       │   └── widgets/
│       │       └── profile_header.dart
│       │
│       ├── locations/
│       │   ├── screens/
│       │   │   └── add_location_screen.dart
│       │   └── widgets/
│       │       └── location_form.dart
│       │
│       └── admin/                   # Flutter Web build terpisah
│           ├── screens/
│           │   ├── admin_dashboard.dart
│           │   ├── verify_technicians.dart
│           │   ├── moderate_locations.dart
│           │   └── manage_orders.dart
│           └── widgets/
│               ├── stat_card.dart
│               └── data_table.dart
│
├── test/
│   ├── unit/
│   │   ├── haversine_test.dart
│   │   ├── formatters_test.dart
│   │   └── validators_test.dart
│   ├── widget/
│   │   ├── bottom_nav_test.dart
│   │   ├── status_badge_test.dart
│   │   └── marker_detail_sheet_test.dart
│   └── integration/
│       └── order_flow_test.dart
│
└── supabase/
    ├── migrations/              # SQL migrations
    └── seed.sql                 # Data awal untuk testing
```

---

## 9. State Management (Riverpod Patterns)

### Service Provider (dependencies)

```dart
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseProvider));
});
```

### Auth State (Stream)

```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final session = ref.watch(supabaseProvider).auth.currentSession;
  if (session == null) return null;
  final user = ref.watch(supabaseProvider).auth.currentUser;
  return user != null ? UserModel.fromSupabaseUser(user) : null;
});
```

### Realtime Order Stream

```dart
final orderStreamProvider = StreamProvider.family.autoDispose<Order, String>(
  (ref, orderId) {
    return ref.watch(supabaseProvider)
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) => Order.fromJson(data.first));
  },
);
```

### Nearby Technicians (Haversine filter)

```dart
final nearbyTechniciansProvider = FutureProvider.family<List<TechnicianProfile>, MapPoint>(
  (ref, userLocation) async {
    final data = await ref.watch(supabaseProvider)
        .from('technician_profiles')
        .select()
        .eq('is_online', true)
        .eq('is_verified', true);
    
    final profiles = data.map((json) => TechnicianProfile.fromJson(json)).toList();
    
    // Filter jarak di client-side (Haversine)
    profiles.sort((a, b) => haversine(userLocation, a.point)
        .compareTo(haversine(userLocation, b.point)));
    
    return profiles.where((p) => haversine(userLocation, p.point) <= 10.0).toList();
  },
);
```

### Order Actions (StateNotifier)

```dart
class OrderController extends StateNotifier<AsyncValue<void>> {
  OrderController(this._supabase) : super(const AsyncData(null));
  
  final SupabaseClient _supabase;

  Future<void> createOrder(CreateOrderRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.from('orders').insert(request.toJson());
    });
  }

  Future<void> acceptOrder(String orderId) async {
    await _supabase.from('orders').update({
      'status': 'accepted',
      'technician_id': _supabase.auth.currentUser!.id,
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }
}
```

---

## 10. Maps — flutter_map Integration

### Setup (pubspec.yaml)

```yaml
dependencies:
  flutter_map: ^6.1.0
  latlong2: ^0.9.0            # LatLng model
  flutter_map_animations: ^0.6.0  # animated marker (opsional)
  geolocator: ^10.1.0         # GPS device
  geocoding: ^2.1.1           # alamat↔koordinat (alternatif Nominatim)
  http: ^1.2.0                # untuk Nominatim API manual
```

### Basic Map Widget

```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(-6.2088, 106.8456),  // Jakarta
    initialZoom: 13,
    onTap: (tapPosition, point) => _onMapTap(point),
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      // Atau OpenFreeMap vector tiles via MapLibre:
      // urlTemplate: 'https://tiles.openfreemap.org/styles/liberty/{z}/{x}/{y}.pbf',
      userAgentPackageName: 'com.goban.app',
    ),
    MarkerLayer(
      markers: [
        // Toko marker
        Marker(
          point: LatLng(shop.lat, shop.lng),
          child: GestureDetector(
            onTap: () => _showShopDetail(shop),
            child: Icon(Icons.location_on, color: Colors.green[700], size: 36),
          ),
        ),
        // Teknisi online marker (pulsing dot)
        Marker(
          point: LatLng(tech.lat, tech.lng),
          child: PulsingDot(size: 20, color: Colors.blue),
        ),
      ],
    ),
    // PolylineLayer untuk rute (opsional)
    if (_routePoints.isNotEmpty)
      PolylineLayer(
        polylines: [
          Polyline(
            points: _routePoints,
            color: Colors.blue,
            strokeWidth: 4,
          ),
        ],
      ),
  ],
)
```

### Pulsing Dot Widget (untuk marker teknisi online)

```dart
class PulsingDot extends StatefulWidget {
  final double size;
  final Color color;
  const PulsingDot({super.key, required this.size, required this.color});
  
  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: widget.color.withAlpha(128), blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}
```

### Real-time Location Update (technician → customer)

```dart
// In technician app:
Future<void> updateLocation(LatLng position) async {
  await supabase.from('technician_profiles').update({
    'lat': position.latitude,
    'lng': position.longitude,
  }).eq('id', supabase.auth.currentUser!.id);
}

// In customer app:
void _subscribeTechnicianLocation(String techId) {
  supabase.from('technician_profiles')
      .stream(primaryKey: ['id'])
      .eq('id', techId)
      .listen((data) {
    if (data.isNotEmpty) {
      final lat = data.first['lat'] as double;
      final lng = data.first['lng'] as double;
      _updateMarkerPosition(LatLng(lat, lng));
    }
  });
}
```

---

## 11. Development Commands

```bash
# Setup
flutter pub get                                # Install dependencies
dart run build_runner build                    # Jika pakai codegen (riverpod_annotation, json_serializable)
dart run build_runner watch                    # Auto-regenerate saat file berubah

# Run (Development)
flutter run -d chrome                          # Web — loop dev paling cepat
flutter run -d chrome --web-port 8080          # Web dengan port spesifik
flutter run -d android                         # Android emulator / device
flutter run -d ios                             # iOS simulator (macOS only)

# Build
flutter build apk --release                    # Android APK
flutter build appbundle --release              # Android App Bundle (Play Store)
flutter build ios --release                    # iOS (macOS only)
flutter build web                              # Web build (admin dashboard)

# Test
flutter test                                   # Semua test
flutter test test/unit/haversine_test.dart     # Single test file
flutter test --coverage                        # Dengan coverage
genhtml coverage/lcov.info -o coverage/html    # Generate coverage report (butuh lcov)

# Lint & Format
flutter analyze                                # Dart analyzer
dart format .                                  # Format all files
dart format --set-exit-if-changed .            # CI: format check

# Supabase CLI (opsional, untuk migration)
supabase init                                  # Init Supabase di lokal
supabase link --project-ref <ref>              # Link ke Supabase project
supabase db push                               # Push migration ke DB
supabase gen types dart --local > lib/services/database.types.dart   # Generate Dart types from DB

# Clean
flutter clean                                  # Bersihkan build cache
flutter pub cache clean                        # Bersihkan pub cache
```

---

## 12. Testing Strategy

| Level | Tools | What to Test |
| ------- | ------- | -------------- |
| **Unit** | `flutter_test` | Haversine distance, Rupiah formatter, validators, model fromJson/toJson, price calculation |
| **Widget** | `flutter_test` | Bottom nav switching, status chip colors, marker detail sheet, order card rendering, loading states |
| **Integration** | `integration_test` | Full order flow: create → accept → track → complete → review (mocked backend) |
| **Golden** | `alchemist` / golden files | Screenshot comparison for critical screens (opsional) |

### Mock Pattern (Supabase)

```dart
// test/mocks/mock_supabase.dart
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQuery extends Mock implements PostgrestQueryBuilder {}
class MockSupabaseStream extends Mock implements Stream<List<Map<String, dynamic>>> {}

// Test helper:
Widget createTestApp() {
  return ProviderScope(
    overrides: [
      supabaseProvider.overrideWithValue(mockSupabaseClient),
      currentUserProvider.overrideWith((ref) => mockUser),
    ],
    child: const MaterialApp(home: GobanApp()),
  );
}
```

---

## 13. Supabase Edge Functions (Opsional — Skip untuk MVP)

Jika dibutuhkan server-side logic, pakai Supabase Edge Functions (Deno):

```ts
// supabase/functions/match-technician/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { customerLat, customerLng, serviceType } = await req.json()
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!)
  
  const { data: technicians } = await supabase.rpc('find_nearest_technicians', {
    lat: customerLat,
    lng: customerLng,
    max_distance_km: 10,
    service: serviceType,
  })
  
  return new Response(JSON.stringify({ technicians }), { headers: { 'Content-Type': 'application/json' } })
})
```

Atau SQL Function langsung di PostgreSQL:

```sql
CREATE OR REPLACE FUNCTION find_nearest_technicians(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  max_distance_km DOUBLE PRECISION DEFAULT 10,
  service TEXT DEFAULT NULL
) RETURNS TABLE(id UUID, shop_name TEXT, distance_km DOUBLE PRECISION, rating_avg REAL)
LANGUAGE SQL STABLE AS $$
  SELECT 
    tp.id,
    tp.shop_name,
    (6371 * acos(cos(radians(lat)) * cos(radians(tp.lat)) * cos(radians(tp.lng) - radians(lng)) + sin(radians(lat)) * sin(radians(tp.lat)))) AS distance_km,
    tp.rating_avg
  FROM technician_profiles tp
  WHERE tp.is_online = true
    AND tp.is_verified = true
    AND (service IS NULL OR tp.services @> ARRAY[service])
  HAVING distance_km <= max_distance_km
  ORDER BY distance_km ASC
  LIMIT 20;
$$;
```

---

## 14. Deployment

### Web (Admin Dashboard)

```bash
flutter build web
# Upload folder build/web ke Vercel/Netlify
# Atau deploy ke Cloudflare Pages
```

### Android (APK / App Bundle)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)

```bash
flutter build ios --release
# Buka di Xcode: archive → upload ke App Store
```

### CI/CD (GitHub Actions — .github/workflows/)

```yaml
# Build + test untuk setiap PR
# Build APK untuk push ke main
# Deploy web ke Vercel/Netlify untuk push ke main
```

---

## 15. Project Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Supabase
  supabase_flutter: ^2.3.0
  
  # Maps
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Location & Geocoding
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # UI
  google_fonts: ^6.1.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
  flutter_rating_bar: ^4.0.1
  
  # Utilities
  intl: ^0.19.0                  # Date & number formatting
  uuid: ^4.2.0                   # Generate UUID
  image_picker: ^1.0.0           # Camera/gallery
  path_provider: ^2.1.0          # File paths
  http: ^1.2.0                   # Nominatim API, ntfy
  flutter_dotenv: ^5.1.0         # .env loader
  url_launcher: ^6.2.0           # Open maps, phone, whatsapp
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

---

## 16. Gotchas & Critical Notes

### Maps & Location

- **flutter_map vs MapLibre**: flutter_map (Leaflet-based) lebih sederhana, dokumentasi Flutter lebih banyak. MapLibre GL (via `mapbox_gl` fork `flutter_mapbox_gl`) untuk vector tiles + kustomisasi lebih advance. Untuk MVP, pakai **flutter_map** + OpenStreetMap raster tiles.
- **Nominatim rate limit**: 1 request/detik. Cache hasil geocoding di `SharedPreferences` atau dictionary in-memory. Jangan reverse geocode setiap kali map di-drag.
- **GPS di Web**: `flutter run -d chrome` tidak bisa akses GPS hardware. Override coordinate manual untuk development: `LatLng(-6.2088, 106.8456)` sebagai default Jakarta.
- **OSRM / ETA**: OSRM demo server tidak cocok untuk produksi (rate limit ketat). Untuk MVP, **skip ETA** atau tampilkan jarak lurus saja (Haversine → estimasi kecepatan rata-rata 30km/j).

### Supabase & Database

- **text[] query**: Filter services dengan `@>` operator. Di supabase_flutter: `.filter('services', 'cs', '{tambal ban}')` (cs = contains).
- **Realtime subscriptions**: Supabase Realtime hanya bekerja untuk baris yang di-`SELECT` oleh user. Pastikan RLS memungkinkan user melihat data yang mereka subscribe.
- **Edge Functions**: Jangan gunakan untuk MVP. Semua logic bisa client-side atau via DB function (`supabase.rpc()`).
- **Storage bucket untuk dokumen**: Buat bucket `technician-docs` dengan akses admin-only. Jangan publik. Untuk foto toko (`location-photos`), set public-read.
- **Migrasi DB**: Simpan SQL migration di `supabase/migrations/`. Eksekusi via Supabase Dashboard SQL Editor atau CLI `supabase db push`.

### Flutter

- **Hot reload vs Hot restart**: Hot reload untuk UI changes. Hot restart untuk state changes (provider, riverpod). `flutter run -d chrome` dengan `--web-port` tetap untuk development.
- **Riverpod codegen**: Jika pakai `riverpod_annotation`, jalankan `dart run build_runner watch` di terminal terpisah.
- **Performance**: `ListView.builder` untuk order list. `shimmer` untuk skeleton loading saat fetch data. Hindari `setState` di widget besar — gunakan Riverpod.
- **Form state**: Gunakan `Form` + `TextFormField` + `validator`. Multi-step form (technician registration) pakai `Stepper` widget atau custom PageView.

### Authentication

- **Role-based routing**: Di `app.dart`, cek `currentUserProvider`. Jika `null` → LoginScreen. Jika `role=customer` → CustomerShellRoute. Jika `role=technician` → TechnicianShellRoute. Jika `role=admin` → AdminShellRoute.
- **Session persistence**: Supabase Flutter otomatis menyimpan session. Tidak perlu token manual.
- **Phone auth**: Supabase Auth support phone login, tapi perlu Twilio atau provider SMS (berbayar). Untuk MVP, cukup email + Google OAuth.

### Admin Web Dashboard

- **Flutter Web entry point**: Bisa dibuat sebagai feature (`lib/features/admin/`) atau project Flutter terpisah. Untuk MVP, cukup feature gate: `if (user.role == 'admin')` tampilkan menu admin.
- **Responsive layout**: Flutter Web untuk admin pakai `LayoutBuilder` + breakpoint untuk tablet vs desktop.

### Testing

- **Mock Supabase**: `mocktail` untuk mock `SupabaseClient` dan `PostgrestQueryBuilder`. Jangan panggil Supabase asli di unit test.
- **Golden testing**: Opsional. Jika dipakai, pastikan snapshot file di-commit ke repo.

---

## 17. Contribution Workflow

1. **Fork** repo → clone lokal
2. **Branch** dari `main`: `git checkout -b feature/nama-fitur`
3. **Code** → ikuti struktur direktori di atas
4. **Format**: `dart format .`
5. **Lint**: `flutter analyze` — must pass tanpa error
6. **Test**: `flutter test` — must pass, tulis test baru untuk logic yang diubah
7. **Commit**: Pesan jelas, bahasa Inggris atau Indonesia (konsisten)
8. **Push**: `git push origin feature/nama-fitur`
9. **PR** ke `main` → deskripsi jelas: apa yang diubah, kenapa, screenshot untuk UI

### Branch naming convention

```text
feature/tambah-filter-peta
fix/haversine-division-by-zero
docs/update-readme
refactor/extract-map-widget
```

---

## 18. Environment Setup

### File `.env` (root project)

```text
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

### Dart define (alternative for build)

```bash
flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### Supabase Client Init (lib/services/supabase_service.dart)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

---

## 19. Project Roadmap (Agent Implementation Order)

| Phase | Tasks | Est. |
| ------- | ------- | ------ |
| **P0: Foundation** | Flutter init, supabase setup, auth (login/register), role selection | 1 week |
| **P1: Map Core** | flutter_map widget, OpenStreetMap tiles, GPS location, basic markers | 1 week |
| **P2: Customer Order** | Service selection, create order, waiting screen, order status | 1 week |
| **P3: Technician** | Registration form (multi-step), admin verification, online toggle, accept/reject order | 2 weeks |
| **P4: Tracking** | Real-time location share (technician), tracking screen (customer), order status flow | 1 week |
| **P5: UGC Locations** | Add location form, pending/review/admin approval, marker display | 1 week |
| **P6: Reviews & History** | Rating form, review list, order history (both sides) | 0.5 week |
| **P7: Admin Dashboard** | Web build, technician verification, location moderation, order monitoring | 1 week |
| **P8: Polish** | Shimmer loading, error handling, chat, push notifications, performance | 1 week |

Total MVP: ~8-9 weeks (single dev).
