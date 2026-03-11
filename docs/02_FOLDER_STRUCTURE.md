# 02 — Folder Structure Explained

## The Full `lib/` Tree

```
lib/
│
├── main.dart                          ← Entry point of the app
│
├── app/
│   └── binary_demo_app.dart           ← Root widget (GetMaterialApp)
│
├── core/
│   ├── colors/
│   │   └── app_colors.dart            ← Centralized color constants
│   └── routes/
│       ├── routes_names.dart           ← Route name strings (e.g. "/home_view")
│       └── app_pages.dart              ← Route ↔ Page mapping
│
├── models/
│   └── todo_model.dart                ← Data model for a Todo item
│
├── controllers/
│   ├── splash_controller.dart          ← Splash screen logic (auto-navigate)
│   └── home_controller.dart            ← Todo CRUD logic & state
│
├── views/
│   ├── splash_view.dart                ← Splash screen UI
│   └── home_view.dart                  ← Home/Todo list screen UI
│
└── widgets/
    ├── common/
    │   └── circle_loader.dart          ← Reusable loading spinner
    └── home/
        ├── todo_list.dart              ← Displays the list of todos
        └── add_todo_dialogue.dart      ← Dialog for adding a new todo
```

---

## What Each Folder Does

### 📁 `app/`

> *Contains the root widget that wraps the entire application.*

- **`binary_demo_app.dart`** — Creates a `GetMaterialApp` (GetX's version of `MaterialApp`). It sets the initial route and registers all available pages/routes.

> **Speaker Note:** *"This is the starting point after `main.dart`. Every screen in our app is registered here through `getPages`."*

---

### 📁 `core/`

> *Holds project-wide constants and configurations — things that don't belong to any single feature.*

#### `core/colors/`
- **`app_colors.dart`** — Stores color constants so you never hard-code a color value in a widget. Example: `AppColors.primaryThemeColor` is `Colors.deepPurple`.

#### `core/routes/`
- **`routes_names.dart`** — A class with `static const String` fields for every route name. This prevents typos. Example: `RoutesNames.homeView` = `"/home_view"`.
- **`app_pages.dart`** — Maps each route name to its corresponding view widget using `GetPage`. This is where GetX knows *which screen to show for which route*.

> **Speaker Note:** *"Think of `core/` as the 'settings' folder. If you need a new color, a new route, a new font constant, or any shared value — it goes here."*

---

### 📁 `models/`

> *Contains plain Dart classes that represent your data.*

- **`todo_model.dart`** — A simple class with `title` and `description` fields. Models don't contain any UI or business logic — they are just *data containers*.

> **Speaker Note:** *"A model answers the question: **What does the data look like?** For a Todo, we need a title and a description."*

---

### 📁 `controllers/`

> *Contains GetX controllers — classes that hold business logic and reactive state.*

- **`splash_controller.dart`** — Waits 3 seconds and then navigates to the home screen. Uses `onInit()` lifecycle method to start automatically.
- **`home_controller.dart`** — Manages the list of todos. Handles loading, adding, and removing todos. Exposes `RxList<TodoModel>` and `RxBool isLoading` as reactive variables.

> **Speaker Note:** *"A controller answers the question: **What should happen?** — load data, navigate, add/remove items, call APIs, etc."*

---

### 📁 `views/`

> *Contains full-screen pages (each screen is one file).*

- **`splash_view.dart`** — The splash/loading screen. It creates a `SplashController` using `Get.put()` inside its `build()` method. Shows the app name and a circular loader.
- **`home_view.dart`** — The main screen. Creates a `HomeController` using `Get.put()`. Displays a loading spinner while data loads, then shows the todo list. Has a floating action button to add new todos.

> **Speaker Note:** *"A view answers the question: **What does the screen look like?** It reads data from its controller and shows widgets."*

---

### 📁 `widgets/`

> *Contains reusable UI components — pieces that are smaller than a full page.*

#### `widgets/common/`
- **`circle_loader.dart`** — A simple `CircularProgressIndicator` styled with the app's primary color. Reused on both the Splash and Home screens.

#### `widgets/home/`
- **`todo_list.dart`** — A `ListView.builder` that renders each todo from the controller's list. Uses `Get.find<HomeController>()` to access the already-registered controller.
- **`add_todo_dialogue.dart`** — An `AlertDialog` with text fields for title & description, plus Cancel/Add buttons. Calls `controller.addTodo()` when the user taps "Add".

> **Speaker Note:** *"Widgets are like LEGO blocks. We build small, reusable pieces and snap them together inside views. The `common/` sub-folder holds widgets used across many screens. The `home/` sub-folder holds widgets used only on the Home screen."*

---

## How the Folders Connect (Data Flow)

```
┌─────────┐     uses      ┌──────────────┐     reads/writes     ┌─────────┐
│  Model   │◄─────────────│  Controller  │─────────────────────►│  Model   │
│ (data)   │              │ (logic)      │                      │ (data)   │
└─────────┘              └──────┬───────┘                      └─────────┘
                                │
                        observed by
                                │
                         ┌──────▼───────┐
                         │    View      │
                         │  (screen)    │
                         └──────┬───────┘
                                │
                          uses  │
                                │
                         ┌──────▼───────┐
                         │   Widgets    │
                         │ (UI pieces)  │
                         └──────────────┘
```

1. **Model** defines the shape of your data.
2. **Controller** creates, stores, and modifies model instances.
3. **View** observes the controller (using `Obx`) and rebuilds when data changes.
4. **Widgets** are the building blocks used inside views.

---

## Suggested Folder Extensions

As your project grows, you can add more sub-folders inside `core/`:

```
core/
├── colors/              ← Already exists
├── routes/              ← Already exists
├── constants/           ← Static strings, numbers, enums
├── themes/              ← ThemeData, text styles
├── utils/               ← Helper functions, formatters
└── services/            ← API clients, socket managers (see chapters 08 & 09)
```

---

**← Previous:** [01 — Project Overview](01_PROJECT_OVERVIEW.md) · **Next →** [03 — Core & Routing](03_CORE_AND_ROUTING.md)
