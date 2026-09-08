import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/offer_model.dart';

class OfferDetailsScreen extends StatefulWidget {
  final OfferModel offer;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
  });

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  bool _processing = false;

  Future<void> _completeHandover() async {
    final paymentMethod = await _showPaymentDialog();

    if (paymentMethod == null || !mounted) {
      return;
    }

    final recycler = FirebaseAuth.instance.currentUser;

    if (recycler == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in as a recycler first.'),
        ),
      );
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      final db = FirebaseFirestore.instance;

      // Get the original lot so we can retrieve the real Collector UID.
      final lotReference = db.collection('lots').doc(widget.offer.lotId);
      final lotSnapshot = await lotReference.get();

      if (!lotSnapshot.exists) {
        throw Exception('The collection lot no longer exists.');
      }

      final lotData = lotSnapshot.data();

      if (lotData == null) {
        throw Exception('Could not read the collection lot.');
      }

      final collectorId = lotData['collectorId'] as String? ?? '';
      final materialId = lotData['materialId'] as String? ?? '';
      final weightKg = (lotData['weightKg'] as num?)?.toDouble() ?? 0;

      if (collectorId.isEmpty) {
        throw Exception('Collector information is missing from the lot.');
      }

      if (materialId.isEmpty) {
        throw Exception('Material information is missing from the lot.');
      }

      if (weightKg <= 0) {
        throw Exception('Invalid lot weight.');
      }

      // Generate Firebase document references.
      final transactionReference =
      db.collection('transactions').doc();

      final traceabilityReference =
      db.collection('traceability').doc();

      // Demo handover reference.
      final handoverReference =
          'HR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final batch = db.batch();

      // 1. Create transaction.
      batch.set(transactionReference, {
        'lotId': widget.offer.lotId,
        'collectorId': collectorId,
        'recyclerId': recycler.uid,
        'materialId': materialId,
        'weightKg': weightKg,
        'quotedPrice': widget.offer.totalOffer,
        'finalPrice': widget.offer.totalOffer,
        'paymentMethod': paymentMethod,
        'paymentStatus': 'paid',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // 2. Create traceability record.
      batch.set(traceabilityReference, {
        'lotId': widget.offer.lotId,
        'collectorId': collectorId,
        'recyclerId': recycler.uid,
        'handoverReference': handoverReference,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Mark lot as completed.
      batch.update(lotReference, {
        'status': 'completed',
      });

      await batch.commit();

      if (!mounted) {
        return;
      }

      await _showSuccessDialog(
        handoverReference,
        paymentMethod,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Handover failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<String?> _showPaymentDialog() async {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: const Text(
            'Select the payment method used for this handover.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'cash');
              },
              child: const Text('Cash'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'digital');
              },
              child: const Text('Digital'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(
      String handoverReference,
      String paymentMethod,
      ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 10),
              Expanded(
                child: Text('Handover Completed'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The transaction has been recorded successfully.',
              ),
              const SizedBox(height: 20),
              Text(
                'Handover Reference',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                handoverReference,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                paymentMethod == 'cash' ? 'Cash • Paid' : 'Digital • Paid',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccepted = widget.offer.status == 'accepted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(
                      Icons.local_offer_outlined,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recycler Offer',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lot ID: ${widget.offer.lotId}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
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
                children: [
                  _detailRow(
                    Icons.currency_rupee,
                    'Price per kg',
                    '₹${widget.offer.offeredPricePerKg.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 28),
                  _detailRow(
                    Icons.payments_outlined,
                    'Total Offer',
                    '₹${widget.offer.totalOffer.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 28),
                  _detailRow(
                    Icons.local_shipping_outlined,
                    'Pickup',
                    widget.offer.pickupAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  const Divider(height: 28),
                  _detailRow(
                    Icons.info_outline,
                    'Status',
                    widget.offer.status.toUpperCase(),
                  ),
                  const Divider(height: 28),
                  _detailRow(
                    Icons.access_time,
                    'Submitted',
                    _formatDate(widget.offer.createdAt),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (isAccepted) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Offer Accepted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The collector has accepted this offer. '
                          'You can now proceed with the handover.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _processing ? null : _completeHandover,
                icon: _processing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.handshake_outlined,
                ),
                label: Text(
                  _processing
                      ? 'Completing Handover...'
                      : 'Complete Handover',
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.hourglass_empty,
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.offer.status == 'pending'
                          ? 'Waiting for Collector'
                          : 'Offer ${widget.offer.status}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.offer.status == 'pending'
                          ? 'The collector has not accepted this offer yet.'
                          : 'This offer is no longer active.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}