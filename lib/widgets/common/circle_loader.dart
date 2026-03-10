import 'package:binary_demo_app/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CircleLoader extends StatelessWidget {
  const CircleLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColors.primaryThemeColor);
  }
}
