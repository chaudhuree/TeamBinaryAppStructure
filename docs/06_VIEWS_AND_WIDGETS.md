# 06 — Views & Widgets

## Views vs Widgets — What's the Difference?

| | Views (`lib/views/`) | Widgets (`lib/widgets/`) |
|---|---|---|
| **What** | Full-screen pages | Small, reusable UI pieces |
| **Size** | One per screen | Many per screen |
| **Controller** | Creates/owns the controller (`Get.put`) | Accesses existing controller (`Get.find`) |
| **Examples** | `SplashView`, `HomeView` | `CircleLoader`, `TodoList`, `AddTodoDialogue` |

---

## Views

### View 1: `SplashView`

**File:** `lib/views/splash_view.dart`

```dart
import 'package:binary_demo_app/controllers/splash_controller.dart';
import 'package:binary_demo_app/core/colors/app_colors.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());              // ← Register controller
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Spacer(),
                Text(
                  "App Demo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryThemeColor,  // ← Using core color
                  ),
                ),
                SizedBox(height: 16),
                Spacer(),
                CircleLoader(),                // ← Reusable widget
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Key Points

| Line | What's Happening |
|------|-----------------|
| `Get.put(SplashController())` | Creates the controller. This triggers `onInit()` → which calls `goNext()` → which waits 3s then navigates to Home. |
| `AppColors.primaryThemeColor` | Uses the centralized color constant instead of hard-coding. |
| `CircleLoader()` | Reusable loading spinner from `widgets/common/`. |
| `Spacer()` | Pushes the text to the center and the loader to the bottom. |

> **Speaker Note:** *"The Splash View is simple — it shows a title and a loader. The interesting part is that just by creating the controller (`Get.put`), the navigation timer starts automatically via `onInit()`."*

---

### View 2: `HomeView`

**File:** `lib/views/home_view.dart`

```dart
import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';
import 'package:binary_demo_app/widgets/home/add_todo_dialogue.dart';
import 'package:binary_demo_app/widgets/home/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.put(HomeController());  // ← Register

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Home"),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(() {                         // ← Reactive wrapper
            if (controller.isLoading.value) {
              return CircleLoader();              // ← Show loader
            }
            return TodoList();                    // ← Show list
          }),
        ),
      ),
      floatingActionButton: _buildAddTodoButton(),
    );
  }

  FloatingActionButton _buildAddTodoButton() {
    return FloatingActionButton(
      onPressed: () {
        final titleController = TextEditingController();
        final descController = TextEditingController();
        Get.dialog(
          AddTodoDialogue(
            titleController: titleController,
            descController: descController,
            controller: controller,
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
```

#### Key Points

| Concept | Explanation |
|---------|-------------|
| `Get.put(HomeController())` | Registers the controller as a class field. This is cleaner than putting it inside `build()` because it only creates once. |
| `Obx(() { ... })` | **The magic of GetX reactivity.** Everything inside `Obx` rebuilds automatically whenever any `.obs` variable used inside it changes. |
| `controller.isLoading.value` | Reading the reactive boolean. When it changes, `Obx` rebuilds. |
| `TodoList()` | A separate widget that displays the list (keeps `HomeView` clean). |
| `Get.dialog(...)` | Shows a dialog without needing `showDialog()` or `BuildContext`. |

> **Speaker Note:** *"`Obx` is like a security camera watching your reactive variables. The moment `isLoading` changes from `true` to `false`, `Obx` spots it and rebuilds the widget inside — swapping the loader for the todo list."*

---

## Widgets

### Widget 1: `CircleLoader` (Common)

**File:** `lib/widgets/common/circle_loader.dart`

```dart
import 'package:binary_demo_app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CircleLoader extends StatelessWidget {
  const CircleLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColors.primaryThemeColor);
  }
}
```

- Lives in `widgets/common/` because it's used on **multiple screens** (Splash + Home).
- Uses `AppColors.primaryThemeColor` so the color stays consistent with the theme.

---

### Widget 2: `TodoList` (Home-specific)

**File:** `lib/widgets/home/todo_list.dart`

```dart
import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();  // ← Find, not Put
    return ListView.builder(
      itemCount: controller.todoList.length,
      itemBuilder: (context, index) {
        TodoModel todo = controller.todoList[index];
        return ListTile(
          trailing: GestureDetector(
            onTap: () {
              controller.removeTodo(todo);
            },
            child: Icon(Icons.delete_forever, color: Colors.red),
          ),
          title: Text(todo.title),
          subtitle: Text(todo.description),
        );
      },
    );
  }
}
```

#### Key Points

- **`Get.find<HomeController>()`** — accesses the controller that `HomeView` already registered. Does NOT create a new one.
- **`ListView.builder`** — efficiently builds list items on demand (only visible items are rendered).
- **`controller.removeTodo(todo)`** — calls the controller method when the trash icon is tapped.

---

### Widget 3: `AddTodoDialogue` (Home-specific)

**File:** `lib/widgets/home/add_todo_dialogue.dart`

```dart
import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTodoDialogue extends StatelessWidget {
  const AddTodoDialogue({
    super.key,
    required this.titleController,
    required this.descController,
    required this.controller,
  });

  final TextEditingController titleController;
  final TextEditingController descController;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Todo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: descController,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            String title = titleController.text;
            String desc = descController.text;
            controller.addTodo(TodoModel(title: title, description: desc));
            Get.back();
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
```

#### Key Points

- Receives `TextEditingController`s and `HomeController` as **constructor parameters** (dependency injection).
- Creates a `TodoModel` from user input and passes it to `controller.addTodo()`.
- `Get.back()` closes the dialog.

---

## Widget Organization Rules

```
widgets/
├── common/        ← Used across multiple screens
│   └── circle_loader.dart
│   └── custom_button.dart        (example: a styled button)
│   └── empty_state.dart          (example: "No data" placeholder)
│
├── home/          ← Used only on the Home screen
│   ├── todo_list.dart
│   └── add_todo_dialogue.dart
│
├── profile/       ← Used only on the Profile screen (example)
│   └── profile_header.dart
│
└── settings/      ← Used only on the Settings screen (example)
    └── settings_tile.dart
```

**Rules:**
1. If a widget is used on **one screen only** → put it in that screen's sub-folder (e.g., `widgets/home/`).
2. If a widget is used on **multiple screens** → put it in `widgets/common/`.
3. Each widget is **one file, one class**.

---

## How to Create a New Reusable Widget

Example: a styled button used across the app.

### Step 1 — Create the File

Create `lib/widgets/common/primary_button.dart`:

```dart
import 'package:binary_demo_app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryThemeColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
```

### Step 2 — Use It Anywhere

```dart
PrimaryButton(
  label: "Save",
  onPressed: () {
    // do something
  },
),
```

> **Speaker Note:** *"Views build the full screen layout. Widgets are the bricks we use inside those layouts. Keeping them separate makes the code reusable and easy to maintain."*

---

**← Previous:** [05 — Controllers](05_CONTROLLERS.md) · **Next →** [07 — Adding New Features](07_ADDING_NEW_FEATURES.md)
