import 'package:binary_demo_app/core/routes/routes_names.dart';
import 'package:binary_demo_app/views/home_view.dart';
import 'package:binary_demo_app/views/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  static List<GetPage> pages = [
    GetPage(
      name: RoutesNames.splashView,
      page: () => SplashView(),
    ),
    GetPage(
      name: RoutesNames.homeView,
      page: () => HomeView(),
    ),
  ];
}