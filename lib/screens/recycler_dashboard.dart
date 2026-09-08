import 'package:flutter/material.dart';
import 'my_offers_screen.dart';
import '../data/models/lot_model.dart';
import '../data/repositories/recycler_repository.dart';
import 'lot_details_screen.dart';

class RecyclerDashboard extends StatelessWidget {
  RecyclerDashboard({super.key});

  final RecyclerRepository _repository = RecyclerRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kollekt'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyOffersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'My Offers',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: StreamBuilder<List<LotModel>>(
        stream: _repository.watchOpenLots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load collection lots.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final lots = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Recycler Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find e-waste lots and make offers.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),

              _buildRecyclerCard(),

              const SizedBox(height: 24),

              Text(
                'Open Collection Lots (${lots.length})',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (lots.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No open collection lots',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'New collector lots will appear here.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...lots.map(
                      (lot) => _buildLotCard(context, lot),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecyclerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(
                Icons.recycling,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Recycler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Pune • Authorized Recycler'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotCard(
      BuildContext context,
      LotModel lot,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Icon(
            _materialIcon(lot.materialId),
          ),
        ),
        title: Text(
          lot.materialName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${lot.weightKg.toStringAsFixed(1)} kg • ${lot.location}\n'
              '${lot.description}',
        ),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LotDetailsScreen(lot: lot),
              ),
            );
          },
          child: const Text('View'),
        ),
      ),
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