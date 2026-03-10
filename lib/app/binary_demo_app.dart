import 'package:binary_demo_app/core/routes/app_pages.dart';
import 'package:binary_demo_app/core/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class BinaryDemoApp extends StatelessWidget {
  const BinaryDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      initialRoute: RoutesNames.splashView,
      getPages: AppPages.pages,
    );
  }
}
