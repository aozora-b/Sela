# Sela — High-Performance Video Frame Extractor

<p align="center">
  <b>Extract crystal-clear, exact video frames with sub-millisecond precision, zero lag, and memory stability.</b><br>
  <i>A modern, robust Flutter & Native Android video frame extraction utility.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-API%2029%20to%2036-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Kotlin-2.0+-7F52FF?logo=kotlin&logoColor=white" alt="Kotlin" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20Riverpod-blue" alt="Architecture" />
  <img src="https://img.shields.io/badge/Tests-91%20Passing-success" alt="Tests" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
</p>

---

## 🌟 Overview

**Sela** is a high-performance Android application built with **Flutter** and accelerated by a native **Kotlin MediaCodec / MediaMetadataRetriever** engine via Platform Channels. 

Engineered specifically for content creators, animators, video editors, and media analysts, Sela solves common mobile video extraction challenges: eliminating dropped frames, preventing out-of-memory crashes on 4K/60fps clips, and ensuring frame-to-timestamp synchronization down to the exact microsecond.

---

## ✨ Key Features

- 📸 **Sub-Millisecond Manual Stepping**: Scrub fluidly through high-resolution video with fine-grained step controls (`-1`, `+1`, `-10`, `+10` frames) and real-time synchronized timeline ticks.
- ⏱️ **Automated Interval Batch Extraction**: Extract hundreds or thousands of frames at designated intervals (0.25s, 0.5s, 1s, 2s, 5s) directly into organized folders.
- ⚡ **Zero-Lag Filmstrip (0 ms Instant Placeholders)**: Rapid scrubbing without blank flicker, powered by sparse keyframe warm-up, predictive background prefetching, and an adaptive 120-frame LRU cache.
- 🖼️ **Native Android Photo Picker**: Uses modern Android `MediaStore.ACTION_PICK_IMAGES` (API 33+) with fallback mechanisms. Operates cleanly without requiring broad or sensitive storage permissions (`READ_MEDIA_VIDEO`).
- 🌍 **Comprehensive 10-Language Localization**: Full native translations for English, Indonesian, Spanish, French, German, and Japanese, alongside full Right-to-Left (RTL) layout mirroring for Arabic, Persian, Hebrew, and Urdu.
- 💾 **Production MediaStore & SAF Export**: Supports lossless PNG and compressed JPEG output formats, automated subfolder grouping, and collision-resistant file naming.
- 🎨 **Warm Editorial Design**: Thoughtfully crafted dark and light modes, typography pairing (Playfair Display + Inter), subtle haptic feedback, and smooth spring animations.

---

## 🛠️ Architecture & Engineering Highlights

```
lib/
├── core/             # Cross-cutting utilities & name registries
├── domain/           # Pure Dart business models, time-to-frame math (Zero Flutter dependencies)
├── engine/           # Platform Channel abstractions & native video picker interfaces
├── features/         # Feature-first modular presentation & Riverpod controllers
│   ├── capture/      # Filmstrip, timeline scrubber, preview & thumbnail caching
│   ├── history/      # Resumable sessions & recent extractions repository
│   ├── home/         # Primary navigation shell & video import dropzone
│   ├── progress/     # Live extraction progress indicator & cancellation controller
│   ├── results/      # Frame review grid, multi-selection, batch sharing & deletion
│   └── settings/     # Output format, storage directories, theme & language pickers
├── l10n/             # ARB localization definitions (10 languages)
└── theme/            # Design tokens: SelaColors, SelaSpace, SelaText, SelaTheme
```

### 1. Dual Native Decoders & Request Coalescing
Preview timeline scrubbing and filmstrip thumbnail rendering operate on dedicated native executors (`previewExecutor` vs. `thumbExecutor`). Scrubbing invokes rapid sequence token cancellation, instantly aborting stale frame decode tasks so playback remains locked at 60 FPS.

### 2. Single Source of Truth for Frame ↔ Time
Container frame counts and durations are unified via `MediaExtractor` and `MediaMetadataRetriever`. The effective average frame rate (`avg_frame_rate = frameCount / durationS`) guarantees 1-to-1 parity between frame numbers and playback timestamps, eliminating black edge-frames.

### 3. Strict Memory Management
To guarantee stability on extended 4K sessions, Flutter's global `ImageCache` is capped at 24 MB (60 entries) and actively flushed on session exit. Every thumbnail decodes strictly through bounded `cacheWidth` constraints.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.24+ / v3.47+ recommended)
- [Android SDK](https://developer.android.com/studio) (API 29 to 36)
- Java 17+

### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/aozora-b/Sela.git
cd Sela

# 2. Install dependencies
flutter pub get

# 3. Run unit & widget test suite (91 tests)
flutter test

# 4. Launch on connected Android device or emulator
flutter run
```

### Production Build
```bash
# Build split-per-ABI release APKs (~19 MB per architecture):
flutter build apk --split-per-abi --release

# Build Google Play release App Bundle:
flutter build appbundle --release
```

---

## 🧪 Quality Assurance

- **Static Analysis**: `flutter analyze` $\rightarrow$ **0 issues found** (Clean).
- **Test Coverage**: 91 unit & widget tests passing (100% pass rate).
- **Standards**: Compliant with enterprise clean architecture, zero-noise self-documenting code, and modular file boundaries ($\le 200$ lines per file).

---

## 📄 License

Copyright © 2026 **aozora-b**. Licensed under the [MIT License](LICENSE).
