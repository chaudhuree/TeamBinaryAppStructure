# 11 — File-by-File Reference

A quick-reference guide to **every file** in the project. Use this while explaining the code or when you need to quickly remember what a file does.

---

## Root Files

### `pubspec.yaml`

| Field | Value | Purpose |
|-------|-------|---------|
| `name` | `binary_demo_app` | Package name — used in imports (`package:binary_demo_app/...`) |
| `sdk` | `^3.11.0` | Minimum Dart SDK version |
| `get` | `^4.7.3` | GetX — state management, routing, dependency injection |
| `cupertino_icons` | `^1.0.8` | iOS-style icon pack |

> **How to explain:** *"This is the project's configuration file. It tells Flutter the project name, which Dart version to use, and which packages to download. The most important package here is `get` — that's GetX."*

### `analysis_options.yaml`

- Contains lint rules that help catch common mistakes.
- You rarely edit this — it comes pre-configured.

> **How to explain:** *"This file sets code quality rules. Think of it as a spell-checker for your code."*

---

## `lib/main.dart`

```dart
import 'package:binary_demo_app/app/binary_demo_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BinaryDemoApp());
}
```

| What | Details |
|------|---------|
| **Purpose** | Entry point — the very first code that runs |
| **`main()`** | Dart's starting function |
| **`runApp()`** | Tells Flutter to start rendering `BinaryDemoApp` |

> **How to explain:** *"Every Flutter app starts from `main.dart`. It's just 3 lines: import the app, define `main()`, and call `runApp()`. That's it."*

---

## `lib/app/binary_demo_app.dart`

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

| What | Details |
|------|---------|
| **Purpose** | Root widget that wraps the entire app |
| **`GetMaterialApp`** | GetX replacement for `MaterialApp` — enables GetX routing & DI |
| **`initialRoute`** | First screen to show (`"/"` = Splash) |
| **`getPages`** | List of all available routes |

> **How to explain:** *"This is the main wrapper. `GetMaterialApp` is special — it hooks GetX into Flutter so we can use `Get.toNamed()`, `Get.put()`, `Obx()` everywhere. It knows all our screens via `getPages` and shows the splash first via `initialRoute`."*

---

## `lib/core/colors/app_colors.dart`

```dart
class AppColors {
  static Color primaryThemeColor = Colors.deepPurple;
}
```

| What | Details |
|------|---------|
| **Purpose** | Centralized color constants |
| **Pattern** | Static class — no instance needed, call `AppColors.primaryThemeColor` directly |
| **Used by** | `SplashView` (title color), `CircleLoader` (spinner color) |

> **How to explain:** *"All colors live here. If the brand color changes, you update one line and the whole app updates. Never hard-code `Colors.deepPurple` in a widget — always use `AppColors`."*

---

## `lib/core/routes/routes_names.dart`

```dart
class RoutesNames {
  static const String splashView = "/";
  static const String homeView   = "/home_view";
}
```

| What | Details |
|------|---------|
| **Purpose** | String constants for every route name |
| **`"/"`** | Root route → Splash Screen |
| **`"/home_view"`** | Home Screen |

> **How to explain:** *"Every screen gets a name — like a URL. We store them as constants so we never make typos. To add a new screen, you add a new line here."*

---

## `lib/core/routes/app_pages.dart`

```dart
class AppPages {
  static List<GetPage> pages = [
    GetPage(name: RoutesNames.splashView, page: () => SplashView()),
    GetPage(name: RoutesNames.homeView,   page: () => HomeView()),
  ];
}
```

| What | Details |
|------|---------|
| **Purpose** | Maps route names → actual page widgets |
| **`GetPage`** | A GetX class that links a name to a widget |
| **Used by** | `GetMaterialApp` in `binary_demo_app.dart` |

> **How to explain:** *"This is the routing table — the phone book. When GetX sees a navigation request for `/home_view`, it looks here and says 'Ah, that means show `HomeView()`'. To add a new screen, add a new `GetPage` entry."*

---

## `lib/models/todo_model.dart`

```dart
class TodoModel {
  String title;
  String description;

  TodoModel({required this.title, required this.description});
}
```

| What | Details |
|------|---------|
| **Purpose** | Data class for a Todo item |
| **Fields** | `title` (String), `description` (String) |
| **Constructor** | Named parameters, both required |
| **Used by** | `HomeController`, `TodoList`, `AddTodoDialogue` |

> **How to explain:** *"This is the simplest file in the project. A Todo has a title and a description. That's the data shape. No logic, no UI — just data."*

---

## `lib/controllers/splash_controller.dart`

```dart
class SplashController extends GetxController {
  Future<void> goNext() async {
    await Future.delayed(Duration(seconds: 3),
      () => Get.offAllNamed(RoutesNames.homeView));
  }

  @override
  void onInit() {
    super.onInit();
    goNext();
  }
}
```

| What | Details |
|------|---------|
| **Purpose** | Handles splash screen logic — auto-navigate after 3 seconds |
| **`goNext()`** | Waits 3s, then navigates to Home and clears the back stack |
| **`onInit()`** | Called automatically when controller is created → starts the timer |
| **Used by** | `SplashView` via `Get.put(SplashController())` |

> **How to explain:** *"The splash controller has one job: wait 3 seconds and go to the home screen. `onInit()` kicks it off automatically. `offAllNamed` means 'go to home and delete the splash from history so the user can't go back'."*

---

## `lib/controllers/home_controller.dart`

```dart
class HomeController extends GetxController {
  RxList<TodoModel> todoList = <TodoModel>[].obs;
  RxBool isLoading = false.obs;
  // ... initializeTodoList(), addTodo(), removeTodo(), onInit()
}
```

| What | Details |
|------|---------|
| **Purpose** | Manages the todo list and loading state |
| **Reactive vars** | `todoList` (RxList), `isLoading` (RxBool) |
| **Methods** | `initializeTodoList()`, `addTodo()`, `removeTodo()` |
| **Lifecycle** | `onInit()` → calls `initializeTodoList()` |
| **Used by** | `HomeView` (via `Get.put`), `TodoList` & `AddTodoDialogue` (via `Get.find`) |

> **How to explain:** *"This is the brain of the home screen. It holds the list of todos and an `isLoading` flag. Both are reactive (`.obs`) — so when they change, the UI updates automatically. It has three methods: load the initial data, add a todo, and remove a todo. Each method sets loading to true, does the work, then sets loading to false."*

---

## `lib/views/splash_view.dart`

```dart
class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(/* ... app name text + CircleLoader ... */);
  }
}
```

| What | Details |
|------|---------|
| **Purpose** | Splash/loading screen UI |
| **Layout** | Centered app title + bottom loading spinner |
| **Controller** | Registers `SplashController` via `Get.put()` inside `build()` |
| **Widgets used** | `CircleLoader` (from `widgets/common/`) |
| **Colors used** | `AppColors.primaryThemeColor` (from `core/colors/`) |

> **How to explain:** *"The splash view is what the user sees first — the app name and a spinner. The key line is `Get.put(SplashController())` — the moment this runs, the controller's `onInit()` fires and the 3-second navigation timer starts."*

---

## `lib/views/home_view.dart`

```dart
class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) return CircleLoader();
        return TodoList();
      }),
      floatingActionButton: /* ... opens AddTodoDialogue ... */,
    );
  }
}
```

| What | Details |
|------|---------|
| **Purpose** | Main screen — displays todo list |
| **Controller** | Registers `HomeController` as a class field |
| **Reactivity** | `Obx()` watches `isLoading` — shows loader or list |
| **FAB** | Opens `AddTodoDialogue` via `Get.dialog()` |
| **Widgets used** | `CircleLoader`, `TodoList`, `AddTodoDialogue` |

> **How to explain:** *"The home view has three states: loading (show spinner), loaded (show list), and the floating button (show add dialog). `Obx` is the bridge between controller and view — it watches reactive variables and rebuilds when they change."*

---

## `lib/widgets/common/circle_loader.dart`

```dart
class CircleLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColors.primaryThemeColor);
  }
}
```

| What | Details |
|------|---------|
| **Purpose** | Reusable loading spinner |
| **Location** | `widgets/common/` — used on multiple screens |
| **Color** | Uses `AppColors.primaryThemeColor` for consistency |

> **How to explain:** *"A tiny, reusable widget. Instead of writing `CircularProgressIndicator(color: ...)` in every screen, we wrap it once in `CircleLoader` and just use `CircleLoader()` everywhere."*

---

## `lib/widgets/home/todo_list.dart`

```dart
class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return ListView.builder(
      itemCount: controller.todoList.length,
      itemBuilder: (context, index) {
        TodoModel todo = controller.todoList[index];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text(todo.description),
          trailing: GestureDetector(
            onTap: () => controller.removeTodo(todo),
            child: Icon(Icons.delete_forever, color: Colors.red),
          ),
        );
      },
    );
  }
}
```

| What | Details |
|------|---------|
| **Purpose** | Renders the list of todos |
| **Controller access** | `Get.find<HomeController>()` — finds the already-registered instance |
| **Delete** | Trash icon calls `controller.removeTodo(todo)` |

> **How to explain:** *"This widget displays the todos. It uses `Get.find` (not `Get.put`) because the controller was already created by `HomeView`. Each list item shows the title, description, and a red delete icon."*

---

## `lib/widgets/home/add_todo_dialogue.dart`

```dart
class AddTodoDialogue extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final HomeController controller;
  // ...
  // onPressed → controller.addTodo(TodoModel(...));  Get.back();
}
```

| What | Details |
|------|---------|
| **Purpose** | Dialog to add a new todo |
| **Inputs** | Two text fields (title + description) |
| **Action** | "Add" button creates a `TodoModel` and calls `controller.addTodo()` |
| **Close** | `Get.back()` dismisses the dialog |

> **How to explain:** *"This dialog pops up when you tap the + button. It has two text fields. When you hit 'Add', it takes the text, creates a TodoModel, and passes it to the controller. The controller handles the rest. Then `Get.back()` closes the dialog."*

---

## Platform Folders (Non-Dart)

| Folder | Purpose |
|--------|---------|
| `android/` | Android build configuration (Gradle files, AndroidManifest) |
| `ios/` | iOS build configuration (Xcode project, Info.plist) |
| `web/` | Web build configuration (index.html, manifest.json) |
| `windows/` | Windows desktop build configuration (CMake) |
| `linux/` | Linux desktop build configuration (CMake) |
| `macos/` | macOS desktop build configuration (Xcode project) |
| `test/` | Unit and widget tests |

> **How to explain:** *"You rarely touch these folders. Flutter generates them. The only time you edit them is for platform-specific settings like app name, permissions, or app icon."*

---

## Quick Lookup Table

| File | Role | One-Line Summary |
|------|------|-----------------|
| `main.dart` | Entry | Runs `BinaryDemoApp` |
| `binary_demo_app.dart` | App Root | `GetMaterialApp` with initial route + pages |
| `app_colors.dart` | Constants | Color palette |
| `routes_names.dart` | Constants | Route name strings |
| `app_pages.dart` | Routing | Route → Page mapping |
| `todo_model.dart` | Model | Todo data shape |
| `splash_controller.dart` | Controller | 3-second delay → navigate to home |
| `home_controller.dart` | Controller | Todo CRUD + loading state |
| `splash_view.dart` | View | App name + spinner |
| `home_view.dart` | View | Todo list + add button |
| `circle_loader.dart` | Widget | Styled `CircularProgressIndicator` |
| `todo_list.dart` | Widget | `ListView` of todos |
| `add_todo_dialogue.dart` | Widget | Dialog with text fields to add a todo |

---

**← Previous:** [10 — Full Example Walkthrough](10_FULL_EXAMPLE_WALKTHROUGH.md) · **Back to Start →** [00 — Table of Contents](00_TABLE_OF_CONTENTS.md)
