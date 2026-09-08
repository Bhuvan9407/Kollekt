import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lot_model.dart';
import '../models/offer_model.dart';
import '../models/recycler_model.dart';

class RecyclerRepository {
  final FirebaseFirestore _firestore;

  RecyclerRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get recycler profile using Firebase Auth UID.
  Future<RecyclerModel?> getRecycler(String recyclerId) async {
    final document =
    await _firestore.collection('recyclers').doc(recyclerId).get();

    if (!document.exists) {
      return null;
    }

    return RecyclerModel.fromMap(
      document.id,
      document.data() ?? {},
    );
  }

  // Get open lots that are waiting for recycler offers.
  Stream<List<LotModel>> watchOpenLots() {
    return _firestore
        .collection('lots')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs
              .map(LotModel.fromFirestore)
              .toList(),
    );
  }

  // Create an offer for a collector's lot.
  Future<String> createOffer({
    required String lotId,
    required String recyclerId,
    required double offeredPricePerKg,
    required double totalOffer,
    required bool pickupAvailable,
  }) async {
    final offerReference = await _firestore.collection('offers').add({
      'lotId': lotId,
      'recyclerId': recyclerId,
      'offeredPricePerKg': offeredPricePerKg,
      'totalOffer': totalOffer,
      'pickupAvailable': pickupAvailable,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update the lot so collectors know an offer has been received.
    await _firestore.collection('lots').doc(lotId).update({
      'status': 'offer_received',
    });

    return offerReference.id;
  }

  Stream<List<OfferModel>> watchMyOffers(String recyclerId) {
    return _firestore
        .collection('offers')
        .where('recyclerId', isEqualTo: recyclerId)
        .snapshots()
        .map((snapshot) {
      final offers = snapshot.docs
          .map(OfferModel.fromFirestore)
          .toList();

      offers.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return offers;
    });
  }
}