class DemoPricePoint {
  final DateTime date;
  final double price;

  const DemoPricePoint(this.date, this.price);
}

class DemoPriceData {
  static const currentRates = <String, Map<String, double>>{
    'pcb': {'min': 400, 'max': 450, 'current': 425},
    'cable': {'min': 520, 'max': 580, 'current': 550},
    'battery': {'min': 90, 'max': 130, 'current': 110},
    'lcd': {'min': 80, 'max': 110, 'current': 95},
    'motor': {'min': 120, 'max': 160, 'current': 145},
    'crt': {'min': 35, 'max': 60, 'current': 48},
    'magnet': {'min': 180, 'max': 240, 'current': 210},
    'plastic': {'min': 25, 'max': 40, 'current': 32},
  };

  static const names = <String, String>{
    'pcb': 'PCB',
    'cable': 'Cable',
    'battery': 'Battery',
    'lcd': 'LCD Panel',
    'motor': 'Motor',
    'crt': 'CRT',
    'magnet': 'Magnet Assembly',
    'plastic': 'Mixed Plastic',
  };

  static List<DemoPricePoint> history(String materialId) {
    final rates = currentRates[materialId] ?? currentRates['pcb']!;
    final current = rates['current']!;
    final values = [
      current - 25,
      current - 15,
      current - 5,
      current - 10,
      current + 5,
      current,
    ];

    final now = DateTime.now();
    return List.generate(
      values.length,
      (i) => DemoPricePoint(
        DateTime(now.year, now.month, now.day - (values.length - 1 - i) * 7),
        values[i],
      ),
    );
  }
}
