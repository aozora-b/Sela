# Dokumen Migrasi: Frame Extractor (Desktop) → Sela (Android & iOS)

**Versi dokumen:** 1.0
**Tanggal:** 23 Oktober 2026
**Sumber yang dianalisis:** [github.com/aozora-b/frame-extractor](https://github.com/aozora-b/frame-extractor) — commit `54af9a9`, 22 commit, rilis v1.0.0
**Tujuan dokumen:** menjadi acuan tunggal untuk membangun aplikasi mobile **Sela** tanpa menulis ulang pekerjaan yang sudah ada di versi desktop.

---

## 1. Ringkasan Eksekutif

### 1.1 Keputusan utama

| Pertanyaan | Keputusan | Alasan |
|---|---|---|
| Apakah kode Python bisa dijalankan di Android/iOS? | **Tidak** | PySide6, ffmpeg subprocess, dan opencv-python tidak punya jalur produksi ke mobile |
| Apakah seluruh pekerjaan desktop hangus? | **Tidak** | Logika perencanaan titik sampel, penamaan berkas, dan katalog terjemahan adalah kode murni yang bisa diport |
| Framework mobile? | **Flutter** | Satu basis kode untuk Android dan iOS; iOS tidak bisa dibangun sekarang tapi tidak perlu menulis ulang UI nanti |
| Mesin ekstraksi? | **API resmi platform**, bukan FFmpeg | `androidx.media3.inspector.frame.FrameExtractor` (Android), `AVAssetImageGenerator` (iOS) |
| Apakah memakai paket Flutter siap pakai? | **Tidak** | Paket populer untuk kebutuhan ini sudah tidak dirawat (lihat §3.2) |
| Bagaimana memastikan perilaku mobile sama dengan desktop? | **Port tes, bukan port kode** | `tests/test_plan.py` dan `tests/test_naming.py` tidak bergantung pada Qt maupun FFmpeg |

### 1.2 Angka kunci dari analisis repo

| Metrik | Nilai | Implikasi |
|---|---|---|
| Modul di `src/frame_extractor/core/` | 14 berkas | 6 diport, 3 diganti, 4 dibuang, 1 `__init__` |
| Berkas uji yang bisa diport | 2 dari 7 | `test_plan.py` (15 kasus), `test_naming.py` (17 kasus) |
| Format video didukung desktop | 21 ekstensi | Akan menyusut menjadi ±8 di mobile |
| Ukuran rilis Windows | 242 MB | Mobile bisa di bawah 20 MB tanpa FFmpeg |
| Batas frame (`MAX_FRAMES`) | 200.000 | Pertahankan angkanya agar konsisten |

### 1.3 Yang harus diterima sebagai konsekuensi

Tiga hal ini bukan kegagalan, tapi konsekuensi wajar dari pindah platform. Semuanya harus ditulis di deskripsi Play Store agar tidak menerima ulasan negatif:

1. **Format video menyusut** dari 21 menjadi sekitar 8 ekstensi.
2. **Tidak ada pemindaian folder** — Android dan iOS tidak memberi akses bebas ke filesystem.
3. **Ekstraksi panjang bisa terhenti** saat aplikasi di latar belakang, kecuali memakai foreground service.

---

## 2. Analisis Repo Sumber

### 2.1 Stack yang terdeteksi

Berdasarkan `pyproject.toml` dan `AGENTS.md`:

| Komponen | Versi | Peran |
|---|---|---|
| Python | 3.11+ (dirilis dengan 3.12) | Bahasa utama |
| PySide6 | 6.12.0 | Antarmuka Qt |
| opencv-python-headless | 5.0.0.93 | Mesin cadangan |
| FFmpeg | n8.1 LGPL shared | Mesin utama (subprocess) |
| PyInstaller | 6.22.3 | Pembuatan paket |
| pytest / ruff | 8+ / 0.6+ | Uji dan lint |

### 2.2 Penilaian kualitas proyek

Ini perlu dinyatakan karena memengaruhi strategi migrasi: **proyek ini di atas rata-rata aplikasi hobi.**

| Aspek | Temuan | Nilai untuk migrasi |
|---|---|---|
| Pemisahan lapisan | `core/` bebas dari impor Qt | **Tinggi** — logika bisa dibaca tanpa memahami UI |
| Kontrak data eksplisit | `models.py` memakai `@dataclass(frozen=True)` | **Tinggi** — mudah diterjemahkan ke Dart `class` + `final` |
| Validasi terpusat | Validasi di `ExtractOptions.__post_init__` | **Tinggi** — titik tunggal kebenaran |
| Pesan galat berlapis | `PlanError` dengan `advice` | **Sedang** — pola bagus, perlu padanan di Dart |
| Cakupan uji | 7 berkas uji, termasuk GUI offscreen | **Tinggi** — 2 berkas langsung bisa diport |
| Lint ketat | ruff: `E,F,I,UP,B,SIM` | **Sedang** — jadi acuan aturan Dart |
| Pemisahan lisensi | `THIRD-PARTY-NOTICES.md` + `licenses/` | **Rendah di mobile** — sebagian besar dependensi hilang |
| Dokumentasi | README sangat rinci, berfungsi sebagai spesifikasi produk | **Tinggi** — jadi dasar dokumen ini |

**Kesimpulan:** struktur proyek ini justru yang membuat migrasi layak. Kalau seluruh logika tertanam di dalam widget Qt, tidak ada yang bisa diselamatkan.

### 2.3 Inventaris `core/` dan status migrasi

| Berkas | Isi | Status | Catatan |
|---|---|---|---|
| `plan.py` | Perhitungan titik sampel 3 mode | **Port** | Murni matematika, tanpa I/O |
| `naming.py` | Sanitasi nama, format waktu, template, anti-tabrakan | **Port** | Perlu penyesuaian aturan MediaStore |
| `models.py` | `VideoInfo`, `ExtractOptions`, `FrameResult` | **Port** | Jadi `class` Dart |
| `formats.py` | 21 ekstensi + pemindaian folder | **Port sebagian** | Daftar ekstensi menyusut; `scan_folder` dibuang |
| `humanize.py` | Format byte, durasi, ETA (id/en) | **Port** | Ganti ke `intl` / terjemahan ARB |
| `errors.py` | Hierarki galat | **Port polanya** | Dart tidak punya exception bertipe seketat Python |
| `probe.py` | Metadata via ffprobe | **Ganti** | `MediaMetadataRetriever` / AVAsset |
| `extract.py` | Orkestrasi pemilihan mesin | **Ganti** | Tidak perlu dua mesin di mobile |
| `extract_common.py` | Logika bersama antar-mesin | **Ganti** | Konsep dua mesin hilang |
| `extract_ffmpeg.py` | Subprocess FFmpeg | **Buang** | Tidak mungkin di mobile |
| `extract_opencv.py` | OpenCV `VideoCapture` | **Buang** | Wheel desktop |
| `process.py` | Manajemen subprocess | **Buang** | Tidak ada subprocess |
| `ffmpeg_tools.py` | Pencarian biner FFmpeg | **Buang** | Tidak relevan |

Di luar `core/`: `app.py`, `ui/`, `worker.py` (QThread), dan `cli.py` seluruhnya dibuang. `QSettings` diganti `shared_preferences`.

---

## 3. Temuan Riset Teknis

Riset ini dilakukan untuk memverifikasi bahwa pilihan yang diambil bukan sekadar kebiasaan, melainkan yang terbaik saat ini.

### 3.1 FFmpeg tidak layak dipakai di mobile — dan ekosistemnya sedang bermasalah

**FFmpegKit resmi dihentikan pada 6 Januari 2025.** Repositori diarsipkan, dan seluruh biner native untuk Android, iOS, Flutter, dan React Native dihapus dari repositori publik. Akibat praktisnya: `CocoaPods` gagal melakukan resolve pada proyek iOS baru, dan dependensi Maven lama tidak bisa diunduh.

Sumber:
- [Saying Goodbye to FFmpegKit — Taner Sener](https://tanersener.medium.com/saying-goodbye-to-ffmpegkit-33ae939767e1)
- [Diskusi r/androiddev](https://www.reddit.com/r/androiddev/comments/1i25lzo/ffmpegkit_is_being_retired_are_there_any/)

Ada pengganti komunitas (FFmpegKitNext), tetapi memilihnya berarti menaruh fondasi aplikasi pada proyek yang baru saja kehilangan maintainer utamanya. Untuk produk yang ingin stabil dan murah dirawat, ini risiko yang tidak perlu diambil — terutama karena kebutuhan kita sebenarnya sederhana.

**Kesimpulan: jangan pakai FFmpeg di Sela.**

### 3.2 Paket Flutter siap pakai untuk ekstraksi frame sudah tidak dirawat

Paket yang paling sering direkomendasikan, `video_thumbnail`:

| Fakta | Nilai |
|---|---|
| Versi terakhir | 0.5.6 |
| Tanggal rilis versi terakhir | **14 Mei 2025** (lebih dari 17 bulan) |
| Publisher | *unverified uploader* |
| Skor pub.dev | 140 poin |
| Status di direktori Flutter Gems | **"Maintenance Status: Poor"** |

Sumber: [pub.dev/packages/video_thumbnail](https://pub.dev/packages/video_thumbnail), [fluttergems.dev/video](https://fluttergems.dev/video/)

Masalah yang lebih serius daripada tanggal rilis: paket ini **tidak memberi kendali atas pemilihan keyframe**. Ia hanya menerima `timeMs` dan mengembalikan gambar terdekat. Padahal justru perbedaan *exact frame* vs *keyframe* inilah yang membuat mode manual dan mode interval terasa cepat atau lambat di aplikasi Anda.

**Kesimpulan: jangan bergantung pada `video_thumbnail`.** Tulis platform channel tipis sendiri.

### 3.3 Android punya API resmi khusus untuk kebutuhan ini

Sejak Media3, Google menyediakan kelas yang memang dirancang untuk kasus ini:

**`androidx.media3.inspector.frame.FrameExtractor`**

| Karakteristik | Detail |
|---|---|
| Pembuatan | `FrameExtractor.Builder(context, mediaItem).build()` |
| Pengambilan frame | `getFrame(timestampMs)` — **asinkron**, mengembalikan `ListenableFuture` |
| Thumbnail | `getThumbnail()` |
| Siklus hidup | Mengimplementasikan `AutoCloseable` |
| Bonus | Bisa menerapkan scaling, cropping, rotasi saat ekstraksi |

Sumber: [Extract video frames — developer.android.com](https://developer.android.com/media/media3/inspector/extract-frames) (diperbarui 8 September 2026)

Ini lebih baik daripada `MediaMetadataRetriever` karena tiga alasan: asinkron sejak awal (tidak memblokir thread), mendukung transformasi tanpa langkah pascaproses, dan dikelola Google sebagai bagian dari Media3.

**`MediaMetadataRetriever` tetap disimpan sebagai cadangan** untuk perangkat lama atau kasus khusus, karena ia tersedia sejak API level rendah dan perilakunya sangat dipahami.

Perbedaan opsi yang wajib dipahami:

| Opsi | Perilaku | Kecepatan | Padanan di aplikasi Anda |
|---|---|---|---|
| `OPTION_CLOSEST` | Decode sampai frame persis | Lambat | **Mode manual** |
| `OPTION_CLOSEST_SYNC` | Berhenti di keyframe terdekat | Cepat (±10×) | **Mode interval** |

### 3.4 iOS punya padanan yang hampir identik

`AVAssetImageGenerator` menyediakan kendali yang sama melalui dua properti:

| Properti | Nilai | Efek | Padanan |
|---|---|---|---|
| `requestedTimeToleranceBefore` / `After` | `.zero` | Frame persis | `OPTION_CLOSEST` |
| `requestedTimeToleranceBefore` / `After` | nilai toleransi bawaan | Keyframe terdekat | `OPTION_CLOSEST_SYNC` |

Ini penting: **konsep dua mode Anda bisa dipertahankan persis di kedua platform** dengan semantik yang sama. Itu bukan kebetulan — kedua API memang dirancang untuk kebutuhan preview dan thumbnail.

### 3.5 Konsekuensi arsitektural dari temuan di atas

| Keputusan | Konsekuensi |
|---|---|
| Tanpa FFmpeg | Ukuran aplikasi turun drastis; tidak ada beban lisensi LGPL; tidak ada subprocess |
| Tanpa paket pihak ketiga | Perlu ±150 baris Kotlin dan ±100 baris Swift |
| Platform channel sendiri | Kendali penuh atas exact vs keyframe, dan atas pembatalan |

Biaya menulis channel sendiri memang nyata, tetapi lebih kecil daripada risiko memakai paket yang tidak dirawat atau FFmpeg yang sudah dihentikan.

---

## 4. Peta Modul: Python → Dart

### 4.1 `plan.py` → `lib/domain/sample_plan.dart`

Ini modul paling berharga di seluruh repo. Logikanya murni: masukan angka, keluaran daftar angka. Tidak menyentuh berkas, tidak menyentuh Qt.

**Yang harus dipertahankan persis:**

| Konstanta / aturan | Nilai | Kenapa penting |
|---|---|---|
| `MAX_FRAMES` | `200_000` | Batas keamanan memori. Jangan diubah tanpa alasan kuat |
| `_EPS` | `1e-9` | Ambang untuk menghindari frame yang menyentuh batas akhir |
| Pembulatan keluaran | 6 desimal | Menjaga determinisme |
| Mode `count` | `step = span / count` | Frame **tidak** menyentuh titik akhir |
| Mode `interval` / `range` | `count = floor((span - eps) / interval) + 1` | Menentukan apakah frame terakhir ikut |

**Kontrak fungsi:**

```
planPoints(VideoInfo info, ExtractOptions opt) -> List<double>   // detik, menaik, unik
estimateOutputBytes(VideoInfo info, ExtractOptions opt, int count) -> int
```

**Aturan validasi yang harus menghasilkan galat:**

| Kondisi | Galat |
|---|---|
| Durasi tidak terhingga atau ≤ 0 | `PlanException` |
| `start >= duration - eps` | `PlanException` |
| `end - start <= eps` | `PlanException` |
| `count < 1` (mode count) | `PlanException` |
| `count > 200000` | `PlanException` |
| `interval <= 0` (mode interval/range) | `PlanException` |
| Hasil akhir kosong setelah pemfilteran | `PlanException` |

**Perkiraan ukuran keluaran** — pertahankan rumusnya agar angka di UI tidak melompat dibanding versi desktop:

| Format | Byte per piksel |
|---|---|
| PNG | `1.5` |
| JPG | `0.15 + 0.35 × (quality / 100)` |

### 4.2 `naming.py` → `lib/domain/frame_naming.dart`

**Sanitasi nama** — karakter `\ / : * ? " < > |` dan kontrol `\x00–\x1F` diganti `_`; spasi/titik di ujung dipangkas; jika kosong pakai `video`; nama yang termasuk reserved Windows diberi awalan `_`; panjang maksimum 180 karakter.

Daftar reserved: `CON, PRN, AUX, NUL, COM1–COM9, LPT1–LPT9, CONIN$, CONOUT$`.

> **Catatan mobile:** sebagian besar aturan ini memang khusus Windows. Tetap port seluruhnya, karena (a) hasil nama akan sama dengan versi desktop — penting kalau pengguna memindahkan berkas antar perangkat, dan (b) `sanitize_filename` berfungsi sebagai pertahanan terhadap *path traversal*, yang tetap relevan di Android karena MediaStore memakai nama sebagai bagian dari path.

**Format waktu** `HH-MM-SS`, dibulatkan ke detik terdekat, nilai negatif dianggap 0.

**Template default:** `{stem}_{index:06d}_{time}.{ext}`

Contoh: `buildName("liburan", 123, 123.0, "png")` → `liburan_000123_00-02-03.png`

**Aturan template:**

| Aturan | Konsekuensi jika dilanggar |
|---|---|
| Tidak boleh kosong / hanya spasi | `InvalidOptionException` |
| Wajib memuat `{index}` | `InvalidOptionException` |
| Wajib memuat `{ext}` | `InvalidOptionException` |
| Hanya boleh `{stem}`, `{index}`, `{time}`, `{ext}` | `InvalidOptionException` |
| Harus bisa dirender (format string valid) | `InvalidOptionException` |

**Anti-tabrakan:** jika nama sudah ada, tambahkan `-1`, `-2`, dan seterusnya hingga batas 100.000 percobaan.

> **Perubahan wajib untuk mobile:** di desktop, `unique_path` memeriksa `Path.exists()`. Di Android, keluaran ditulis ke **MediaStore**, bukan ke direktori biasa. Pemeriksaan harus dilakukan terhadap nama `DISPLAY_NAME` yang sudah ada di album tujuan, atau dengan menangani kegagalan insert lalu menaikkan sufiks. Perilaku yang terlihat pengguna harus tetap sama: **nama lama tidak pernah tertimpa.**

### 4.3 `models.py` → `lib/domain/models.dart`

| Python | Dart |
|---|---|
| `@dataclass(frozen=True) VideoInfo` | `class VideoInfo` dengan seluruh field `final` |
| `@dataclass(frozen=True) ExtractOptions` | `class ExtractOptions` + validasi di konstruktor `factory` |
| `@dataclass(frozen=True) FrameResult` | `class FrameResult` |
| `property resolution` | `String get resolution => '${width}×${height}'` |
| `Literal["interval","count","range"]` | `enum CaptureMode { interval, count, range }` |
| `Literal["png","jpg"]` | `enum OutputFormat { png, jpg }` |

Mengganti `Literal` dengan `enum` adalah perbaikan, bukan kompromi: Dart akan menolak nilai di luar enum saat kompilasi, sementara Python hanya menolaknya saat runtime.

**Tambahan yang disarankan di Dart:** field `warnings` pada `VideoInfo` (sudah ada di Python) sebaiknya dipakai untuk menandai video **VFR** (variable frame rate). Di mobile, VFR dari rekaman layar dan kamera HP sangat umum, dan pemetaan timestamp-ke-frame pada video VFR sering meleset. Ini perlu ditampilkan sebagai peringatan di UI, bukan disembunyikan.

### 4.4 `formats.py` → `lib/domain/formats.dart`

`scan_folder` dibuang — tidak ada padanannya di mobile.

`is_video_file` dipertahankan, tapi daftar ekstensinya menyusut (lihat §6).

### 4.5 `humanize.py` → `lib/core/format_utils.dart`

| Fungsi | Perilaku yang dipertahankan |
|---|---|
| `humanBytes` | Satuan `B, KB, MB, GB, TB`; satu desimal; pemisah desimal mengikuti bahasa (`1,5 MB` untuk id, `1.5 MB` untuk en) |
| `humanDuration` | id: `1 j 01 mnt`, `5 mnt 03 dtk`, `42 dtk`; en: `1 h 01 min`, `5 min 03 s`, `42 s` |
| `etaText` | id: `menghitung sisa waktu…`, `sisa 5 mnt 03 dtk`, `hampir selesai`; en: `calculating remaining time…`, `remaining 5 min 03 s`, `almost done` |

Perhatikan detail kecil yang mudah hilang saat porting: **`1.0` ditulis `1`, bukan `1.0`** (Python memakai `.rstrip("0").rstrip(".")`). Kalau ini terlewat, UI akan menampilkan "5.0 MB" alih-alih "5 MB".

---

## 5. Spesifikasi Perilaku yang Tidak Boleh Berubah

Bagian ini adalah "kontrak produk" yang harus tetap benar setelah pindah platform. Setiap baris bisa diverifikasi lewat tes di §7.

### 5.1 Mode pengambilan

| Mode | Definisi | Contoh |
|---|---|---|
| `interval` | Satu frame tiap N detik mulai dari `start`, hingga sebelum `end` | Video 60 dtk, interval 1 dtk → 60 frame, `0.0` sampai `59.0` |
| `count` | N frame tersebar **merata**, frame pertama di `start`, frame terakhir **sebelum** `end` | Video 60 dtk, 30 frame → jarak 2 dtk, terakhir `58.0` |
| `range` | Seperti `interval`, tapi `end` wajib diisi | Rentang 10–20 dtk, interval 2 dtk → `10,12,14,16,18` |

### 5.2 Batas dan klaim

| Aturan | Perilaku |
|---|---|
| `end` melebihi durasi | Di-*clamp* ke durasi, bukan galat |
| `start` melebihi durasi | Galat |
| Rentang tersisa ≤ 0 | Galat |
| Frame yang menyentuh `end` | Dibuang |
| Duplikat akibat pembulatan | Dibuang, urutan dipertahankan |

### 5.3 Pembatalan

| Aspek | Desktop (sekarang) | Mobile (target) |
|---|---|---|
| Cara | Hentikan subprocess | Batalkan `Future`, tutup `FrameExtractor` |
| Berkas yang sudah tersimpan | **Dipertahankan** | **Dipertahankan** — sama |
| Status antrean | Video tetap bertanda belum selesai | Sama |

Perilaku "frame yang sudah tersimpan tidak dihapus saat dibatalkan" adalah keputusan produk yang bagus dan harus dipertahankan. Di mobile ini bahkan lebih penting, karena pengguna lebih sering terpaksa berhenti (telepon masuk, baterai lemah, berpindah aplikasi).

### 5.4 Kelanjutan sesi

Fitur "video yang sudah selesai tidak diekstrak ulang" di versi desktop punya nilai berbeda di mobile: ia menjadi **pemulihan setelah terputus**. Sesi ekstraksi 300 frame di HP bisa terhenti di frame ke-180 ketika pengguna membuka WhatsApp. Tanpa mekanisme ini, pengguna harus mengulang dari nol.

**Rekomendasi:** simpan progres per video (`videoPath`, `savedCount`, `lastIndex`) di `shared_preferences`, sehingga setelah aplikasi dibuka kembali pengguna ditawari "Lanjutkan dari frame 181".

---

## 6. Dukungan Format: Angka yang Jujur

### 6.1 Perbandingan

| Ekstensi | Desktop | Android/iOS | Catatan |
|---|---|---|---|
| `.mp4` | ✅ | ✅ | Format utama kamera HP |
| `.m4v` | ✅ | ✅ | Varian MP4 |
| `.mov` | ✅ | ✅ | Format kamera iPhone |
| `.3gp` / `.3g2` | ✅ | ✅ | Perangkat lama |
| `.webm` | ✅ | ✅ | Unduhan media sosial |
| `.mkv` | ✅ | ⚠️ | Tergantung codec perangkat |
| `.ts` / `.m2ts` | ✅ | ⚠️ | Sebagian; sering gagal |
| `.avi` | ✅ | ❌ | Codec lama, umumnya tidak didukung |
| `.wmv` | ✅ | ❌ | Windows Media |
| `.flv` | ✅ | ❌ | Flash |
| `.mpg` / `.mpeg` | ✅ | ❌ | MPEG-1/2 |
| `.ogv` / `.ogg` | ✅ | ❌ | Umumnya tidak |
| `.asf` | ✅ | ❌ | Windows Media |
| `.vob` | ✅ | ❌ | DVD |
| `.f4v` | ✅ | ❌ | Flash MP4 |
| `.mxf` | ✅ | ❌ | Profesional |

**Ringkasnya: 21 ekstensi desktop → sekitar 8 di mobile, 6 di antaranya andal.**

### 6.2 Cara menyampaikannya ke pengguna

Jangan sembunyikan. Tiga langkah:

1. **Deskripsi Play Store** menuliskan format yang didukung secara eksplisit, bukan "berbagai format video".
2. **Saat berkas dipilih tapi gagal dibaca**, tampilkan pesan spesifik: *"Format ini belum didukung di versi mobile. Coba MP4, MOV, atau WebM."* — bukan "Terjadi kesalahan".
3. **Saat `.mkv` gagal**, sebutkan alasannya: *"Codec di dalam berkas ini tidak tersedia di perangkat Anda."* Ini berbeda dari format yang tidak didukung, dan pengguna berhak tahu bedanya.

### 6.3 Uji nyata yang wajib dilakukan

Dukungan format **tidak bisa** ditentukan dari dokumentasi. Ia bergantung pada codec yang dipasang vendor perangkat. Sebelum rilis:

| Uji | Perangkat |
|---|---|
| MP4 H.264 1080p | Minimal 3 merek berbeda |
| MP4 HEVC (H.265) | Perangkat kelas menengah dan atas |
| MOV dari iPhone | Perangkat iOS nyata |
| WebM VP9 | Android dan iOS |
| MKV | Catat mana yang berhasil, mana yang gagal |
| Video VFR (rekaman layar) | Android dan iOS |
| Video 4K 60fps | Uji memori — kandidat crash |

Hasil uji ini yang menjadi daftar format final di Play Store, bukan tabel di atas.

---

## 7. Port Tes, Bukan Port Kode

Ini inti strategi migrasi. Alih-alih menerjemahkan kode Python baris demi baris (rawan salah dan sulit diverifikasi), terjemahkan **tesnya**. Jika seluruh tes lulus di Dart, perilaku Sela terbukti sama dengan versi desktop — tanpa perlu membandingkan tampilan secara manual.

### 7.1 Pemetaan berkas uji

| Berkas pytest | Jumlah kasus | Port ke Dart? |
|---|---|---|
| `test_plan.py` | 15 | ✅ Ya — inti |
| `test_naming.py` | 17 | ✅ Ya — inti |
| `test_probe.py` | Bervariasi | ❌ Ganti total (API berbeda) |
| `test_extract.py` | Bervariasi | ❌ Ganti total (mesin berbeda) |
| `test_cli.py` | Bervariasi | ❌ Tidak ada CLI |
| `test_gui.py` | Bervariasi | ❌ Diganti widget test |
| `test_theme.py` | Bervariasi | ❌ Diganti golden test |

### 7.2 Tes perencanaan — `test/domain/sample_plan_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/domain/sample_plan.dart';

VideoInfo info(double duration) => VideoInfo(
      path: 'video.mp4',
      durationS: duration,
      fps: 30,
      width: 1920,
      height: 1080,
      frameCount: (duration * 30).toInt(),
      codec: 'h264',
    );

void main() {
  group('mode interval', () {
    test('1 detik pada video 60 detik menghasilkan 60 titik', () {
      final p = planPoints(info(60), const ExtractOptions(
        mode: CaptureMode.interval, intervalS: 1.0));
      expect(p.length, 60);
      expect(p.first, 0.0);
      expect(p.last, 59.0);
      expect(p, orderedEquals([...p]..sort()));
    });

    test('3 detik pada video 10 detik', () {
      final p = planPoints(info(10), const ExtractOptions(
        mode: CaptureMode.interval, intervalS: 3.0));
      expect(p, [0.0, 3.0, 6.0, 9.0]);
    });

    test('menghormati start dan end', () {
      final p = planPoints(info(60), const ExtractOptions(
        mode: CaptureMode.interval, intervalS: 1.0, startS: 10, endS: 20));
      expect(p.length, 10);
      expect(p.first, 10.0);
      expect(p.last, 19.0);
    });

    test('interval lebih kecil dari durasi frame', () {
      final p = planPoints(info(10), const ExtractOptions(
        mode: CaptureMode.interval, intervalS: 0.25));
      expect(p.length, 40);
      expect(p.last, closeTo(9.75, 1e-9));
    });
  });

  group('mode count', () {
    test('30 frame tersebar merata pada 60 detik', () {
      final p = planPoints(info(60), const ExtractOptions(
        mode: CaptureMode.count, frameTotal: 30));
      expect(p.length, 30);
      final gaps = [for (var i = 1; i < p.length; i++) p[i] - p[i - 1]];
      expect(gaps.reduce((a, b) => a > b ? a : b) -
             gaps.reduce((a, b) => a < b ? a : b), lessThan(1e-9));
      expect(p.first, 0.0);
      expect(p.last, lessThan(60.0));
      expect(p.last, closeTo(58.0, 1e-9));
    });

    test('satu frame', () {
      final p = planPoints(info(10), const ExtractOptions(
        mode: CaptureMode.count, frameTotal: 1));
      expect(p, [0.0]);
    });

    test('menghormati rentang', () {
      final p = planPoints(info(100), const ExtractOptions(
        mode: CaptureMode.count, frameTotal: 5, startS: 20, endS: 30));
      expect(p.length, 5);
      expect(p.first, 20.0);
      expect(p.last, closeTo(28.0, 1e-9));
    });
  });

  group('mode range', () {
    test('menghormati batas', () {
      final p = planPoints(info(60), const ExtractOptions(
        mode: CaptureMode.range, intervalS: 2.0, startS: 10, endS: 20));
      expect(p, [10.0, 12.0, 14.0, 16.0, 18.0]);
    });

    test('tanpa end memakai seluruh durasi', () {
      final p = planPoints(info(5), const ExtractOptions(
        mode: CaptureMode.range, intervalS: 1.0));
      expect(p, [0.0, 1.0, 2.0, 3.0, 4.0]);
    });

    test('end di-clamp ke durasi', () {
      final p = planPoints(info(10), const ExtractOptions(
        mode: CaptureMode.range, intervalS: 2.0, startS: 5, endS: 99));
      expect(p, [5.0, 7.0, 9.0]);
    });
  });

  group('galat', () {
    test('start di luar durasi', () {
      expect(() => planPoints(info(10), const ExtractOptions(
        mode: CaptureMode.interval, startS: 20)), throwsA(isA<PlanException>()));
    });

    test('durasi nol', () {
      expect(() => planPoints(info(0), const ExtractOptions(
        mode: CaptureMode.interval)), throwsA(isA<PlanException>()));
    });

    test('terlalu banyak frame', () {
      expect(() => planPoints(info(10000), const ExtractOptions(
        mode: CaptureMode.count, frameTotal: 250000)), throwsA(isA<PlanException>()));
    });
  });

  group('validasi opsi', () {
    test('nilai tidak sah ditolak', () {
      expect(() => ExtractOptions(mode: CaptureMode.interval, intervalS: 0),
          throwsA(isA<InvalidOptionException>()));
      expect(() => ExtractOptions(mode: CaptureMode.count, frameTotal: 0),
          throwsA(isA<InvalidOptionException>()));
      expect(() => ExtractOptions(mode: CaptureMode.interval, quality: 0),
          throwsA(isA<InvalidOptionException>()));
      expect(() => ExtractOptions(mode: CaptureMode.interval, startS: 5, endS: 5),
          throwsA(isA<InvalidOptionException>()));
    });
  });

  test('perkiraan PNG lebih besar dari JPG', () {
    final i = info(10);
    final png = estimateOutputBytes(i,
        const ExtractOptions(mode: CaptureMode.count), 10);
    final jpg = estimateOutputBytes(i,
        const ExtractOptions(mode: CaptureMode.count, fmt: OutputFormat.jpg, quality: 80), 10);
    expect(png, greaterThan(jpg));
    expect(jpg, greaterThan(0));
  });
}
```

### 7.3 Tes penamaan — `test/domain/frame_naming_test.dart`

```dart
void main() {
  const tpl = '{stem}_{index:06d}_{time}.{ext}';

  group('sanitizeStem', () {
    test('membuang karakter terlarang Windows', () {
      final r = sanitizeStem('liburan:2024*"<>|?');
      for (final c in [':', '*', '"', '<', '>', '|', '?']) {
        expect(r.contains(c), isFalse);
      }
    });

    test('memangkas titik dan spasi di ujung', () {
      expect(sanitizeStem('video...   '), 'video');
      expect(sanitizeStem('   '), 'video');
      expect(sanitizeStem('  nama  '), 'nama');
    });

    test('nama reserved diberi awalan garis bawah', () {
      for (final n in ['CON', 'con', 'PRN', 'NUL', 'COM1', 'lpt9']) {
        expect(sanitizeStem(n).toUpperCase().startsWith('_'), isTrue);
      }
    });

    test('mempertahankan unicode', () {
      expect(sanitizeStem('Liburan di Bali — 2024'), 'Liburan di Bali — 2024');
    });
  });

  test('sanitizeFilename memblokir pemisah path', () {
    final r = sanitizeFilename('../../etc/passwd.png');
    expect(r.contains('/'), isFalse);
    expect(r.contains(r'\'), isFalse);
  });

  group('formatTime', () {
    test('memetakan detik ke HH-MM-SS', () {
      expect(formatTime(0), '00-00-00');
      expect(formatTime(3), '00-00-03');
      expect(formatTime(123), '00-02-03');
      expect(formatTime(3661), '01-01-01');
      expect(formatTime(-5), '00-00-00');
    });
  });

  group('buildName', () {
    test('pola bawaan', () {
      expect(buildName(stem: 'liburan', index: 123, ts: 123, ext: 'png', template: tpl),
          'liburan_000123_00-02-03.png');
    });

    test('mulai dari 1 dengan enam digit', () {
      expect(buildName(stem: 'a', index: 1, ts: 0, ext: 'jpg', template: tpl),
          'a_000001_00-00-00.jpg');
    });

    test('membersihkan stem', () {
      expect(buildName(stem: 'a:b*c', index: 1, ts: 0, ext: 'png', template: tpl),
          'a_b_c_000001_00-00-00.png');
    });

    test('menolak template tanpa {ext}', () {
      expect(() => buildName(stem: 'a', index: 1, ts: 0, ext: 'png',
          template: '{stem}_{index:06d}'), throwsA(isA<InvalidOptionException>()));
    });

    test('menolak ekstensi tidak dikenal', () {
      expect(() => buildName(stem: 'a', index: 1, ts: 0, ext: 'gif', template: tpl),
          throwsA(isA<InvalidOptionException>()));
    });

    test('tidak mengizinkan path traversal', () {
      final r = buildName(stem: 'a', index: 1, ts: 0, ext: 'png',
          template: '../{stem}_{index:06d}.{ext}');
      expect(r.contains('/'), isFalse);
      expect(r.contains(r'\'), isFalse);
    });

    test('nama panjang dipotong di 180 karakter', () {
      final r = buildName(stem: 'x' * 400, index: 1, ts: 0, ext: 'png', template: tpl);
      expect(r.length, lessThanOrEqualTo(180));
      expect(r.endsWith('.png'), isTrue);
    });
  });

  group('validateTemplate', () {
    test('menolak pola buruk', () {
      for (final t in ['', '   ', '{stem}_{index:06d}_{unknown}.{ext}',
                       '{stem}_{time}.{ext}', '{stem}_{index:06d}',
                       '{stem}_{index:06d_{time}.{ext}']) {
        expect(() => validateTemplate(t), throwsA(isA<InvalidOptionException>()),
            reason: 'harus menolak: $t');
      }
    });
  });
}
```

### 7.4 Tes anti-tabrakan — khusus mobile

`unique_path` di desktop memakai filesystem. Di mobile, tulis tes terhadap **abstraksi**, bukan `File`:

```dart
abstract class NameRegistry {
  Future<bool> exists(String name);
}

class FakeRegistry implements NameRegistry {
  FakeRegistry(this.existing);
  final Set<String> existing;
  @override
  Future<bool> exists(String name) => Future.value(existing.contains(name));
}

test('menambahkan sufiks saat nama sudah dipakai', () async {
  final reg = FakeRegistry({'frame.png', 'frame-1.png'});
  expect(await uniqueName(reg, 'frame.png'), 'frame-2.png');
});

test('nama lama tidak pernah tertimpa', () async {
  final reg = FakeRegistry({'hasil_000001_00-00-00.png'});
  final chosen = await uniqueName(reg, 'hasil_000001_00-00-00.png');
  expect(chosen, isNot('hasil_000001_00-00-00.png'));
});

test('melempar galat saat percobaan habis', () async {
  final reg = _AlwaysExistsRegistry();
  expect(() => uniqueName(reg, 'a.png'), throwsA(isA<OutputNotWritableException>()));
});
```

Pemisahan ini sekaligus membuat logika bisa diuji tanpa Android — sesuatu yang tidak mungkin dilakukan dengan `Path.exists()` langsung.

### 7.5 Kriteria lulus

| Kriteria | Ambang |
|---|---|
| Tes perencanaan port | 15/15 lulus |
| Tes penamaan port | 17/17 lulus |
| Tes anti-tabrakan | 3/3 lulus |
| `flutter analyze` | 0 masalah |
| Cakupan baris `domain/` | ≥ 90% |

Selama kelima angka ini terpenuhi, Anda punya **bukti terukur** bahwa logika inti Sela setara versi desktop — bukan perkiraan.

---

## 8. Arsitektur Sela

### 8.1 Prinsip

1. **`domain/` tidak boleh mengimpor Flutter.** Kalau ia bisa diuji tanpa `flutter_test`, berarti ia benar-benar murni.
2. **`engine/` adalah satu-satunya tempat yang menyentuh platform.** Semua `MethodChannel` berada di sini.
3. **`features/` hanya berisi UI dan state.** Tidak ada logika bisnis.
4. **Tidak ada file lebih dari 200 baris.**

### 8.2 Struktur

```
lib/
├── main.dart                       # bootstrap, < 40 baris
├── app.dart                        # MaterialApp, router, tema
├── theme/
│   ├── sela_colors.dart
│   ├── sela_space.dart
│   ├── sela_text.dart
│   └── sela_theme.dart
├── domain/                         # murni, tanpa Flutter
│   ├── models.dart
│   ├── sample_plan.dart
│   ├── frame_naming.dart
│   ├── formats.dart
│   ├── name_registry.dart
│   └── exceptions.dart
├── engine/                         # satu-satunya jembatan platform
│   ├── frame_engine.dart           # antarmuka Dart
│   ├── frame_engine_channel.dart   # MethodChannel
│   └── gallery_writer.dart
├── features/
│   ├── import/
│   │   ├── import_screen.dart
│   │   ├── import_controller.dart
│   │   └── widgets/
│   ├── capture/
│   │   ├── capture_screen.dart
│   │   ├── capture_controller.dart
│   │   └── widgets/
│   │       ├── timeline_scrubber.dart
│   │       ├── frame_filmstrip.dart
│   │       └── interval_chips.dart
│   ├── progress/
│   ├── history/
│   └── settings/
├── core/
│   ├── format_utils.dart
│   └── logger.dart
└── l10n/
    ├── app_id.arb
    └── app_en.arb

android/app/src/main/kotlin/.../SelaEngine.kt
ios/Runner/SelaEngine.swift
```

### 8.3 Manajemen state

**Pilihan: Riverpod** (`flutter_riverpod` + `Notifier`/`AsyncNotifier`).

Alasan dibanding alternatif:

| Opsi | Alasan tidak dipilih |
|---|---|
| `setState` | Tidak ada sumber kebenaran tunggal; setelah 6 layar state tersebar dan sulit dilacak |
| `Provider` | Bekerja, tapi bergantung pada `BuildContext` sehingga sulit diuji |
| `Bloc` | Sangat terstruktur, tapi boilerplate-nya berat untuk aplikasi 3 layar |
| **Riverpod** | Bisa diuji tanpa widget, tidak butuh `BuildContext`, dan mudah dibaca AI karena polanya seragam |

Satu controller per fitur, satu file per controller. Tetapkan ini di `AGENTS.md` agar AI tidak mencampur `setState` dengan Riverpod.

---

## 9. Kontrak Engine

### 9.1 Antarmuka Dart

```dart
abstract class FrameEngine {
  Future<VideoInfo> probe(String path);

  /// [exact] = true  → frame persis (lambat)
  /// [exact] = false → keyframe terdekat (cepat)
  Future<Uint8List> frameAt(String path, int timestampMs, {required bool exact});

  Future<void> cancel();
}
```

### 9.2 Aturan yang wajib dipatuhi implementasi native

| Aturan | Alasan |
|---|---|
| Satu extractor/retriever per video, **bukan per frame** | Membuat ulang per frame membuat ekstraksi 10–20× lebih lambat |
| `exact: true` → `OPTION_CLOSEST` / toleransi `.zero` | Mode manual butuh presisi |
| `exact: false` → `OPTION_CLOSEST_SYNC` / toleransi bawaan | Mode interval butuh kecepatan |
| Selalu panggil `close()` / `release()` | Kebocoran native memori tidak terlihat sampai perangkat kehabisan RAM |
| Kembalikan **byte JPEG/PNG**, bukan `Bitmap`/`UIImage` | Menyeberangkan gambar mentah lewat channel mahal; byte jauh lebih murah |
| Encode gambar di sisi native | Menghindari transfer piksel mentah 8 MB per frame |
| Pembatalan harus benar-benar menghentikan decode | Kalau tidak, tombol "Batalkan" hanya menyembunyikan UI sementara proses tetap berjalan |

### 9.3 Android — `SelaEngine.kt`

```kotlin
class SelaEngine : AutoCloseable {
    private var extractor: FrameExtractor? = null
    private var retriever: MediaMetadataRetriever? = null

    fun probe(context: Context, path: String): Map<String, Any?> { /* AVAsset-like metadata */ }

    fun frameAt(
        context: Context,
        path: String,
        timestampMs: Long,
        exact: Boolean,
        quality: Int,
    ): ByteArray {
        // Utama: Media3 FrameExtractor (asinkron, disarankan)
        // Cadangan: MediaMetadataRetriever untuk perangkat lama
    }

    override fun close() { /* extractor?.close(); retriever?.release() */ }
}
```

Poin implementasi yang mudah salah:

| Hal | Perhatian |
|---|---|
| Media3 `FrameExtractor` | Mengembalikan `ListenableFuture` — jangan `get()` di main thread |
| `MediaMetadataRetriever.getFrameAtTime` | Parameter dalam **mikrodetik**, bukan milidetik |
| `Bitmap.compress` | `quality` 0–100, tapi hasilnya **tidak identik** dengan `-q:v` FFmpeg |
| Rotasi | Video dari kamera HP sering membawa metadata rotasi; Media3 `FrameExtractor` bisa menerapkannya saat ekstraksi — manfaatkan |
| Memori | `bitmap.recycle()` wajib setelah encode |

### 9.4 iOS — `SelaEngine.swift`

```swift
final class SelaEngine {
    private var generator: AVAssetImageGenerator?

    func frameAt(path: String, timestampMs: Int64, exact: Bool,
                 quality: CGFloat) throws -> Data {
        // exact  → requestedTimeToleranceBefore = .zero, After = .zero
        // cepat  → biarkan toleransi bawaan (keyframe terdekat)
    }
}
```

| Hal | Perhatian |
|---|---|
| API asinkron | Gunakan `generateCGImageAsynchronously` / `image(at:)`, bukan API sinkron lama |
| Orientasi | Set `appliesPreferredTrackTransform = true` |
| Encode | `UIImage.jpegData(compressionQuality:)` — 0.0–1.0, **bukan** 0–100 |
| Konversi kualitas | Bagi nilai 0–100 menjadi 0.0–1.0, dan sadari hasilnya tidak identik dengan Android |

**Ini poin lintas platform yang sering diabaikan:** kualitas 90 di Android dan kualitas 90 di iOS akan menghasilkan ukuran berkas berbeda. Kalau Anda ingin hasil seragam, uji dan kalibrasi — atau terima perbedaan kecil dan jangan menjanjikan ukuran berkas identik.

### 9.5 Penyimpanan ke galeri

| Platform | Mekanisme | Catatan |
|---|---|---|
| Android 10+ | `MediaStore.Images` dengan `RELATIVE_PATH = Pictures/Sela` | **Tidak butuh izin storage** untuk berkas milik sendiri |
| Android 9 ke bawah | `WRITE_EXTERNAL_STORAGE` | Perlu izin runtime |
| iOS | `PHPhotoLibrary` + `PHAssetCreationRequest` | Perlu izin *Add Photos Only* — minta yang paling minimal |

---

## 10. Perbedaan Perilaku Desktop vs Mobile

| Aspek | Desktop | Mobile | Tindakan |
|---|---|---|---|
| Sumber berkas | Path filesystem, `scan_folder` | Pemilih berkas sistem (SAF / PHPicker) | Buang pemindaian folder |
| Keluaran | Folder pilihan pengguna | Album `Pictures/Sela` | Tetapkan, jangan biarkan pengguna memilih path |
| Antrean batch | Banyak video sekaligus | **Satu video per sesi** | Keputusan produk; antrean di mobile menambah kerumitan besar |
| Mesin | ffmpeg subprocess | API platform | Diganti total |
| Format | 21 ekstensi | ±8 | Sampaikan jujur (§6) |
| Kualitas JPG | ffmpeg `-q:v` | `Bitmap.compress` / `jpegData` | Kalibrasi atau terima selisih |
| Pembatalan | Terminate process | Cancel Future + close | Sama dari sisi pengguna |
| Latar belakang | Jalan terus | Dibatasi OS | Foreground service untuk sesi panjang |
| Pengaturan | `QSettings` | `shared_preferences` | Port nama kunci agar mudah dibandingkan |
| Bahasa | Menu Tampilan | Setelan + RTL | Sudah dirancang (§9 desain) |

**Soal latar belakang** — ini yang paling sering dijanjikan berlebihan. Android akan membekukan proses saat aplikasi tidak terlihat, kecuali Anda menjalankan **foreground service** dengan notifikasi persisten. iOS lebih ketat lagi. Rekomendasi jujur:

- **Fase 1:** ekstraksi hanya berjalan saat aplikasi terbuka. Tampilkan pesan *"Jangan tutup aplikasi selama ekstraksi."*
- **Fase 2:** tambahkan foreground service Android setelah alur dasar stabil.

Jangan menuliskan "berjalan di latar belakang" di Play Store sebelum fase 2 selesai.

---

## 11. Roadmap dan Kriteria Selesai

| Tahap | Isi | Estimasi | Kriteria selesai |
|---|---|---|---|
| **0** | Repo `sela`, Flutter init, tema, `flutter analyze` bersih | 2 hari | Aplikasi kosong berjalan, 0 warning |
| **1** | `domain/` + seluruh tes port | 5 hari | 32/32 tes lulus, cakupan ≥ 90% |
| **2** | `engine/` Android: probe + frame tunggal | 5 hari | 1 frame tersimpan dari video nyata |
| **3** | Mode manual lengkap | 7 hari | Scrub, ±1 frame, simpan, penanda tersimpan |
| **4** | Mode interval lengkap | 5 hari | Tick timeline, preset, estimasi jumlah |
| **5** | Galeri + progres + pemulihan sesi | 5 hari | Simpan ke album, lanjut setelah terputus |
| **6** | Setelan + bahasa (id/en, RTL) | 4 hari | RTL tidak merusak layout |
| **7** | Uji perangkat + perbaikan | 7 hari | Matriks §6.3 lulus di 3 perangkat |
| **8** | Rilis Play Store | 2 hari | AAB terunggah, deskripsi jujur |

**Total: ±42 hari kerja** untuk Android. Dikerjakan paruh waktu, realistis 3–4 bulan.

**iOS** menyusul setelah ada pemasukan: satu berkas `SelaEngine.swift` + pengujian di Mac. Perkiraan 2–3 minggu, karena UI Flutter sudah siap.

### Urutan yang tidak boleh dibalik

```
domain + tes  →  engine  →  UI
```

Banyak orang mulai dari UI karena paling memuaskan secara visual. Hasilnya: aplikasi cantik yang tidak bisa menyimpan satu frame pun, dan tidak ada cara membuktikan logikanya benar.

---

## 12. `AGENTS.md` untuk Repo Sela

Salin berkas ini ke akar repo `sela`. AI coding agent akan membacanya sebelum menulis kode.

```markdown
# Aturan Proyek Sela

## Konteks
Aplikasi Android/iOS untuk mengekstrak frame diam dari video.
Turunan dari aplikasi desktop (Python/PySide6) yang sudah stabil — perilaku
logika HARUS identik. Spesifikasi ada di `docs/sela-migrasi.md`.

## Batas file — WAJIB
- Tidak ada file Dart lebih dari 200 baris.
- Satu file satu tanggung jawab.
- `main.dart` maksimal 40 baris.

## Lapisan — jangan dicampur
- `domain/`  : murni. DILARANG mengimpor `package:flutter/*`.
- `engine/`  : satu-satunya tempat yang memakai MethodChannel / kode native.
- `features/`: UI dan state saja. DILARANG berisi perhitungan bisnis.
- `theme/`   : semua warna, ukuran, radius. DILARANG angka ajaib di widget.

## State
Gunakan Riverpod. DILARANG memakai setState untuk state lintas layar.
Satu controller per fitur.

## Larangan
- Jangan menambah paket baru tanpa persetujuan.
- Jangan memakai FFmpeg atau plugin thumbnail pihak ketiga.
- Jangan hardcode teks yang dilihat pengguna — pakai ARB.
- Jangan memakai left/right. Selalu start/end.
- Jangan memanggil I/O atau decode video di dalam build().
- Jangan meninggalkan TODO atau kode mati.

## Mesin ekstraksi
- Android: Media3 FrameExtractor (utama), MediaMetadataRetriever (cadangan).
- iOS: AVAssetImageGenerator.
- exact=true  → OPTION_CLOSEST / toleransi .zero.
- exact=false → OPTION_CLOSEST_SYNC / toleransi bawaan.
- Satu instance per video, bukan per frame.
- Selalu tutup/release. Selalu recycle bitmap setelah encode.
- Kembalikan byte gambar, bukan objek gambar.

## Sebelum menyatakan selesai
1. `flutter analyze` → 0 masalah.
2. `dart format .`
3. `flutter test` → semua lulus.
4. Laporkan daftar file baru beserta jumlah barisnya.
```

---

## 13. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Media3 `FrameExtractor` belum tersedia di perangkat lama | Crash saat fitur dipanggil | Cek ketersediaan, jatuh ke `MediaMetadataRetriever` |
| Video VFR menghasilkan frame tidak sesuai timestamp | Pengguna mengira aplikasi salah | Deteksi VFR saat probe, tampilkan peringatan |
| Memori habis pada video 4K panjang | Crash | Proses satu frame, encode langsung, `recycle()` segera, batasi `MAX_FRAMES` |
| Ekstraksi terhenti saat pindah aplikasi | Pengguna kehilangan progres | Simpan progres per video, tawarkan lanjutkan |
| Dukungan format lebih sempit dari desktop | Ulasan negatif | Sampaikan eksplisit di deskripsi (§6.2) |
| Kualitas JPG beda antar platform | Laporan bug | Dokumentasikan, jangan janjikan ukuran identik |
| RTL merusak layout | Aplikasi terlihat rusak di pasar Arab | Uji dengan bahasa Arab sejak tahap 6, bukan setelah rilis |

---

## 14. Daftar Periksa Sebelum Menulis Kode

- [ ] Repo `sela` dibuat terpisah dari `frame-extractor`
- [ ] `docs/sela-migrasi.md` disalin ke repo baru
- [ ] `AGENTS.md` disalin ke akar repo
- [ ] `analysis_options.yaml` disetel ketat (`strict-casts`, `strict-raw-types`)
- [ ] Tema Sela dibuat dari token desain (warna, spasi, radius, tipografi)
- [ ] 32 tes domain ditulis **sebelum** UI disentuh
- [ ] `flutter test` lulus 32/32
- [ ] Baru setelah itu: satu tombol, satu video, satu frame tersimpan

---

## Lampiran A — Ringkasan Keputusan

| # | Keputusan | Dasar |
|---|---|---|
| 1 | Flutter, bukan Kotlin murni | Satu kode untuk dua platform; iOS tertunda tanpa menulis ulang |
| 2 | Tanpa FFmpeg | FFmpegKit dihentikan Jan 2025; API platform lebih ringan dan resmi |
| 3 | Tanpa `video_thumbnail` | Tidak dirawat 17 bulan; tidak bisa mengendalikan keyframe |
| 4 | Platform channel sendiri | ±250 baris native, tapi kendali penuh dan tidak bergantung pihak ketiga |
| 5 | Port tes, bukan kode | Satu-satunya cara terukur membuktikan perilaku setara |
| 6 | `domain/` bebas Flutter | Bisa diuji tanpa perangkat, dan AI tidak bisa mencampur logika ke UI |
| 7 | Riverpod | Dapat diuji tanpa `BuildContext`, pola seragam |
| 8 | Satu video per sesi | Antrean batch di mobile menambah kerumitan tanpa nilai sepadan |
| 9 | Ekstraksi hanya saat aplikasi terbuka (fase 1) | Menghindari janji latar belakang yang tidak bisa ditepati |
| 10 | Format ditulis jujur di Play Store | Mencegah ulasan negatif yang bisa dihindari |
