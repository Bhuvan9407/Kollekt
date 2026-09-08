import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'offer_details_screen.dart';
import '../data/models/offer_model.dart';
import '../data/repositories/recycler_repository.dart';

class MyOffersScreen extends StatelessWidget {
  MyOffersScreen({super.key});

  final RecyclerRepository _repository = RecyclerRepository();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Please log in as a recycler to view your offers.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final String recyclerId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
      ),
      body: StreamBuilder<List<OfferModel>>(
        stream: _repository.watchMyOffers(recyclerId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your offers.\n\n${snapshot.error}',
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

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'My Offers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track the offers you have submitted.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ...offers.map(
                    (offer) => _buildOfferCard(context, offer),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(
      BuildContext context,
      OfferModel offer,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferDetailsScreen(
              offer: offer,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.local_offer_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Offer Submitted',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lot ID: ${offer.lotId}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(offer.status),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),
              _detailRow(
                Icons.currency_rupee,
                'Price per kg',
                '₹${offer.offeredPricePerKg.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 12),
              _detailRow(
                Icons.payments_outlined,
                'Total Offer',
                '₹${offer.totalOffer.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 12),
              _detailRow(
                Icons.local_shipping_outlined,
                'Pickup',
                offer.pickupAvailable
                    ? 'Available'
                    : 'Not available',
              ),
              const SizedBox(height: 12),
              _detailRow(
                Icons.access_time,
                'Submitted',
                _formatDate(offer.createdAt),
              ),
            ],
          ),
        ),
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
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 12),
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

  Widget _statusChip(String status) {
    String label;

    switch (status) {
      case 'pending':
        label = 'Pending';
        break;
      case 'accepted':
        label = 'Accepted';
        break;
      case 'rejected':
        label = 'Rejected';
        break;
      default:
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(label),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No offers yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Offers you submit for collection lots '
                  'will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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