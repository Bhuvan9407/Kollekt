import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../pricing/demo_price_data.dart';

class PriceHistoryScreen extends StatefulWidget {
  const PriceHistoryScreen({super.key});

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  String _materialId = 'pcb';

  @override
  Widget build(BuildContext context) {
    final points = DemoPriceData.history(_materialId);
    final rates = DemoPriceData.currentRates[_materialId]!;
    final current = rates['current']!;

    return Scaffold(
      appBar: AppBar(title: const Text('Price History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
          initialValue: _materialId,
            decoration: const InputDecoration(
              labelText: 'Material',
              border: OutlineInputBorder(),
            ),
            items: DemoPriceData.names.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _materialId = value);
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: Text('Current: ₹${current.toStringAsFixed(0)}/kg'),
              subtitle: const Text('Prototype seeded historical data'),
              trailing: const Icon(Icons.trending_up),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: points.map((p) => p.price).reduce((a, b) => a < b ? a : b) - 10,
                maxY: points.map((p) => p.price).reduce((a, b) => a > b ? a : b) + 10,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (i < 0 || i >= points.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${points[i].date.day}/${points[i].date.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 42),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      points.length,
                      (i) => FlSpot(i.toDouble(), points[i].price),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Production behavior: recycler quotes and completed transactions '
            'will be stored with date/location and become future price-history data.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
