import 'dart:io';

import 'package:flutter/material.dart';

import 'demo_price_data.dart';
import '../lots/create_lot_screen.dart';

class PriceEstimateScreen extends StatefulWidget {
  final File imageFile;
  final String materialId;
  final String materialName;

  const PriceEstimateScreen({
    super.key,
    required this.imageFile,
    required this.materialId,
    required this.materialName,
  });

  @override
  State<PriceEstimateScreen> createState() => _PriceEstimateScreenState();
}

class _PriceEstimateScreenState extends State<PriceEstimateScreen> {
  final _weight = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  double get currentRate =>
      DemoPriceData.currentRates[widget.materialId]?['current'] ?? 0;

  double get estimate =>
      (double.tryParse(_weight.text.trim()) ?? 0) * currentRate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price Estimate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.recycling),
            title: Text(widget.materialName),
            subtitle: Text('Current demo rate: ₹${currentRate.toStringAsFixed(0)}/kg'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Approximate weight',
              suffixText: 'kg',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Estimated value'),
                  const SizedBox(height: 8),
                  Text(
                    '₹${estimate.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_weight.text.isEmpty ? '0' : _weight.text} kg × '
                    '₹${currentRate.toStringAsFixed(0)}/kg',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: estimate <= 0
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateLotScreen(
                          imageFile: widget.imageFile,
                          materialId: widget.materialId,
                          materialName: widget.materialName,
                          weightKg: double.parse(_weight.text.trim()),
                          estimatedPrice: estimate,
                        ),
                      ),
                    );
                  },
            child: const Text('Continue to Create Lot'),
          ),
        ],
      ),
    );
  }
}
