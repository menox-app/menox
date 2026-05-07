# MENOX - The Ultimate Social Meme Platform 🚀

<div align="center">
  <img src="assets/banner.png" alt="MENOX Banner" width="100%">
  <br />
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Riverpod](https://img.shields.io/badge/State-Riverpod-00BCD4?logo=dart&logoColor=white)](https://riverpod.dev)
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green.svg)](#)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
</div>

---

## 🌟 Overview
**MENOX** is a cutting-edge social media platform exclusively engineered for the meme ecosystem. It empowers users to discover, create, and engage with high-velocity viral content in a seamless, high-performance environment. Built with modern software architecture principles, MENOX delivers a premium user experience and robust scalability for the next generation of meme enthusiasts.

## ✨ Key Features
- **Dynamic Meme Feed**: Curated algorithmic feed showcasing the latest trends.
- **Micro-Interactions**: High-speed engagement with ultra-low latency likes and comments.
- **Personal Vault**: Securely store and categorize your favorite funny content.
- **Performance Optimized**: Silky smooth scrolling and optimized asset loading for a premium feel.

## 🛠 Tech Stack & Architecture

### Core Technologies
- **Framework**: [Flutter](https://flutter.dev) (v3.x) - Multi-platform excellence.
- **State Management**: [Riverpod](https://riverpod.dev) - Robust, testable, and type-safe.
- **Networking**: [Dio](https://pub.dev/packages/dio) & [Retrofit](https://pub.dev/packages/retrofit) - Type-safe REST API integration.
- **Server State**: Riverpod notifiers over the SDK API client for loading, caching, optimistic updates, and pagination.
- **Persistence**: [Hive](https://pub.dev/packages/hive) & [Shared Preferences](https://pub.dev/packages/shared_preferences) - High-performance local storage.
- **Environment Management**: [Envied](https://pub.dev/packages/envied) - Secure, obfuscated environment configuration.

### Architectural Principles
The project adheres to **Clean Architecture** patterns, ensuring a clear separation of concerns:
- **Presentation**: UI widgets and State Notifiers (Riverpod).
- **Domain**: Business logic, entities, and repository interfaces.
- **Data**: API implementations, local storage, and DTO parsing.

## 📁 Project Structure
```text
lib/
├── core/             # Cross-cutting concerns: Themes, Networking, DI, Config
│   ├── config/       # Environment & Flavor settings
│   └── network/      # API configurations
├── features/         # Domain-driven feature modules
│   ├── meme/         # Feature logic (Domain-Data-Presentation)
│   └── pokemon/      # Sample/Demo features
├── shared/           # Reusable UI components & Utility functions
└── main.dart         # Entry point selector
```

## 🚀 Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Dart SDK (bundled with Flutter)

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/memox.git
   cd memox
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Source Code**:
   This project leverages code generation for models, state management, and environments:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Environment Configuration
MENOX utilizes `Envied` for secure environment variable management. Create the following files in the project root:
- `.env.staging`: API keys and URLs for development.
- `.env.prod`: Sensitive production configuration.

Example `.env` format:
```text
APP_API_URL=https://api.menox.com
```

## 📱 Running the Application

The app uses **Flavors** to separate environments.

### Staging (Development)
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

### Production (Release)
```bash
flutter run --flavor production -t lib/main_production.dart
```

---

## 📦 Build & Release

| Platform | Flavor | Command |
| :--- | :--- | :--- |
| **Android** | Staging | `flutter build apk --flavor staging -t lib/main_staging.dart` |
| **Android** | Production | `flutter build apk --flavor production -t lib/main_production.dart` |
| **iOS** | Staging | `flutter build ios --flavor staging -t lib/main_staging.dart` |
| **iOS** | Production | `flutter build ios --flavor production -t lib/main_production.dart` |

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ by the MENOX Team © 2026*
