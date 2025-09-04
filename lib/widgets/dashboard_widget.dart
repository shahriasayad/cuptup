import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/item_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardWidget extends StatelessWidget {
  DashboardWidget({Key? key}) : super(key: key);

  Map<String, dynamic> computeSalesSummary(
      Box<ItemModel> itemsBox, Box salesBox) {
    final Map<String, Map<String, dynamic>> itemStats = {};
    double totalRevenue = 0;

    for (var item in itemsBox.values) {
      itemStats[item.name] = {
        'icon': item.icon,
        'count': 0,
        'profit': 0.0,
      };
    }

    for (var sale in salesBox.values) {
      if (sale is Map && sale['items'] is List) {
        for (var sold in sale['items']) {
          if (sold is Map && itemStats.containsKey(sold['name'])) {
            final count = (sold['qty'] as int?) ?? 0;
            final price = (sold['price'] as num?)?.toDouble() ?? 0.0;
            itemStats[sold['name']]!['count'] += count;
            itemStats[sold['name']]!['profit'] += price * count;
            totalRevenue += price * count;
          }
        }
      }
    }

    return {
      'itemStats': itemStats,
      'totalRevenue': totalRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final itemsBox = Hive.box<ItemModel>('itemsBox');
    final salesBox = Hive.box('salesBox');

    return ValueListenableBuilder(
      valueListenable: itemsBox.listenable(),
      builder: (context, Box<ItemModel> itemsBox, _) {
        return ValueListenableBuilder(
          valueListenable: salesBox.listenable(),
          builder: (context, Box salesBox, _) {
            final summary = computeSalesSummary(itemsBox, salesBox);
            final itemStats =
                summary['itemStats'] as Map<String, Map<String, dynamic>>;
            final totalRevenue = summary['totalRevenue'] as double;

            return Column(
              children: [
                Expanded(
                  child: itemStats.isEmpty
                      ? Center(child: Text('No menu items.'))
                      : ListView(
                          children: itemStats.entries.map(
                            (entry) {
                              final icon = entry.value['icon'];
                              final count = entry.value['count'];
                              final profit = entry.value['profit'];
                              return Card(
                                color: Colors.teal.shade200,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                child: ListTile(
                                  leading: Text(
                                    icon,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  title: Text(
                                    '${entry.key}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    'Sold: $count     Profit: ৳${profit.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                ),
                Card(
                  color: Colors.teal.shade100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text('৳${totalRevenue.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
