class RecyclerModel {
  final String id;
  final String name;
  final String location;
  final bool authorized;
  final List<String> acceptedMaterials;
  final String phone;
  final bool pickupAvailable;

  const RecyclerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.authorized,
    required this.acceptedMaterials,
    required this.phone,
    required this.pickupAvailable,
  });

  factory RecyclerModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return RecyclerModel(
      id: id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      authorized: data['authorized'] as bool? ?? false,
      acceptedMaterials:
      List<String>.from(data['acceptedMaterials'] ?? const []),
      phone: data['phone'] as String? ?? '',
      pickupAvailable: data['pickupAvailable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'authorized': authorized,
      'acceptedMaterials': acceptedMaterials,
      'phone': phone,
      'pickupAvailable': pickupAvailable,
    };
  }
}