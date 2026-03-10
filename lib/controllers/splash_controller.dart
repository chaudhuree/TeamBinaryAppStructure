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
