import 'package:get/get.dart';
import 'screens/login_screen.dart';
import 'screens/owner_dashboard.dart';
import 'screens/employee_dashboard.dart';
import 'screens/item_management_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sales_history_screen.dart';
import 'screens/transaction_details_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/user_page.dart';

final appRoutes = [
  GetPage(name: '/login', page: () => LogInScreen()),
  GetPage(name: '/owner_dashboard', page: () => OwnerDashboard()),
  GetPage(name: '/employee_dashboard', page: () => EmployeeDashboard()),
  GetPage(name: '/item_management', page: () => ItemManagementScreen()),
  GetPage(name: '/menu', page: () => MenuScreen()),
  GetPage(name: '/cart', page: () => CartScreen()),
  GetPage(name: '/sales_history', page: () => SalesHistoryScreen()),
  GetPage(name: '/transaction_details', page: () => TransactionDetailsScreen()),
  GetPage(name: '/about', page: () => AboutAppScreen()),
  GetPage(name: '/user', page: () => UserPage()),
];
