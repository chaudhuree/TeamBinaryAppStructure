# 07 — Adding New Features (Cheat Sheet)

This chapter is a **quick-reference guide**. Whenever you need to add something new to the project, follow these step-by-step instructions.

---

## 1. Add a New Model

**When:** You have a new type of data (e.g., User, Product, Order).

### Steps

1. Create `lib/models/<name>_model.dart`.
2. Define the class with its fields and a named constructor.
3. (Optional) Add `fromJson()` and `toJson()` if you'll use it with APIs.

### Template

```dart
// lib/models/product_model.dart

class ProductModel {
  String id;
  String name;
  double price;
  String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  // For API usage:
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
```

---

## 2. Add a New Controller

**When:** You have a new screen or a new piece of business logic.

### Steps

1. Create `lib/controllers/<name>_controller.dart`.
2. Extend `GetxController`.
3. Declare reactive variables (`.obs`).
4. Write your methods.
5. Use `onInit()` for initial loading.

### Template

```dart
// lib/controllers/product_controller.dart

import 'package:get/get.dart';
import 'package:binary_demo_app/models/product_model.dart';

class ProductController extends GetxController {
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      // Replace with actual API call later:
      await Future.delayed(Duration(seconds: 2));
      products.addAll([
        ProductModel(id: "1", name: "Laptop", price: 999.99),
        ProductModel(id: "2", name: "Phone", price: 499.99),
      ]);
    } catch (e) {
      debugPrint("Fetch Products Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }
}
```

---

## 3. Add a New View (Screen)

**When:** You need a new page in the app.

### Steps

1. Create `lib/views/<name>_view.dart`.
2. Create a `StatelessWidget`.
3. Register the controller with `Get.put()`.
4. Use `Obx()` to reactively display data.

### Template

```dart
// lib/views/product_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_demo_app/controllers/product_controller.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';

class ProductView extends StatelessWidget {
  ProductView({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircleLoader());
        }
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text("\$${product.price}"),
            );
          },
        );
      }),
    );
  }
}
```

---

## 4. Add a New Route

**When:** You've created a new view and want to navigate to it.

### Steps

1. Add the route name in `lib/core/routes/routes_names.dart`.
2. Register the page in `lib/core/routes/app_pages.dart`.
3. Navigate using `Get.toNamed()`.

### Step-by-Step

```dart
// Step 1: routes_names.dart
class RoutesNames {
  static const String splashView   = "/";
  static const String homeView     = "/home_view";
  static const String productView  = "/product_view";   // ← ADD THIS
}
```

```dart
// Step 2: app_pages.dart
import 'package:binary_demo_app/views/product_view.dart';  // ← ADD IMPORT

static List<GetPage> pages = [
  GetPage(name: RoutesNames.splashView,  page: () => SplashView()),
  GetPage(name: RoutesNames.homeView,    page: () => HomeView()),
  GetPage(name: RoutesNames.productView, page: () => ProductView()),  // ← ADD THIS
];
```

```dart
// Step 3: Navigate from anywhere
Get.toNamed(RoutesNames.productView);
```

---

## 5. Add New Constants (Colors, Strings, Sizes)

**When:** You need project-wide constant values.

### Add Colors

```dart
// lib/core/colors/app_colors.dart
class AppColors {
  static Color primaryThemeColor = Colors.deepPurple;
  static Color accentColor       = Color(0xFF03DAC6);  // ← ADD
  static Color danger            = Colors.redAccent;    // ← ADD
}
```

### Add String Constants

Create `lib/core/constants/app_strings.dart`:

```dart
class AppStrings {
  static const String appName    = "Binary Demo App";
  static const String welcomeMsg = "Welcome back!";
  static const String noData     = "No items found.";
}
```

### Add Size Constants

Create `lib/core/constants/app_sizes.dart`:

```dart
class AppSizes {
  static const double paddingSmall  = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge  = 24.0;
  static const double borderRadius  = 12.0;
  static const double iconSize      = 24.0;
}
```

### Add Text Style Constants

Create `lib/core/themes/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:binary_demo_app/core/colors/app_colors.dart';

class AppTextStyles {
  static TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryThemeColor,
  );

  static TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
```

---

## 6. Add a New Widget

### Common Widget (Reusable Across Screens)

Create in `lib/widgets/common/`:

```dart
// lib/widgets/common/empty_state.dart

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, this.message = "No items found"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
```

### Screen-Specific Widget

Create a sub-folder matching the screen name: `lib/widgets/product/`:

```dart
// lib/widgets/product/product_card.dart

import 'package:binary_demo_app/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text("\$${product.price}"),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
```

---

## Quick Checklist: Adding a Full Feature

When adding a complete new feature (e.g., "Products"), follow this order:

- [ ] **Model** → `lib/models/product_model.dart`
- [ ] **Controller** → `lib/controllers/product_controller.dart`
- [ ] **View** → `lib/views/product_view.dart`
- [ ] **Widgets** → `lib/widgets/product/product_card.dart`
- [ ] **Route Name** → add in `routes_names.dart`
- [ ] **Route Page** → add in `app_pages.dart`
- [ ] **Constants** → add colors, strings, sizes as needed
- [ ] **Navigate** → use `Get.toNamed()` from an existing screen

> **Speaker Note:** *"Every new feature follows the same recipe: Model → Controller → View → Widgets → Route. Once you do it 2-3 times, it becomes muscle memory."*

---

**← Previous:** [06 — Views & Widgets](06_VIEWS_AND_WIDGETS.md) · **Next →** [08 — API Integration](08_API_INTEGRATION.md)
