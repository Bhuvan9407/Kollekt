import 'package:flutter/material.dart';
import 'make_offer_screen.dart';
import '../data/models/lot_model.dart';

class LotDetailsScreen extends StatelessWidget {
  final LotModel lot;

  const LotDetailsScreen({
    super.key,
    required this.lot,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(
                  _materialIcon(lot.materialId),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.materialName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lot.lotId,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _detailRow(
                    Icons.scale,
                    'Weight',
                    '${lot.weightKg.toStringAsFixed(1)} kg',
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.location_on_outlined,
                    'Location',
                    lot.location,
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.currency_rupee,
                    'Estimated Value',
                    '₹${lot.estimatedPrice.toStringAsFixed(0)}',
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.info_outline,
                    'Status',
                    lot.status.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lot.description.isEmpty
                        ? 'No description provided.'
                        : lot.description,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MakeOfferScreen(lot: lot),
                  ),
                );
              },
              icon: const Icon(Icons.local_offer_outlined),
              label: const Text('Make an Offer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _materialIcon(String materialId) {
    switch (materialId) {
      case 'pcb':
        return Icons.memory;
      case 'lcd':
        return Icons.desktop_windows;
      case 'cable':
        return Icons.cable;
      case 'battery':
        return Icons.battery_full;
      case 'mixed_plastic':
        return Icons.category;
      default:
        return Icons.recycling;
    }
  }
}