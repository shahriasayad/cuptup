import 'package:hive/hive.dart';
import 'item_model.dart';

class HiveService {
  static late Box loginBox;
  static late Box userBox;
  static late Box<ItemModel> itemsBox;
  static late Box salesBox;
  static late Box transactionsBox;

  static Future<void> init() async {
    loginBox = await Hive.openBox('loginBox');
    userBox = await Hive.openBox('userBox');
    itemsBox = await Hive.openBox<ItemModel>('itemsBox');
    salesBox = await Hive.openBox('salesBox');
    transactionsBox = await Hive.openBox('transactionsBox');
  }

  // Login management
  static bool isLoggedIn() => loginBox.get('isLoggedIn', defaultValue: false) ?? false;
  static void setLoggedIn(bool value) => loginBox.put('isLoggedIn', value);

  // Role management
  static String? getUserRole() => userBox.get('role');
  static void setUserRole(String role) => userBox.put('role', role);
  static void clearUserRole() => userBox.delete('role');

  // Items CRUD
  static List<ItemModel> getItems() => itemsBox.values.toList();
  static Future<void> addItem(ItemModel item) async => await itemsBox.add(item);
  static Future<void> removeItem(int index) async => await itemsBox.deleteAt(index);
  static Future<void> clearItems() async => await itemsBox.clear();

  // Sales
  static Future<void> recordSale(Map<String, dynamic> sale) async => await salesBox.add(sale);
  static List<Map> getSalesHistory() => salesBox.values.cast<Map>().toList();
  static Future<void> clearSalesHistory() async => await salesBox.clear();
}