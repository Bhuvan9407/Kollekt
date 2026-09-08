class DemoRecycler {
  final String id;
  final String name;
  final String location;
  final bool authorized;
  final List<String> acceptedMaterials;
  final double pricePerKg;
  final bool pickupAvailable;
  final double distanceKm;

  const DemoRecycler({
    required this.id,
    required this.name,
    required this.location,
    required this.authorized,
    required this.acceptedMaterials,
    required this.pricePerKg,
    required this.pickupAvailable,
    required this.distanceKm,
  });
}

const demoRecyclers = <DemoRecycler>[
  DemoRecycler(
    id: 'DEMO_REC_001',
    name: 'GreenCycle Demo Recycling',
    location: 'Pune',
    authorized: true,
    acceptedMaterials: ['pcb', 'cable', 'lcd'],
    pricePerKg: 440,
    pickupAvailable: true,
    distanceKm: 8,
  ),
  DemoRecycler(
    id: 'DEMO_REC_002',
    name: 'EcoRecover Demo Facility',
    location: 'Pune',
    authorized: true,
    acceptedMaterials: ['pcb', 'battery', 'motor'],
    pricePerKg: 425,
    pickupAvailable: false,
    distanceKm: 14,
  ),
  DemoRecycler(
    id: 'DEMO_REC_003',
    name: 'RecycleHub Demo',
    location: 'Pune',
    authorized: true,
    acceptedMaterials: ['pcb', 'cable', 'battery'],
    pricePerKg: 410,
    pickupAvailable: true,
    distanceKm: 21,
  ),
];
