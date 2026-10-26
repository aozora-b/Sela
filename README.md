# Sela — High-Performance Video Frame Extractor

<p align="center">
  <b>Ekstraksi frame diam dari video dengan presisi tinggi, mulus, dan bebas jeda.</b><br>
  <i>A modern, robust Flutter & Native Android video frame extraction utility.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-API%2029%20to%2036-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Kotlin-2.0+-7F52FF?logo=kotlin&logoColor=white" alt="Kotlin" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20Riverpod-blue" alt="Architecture" />
  <img src="https://img.shields.io/badge/Tests-91%20Passing-success" alt="Tests" />
</p>

---

## 🌟 Tentang Aplikasi (Overview)

**Sela** adalah aplikasi Android berbasis Flutter dengan backend performa tinggi yang ditulis dalam **Kotlin** dan **Platform Channel**. Dirancang untuk kreator konten, animator, editor video, dan analis media yang membutuhkan ekstraksi frame foto dari video dengan akurasi tinggi hingga ke tingkat milidetik, tanpa mengalami masalah *memory leak* atau *lag* pada video berdurasi panjang / VFR (Variable Frame Rate).

---

## ✨ Fitur Utama (Key Features)

- 📸 **Mode Manual Presisi**: Jelajahi video frame-demi-frame dengan tombol langkah halus (`-1`, `+1`, `-10`, `+10`) dan scrub timeline presisi.
- ⏱️ **Mode Interval Otomatis**: Ekstrak ribuan frame secara berkala berdasarkan interval waktu (0.25s, 0.5s, 1s, 2s, 5s) langsung ke folder penyimpanan rapi.
- ⚡ **Filmstrip Cepat (0 ms Instant Placeholder)**: Pindah dan lompat menit tanpa layar kosong berkat sistem *strip warm-up*, *background neighbour prefetch*, dan *LRU caching*.
- 🖼️ **Android Photo Picker Terintegrasi**: Membuka galeri video modern tanpa memerlukan izin penyimpanan sensitif (`READ_MEDIA_VIDEO`), aman dan cepat.
- 🌍 **Dukungan 10 Bahasa (Internationalization)**: Tersedia dalam Bahasa Indonesia, English, Español, Français, Deutsch, 日本語, serta dukungan layout RTL penuh untuk العربية, فارسی, עברית, dan اردو.
- 💾 **Penyimpanan Langsung ke MediaStore Galeri**: Mendukung ekspor format PNG kualitas tinggi dan JPEG terkompresi dengan pengorganisasian per nama subfolder video.
- 🎨 **Tampilan Elegan & Responsif**: Palet warna dark mode modern, animasi halus, dan haptic feedback pada setiap ketukan.

---

## 🛠️ Arsitektur & Optimasi Mesin (Engineering Highlights)

1. **Dual Native Decoders & Request Coalescing**:
   - Memisahkan thread pratinjau utama (`previewExecutor`) dan thread pembuatan thumbnail filmstrip (`thumbExecutor`).
   - Pembatalan permintaan kadaluarsa secara instan saat pengguna menggeser slider dengan cepat (*token sequence cancellation*).
2. **Single Source of Truth Frame ↔ Waktu**:
   - Menghitung `avg_frame_rate` container secara akurat dari `MediaExtractor` dan `MediaMetadataRetriever` sehingga nomor frame dan posisi waktu selalu sinkron 100%.
   - Mencegah masalah frame hitam/kosong pada ujung akhir video.
3. **Manajemen Memori Ketat (Zero Memory Leak)**:
   - Pembatasan memori `ImageCache` Flutter (60 entri / 24 MB) dan pembersihan otomatis saat sesi selesai.
   - Pemanfaatan `cacheWidth` pada seluruh widget gambar untuk menghindari decode resolusi penuh 4K pada kartu thumbnail kecil.

---

## 🚀 Memulai (Getting Started)

### Prasyarat
- [Flutter SDK](https://flutter.dev) (v3.24+ / v3.47+)
- [Android SDK](https://developer.android.com/studio) (API 29–36)
- Java 17

### Menjalankan Aplikasi
```bash
# 1. Clone repository
git clone https://github.com/aozora-b/sela.git
cd sela

# 2. Ambil dependensi
flutter pub get

# 3. Jalankan pengujian unit & widget (91 tests)
flutter test

# 4. Jalankan aplikasi di HP / Emulator
flutter run
```

### Membangun Berkas Rilis (Production Build)
```bash
# Membangun APK (Split per ABI agar ukuran berkas kecil ~19MB):
flutter build apk --split-per-abi --release

# Membangun AAB (Android App Bundle untuk Google Play Store):
flutter build appbundle --release
```

---

## 🧪 Kualitas Kode (Quality Assurance)
- **Static Analysis**: `flutter analyze` $\rightarrow$ **0 issues found**.
- **Test Coverage**: 91 unit & widget tests lolos (100%).
- **Constraint Compliance**: Kode modular terstruktur rapi.

---

## 📄 Lisensi
Hak Cipta © 2026 **aozora-b**. Seluruh hak cipta dilindungi undang-undang.
