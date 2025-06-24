import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/item_model.dart';
import '../data/hive_service.dart';

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final itemsBox = Hive.box<ItemModel>('itemsBox');
  late RxList<int> quantities;

  @override
  void initState() {
    super.initState();
    if (HiveService.getUserRole() != 'employee') {
      Get.snackbar('Error', 'Unauthorized');
      Get.offAllNamed('/login');
      return;
    }
    quantities = List<int>.filled(itemsBox.length, 0).obs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: ValueListenableBuilder(
        valueListenable: itemsBox.listenable(),
        builder: (context, Box<ItemModel> box, _) {
          if (box.isEmpty) return Center(child: Text('No menu items.'));
          // Adjust quantities length if items are added/removed
          if (quantities.length != box.length)
            quantities.value = List<int>.filled(box.length, 0);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, i) {
                    final item = box.getAt(i)!;
                    return Obx(() => ListTile(
                          leading: Text(item.icon),
                          title: Text(item.name),
                          subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (quantities[i] > 0) quantities[i]--;
                                },
                              ),
                              Text(quantities[i].toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => quantities[i]++,
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
              Obx(() => ElevatedButton(
                    child: Text('Go to Cart'),
                    onPressed: quantities.any((q) => q > 0)
                        ? () =>
                            Get.toNamed('/cart', arguments: quantities.toList())
                        : null,
                  )),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
