import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String lotId;
  final String collectorId;
  final String recyclerId;
  final String materialId;
  final double weightKg;
  final double quotedPrice;
  final double finalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime completedAt;

  const TransactionModel({
    required this.transactionId,
    required this.lotId,
    required this.collectorId,
    required this.recyclerId,
    required this.materialId,
    required this.weightKg,
    required this.quotedPrice,
    required this.finalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.completedAt,
  });

  factory TransactionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};
    final timestamp = data['completedAt'];

    return TransactionModel(
      transactionId: document.id,
      lotId: data['lotId'] as String? ?? '',
      collectorId: data['collectorId'] as String? ?? '',
      recyclerId: data['recyclerId'] as String? ?? '',
      materialId: data['materialId'] as String? ?? '',
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
      quotedPrice: (data['quotedPrice'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (data['finalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      completedAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lotId': lotId,
      'collectorId': collectorId,
      'recyclerId': recyclerId,
      'materialId': materialId,
      'weightKg': weightKg,
      'quotedPrice': quotedPrice,
      'finalPrice': finalPrice,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}