import 'package:get/get.dart';
import 'package:hungry/views/screens/auth/welcome_page.dart';
import 'package:hungry/views/screens/search_page.dart';

import '../views/screens/page_switcher.dart';
part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.welcome_page, page: () => WelcomePage()),
    GetPage(name: Routes.home_page, page: () => PageSwitcher()),
    GetPage(name: Routes.search_page, page: () => SearchPage()),
  ];
}
