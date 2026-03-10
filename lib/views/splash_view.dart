import 'package:binary_demo_app/controllers/splash_controller.dart';
import 'package:binary_demo_app/core/colors/app_colors.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
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
                    color: AppColors.primaryThemeColor,
                  ),
                ),
                SizedBox(height: 16),
                Spacer(),
                CircleLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

