# Spesifikasi Desain & Tata Letak Sela (Flutter UI/UX Spec)

Dokumen ini adalah acuan visual dan perilaku layout untuk 10 layar Sela. 
Dokumen ini disusun menggunakan prinsip tata letak **Constraint-Driven & Responsive Flutter Layout**, menghindari angka mutlak yang kaku agar tampilan adaptif di berbagai ukuran layar ponsel (layar kecil 360dp hingga layar lebar 430dp+).

---

## 1. Sistem Token Desain (Design Tokens)

### 1.1 Palet Warna (`SelaColors`)

| Token | Hex | Kegunaan |
|---|---|---|
| `bg` | `#17120F` | Latar belakang kanvas utama (*deep espresso*) |
| `bgElevated` | `#221B17` | Latar permukaan melayang, modal sheet, navbar |
| `surface` | `#2B2420` | Kartu konten, baris daftar setelan, panel kontrol |
| `surfaceHighlight` | `#352D28` | Efek hover / seleksi kartu aktif |
| `border` | `#3A312B` | Garis tepi subtil 1px pada kartu dan divider |
| `textPrimary` | `#F3EDE3` | Judul, teks utama, angka aktif (*warm cream*) |
| `textSecondary` | `#A2968B` | Subjudul, metadata, hint, label non-aktif (*muted taupe*) |
| `accent` | `#C4693F` | Tombol CTA utama, radio/centang aktif, tick mark (*terracotta*) |
| `accentSoft` | `#2B1D17` | Latar belakang chip seleksi aktif |

### 1.2 Spasi & Padding Elastis (`SelaSpace`)

Gunakan token spasi di dalam `EdgeInsetsDirectional`:

| Token | Nilai dp | Kegunaan Utama |
|---|---|---|
| `xs` | `4.0` | Jarak mikro antar ikon dan teks pendukung |
| `sm` | `8.0` | Jarak antar item dalam daftar rapat, gap thumbnail |
| `md` | `12.0` | Padding internal kartu ringkas |
| `lg` | `16.0` | Jarak standar antar seksi kontrol |
| `xl` | `24.0` | **Margin horizontal standar layar** |
| `xxl` | `32.0` | Spasi vertikal antar blok besar |

### 1.3 Radius Sudut (`SelaRadius`)

| Token | Nilai dp | Komponen |
|---|---|---|
| `sm` | `8.0` | Thumbnail filmstrip, tag kecil |
| `card` | `16.0` | Kartu utama, panel kontrol, kotak input |
| `sheet` | `24.0` | Sudut atas modal bottom sheet |
| `pill` | `999.0` | Tombol aksi utama, segmented control, chip filter |

---

## 2. Pola Tata Letak Fleksibel Flutter (Constraint-Driven Layout Rules)

### 2.1 Mengisi Ruang Lebar (Horizontal Fluidity)
* **Tombol CTA Penuh**: Gunakan `SizedBox(width: double.infinity, height: 56, child: ElevatedButton(...))` atau bungkus dalam `Row` dengan `Expanded`.
* **Kartu Konten**: Jangan beri lebar statis. Biarkan `Column` dengan `crossAxisAlignment: CrossAxisAlignment.stretch` atau `width: double.infinity` mengisi seluruh lebar layar dikurangi margin `SelaSpace.xl`.

### 2.2 Penanganan Area Vertikal (Vertical Adaptability)
* **Area Pratinjau Video**:
  Gunakan `AspectRatio(aspectRatio: 16 / 9, ...)` atau `LayoutBuilder` untuk menghitung rasio tinggi video secara dinamis agar tidak memotong kontrol di layar berukuran pendek.
* **Scrollability**:
  Layar dengan banyak setelan wajib dibungkus `SingleChildScrollView` atau `CustomScrollView` dengan `SliverFillRemaining(hasScrollBody: false)` agar tombol CTA tetap berada di bawah tanpa overflow di layar kecil.

### 2.3 Safe Insets (Edge-to-Edge)
* **Top App Bar**:
  ```dart
  SafeArea(
    bottom: false,
    child: Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: SelaSpace.xl, vertical: SelaSpace.md),
      child: ...,
    ),
  )
  ```
* **Bottom Action Bar**:
  ```dart
  Padding(
    padding: EdgeInsetsDirectional.only(
      start: SelaSpace.xl,
      end: SelaSpace.xl,
      top: SelaSpace.md,
      bottom: MediaQuery.paddingOf(context).bottom + SelaSpace.md,
    ),
    child: SizedBox(width: double.infinity, height: 56, child: ...),
  )
  ```

---

## 3. Spesifikasi Rinci 10 Layar Sela

### Layar 01: Home / Impor Video
* **Tujuan**: Titik awal memilih video atau membuka video terakhir.
* **Komponen Utama**:
  1. *Wordmark Header*: Judul "Sela" bergaya serif elegan.
  2. *Hero Drop Zone*: Kartu permukaan `SelaColors.surface` bergaris putus-putus halus `SelaColors.border`, berisi ikon video dan teks ajakan *"Pilih video untuk mulai mengekstrak frame"*.
  3. *Tombol Utama*: Lebar `double.infinity`, tinggi 56dp, warna terracotta *"Pilih Video"*.
  4. *Quick Access Card*: Riwayat video terakhir yang belum selesai diekstrak (jika ada).

### Layar 02: Ekstraksi (Pusat Kendali Pengambilan)
* **Tujuan**: Menavigasi video dan menyetel parameter ekstraksi.
* **Komponen Utama**:
  1. *Header Bar*: Tombol kembali + nama file video (`TextOverflow.ellipsis`) + chip resolusi `1080×1920`.
  2. *Video Player Container*: Rasio dinamis dengan overlay waktu `00:04.2` dan nomor frame saat ini `Frame 128 / 261`.
  3. *Timeline Scrubber*: Bar progres interaktif dengan penanda titik tangkapan.
  4. *Segmented Control*: Sakelar mode `[ Manual | Interval ]` (pill shape).

### Layar 03: Mode Manual
* **Tujuan**: Mengambil frame tunggal yang sangat presisi dengan geseran milidetik.
* **Komponen Utama**:
  1. *Tombol Nudge*: Dua tombol melingkar 48x48dp berlabel `−1 Frame` dan `+1 Frame`.
  2. *Filmstrip Reel*: Daftar horizontal thumbnail frame sekitar (scrollable), frame tengah memiliki border `SelaColors.accent` 2px.
  3. *Action Button*: Tombol `width: double.infinity` *"Simpan Frame Ini"* + tautan teks *"Simpan Semua Frame Ditandai"*.

### Layar 04: Mode Interval
* **Tujuan**: Mengekstrak ratusan frame otomatis berdasarkan jeda waktu.
* **Komponen Utama**:
  1. *Timeline dengan Tick Marks*: Garis waktu menampilkan titik-titik terracotta di setiap detik pengambilan.
  2. *Preset Chips*: Baris horizontal chip interval `[ 0.25s | 0.5s | 1s | 2s | 5s | Kustom ]`.
  3. *Summary Badge*: Ringkasan dinamis *"±9 frame akan diekstrak (estimasi ~18 MB)"*.
  4. *Action Button*: Tombol terracotta lebar penuh *"Mulai Ekstraksi"*.

### Layar 05: Progres Ekstraksi
* **Tujuan**: Menampilkan proses decode video di latar depan secara transparan.
* **Komponen Utama**:
  1. *Circular Progress Gauge*: Ring progres terracotta 160dp dengan angka besar di tengah (contoh: `128 / 188 Frame`).
  2. *ETA Subtitle*: Teks taupe halus *"Sisa waktu sekitar 4 detik..."*.
  3. *Live Stream Thumbnails*: 4 thumbnail frame terakhir yang berhasil diproses muncul secara real-time.
  4. *Tombol Batalkan*: Tombol outline netral *"Batalkan"*.

### Layar 06: Hasil Ekstraksi (Grid Galeri)
* **Tujuan**: Memilih, meninjau, dan mengekspor frame ke galeri ponsel.
* **Komponen Utama**:
  1. *Top Bar*: Judul "Hasil" + tombol teks *"Pilih Semua"*.
  2. *Responsive Grid*: `GridView.builder` 3 kolom (aspek rasio 1:1, gap 8dp).
  3. *Selection Badge*: Ikon centang terracotta di sudut kanan atas thumbnail yang dipilih.
  4. *Sticky Bottom Bar*: Tombol *"Simpan ke Galeri"* + tombol icon *"Bagikan"*.

### Layar 07: Riwayat Ekstraksi
* **Tujuan**: Melihat arsip sesi ekstraksi sebelumnya tanpa mengekstrak ulang video.
* **Komponen Utama**:
  1. *Daftar Kartu Riwayat*: Setiap baris memuat thumbnail video, nama berkas, tanggal, jumlah frame tersimpan, dan ukuran total.
  2. *Swipe Action*: Geser ke kiri untuk menghapus riwayat.

### Layar 08: Setelan Utama
* **Tujuan**: Mengatur format output bawaan, kualitas, dan tema.
* **Komponen Utama**:
  1. *Grup Setelan Output*: Format default (JPEG / PNG), Kualitas kompresi JPG (slider + angka persis).
  2. *Grup Preferensi*: Pilihan Bahasa, Tema (Gelap / Terang / Sistem), Informasi Versi Sela.

### Layar 09: Lembar Pemilih Bahasa (Bottom Sheet)
* **Tujuan**: Mengganti bahasa aplikasi dengan cepat dan aman.
* **Komponen Utama**:
  1. *Search Input*: Kolom pencarian bahasa dengan ikon kaca pembesar.
  2. *Disarankan*: Dua chip atas `[ Bahasa Indonesia ✓ ]` dan `[ English ]`.
  3. *Daftar Bahasa*: Radio button list dengan nama asli (native script) + nama Inggris di bawahnya + tag `[RTL]` untuk bahasa Arab/Ibrani.

### Layar 10: Dialog Konfirmasi RTL
* **Tujuan**: Mencegah kebingungan pengguna saat tata letak dibalik dari kanan ke kiri.
* **Komponen Utama**:
  1. *Pratinjau Miniatur*: Ilustrasi ringkas tata letak terbalik.
  2. *Teks Penjelasan*: *"Tata letak navigasi akan dibalik mengikuti kaidah baca kanan ke kiri."*
  3. *Tombol Konfirmasi*: Tombol Batal & Terapkan.
