import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CollectorOffersScreen extends StatelessWidget {
  final String? lotId;

  const CollectorOffersScreen({super.key, this.lotId});

  @override
  Widget build(BuildContext context) {
    if (lotId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offers')),
        body: const Center(
          child: Text('Open a lot from My Lots to view its offers.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recycler Offers')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('offers')
            .where('lotId', isEqualTo: lotId)
            .orderBy('offeredPricePerKg', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load offers: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No offers yet. Ask the Recycler side to submit an offer.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data();
              final recyclerId = data['recyclerId'] as String? ?? '';
              final price = (data['offeredPricePerKg'] as num?)?.toDouble() ?? 0;
              final total = (data['totalOffer'] as num?)?.toDouble() ?? 0;
              final pickup = data['pickupAvailable'] == true;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.factory)),
                  title: Text(_recyclerName(recyclerId)),
                  subtitle: Text(
                    '₹${price.toStringAsFixed(0)}/kg • '
                    'Total ₹${total.toStringAsFixed(0)}\n'
                    '${pickup ? 'Pickup available' : 'Pickup unavailable'}',
                  ),
                  isThreeLine: true,
                  trailing: data['status'] == 'accepted'
                      ? const Chip(label: Text('SELECTED'))
                      : FilledButton(
                          onPressed: data['status'] == 'pending'
                              ? () => _accept(context, doc)
                              : null,
                          child: const Text('Choose'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _recyclerName(String uid) {
    // Names are deliberately not hardcoded as real organizations.
    // Live UI should resolve the recycler profile by UID.
    if (uid == 'DEMO_REC_001') return 'GreenCycle Demo Recycling';
    if (uid == 'DEMO_REC_002') return 'EcoRecover Demo Facility';
    if (uid == 'DEMO_REC_003') return 'RecycleHub Demo';
    return 'Recycler ${uid.length > 8 ? '${uid.substring(0, 8)}…' : uid}';
  }

  Future<void> _accept(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> selected,
  ) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    batch.update(selected.reference, {'status': 'accepted'});

    final others = await db
        .collection('offers')
        .where('lotId', isEqualTo: lotId)
        .get();

    for (final doc in others.docs) {
      if (doc.id != selected.id && doc.data()['status'] == 'pending') {
        batch.update(doc.reference, {'status': 'rejected'});
      }
    }

    batch.update(
      db.collection('lots').doc(lotId),
      {'status': 'accepted'},
    );

    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer selected successfully.')),
      );
    }
  }
}
