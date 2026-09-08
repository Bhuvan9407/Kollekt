import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../offers/collector_offers_screen.dart';
import 'recycler_demo_data.dart';

class RecyclerComparisonScreen extends StatefulWidget {
  final String lotId;
  final String materialId;
  final double weightKg;

  const RecyclerComparisonScreen({
    super.key,
    required this.lotId,
    required this.materialId,
    required this.weightKg,
  });

  @override
  State<RecyclerComparisonScreen> createState() =>
      _RecyclerComparisonScreenState();
}

class _RecyclerComparisonScreenState extends State<RecyclerComparisonScreen> {
  List<Map<String, dynamic>> _recyclers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('recyclers').get();

      final firebaseRows = snapshot.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'name': data['name'] ?? 'Recycler',
          'location': data['location'] ?? 'Unknown',
          'authorized': data['authorized'] == true,
          'acceptedMaterials':
              List<String>.from(data['acceptedMaterials'] ?? const []),
          'pickupAvailable': data['pickupAvailable'] == true,
          'price': _readRate(data['offeredRates'], widget.materialId),
          'distance': (data['distanceKm'] as num?)?.toDouble() ?? 999.0,
          'demo': false,
        };
      }).where((r) {
        return r['authorized'] == true &&
            (r['acceptedMaterials'] as List).contains(widget.materialId);
      }).toList();

      if (!mounted) return;
      setState(() {
        _recyclers = firebaseRows.isNotEmpty
            ? firebaseRows
            : demoRecyclers
                .where((r) =>
                    r.authorized &&
                    r.acceptedMaterials.contains(widget.materialId))
                .map((r) => {
                      'id': r.id,
                      'name': r.name,
                      'location': r.location,
                      'authorized': r.authorized,
                      'acceptedMaterials': r.acceptedMaterials,
                      'pickupAvailable': r.pickupAvailable,
                      'price': r.pricePerKg,
                      'distance': r.distanceKm,
                      'demo': true,
                    })
                .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recyclers = demoRecyclers
            .where((r) =>
                r.authorized &&
                r.acceptedMaterials.contains(widget.materialId))
            .map((r) => {
                  'id': r.id,
                  'name': r.name,
                  'location': r.location,
                  'authorized': r.authorized,
                  'acceptedMaterials': r.acceptedMaterials,
                  'pickupAvailable': r.pickupAvailable,
                  'price': r.pricePerKg,
                  'distance': r.distanceKm,
                  'demo': true,
                })
            .toList();
        _loading = false;
      });
    }
  }

  double _readRate(dynamic rates, String materialId) {
    if (rates is Map) {
      final value = rates[materialId];
      if (value is num) return value.toDouble();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Recyclers')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recyclers.isEmpty
              ? const Center(child: Text('No suitable recyclers found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _recyclers.length,
                  itemBuilder: (_, index) {
                    final r = _recyclers[index];
                    final total = (r['price'] as num).toDouble() * widget.weightKg;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.factory),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                if (r['demo'] == true)
                                  const Chip(label: Text('DEMO')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('₹${(r['price'] as num).toStringAsFixed(0)}/kg'),
                            Text('Total offer: ₹${total.toStringAsFixed(0)}'),
                            Text('${r['distance']} km away'),
                            Text(r['pickupAvailable'] == true
                                ? 'Pickup available'
                                : 'Pickup unavailable'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.verified, size: 18),
                                const SizedBox(width: 4),
                                Text(r['authorized'] == true
                                    ? 'Authorized / verified'
                                    : 'Not authorized'),
                                const Spacer(),
                                FilledButton(
                                  onPressed: r['authorized'] != true
                                      ? null
                                      : () => _choose(r),
                                  child: const Text('Choose'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _choose(Map<String, dynamic> recycler) async {
    final collectorId = FirebaseAuth.instance.currentUser?.uid;
    if (collectorId == null) return;

    final offers = await FirebaseFirestore.instance
        .collection('offers')
        .where('lotId', isEqualTo: widget.lotId)
        .get();

    if (!mounted) return;

    final matching = offers.docs
        .where((d) => d.data()['recyclerId'] == recycler['id'])
        .toList();

    // The collector may select only an offer that actually exists.
    if (matching.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No offer from this recycler exists yet. Wait for the Recycler side to submit an offer.',
          ),
        ),
      );
      return;
    }

    await _acceptOffer(matching.first);
  }

  Future<void> _acceptOffer(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.update(doc.reference, {'status': 'accepted'});

    final others = await FirebaseFirestore.instance
        .collection('offers')
        .where('lotId', isEqualTo: widget.lotId)
        .get();

    for (final other in others.docs) {
      if (other.id != doc.id && other.data()['status'] == 'pending') {
        batch.update(other.reference, {'status': 'rejected'});
      }
    }

    batch.update(
      FirebaseFirestore.instance.collection('lots').doc(widget.lotId),
      {'status': 'accepted'},
    );

    await batch.commit();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CollectorOffersScreen(lotId: widget.lotId),
      ),
    );
  }
}
