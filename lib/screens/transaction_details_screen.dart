import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sale = Map<String, dynamic>.from(ModalRoute.of(context)!.settings.arguments as Map);
    final time = DateTime.tryParse(sale['time'] ?? '') ?? DateTime.now();
    final items = List<Map<String, dynamic>>.from(sale['items'] ?? []);
    final total = sale['total'] ?? 0.0;
    final collected = sale['collected'] ?? 0.0;
    final change = sale['change'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${DateFormat('yyyy-MM-dd h:mm a').format(time)}'),
            SizedBox(height: 8),
            Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${item['name']} x${item['qty']} - \$${(item['price'] * item['qty']).toStringAsFixed(2)}'),
            )),
            Divider(),
            Text('Total: \$${total.toStringAsFixed(2)}'),
            Text('Collected: \$${collected.toStringAsFixed(2)}'),
            Text('Change: \$${change.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}