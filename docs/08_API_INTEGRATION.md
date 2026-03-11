# 08 — API Integration

This chapter shows how to set up HTTP API calls in the template, fetch data from a server, and display it on screen.

---

## Overview

```
┌──────────┐     HTTP      ┌──────────┐     JSON       ┌───────────┐
│  Server  │◄─────────────►│ ApiService│──────────────►│   Model   │
│  (API)   │               │ (service) │  fromJson()   │ (Dart obj)│
└──────────┘               └─────┬─────┘               └─────┬─────┘
                                 │                            │
                            called by                    stored in
                                 │                            │
                           ┌─────▼──────┐              ┌──────▼──────┐
                           │ Controller │──────────────►│  RxList/Rx  │
                           └─────┬──────┘   updates     └──────┬──────┘
                                 │                            │
                            observed by                  read by
                                 │                            │
                           ┌─────▼──────┐                     │
                           │    View    │◄────────────────────┘
                           └────────────┘       Obx() rebuilds
```

---

## Step 1: Add the `http` Package

Open `pubspec.yaml` and add:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.7.3
  http: ^1.2.1          # ← ADD THIS
```

Then run:

```bash
flutter pub get
```

> **Alternative:** You can also use the `dio` package (`dio: ^5.4.0`) which has more features like interceptors, cancellation, and progress tracking. The approach below works with both — just swap the HTTP call syntax.

---

## Step 2: Create an API Service

Create a new folder and file: `lib/core/services/api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL of your backend
  static const String baseUrl = "https://jsonplaceholder.typicode.com";

  // ──────────── GET REQUEST ────────────
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

  // ──────────── POST REQUEST ────────────
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

  // ──────────── PUT REQUEST ────────────
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("PUT failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("PUT error: $e");
    }
  }

  // ──────────── DELETE REQUEST ────────────
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

### What This Does

- **One file** handles all HTTP methods (GET, POST, PUT, DELETE).
- **`baseUrl`** — change this to your own server URL.
- Every method returns decoded JSON or throws an exception.
- You call it from controllers like: `ApiService.get("/users")`.

---

## Step 3: Create a Model with `fromJson`

Create `lib/models/post_model.dart`:

```dart
class PostModel {
  int id;
  String title;
  String body;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
```

---

## Step 4: Create a Controller That Calls the API

Create `lib/controllers/post_controller.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_demo_app/core/services/api_service.dart';
import 'package:binary_demo_app/models/post_model.dart';

class PostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  // ──────── FETCH ALL POSTS ────────
  Future<void> fetchPosts() async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      final List<dynamic> jsonList = await ApiService.get("/posts");
      posts.value = jsonList.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ──────── CREATE A POST ────────
  Future<void> createPost(String title, String body) async {
    isLoading.value = true;
    try {
      final json = await ApiService.post("/posts", {
        "title": title,
        "body": body,
        "userId": 1,
      });
      posts.add(PostModel.fromJson(json));
      Get.snackbar("Success", "Post created!");
    } catch (e) {
      debugPrint("Create Post Error: $e");
      Get.snackbar("Error", "Failed to create post");
    } finally {
      isLoading.value = false;
    }
  }

  // ──────── DELETE A POST ────────
  Future<void> deletePost(int id) async {
    try {
      await ApiService.delete("/posts/$id");
      posts.removeWhere((post) => post.id == id);
      Get.snackbar("Deleted", "Post removed");
    } catch (e) {
      debugPrint("Delete Post Error: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }
}
```

### What's Happening

1. `fetchPosts()` calls `ApiService.get("/posts")` → gets a JSON list → converts each item to a `PostModel` using `fromJson()`.
2. `createPost()` sends data via `ApiService.post()` → adds the returned model to the list.
3. `deletePost()` calls `ApiService.delete()` → removes the item from the reactive list.
4. `onInit()` auto-fetches posts when the controller is created.

---

## Step 5: Create the View

Create `lib/views/post_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_demo_app/controllers/post_controller.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';

class PostView extends StatelessWidget {
  PostView({super.key});

  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posts from API")),
      body: Obx(() {
        // Show loader
        if (controller.isLoading.value) {
          return Center(child: CircleLoader());
        }

        // Show error
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Something went wrong!"),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.fetchPosts(),
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        }

        // Show posts
        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.deletePost(post.id),
              ),
            );
          },
        );
      }),
    );
  }
}
```

---

## Step 6: Register the Route

```dart
// routes_names.dart
static const String postView = "/post_view";

// app_pages.dart
GetPage(name: RoutesNames.postView, page: () => PostView()),
```

---

## Step 7: Navigate to It

```dart
Get.toNamed(RoutesNames.postView);
```

---

## Adding Auth Headers (Token-Based APIs)

If your API requires an authentication token, update `ApiService`:

```dart
class ApiService {
  static const String baseUrl = "https://your-api.com";
  static String? _token;

  // Call this after login:
  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    "Content-Type": "application/json",
    if (_token != null) "Authorization": "Bearer $_token",
  };

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(url, headers: _headers);
    // ... rest of the code
  }
}
```

---

## Folder Structure After Adding API Support

```
lib/
├── core/
│   ├── colors/
│   │   └── app_colors.dart
│   ├── routes/
│   │   ├── routes_names.dart
│   │   └── app_pages.dart
│   └── services/              ← NEW FOLDER
│       └── api_service.dart   ← NEW FILE
│
├── models/
│   ├── todo_model.dart
│   └── post_model.dart        ← NEW FILE
│
├── controllers/
│   ├── splash_controller.dart
│   ├── home_controller.dart
│   └── post_controller.dart   ← NEW FILE
│
└── views/
    ├── splash_view.dart
    ├── home_view.dart
    └── post_view.dart          ← NEW FILE
```

> **Speaker Note:** *"API integration follows the exact same pattern as our Todo feature: Model → Controller → View. The only new piece is the `ApiService` in `core/services/`. It's a helper that does the actual HTTP calls. The controller calls the service, converts JSON to models, and the view displays the data."*

---

**← Previous:** [07 — Adding New Features](07_ADDING_NEW_FEATURES.md) · **Next →** [09 — Socket Integration](09_SOCKET_INTEGRATION.md)
