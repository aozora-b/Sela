# AGENTS.md — Aturan Proyek Sela (Android & iOS)

Berkas ini dibaca otomatis oleh AI coding agent sebelum menulis kode.
Patuhi seluruh aturan di sini. Jika ada konflik dengan permintaan lain, aturan
di berkas ini yang menang, kecuali dinyatakan sebaliknya secara eksplisit.

---

## 1. Konteks & Repositori

**Sela** adalah aplikasi Flutter (Android & iOS) untuk mengekstrak frame diam dari video secara presisi dan cepat.

```
Referensi (HANYA BACA):  C:\Users\Stelle\projects\frame-extractor
Target  (tulis di sini): C:\Users\Stelle\StudioProjects\Sela
```

- **Perilaku logika HARUS identik dengan versi desktop.**
- Spesifikasi migrasi: `docs/sela-migrasi.md`.
- Spesifikasi desain & layout: `docs/design-spec.md`.

### DILARANG MENGUBAH REPO REFERENSI
`C:\Users\Stelle\projects\frame-extractor` adalah proyek Python/Qt yang sudah dirilis. Dilarang menulis, mengedit, atau menghapus berkas apa pun di sana.

---

## 2. Target Platform & Android SDK

Konfigurasi Android di `android/app/build.gradle.kts`:
- `compileSdk = 36`
- `minSdk = 29` (Android 10 — Scoped Storage / zero storage permissions)
- `targetSdk = 36` (Android 16 — standar rilis Google Play)
- iOS: iOS 14.0+

---

## 3. Filosofi Tata Letak Flutter (Constraint-Driven, Anti-Hardcode)

DILARANG membuat layout kaku dengan lebar/tinggi piksel tetap di luar batas token.
Patuhi aturan Flutter idiomatik:

1. **Gunakan Fluid Width**: Gunakan `double.infinity`, `Expanded`, `Flexible`, atau `FractionallySizedBox` untuk mengisi ruang kontainer secara elastis.
2. **Constraint-Based**: Biarkan *parent widget* memberikan constraint ke *child*. Jangan mengunci dimensi yang memicu `RenderFlex overflowed`.
3. **Sentuhan Aman (Touch Target)**: Tombol dan area interaktif memiliki target sentuh minimal `48x48 dp` (`kMinInteractiveDimension`).
4. **Insets & Safe Area Responsif**:
   - Header/Top Bar: Gunakan `SafeArea(bottom: false, ...)` atau `MediaQuery.paddingOf(context).top`.
   - Bottom Sheet / Bottom Bar: Wajib perhitungkan `MediaQuery.paddingOf(context).bottom` (gesture bar Android 15+ edge-to-edge).
5. **Arah Teks & Tata Letak**: Selalu gunakan `EdgeInsetsDirectional`, `AlignmentDirectional`, `start` dan `end` (BUKAN `left`/`right`) untuk mendukung mode LTR dan RTL secara otomatis.

---

## 4. Batas & Kerapian Berkas — WAJIB

- **Maksimal 200 baris per berkas Dart.**
- Satu berkas satu tanggung jawab (Single Responsibility Principle).
- `main.dart` maksimal **40 baris** (bootstrap + inisialisasi saja).
- Jika berkas mendekati 200 baris, segera pecah widget privat menjadi komponen terpisah di subfolder `widgets/`.

---

## 5. Pemisahan Lapisan Arsitektur

```
lib/
├── domain/     → Murni logika Dart. DILARANG import 'package:flutter/*'.
├── engine/     → MethodChannel native (Android Media3/iOS AVAsset).
├── features/   → UI & State Management (Riverpod).
├── theme/      → Token warna, tipografi, spasi, radius, ThemeData.
└── core/       → Utilitas format, logger, result type.
```

- **Uji `domain/`**: Seluruh berkas di `lib/domain/` wajib bisa diuji dengan `dart test` murni tanpa emulator atau runtime Flutter.

---

## 6. State Management

- Gunakan **Riverpod** (`flutter_riverpod` + `Notifier` / `AsyncNotifier`).
- Satu controller/notifier per fitur.
- DILARANG memakai `setState` untuk membagikan data lintas layar atau komponen.
- `setState` hanya diizinkan untuk animasi mikro lokal di dalam satu `StatefulWidget`.

---

## 7. Mesin Ekstraksi (Platform Channel)

| Aspek | Aturan Implementasi |
|---|---|
| Android Utama | `androidx.media3.inspector.frame.FrameExtractor` (asinkron) |
| Android Cadangan | `MediaMetadataRetriever` |
| iOS | `AVAssetImageGenerator` |
| `exact = true` (Manual) | `OPTION_CLOSEST` / `requestedTimeTolerance = .zero` |
| `exact = false` (Interval) | `OPTION_CLOSEST_SYNC` / toleransi bawaan |
| Instance Extractor | **1 instance per video**, BUKAN dibuat ulang tiap frame |
| Siklus Hidup | Wajib `close()` / `release()` saat selesai atau dibatalkan |
| Manajemen Memori | Panggil `bitmap.recycle()` segera setelah di-encode ke byte |
| Data Channel | Kirim **byte terkompresi (JPEG/PNG)** ke Dart, bukan raw bitmap |
| Satuan Waktu | `MediaMetadataRetriever` memakai **mikrodetik** (`timeMs * 1000`) |

---

## 8. Standar Sebelum Menyatakan Selesai

Sebelum melapor ke pengguna bahwa satu tahap selesai, AI WAJIB menjalankan:

```bash
flutter analyze
dart format .
flutter test
```

Laporan penyelesaian harus mencantumkan:
1. Status `flutter analyze` (harus `0 issues found`).
2. Status pengujian `flutter test` (jumlah tes lulus).
3. Daftar berkas baru/diedit beserta jumlah barisnya.
