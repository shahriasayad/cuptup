import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SalesHistoryScreen extends StatelessWidget {
  final salesBox = Hive.box('salesBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales History')),
      body: ValueListenableBuilder(
        valueListenable: salesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) return Center(child: Text('No sales yet.'));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, i) {
              final sale = box.getAt(i) as Map;
              final user = sale['user'] ?? '';
              final time =
                  DateTime.tryParse(sale['time'] ?? '') ?? DateTime.now();
              final total = sale['total'] ?? 0.0;
              return ListTile(
                title: Text('$user'),
                subtitle: Text(DateFormat('h:mm a').format(time)),
                trailing: Text('\$${total.toStringAsFixed(2)}'),
                onTap: () =>
                    Get.toNamed('/transaction_details', arguments: sale),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade400,
        child: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        tooltip: 'Clear All',
        onPressed: () async {
          final confirm = await Get.dialog(
            AlertDialog(
              title: Text('Clear all sales?'),
              actions: [
                TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.green),
                    )),
                TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          );
          if (confirm == true) salesBox.clear();
        },
      ),
    );
  }
}
