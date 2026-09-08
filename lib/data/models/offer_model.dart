import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String offerId;
  final String lotId;
  final String recyclerId;
  final double offeredPricePerKg;
  final double totalOffer;
  final bool pickupAvailable;
  final String status;
  final DateTime createdAt;

  const OfferModel({
    required this.offerId,
    required this.lotId,
    required this.recyclerId,
    required this.offeredPricePerKg,
    required this.totalOffer,
    required this.pickupAvailable,
    required this.status,
    required this.createdAt,
  });

  factory OfferModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};
    final timestamp = data['createdAt'];

    return OfferModel(
      offerId: document.id,
      lotId: data['lotId'] as String? ?? '',
      recyclerId: data['recyclerId'] as String? ?? '',
      offeredPricePerKg:
      (data['offeredPricePerKg'] as num?)?.toDouble() ?? 0.0,
      totalOffer:
      (data['totalOffer'] as num?)?.toDouble() ?? 0.0,
      pickupAvailable:
      data['pickupAvailable'] as bool? ?? false,
      status: data['status'] as String? ?? 'pending',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lotId': lotId,
      'recyclerId': recyclerId,
      'offeredPricePerKg': offeredPricePerKg,
      'totalOffer': totalOffer,
      'pickupAvailable': pickupAvailable,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
