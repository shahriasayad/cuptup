import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/item_model.dart';

class ItemManagementScreen extends StatefulWidget {
  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final iconController = TextEditingController();

  final itemsBox = Hive.box<ItemModel>('itemsBox');

  void addItem() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final icon = iconController.text.trim();

    if (name.isEmpty || price <= 0.0) {
      Get.snackbar('Error', 'Enter valid name and price');
      return;
    }
    itemsBox.add(ItemModel(name: name, price: price, icon: icon));
    nameController.clear();
    priceController.clear();
    iconController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Items')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name')),
            TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
              controller: iconController,
              decoration: InputDecoration(labelText: 'Icon (emoji only)'),
              keyboardType: TextInputType.text,
              maxLength: 2, // restrict to 1 or 2 characters max
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r'[\u2190-\u21FF\u2600-\u27BF\u1F300-\u1F64F\u1F680-\u1F6FF\u1F900-\u1F9FF\u1FA70-\u1FAFF\u1F1E6-\u1F1FF]+')),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(child: Text('Add Item'), onPressed: addItem),
            SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: itemsBox.listenable(),
                builder: (context, Box<ItemModel> box, _) {
                  if (box.isEmpty) return Center(child: Text('No items'));
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, i) {
                      final item = box.getAt(i)!;
                      return ListTile(
                        leading: Text(item.icon),
                        title: Text(item.name),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => box.deleteAt(i),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
