# kosan_euy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


#Structure Project Flutter
my_flutter_app/
├── android/              # Kode platform Android
├── ios/                  # Kode platform iOS
├── lib/                  # Kode sumber utama Flutter
│   ├── main.dart         # Entry point aplikasi
│   ├── screens/          # Halaman-halaman aplikasi
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/          # Widget yang bisa dipakai ulang
│   │   ├── custom_button.dart
│   │   └── loading_indicator.dart
│   ├── models/           # Model data dari API
│   │   ├── user.dart
│   │   └── product.dart
│   ├── services/         # Layanan API dan storage
│   │   ├── api_service.dart   # Semua panggilan API
│   │   └── storage_service.dart   # Simpan data lokal
│   └── utils/            # Fungsi pembantu
│       ├── constants.dart     # URL API, key, dll
│       └── helpers.dart       # Fungsi pembantu
├── assets/               # Gambar, fonts, dll
└── pubspec.yaml          # Dependency dan konfigurasi