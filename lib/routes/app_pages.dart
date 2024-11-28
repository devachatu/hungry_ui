import 'package:get/get.dart';
import 'package:hungry/views/screens/auth/welcome_page.dart';
import 'package:hungry/views/screens/search_page.dart';
part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.welcome_page, page: () => SearchPage())
  ];
}
