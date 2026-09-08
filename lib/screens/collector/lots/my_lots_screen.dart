import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../offers/collector_offers_screen.dart';

class MyLotsScreen extends StatelessWidget {
  const MyLotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Lots')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('lots')
            .where('collectorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load lots: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No lots created yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data();
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                  title: Text(data['materialName'] ?? 'Material'),
                  subtitle: Text(
                    '${data['weightKg'] ?? 0} kg • '
                    '₹${data['estimatedPrice'] ?? 0}\n'
                    'Lot: ${doc.id}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text(data['status'] ?? 'open')),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectorOffersScreen(lotId: doc.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
