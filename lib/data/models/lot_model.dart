import 'package:cloud_firestore/cloud_firestore.dart';

class LotModel {
  final String lotId;
  final String collectorId;
  final String materialId;
  final String materialName;
  final String description;
  final double weightKg;
  final String? photoUrl;
  final String location;
  final double estimatedPrice;
  final String status;
  final DateTime createdAt;

  const LotModel({
    required this.lotId,
    required this.collectorId,
    required this.materialId,
    required this.materialName,
    required this.description,
    required this.weightKg,
    this.photoUrl,
    required this.location,
    required this.estimatedPrice,
    required this.status,
    required this.createdAt,
  });

  factory LotModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final timestamp = data['createdAt'];

    return LotModel(
      lotId: document.id,
      collectorId: data['collectorId'] as String? ?? '',
      materialId: data['materialId'] as String? ?? '',
      materialName: data['materialName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
      photoUrl: data['photoUrl'] as String?,
      location: data['location'] as String? ?? '',
      estimatedPrice:
      (data['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'open',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collectorId': collectorId,
      'materialId': materialId,
      'materialName': materialName,
      'description': description,
      'weightKg': weightKg,
      'photoUrl': photoUrl,
      'location': location,
      'estimatedPrice': estimatedPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}