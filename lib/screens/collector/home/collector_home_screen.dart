import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../capture/waste_capture_screen.dart';
import '../offers/collector_offers_screen.dart';
import '../price_history/price_history_screen.dart';
import '../pricing/price_board_screen.dart';
import '../lots/my_lots_screen.dart';
import '../transactions/earnings_screen.dart';
import '../traceability/traceability_screen.dart';
import '../localization/collector_localization.dart';

class CollectorHomeScreen extends StatelessWidget {
  const CollectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'Not signed in';

    final language = CollectorLanguageScope.of(context);
    final strings = language.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: strings.language,
            icon: const Icon(Icons.language),
            onSelected: language.setLanguage,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              PopupMenuItem(
                value: 'hi',
                child: Text('हिन्दी'),
              ),
              PopupMenuItem(
                value: 'mr',
                child: Text('मराठी'),
              ),
            ],
          ),
          IconButton(
            tooltip: strings.logout,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Welcome card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    child: Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.welcome,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${uid.length > 12 ? '${uid.substring(0, 12)}…' : uid}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add E-Waste
          _ActionCard(
            icon: Icons.camera_alt,
            title: strings.addWaste,
            subtitle: strings.addWasteSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WasteCaptureScreen(),
              ),
            ),
          ),

          // Today's Prices
          _ActionCard(
            icon: Icons.currency_rupee,
            title: strings.prices,
            subtitle: strings.pricesSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PriceBoardScreen(),
              ),
            ),
          ),

          // Price History
          _ActionCard(
            icon: Icons.show_chart,
            title: strings.history,
            subtitle: strings.historySubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PriceHistoryScreen(),
              ),
            ),
          ),

          // My Lots
          _ActionCard(
            icon: Icons.local_shipping,
            title: strings.lots,
            subtitle: strings.lotsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyLotsScreen(),
              ),
            ),
          ),

          // Offers
          _ActionCard(
            icon: Icons.local_offer,
            title: strings.offers,
            subtitle: strings.offersSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectorOffersScreen(),
              ),
            ),
          ),

          // Earnings
          _ActionCard(
            icon: Icons.account_balance_wallet,
            title: strings.earnings,
            subtitle: strings.earningsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EarningsScreen(),
              ),
            ),
          ),

          // Traceability
          _ActionCard(
            icon: Icons.verified,
            title: strings.traceability,
            subtitle: strings.traceabilitySubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TraceabilityScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}