import 'package:flutter/material.dart';

import 'demo_price_data.dart';

class PriceBoardScreen extends StatelessWidget {
  const PriceBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today’s Prices')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: DemoPriceData.currentRates.entries.map((entry) {
          final rate = entry.value;
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.currency_rupee)),
              title: Text(DemoPriceData.names[entry.key]!),
              subtitle: Text(
                'Market range: ₹${rate['min']!.toStringAsFixed(0)}–'
                '₹${rate['max']!.toStringAsFixed(0)}/kg',
              ),
              trailing: Text(
                '₹${rate['current']!.toStringAsFixed(0)}/kg',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
