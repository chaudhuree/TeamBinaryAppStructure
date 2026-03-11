# 04 — Models

## What Is a Model?

A **model** is a plain Dart class that describes the **shape of your data**. It answers the question: *"What fields does this piece of data have?"*

Models contain **no UI** and **no business logic**. They are pure data containers.

---

## Existing Model: `TodoModel`

**File:** `lib/models/todo_model.dart`

```dart
class TodoModel {
  String title;
  String description;

  TodoModel({required this.title, required this.description});
}
```

### Line-by-Line Breakdown

| Line | What It Does |
|------|-------------|
| `class TodoModel` | Declares a new class named `TodoModel`. |
| `String title;` | A required field for the todo's title. |
| `String description;` | A required field for the todo's description. |
| `TodoModel({required this.title, required this.description});` | A **named constructor**. When creating a `TodoModel`, you must provide both `title` and `description`. |

### How to Create an Instance

```dart
TodoModel myTodo = TodoModel(title: "Buy groceries", description: "Milk, eggs, bread");
```

### Where This Model Is Used

1. **`HomeController`** — stores a list of `TodoModel` objects: `RxList<TodoModel> todoList`.
2. **`TodoList` widget** — reads each `TodoModel` from the controller and displays its `title` and `description`.
3. **`AddTodoDialogue` widget** — creates a new `TodoModel` from user input and passes it to the controller.

---

## How to Create a New Model

Let's say you need a **User** model.

### Step 1 — Create the File

Create `lib/models/user_model.dart`:

```dart
class UserModel {
  String id;
  String name;
  String email;
  String? avatarUrl;  // nullable — not every user has a profile picture

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}
```

### Step 2 — Use It

```dart
UserModel user = UserModel(
  id: "1",
  name: "Ali",
  email: "ali@example.com",
);
```

---

## Model with JSON Serialization (For API Calls)

When you fetch data from an API, the response is JSON. You need methods to convert JSON → Model and Model → JSON.

```dart
class UserModel {
  String id;
  String name;
  String email;
  String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  // Convert JSON Map → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }

  // Convert UserModel → JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}
```

### Why `fromJson` and `toJson`?

| Method | When to Use |
|--------|-------------|
| `fromJson` | When you get data FROM the server (API response → Dart object) |
| `toJson` | When you send data TO the server (Dart object → API request body) |

### Example Usage

```dart
// API gives you this JSON:
Map<String, dynamic> jsonData = {
  "id": "1",
  "name": "Ali",
  "email": "ali@example.com",
  "avatar_url": null,
};

// Convert to model:
UserModel user = UserModel.fromJson(jsonData);

// Convert back to JSON (e.g., to send to an API):
Map<String, dynamic> json = user.toJson();
```

---

## Updated `TodoModel` with JSON Support

If you later need to connect `TodoModel` to an API, update it like this:

```dart
class TodoModel {
  String title;
  String description;

  TodoModel({required this.title, required this.description});

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
```

---

## Best Practices for Models

1. **One model per file.** Keep it clean.
2. **File naming:** `snake_case` matching the class → `user_model.dart` for `UserModel`.
3. **Always put models in `lib/models/`.** Don't scatter them.
4. **Add `fromJson` / `toJson`** if the model will interact with APIs.
5. **Use `required`** for fields that must always exist.
6. **Use nullable types (`?`)** for fields that might be missing.

> **Speaker Note:** *"Models are the simplest part of the project. They just say: this is what a Todo looks like — it has a title and a description. That's it. No logic, no UI."*

---

**← Previous:** [03 — Core & Routing](03_CORE_AND_ROUTING.md) · **Next →** [05 — Controllers](05_CONTROLLERS.md)
