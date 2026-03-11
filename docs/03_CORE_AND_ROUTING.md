# 03 — Core: Colors & Routing

The `core/` folder is the backbone of shared configuration. In this template it has two sub-folders: **colors** and **routes**. This chapter explains both in detail.

---

## 1. Colors — `core/colors/app_colors.dart`

### The File

```dart
import 'package:flutter/material.dart';

class AppColors {
  static Color primaryThemeColor = Colors.deepPurple;
}
```

### How It Works

- `AppColors` is a simple class with **static** fields. You don't need to create an instance — just call `AppColors.primaryThemeColor` anywhere.
- Every time you need a color in a widget, **import and use this class** instead of writing `Colors.deepPurple` directly.

### Why This Matters

If your client says *"change the brand color from purple to blue"*, you update **one line** in this file and the entire app changes automatically.

### How to Add More Colors

```dart
class AppColors {
  static Color primaryThemeColor = Colors.deepPurple;
  
  // Add more colors below:
  static Color secondaryColor    = Color(0xFF03DAC6);
  static Color backgroundColor   = Color(0xFFF5F5F5);
  static Color errorColor         = Colors.redAccent;
  static Color textPrimary        = Color(0xFF212121);
  static Color textSecondary      = Color(0xFF757575);
}
```

> **Speaker Note:** *"This is our color palette. One file, one place. If you see a hard-coded color anywhere else in the project, it should be moved here."*

---

## 2. Routing — How GetX Navigation Works

GetX routing requires two files working together:

| File | Purpose |
|------|---------|
| `routes_names.dart` | Holds the **name** (URL-like string) for each screen |
| `app_pages.dart` | Maps each name to its **page widget** |

### 2a. Route Names — `core/routes/routes_names.dart`

```dart
class RoutesNames {
  static const String splashView = "/";
  static const String homeView   = "/home_view";
}
```

**What's happening:**
- Each screen gets a unique string name — like a URL.
- `"/"` is the root/initial route (Splash Screen).
- `"/home_view"` is the Home Screen.

**Why use constants?** If you write `"/home_view"` in 10 places and make a typo in one, you'll get a runtime error that's hard to find. Using `RoutesNames.homeView` gives you compile-time safety.

### 2b. App Pages — `core/routes/app_pages.dart`

```dart
import 'package:binary_demo_app/core/routes/routes_names.dart';
import 'package:binary_demo_app/views/home_view.dart';
import 'package:binary_demo_app/views/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  static List<GetPage> pages = [
    GetPage(
      name: RoutesNames.splashView,
      page: () => SplashView(),
    ),
    GetPage(
      name: RoutesNames.homeView,
      page: () => HomeView(),
    ),
  ];
}
```

**What's happening:**
- `AppPages.pages` is a list of `GetPage` objects.
- Each `GetPage` links a **route name** to a **widget**.
- `name: RoutesNames.splashView` → when this route is requested, show `SplashView()`.

### 2c. How They Connect to `GetMaterialApp`

In `lib/app/binary_demo_app.dart`:

```dart
GetMaterialApp(
  initialRoute: RoutesNames.splashView,   // ← start here ("/")
  getPages: AppPages.pages,               // ← all available routes
);
```

When the app starts:
1. GetX looks at `initialRoute` → it's `"/"`.
2. GetX searches `AppPages.pages` for a `GetPage` with `name: "/"`.
3. It finds `SplashView()` → shows the Splash Screen.

---

## 3. How Navigation Happens at Runtime

### Navigating Forward

```dart
// Push a new screen on top of the current one
Get.toNamed(RoutesNames.homeView);
```

### Navigating & Removing Previous Screens

```dart
// Go to home and remove ALL previous screens from history
Get.offAllNamed(RoutesNames.homeView);
```

This is what `SplashController` does — after 3 seconds it navigates to home and clears the splash from the back stack so the user can't go back to it.

### Going Back

```dart
// Pop the current screen
Get.back();
```

### Passing Data Between Screens

```dart
// Sending data
Get.toNamed(RoutesNames.homeView, arguments: {"id": 42});

// Receiving data in the next screen/controller
var data = Get.arguments;  // {"id": 42}
```

---

## 4. Adding a New Route (Step-by-Step)

Let's say you want to add a **Profile** screen:

### Step 1 — Add the route name

```dart
// routes_names.dart
class RoutesNames {
  static const String splashView   = "/";
  static const String homeView     = "/home_view";
  static const String profileView  = "/profile_view";   // ← NEW
}
```

### Step 2 — Create the view file

Create `lib/views/profile_view.dart`:

```dart
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(child: Text("Profile Screen")),
    );
  }
}
```

### Step 3 — Register the page

```dart
// app_pages.dart
static List<GetPage> pages = [
  GetPage(name: RoutesNames.splashView, page: () => SplashView()),
  GetPage(name: RoutesNames.homeView,   page: () => HomeView()),
  GetPage(name: RoutesNames.profileView, page: () => ProfileView()),  // ← NEW
];
```

### Step 4 — Navigate to it

From anywhere in the app:

```dart
Get.toNamed(RoutesNames.profileView);
```

---

## 5. The Complete Flow Diagram

```
main.dart
   │
   ▼
BinaryDemoApp  (GetMaterialApp)
   │
   ├── initialRoute: "/"  ──────► RoutesNames.splashView
   │
   └── getPages: AppPages.pages
              │
              ├── "/" ──────────────► SplashView
              └── "/home_view" ─────► HomeView
```

> **Speaker Note:** *"Routing is like a phone book. `RoutesNames` gives each screen a contact name. `AppPages` is the phone book that says 'when someone asks for this name, show this screen'. And `GetMaterialApp` is the operator that looks things up."*

---

**← Previous:** [02 — Folder Structure](02_FOLDER_STRUCTURE.md) · **Next →** [04 — Models](04_MODELS.md)
