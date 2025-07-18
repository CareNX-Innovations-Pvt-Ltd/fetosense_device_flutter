# Contributing to Fetosense Device Flutter

Welcome, and thank you for your interest in contributing to **fetosense_device_flutter**, the device-side interface of the Fetosense system built with Flutter. This guide will help you understand how to contribute effectively.

## 🧭 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [How You Can Contribute](#how-you-can-contribute)
  - [Bug Reports](#bug-reports)
  - [Feature Requests](#feature-requests)
  - [Code Contributions](#code-contributions)
- [Code Guidelines](#code-guidelines)
- [Commit Conventions](#commit-conventions)
- [Testing and Debugging](#testing-and-debugging)
- [Need Help?](#need-help)

---

## 📜 Code of Conduct

We follow a [Code of Conduct](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_device_flutter/blob/main/CODE_OF_CONDUCT.md) that ensures a respectful and inclusive environment. Be kind, patient, and constructive in all interactions.

---

## 📦 Project Overview

This Flutter project handles **device-side communication and UI** for fetal monitoring devices. It includes:

- Bluetooth/BLE integration
- Real-time data display
- Device registration and syncing
- Integration with other Fetosense services

---

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/<your-username>/fetosense_device_flutter.git
   cd fetosense_device_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Connect to a device** (if needed for debugging) and run:
   ```bash
   flutter run
   ```

4. **Run on emulator/browser** for UI changes:
   ```bash
   flutter run -d chrome
   ```

---

## How You Can Contribute

### 🐞 Bug Reports

Found a bug? Open an [issue](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_device_flutter/issues/new) with:

- Steps to reproduce
- Expected vs. actual results
- Logs/screenshots (if any)

### 💡 Feature Requests

Have a new idea? Submit it as a feature request. Please describe the use case and benefits clearly.

### 🔧 Code Contributions

1. Create a new branch:
   ```bash
   git checkout -b feature/my-change
   ```

2. Make your changes.

3. Run formatting and analysis:
   ```bash
   flutter format .
   flutter analyze
   ```

4. Add tests if needed, and run:
   ```bash
   flutter test
   ```

5. Commit using conventional format and push:
   ```bash
   git commit -m "feat: describe your feature"
   git push origin feature/my-change
   ```

6. Create a Pull Request on GitHub.

---

## 🧹 Code Guidelines

- Use `Bloc`/`Cubit` for state management
- Avoid business logic inside UI files
- Use clear naming: `*_view.dart`, `*_cubit.dart`, `*_service.dart`
- Maintain separation of concerns (Bluetooth logic, UI, API calls)

---

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <short description>
```

Examples:

- `feat(bluetooth): add auto-reconnect logic`
- `fix(view): resolve layout glitch in test screen`
- `refactor(device): split connection logic`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 🧪 Testing and Debugging

- Place tests under `test/` matching the source structure
- Use mocks for services (e.g. Bluetooth or Firebase)
- Run all tests before submitting:
  ```bash
  flutter test
  ```

---

## Need Help?

- Start a [discussion](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_device_flutter/discussions)
- Mention a maintainer in issues
- Refer to `README.md` for setup help

---

Thanks for helping improve Fetosense Device Flutter! 💙
