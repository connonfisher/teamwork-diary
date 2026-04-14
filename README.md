## Software Introduction

Moodiary is a cross-platform diary application with the following features:

- **Cross-platform support**: Compatible with Android, iOS, Windows, MacOS.
- **Material Design**: Intuitive and user-friendly interface following Material Design specifications.
- **Multiple editors**: Supports markdown, plain text, rich text and other forms of text editing.
- **Multimedia accessories**: You can add pictures, audio, video or even draw a picture to your diary.
- **Search and classification**: Easily manage your diary by full-text search and categorization.
- **Custom theme**: Supports light and dark modes, as well as a variety of color schemes (default Ultramarine).
- **Custom fonts**: Supports importing different fonts, and supports variable fonts.
- **Data security**: Keep your diary safe with a password, supports biometric unlocking.
- **Export and share**: Support all data import/export, as well as single diary sharing.
- **Backup and synchronization**: Support for LAN synchronization and WebDav backup.
- **Trail Map**: See your footprints on a map. Every step of your life is worth documenting.
- **Mood Palette**: 12-color mood palette, with preset moods for quick selection and AI-recommended moods.
- **AI Mood Detection**: Automatic mood detection when saving diaries (Volcengine Ark API).
- **Analysis &amp; Statistics**: Mood trend line chart, average mood for multiple diaries on the same day, AI mood analysis.
- **Intelligent assistant**: Supports access to Volcengine Ark large models, providing Q&amp;A, sentiment analysis and other functions.

## Installation and Configuration Guide

### Third Party SDK

Some capabilities need to apply for third-party SDKS, and the following service providers provide free versions, and the obtained keys are configured in the settings.

#### Weather service
- [QWeather](https://dev.qweather.com/docs/api/)

#### Map service
- [Tianditu](http://lbs.tianditu.gov.cn/server/MapService.html)

#### Intelligent assistant
- [Volcengine Ark](https://www.volcengine.com/product/ark) (supports Standard and Coding Plan)

### Direct Install

Use it by downloading the compiled installation package in Release, or manually compiling it if you don't have the platform you need.

### Manual Compilation

#### Environmental Requirements

- Flutter SDK (&gt;= 3.29.0 Stable) (It is recommended to use FVM to manage the Flutter version)
- Dart (&gt;= 3.7.0)
- Rust Toolchain (Nightly)
- Clang/LLVM
- Compatible IDE (e.g. Android Studio, Visual Studio Code)

#### Installation Procedure

1. **Get Source Code**:
   Extract the source code to a local directory.

2. **Install Dependencies**:
```bash
flutter pub get
```

3. **Run Application**:
```bash
flutter run
```

4. **Package Release**:
- Android: `flutter build apk`
- iOS: `flutter build ipa`
- Windows: `flutter build windows`
- MacOS: `flutter build macos`

&gt; Note: For security reasons, signatures are not included in the codebase. When you need to manually package, you need to modify the configuration file of the corresponding platform.
