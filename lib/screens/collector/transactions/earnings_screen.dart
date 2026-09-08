import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/collector_localization.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final strings = CollectorLanguageScope.of(context).strings;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.earnings)),
        body: const Center(
          child: Text('Please log in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.earnings),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('collectorId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load transactions:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          double paidTotal = 0;
          double pendingTotal = 0;
          int paidCount = 0;
          int pendingCount = 0;

          for (final doc in docs) {
            final data = doc.data();

            final amount =
                (data['finalPrice'] as num?)?.toDouble() ?? 0;

            final paymentStatus =
            (data['paymentStatus'] ??
                data['transactionStatus'] ??
                data['status'] ??
                '')
                .toString()
                .toLowerCase();

            if (paymentStatus == 'paid' ||
                paymentStatus == 'completed') {
              paidTotal += amount;
              paidCount++;
            } else {
              pendingTotal += amount;
              pendingCount++;
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 400),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _TotalEarningsCard(
                  total: paidTotal,
                  label: strings.totalPaid,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.check_circle,
                        title: strings.paid,
                        value: '$paidCount',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.schedule,
                        title: strings.pending,
                        value: '$pendingCount',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.account_balance_wallet),
                    ),
                    title: const Text('Pending Value'),
                    trailing: Text(
                      '₹${pendingTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  strings.transactions,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                if (docs.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.noTransactions,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                ...docs.map(
                      (doc) => _TransactionCard(
                    data: doc.data(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  final double total;
  final String label;

  const _TotalEarningsCard({
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Total money received',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final material = data['materialName'] ??
        data['materialCategory'] ??
        'E-Waste';

    final amount =
        (data['finalPrice'] as num?)?.toDouble() ?? 0;

    final status = (data['paymentStatus'] ??
        data['transactionStatus'] ??
        data['status'] ??
        'unknown')
        .toString();

    final lotId = data['lotId']?.toString();

    Timestamp? timestamp;
    if (data['createdAt'] is Timestamp) {
      timestamp = data['createdAt'] as Timestamp;
    }

    final dateText = timestamp == null
        ? ''
        : _formatDate(timestamp.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: const CircleAvatar(
          child: Icon(Icons.recycling),
        ),
        title: Text(
          material.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: $status'),
            if (lotId != null) Text('Lot: $lotId'),
            if (dateText.isNotEmpty) Text(dateText),
          ],
        ),
        trailing: Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}