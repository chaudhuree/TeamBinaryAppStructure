# 10 — Full Example Walkthrough: Build a "Notes" Feature

This chapter is a **hands-on exercise**. Follow along step-by-step to add a complete **Notes** feature to the template. By the end, you'll have a working Notes screen with Create, Read, and Delete functionality.

---

## What We're Building

A screen that:
- Displays a list of notes (title + content).
- Has a button to add a new note.
- Lets you delete notes.
- Fetches notes from a free public API.

We'll use the **JSONPlaceholder** API (`https://jsonplaceholder.typicode.com/posts`) as our data source.

---

## Step 1: Add the `http` Package

Open `pubspec.yaml` and add `http` under dependencies (if not already added):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.7.3
  http: ^1.2.1          # ← Make sure this is here
```

Run:

```bash
flutter pub get
```

---

## Step 2: Create the API Service (If Not Already Created)

If you haven't already created this from Chapter 08, create `lib/core/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com";

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("GET failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("GET error: $e");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("POST failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("POST error: $e");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("DELETE failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("DELETE error: $e");
    }
  }
}
```

---

## Step 3: Create the Note Model

Create `lib/models/note_model.dart`:

```dart
class NoteModel {
  int id;
  String title;
  String content;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
  });

  // Convert JSON → NoteModel
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['body'],   // JSONPlaceholder uses "body" for content
    );
  }

  // Convert NoteModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': content,
    };
  }
}
```

> **Explanation note:** The JSON from `jsonplaceholder.typicode.com/posts` has fields `id`, `title`, and `body`. We're mapping `body` → `content` for a nicer Dart API.

---

## Step 4: Create the Note Controller

Create `lib/controllers/note_controller.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_demo_app/core/services/api_service.dart';
import 'package:binary_demo_app/models/note_model.dart';

class NoteController extends GetxController {
  RxList<NoteModel> notes = <NoteModel>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  // ──────── FETCH NOTES FROM API ────────
  Future<void> fetchNotes() async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      // Fetch only first 10 posts from JSONPlaceholder
      final List<dynamic> jsonList = await ApiService.get("/posts");
      final firstTen = jsonList.take(10).toList();
      notes.value = firstTen.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = "Failed to load notes. Please try again.";
      debugPrint("Fetch Notes Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ──────── ADD A NOTE ────────
  Future<void> addNote(String title, String content) async {
    if (title.isEmpty || content.isEmpty) {
      Get.snackbar("Error", "Title and content are required");
      return;
    }

    isLoading.value = true;
    try {
      final json = await ApiService.post("/posts", {
        "title": title,
        "body": content,
        "userId": 1,
      });

      notes.insert(0, NoteModel.fromJson(json));  // Add to top of list
      Get.snackbar("Success", "Note added!");
    } catch (e) {
      debugPrint("Add Note Error: $e");
      Get.snackbar("Error", "Failed to add note");
    } finally {
      isLoading.value = false;
    }
  }

  // ──────── DELETE A NOTE ────────
  void deleteNote(NoteModel note) {
    notes.remove(note);
    Get.snackbar("Deleted", "'${note.title}' removed");
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }
}
```

---

## Step 5: Create the Widgets

### 5a: Note Card Widget

Create `lib/widgets/notes/note_card.dart`:

```dart
import 'package:binary_demo_app/models/note_model.dart';
import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Content preview
            Text(
              note.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5b: Add Note Dialog Widget

Create `lib/widgets/notes/add_note_dialogue.dart`:

```dart
import 'package:binary_demo_app/controllers/note_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNoteDialogue extends StatelessWidget {
  final NoteController controller;

  AddNoteDialogue({super.key, required this.controller});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Note"),
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
            controller: contentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Content",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
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
            controller.addNote(
              titleController.text,
              contentController.text,
            );
            Get.back();
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
```

---

## Step 6: Create the Note View

Create `lib/views/note_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_demo_app/controllers/note_controller.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';
import 'package:binary_demo_app/widgets/notes/note_card.dart';
import 'package:binary_demo_app/widgets/notes/add_note_dialogue.dart';

class NoteView extends StatelessWidget {
  NoteView({super.key});

  final NoteController controller = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Notes"),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return Center(child: CircleLoader());
          }

          // Error state
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(controller.errorMessage.value),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchNotes(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (controller.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No notes yet. Tap + to add one!"),
                ],
              ),
            );
          }

          // Notes list
          return ListView.builder(
            itemCount: controller.notes.length,
            itemBuilder: (context, index) {
              final note = controller.notes[index];
              return NoteCard(
                note: note,
                onDelete: () => controller.deleteNote(note),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(AddNoteDialogue(controller: controller));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## Step 7: Register the Route

### 7a: Add Route Name

Open `lib/core/routes/routes_names.dart`:

```dart
class RoutesNames {
  static const String splashView = "/";
  static const String homeView   = "/home_view";
  static const String noteView   = "/note_view";    // ← ADD THIS
}
```

### 7b: Add Route Page

Open `lib/core/routes/app_pages.dart`:

```dart
import 'package:binary_demo_app/core/routes/routes_names.dart';
import 'package:binary_demo_app/views/home_view.dart';
import 'package:binary_demo_app/views/splash_view.dart';
import 'package:binary_demo_app/views/note_view.dart';    // ← ADD IMPORT

class AppPages {
  static List<GetPage> pages = [
    GetPage(name: RoutesNames.splashView, page: () => SplashView()),
    GetPage(name: RoutesNames.homeView,   page: () => HomeView()),
    GetPage(name: RoutesNames.noteView,   page: () => NoteView()),   // ← ADD THIS
  ];
}
```

---

## Step 8: Add a Navigation Button

You can add a button on the Home screen to navigate to Notes. Open `lib/views/home_view.dart` and add a button in the AppBar:

```dart
appBar: AppBar(
  title: Text("Todo Home"),
  actions: [
    IconButton(
      icon: Icon(Icons.note),
      onPressed: () => Get.toNamed(RoutesNames.noteView),  // ← Navigate
    ),
  ],
),
```

---

## Step 9: Run the App!

```bash
flutter run
```

### What You Should See

1. **Splash Screen** → auto-navigates to Home after 3 seconds.
2. **Home Screen** → the existing Todo list + a note icon in the app bar.
3. **Tap the note icon** → you land on the **Notes Screen**.
4. **Notes Screen** → loads 10 notes from the API, shows them as cards.
5. **Tap +** → opens a dialog to add a new note.
6. **Tap the trash icon** → deletes that note from the list.

---

## Files Created in This Exercise

```
lib/
├── core/
│   └── services/
│       └── api_service.dart        ← Step 2 (if not already created)
│
├── models/
│   └── note_model.dart             ← Step 3
│
├── controllers/
│   └── note_controller.dart        ← Step 4
│
├── widgets/
│   └── notes/
│       ├── note_card.dart          ← Step 5a
│       └── add_note_dialogue.dart  ← Step 5b
│
└── views/
    └── note_view.dart              ← Step 6
```

**Modified files:**
- `routes_names.dart` — added `noteView` route name.
- `app_pages.dart` — added `NoteView` page.
- `home_view.dart` — added navigation button (optional).

---

## Summary: The Pattern

Every feature follows this exact sequence:

```
1. Model        → What does the data look like?
2. Service      → How do we get the data? (API/Socket)
3. Controller   → What logic manages the data?
4. Widgets      → What small UI pieces do we need?
5. View         → What does the full screen look like?
6. Route        → How do we navigate to it?
```

Once you've done this 2-3 times, you can build any new feature in minutes.

> **Speaker Note:** *"And that's the whole pattern! Model, Controller, View, Widgets, Route. Every single feature you'll ever build in this template follows these exact steps. Let's recap by looking at the file-by-file reference in the next chapter."*

---

**← Previous:** [09 — Socket Integration](09_SOCKET_INTEGRATION.md) · **Next →** [11 — File-by-File Reference](11_FILE_BY_FILE_REFERENCE.md)
