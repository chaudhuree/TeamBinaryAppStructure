# 01 — Project Overview

## What Is This Template?

This is a **Flutter starter template** built with the **GetX** state-management package. It gives you a clean, pre-organized folder structure so you can jump straight into building features without worrying about how to lay out your project.

The template ships with a simple **Todo App** as a working demo — it shows how models, controllers, views, widgets, routing, and colors all fit together.

---

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter** (SDK ≥ 3.11) | Cross-platform UI framework |
| **Dart** | Programming language |
| **GetX** (`get: ^4.7.3`) | State management, routing, dependency injection |
| **Cupertino Icons** | iOS-style icon set |

> **Note:** GetX is an all-in-one package. It handles **state management**, **navigation/routing**, and **dependency injection** — so you don't need separate packages for each.

---

## How to Run the Project

### Prerequisites

- Flutter SDK installed ([install guide](https://docs.flutter.dev/get-started/install))
- An editor — VS Code (recommended) or Android Studio
- An emulator/simulator **or** a physical device connected

### Steps

```bash
# 1. Navigate into the project folder
cd "app template"

# 2. Fetch all dependencies
flutter pub get

# 3. Run the app
flutter run
```

When the app launches you will see:

1. **Splash Screen** — shows the app name + a loading spinner for 3 seconds.
2. **Home Screen** — loads a list of 3 sample todos. You can add new todos with the `+` button and delete them with the trash icon.

---

## Entry Point — `main.dart`

Every Flutter app starts from `main.dart`. Here is ours:

```dart
import 'package:binary_demo_app/app/binary_demo_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BinaryDemoApp());
}
```

**What happens here:**

1. `main()` is the very first function Dart runs.
2. `runApp()` tells Flutter which widget to show on the screen.
3. `BinaryDemoApp()` is our custom root widget (defined in `lib/app/binary_demo_app.dart`).

---

## Root Widget — `BinaryDemoApp`

```dart
class BinaryDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: RoutesNames.splashView,
      getPages: AppPages.pages,
    );
  }
}
```

**Key points:**

| Concept | Explanation |
|---------|-------------|
| `GetMaterialApp` | GetX's version of Flutter's `MaterialApp`. It enables GetX routing & dependency injection throughout the whole app. |
| `initialRoute` | The first screen the user sees. We set it to `"/"` which maps to `SplashView`. |
| `getPages` | The list of all available routes/pages in the app (defined in `AppPages`). |

> **Speaker Note:** *"Think of `GetMaterialApp` as the 'control center' of the app. It knows every screen that exists (via `getPages`) and which screen to show first (via `initialRoute`)."*

---

## Project Architecture at a Glance

```
lib/
├── main.dart              ← App starts here
├── app/                   ← Root widget (GetMaterialApp setup)
├── core/                  ← Shared constants (colors, routes)
├── models/                ← Data classes (e.g. TodoModel)
├── controllers/           ← Business logic (GetxControllers)
├── views/                 ← Screens (full pages)
└── widgets/               ← Reusable UI pieces
```

Each of these folders has a single responsibility. The next chapter will dive deep into every folder.

---

**Next →** [02 — Folder Structure Explained](02_FOLDER_STRUCTURE.md)
