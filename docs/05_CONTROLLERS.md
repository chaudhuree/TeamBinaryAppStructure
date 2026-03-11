# 05 — Controllers

## What Is a Controller?

A **controller** is a class that holds your **business logic** and **reactive state**. In GetX, controllers extend `GetxController`.

A controller answers the question: *"What should happen when the user does something?"* — load data, add an item, navigate, call an API, etc.

---

## Key GetX Concepts Used in Controllers

| Concept | Syntax | What It Does |
|---------|--------|-------------|
| **Reactive Variable** | `RxBool`, `RxString`, `RxList`, etc. | A variable that **automatically notifies** the UI when its value changes. |
| `.obs` | `false.obs`, `<TodoModel>[].obs` | Shortcut to create a reactive variable. |
| `.value` | `isLoading.value = true` | How you **read or write** a reactive variable's value. |
| `onInit()` | Override from `GetxController` | Runs **once** when the controller is first created. Great for loading initial data. |
| `onClose()` | Override from `GetxController` | Runs when the controller is destroyed. Good for cleanup (cancel timers, close streams). |

---

## Controller 1: `SplashController`

**File:** `lib/controllers/splash_controller.dart`

```dart
import 'package:binary_demo_app/core/routes/routes_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  Future<void> goNext() async {
    await Future.delayed(
      Duration(seconds: 3),
      () => Get.offAllNamed(RoutesNames.homeView),
    );
  }

  @override
  void onInit() {
    super.onInit();
    goNext();
  }
}
```

### Line-by-Line Breakdown

| Line | Explanation |
|------|-------------|
| `extends GetxController` | Makes this class a GetX controller with lifecycle hooks. |
| `goNext()` | An async method that waits 3 seconds, then navigates to the Home screen. |
| `Get.offAllNamed(RoutesNames.homeView)` | Navigate to Home **and remove Splash** from the navigation stack (user can't press back to return). |
| `onInit()` | Automatically called when the controller is first created. We call `goNext()` here so the navigation starts as soon as the Splash screen appears. |

### How It's Used in the View

In `splash_view.dart`:

```dart
Get.put(SplashController());  // Creates & registers the controller
```

`Get.put()` creates the controller **and** calls `onInit()` automatically.

---

## Controller 2: `HomeController`

**File:** `lib/controllers/home_controller.dart`

```dart
import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<TodoModel> todoList = <TodoModel>[].obs;

  final List<TodoModel> _initialTodoList = [
    TodoModel(title: "Todo 1", description: "Todo Description 1"),
    TodoModel(title: "Todo 2", description: "Todo Description 2"),
    TodoModel(title: "Todo 3", description: "Todo Description 3"),
  ];

  RxBool isLoading = false.obs;

  Future<void> initializeTodoList() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 3));
      todoList.addAll(_initialTodoList);
    } catch (e) {
      debugPrint("Load Todo Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 3));
      todoList.add(todo);
    } catch (e) {
      debugPrint("Add Todo Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeTodo(TodoModel todo) async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 3));
      todoList.remove(todo);
    } catch (e) {
      debugPrint("Remove Todo Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeTodoList();
  }
}
```

### Detailed Breakdown

#### Reactive Variables

```dart
RxList<TodoModel> todoList = <TodoModel>[].obs;  // reactive list
RxBool isLoading = false.obs;                     // reactive boolean
```

- `todoList.obs` — whenever an item is added or removed, any `Obx()` widget watching it rebuilds.
- `isLoading.obs` — when set to `true` or `false`, any `Obx()` watching it rebuilds.

#### The Loading Pattern

Every async method follows the same pattern:

```dart
Future<void> someMethod() async {
  isLoading.value = true;          // 1. Show loading
  try {
    await someAsyncWork();         // 2. Do the work
  } catch (e) {
    debugPrint("Error: $e");       // 3. Handle errors
  } finally {
    isLoading.value = false;       // 4. Hide loading (always runs)
  }
}
```

This is a great pattern to follow for all your controllers.

#### Methods

| Method | What It Does |
|--------|-------------|
| `initializeTodoList()` | Loads the initial 3 hard-coded todos (simulates a network delay with `Future.delayed`). |
| `addTodo(TodoModel todo)` | Adds a new todo to the list. |
| `removeTodo(TodoModel todo)` | Removes a todo from the list. |
| `onInit()` | Calls `initializeTodoList()` as soon as the controller is created. |

---

## How Controllers Are Connected to Views

### `Get.put()` — Register (Create) a Controller

```dart
// In the view:
final HomeController controller = Get.put(HomeController());
```

- Creates a new `HomeController` instance.
- Registers it in GetX's internal dependency container.
- Returns the instance so you can use it immediately.
- **Also calls `onInit()` automatically.**

### `Get.find()` — Access an Already-Registered Controller

```dart
// In a widget (e.g., TodoList):
final HomeController controller = Get.find<HomeController>();
```

- Does **not** create a new instance.
- Looks up the controller that was already registered via `Get.put()`.
- Throws an error if it hasn't been registered yet.

### When to Use Which?

| Scenario | Use |
|----------|-----|
| Creating the controller **for the first time** (usually in the View) | `Get.put()` |
| Accessing a controller that **already exists** (usually in child widgets) | `Get.find()` |

---

## How to Create a New Controller

Let's say you need a **ProfileController**:

### Step 1 — Create the File

Create `lib/controllers/profile_controller.dart`:

```dart
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxString userName = "".obs;
  RxBool isLoading = false.obs;

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 2));
      userName.value = "Ali Ahmed";
    } catch (e) {
      debugPrint("Load Profile Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
}
```

### Step 2 — Use It in a View

```dart
class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return CircleLoader();
          }
          return Text("Hello, ${controller.userName.value}");
        }),
      ),
    );
  }
}
```

---

## GetxController Lifecycle

```
Get.put(MyController())
       │
       ▼
   onInit()        ← Controller is created (load data, start listeners)
       │
       ▼
   onReady()       ← Called after the widget is rendered on screen (1 frame later)
       │
       ▼
  [Controller lives and manages state...]
       │
       ▼
   onClose()       ← Controller is destroyed (clean up resources)
```

| Lifecycle Method | When It Runs | Common Uses |
|-----------------|-------------|-------------|
| `onInit()` | Immediately when created | Fetch initial data, set defaults |
| `onReady()` | After first frame is rendered | Show a dialog, start animations |
| `onClose()` | When controller is disposed | Cancel timers, close streams |

---

## Common GetX Shortcuts in Controllers

```dart
// Show a snackbar
Get.snackbar("Title", "Message");

// Show a dialog
Get.dialog(AlertDialog(title: Text("Hello")));

// Show a bottom sheet
Get.bottomSheet(Container(child: Text("Bottom Sheet")));

// Navigate
Get.toNamed("/some_route");

// Go back
Get.back();

// Access arguments from previous screen
var args = Get.arguments;
```

> **Speaker Note:** *"Controllers are the brain of each screen. The view just displays what the controller tells it. If you want to change what happens when the user taps a button, you change the controller — not the view."*

---

**← Previous:** [04 — Models](04_MODELS.md) · **Next →** [06 — Views & Widgets](06_VIEWS_AND_WIDGETS.md)
