import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../data/item_model.dart';
import '../data/hive_service.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<int> quantities;
  late List<ItemModel> items;
  late double total;
  late TextEditingController collectedController;
  double collected = 0.0;
  double change = 0.0;

  @override
  void initState() {
    super.initState();
    if (HiveService.getUserRole() != 'employee') {
      Get.snackbar('Error', 'Unauthorized');
      Get.offAllNamed('/login');
      return;
    }
    final itemsBox = Hive.box<ItemModel>('itemsBox');
    items = itemsBox.values.toList();
    quantities =
        List<int>.from(Get.arguments ?? List<int>.filled(items.length, 0));
    total = _calculateTotal();
    collectedController = TextEditingController();
    collectedController.addListener(_onCollectedChanged);
  }

  double _calculateTotal() {
    double sum = 0;
    for (int i = 0; i < items.length; i++) {
      sum += items[i].price * quantities[i];
    }
    return sum;
  }

  void _onCollectedChanged() {
    setState(() {
      collected = double.tryParse(collectedController.text) ?? 0.0;
      change = collected - total;
    });
  }

  @override
  void dispose() {
    collectedController.dispose();
    super.dispose();
  }

  void handleDone() {
    final selectedItems = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length; i++) {
      if (quantities[i] > 0) {
        selectedItems.add({
          'name': items[i].name,
          'qty': quantities[i],
          'price': items[i].price,
        });
      }
    }
    final user = HiveService.userBox.get('username') ?? '';
    final sale = {
      'user': user,
      'time': DateTime.now().toIso8601String(),
      'items': selectedItems,
      'total': total,
      'collected': collected,
      'change': change,
    };
    HiveService.salesBox.add(sale);
    Get.offAllNamed('/employee_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = quantities.where((q) => q > 0).length;
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: selectedCount == 0
          ? Center(child: Text('No items selected.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        ...List.generate(items.length, (i) {
                          if (quantities[i] == 0) return SizedBox.shrink();
                          final item = items[i];
                          final subtotal = item.price * quantities[i];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Text(
                                  item.name[0].toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Qty: ${quantities[i]}  •  Price: \৳${item.price.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              trailing: Text(
                                '\৳${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('VAT'),
                      Text('\৳0.00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount'),
                      Text('\৳0.00'),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\৳${total.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: collectedController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Collected Amount',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.money, color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Change',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\৳${change.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(60),
                    ),
                    child: Text(
                      'DONE',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: collected >= total ? handleDone : null,
                  ),
                ],
              ),
            ),
    );
  }
}
