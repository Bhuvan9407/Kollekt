import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TraceabilityScreen extends StatelessWidget {
  const TraceabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Traceability')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('lots')
            .where('collectorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load traceability: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No traceable lots yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final d = doc.data();
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.verified),
                  title: Text(d['materialName'] ?? 'Material'),
                  subtitle: Text('Lot ${doc.id} • ${d['status'] ?? 'open'}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _row('Weight', '${d['weightKg'] ?? 0} kg'),
                    _row('Location', '${d['location'] ?? '-'}'),
                    _row('Estimated value', '₹${d['estimatedPrice'] ?? 0}'),
                    _row('Photo', d['photoUrl'] == null ? 'Not uploaded' : 'Stored'),
                    _row('Collector UID', '${d['collectorId'] ?? '-'}'),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'The Recycler side will add handover and transaction records using this same Lot ID.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
