import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, List<Review>> _reviewsByHotel = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Review> getReviews(String hotelId) => _reviewsByHotel[hotelId] ?? [];

  // ─── Fetch Reviews for Hotel ──────────────────────────────────────
  Future<void> fetchReviews(String hotelId) async {
    if (_reviewsByHotel.containsKey(hotelId)) return; // cached
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection('reviews')
          .where('hotelId', isEqualTo: hotelId)
          .orderBy('date', descending: true)
          .limit(20)
          .get();
      _reviewsByHotel[hotelId] = snap.docs.map((d) => Review.fromFirestore(d)).toList();
    } catch (e) {
      _error = 'Failed to load reviews.';
      debugPrint('ReviewProvider error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Real-time Reviews Stream ─────────────────────────────────────
  Stream<List<Review>> reviewsStream(String hotelId) {
    return _db
        .collection('reviews')
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Review.fromFirestore(d)).toList());
  }

  // ─── Add Review ───────────────────────────────────────────────────
  Future<bool> addReview({
    required String hotelId,
    required String userId,
    required String userName,
    required String userAvatar,
    required double rating,
    required String comment,
  }) async {
    try {
      final review = Review(
        id: '',
        hotelId: hotelId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
      );

      final docRef = await _db.collection('reviews').add(review.toFirestore());

      // Update hotel average rating
      await _updateHotelRating(hotelId, rating);

      // Add to local cache
      final newReview = Review(
        id: docRef.id,
        hotelId: hotelId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
      );
      _reviewsByHotel[hotelId]?.insert(0, newReview);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit review.';
      notifyListeners();
      return false;
    }
  }

  // ─── Update Hotel Rating Average ──────────────────────────────────
  Future<void> _updateHotelRating(String hotelId, double newRating) async {
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final hotelRef = FirebaseFirestore.instance.collection('hotels').doc(hotelId);
        final hotelSnap = await tx.get(hotelRef);
        if (!hotelSnap.exists) return;

        final data = hotelSnap.data()!;
        final currentCount = (data['reviewCount'] ?? 0) as int;
        final currentRating = (data['rating'] ?? 0).toDouble();
        final newCount = currentCount + 1;
        final updatedRating = ((currentRating * currentCount) + newRating) / newCount;

        tx.update(hotelRef, {
          'rating': double.parse(updatedRating.toStringAsFixed(1)),
          'reviewCount': newCount,
        });
      });
    } catch (e) {
      debugPrint('Error updating hotel rating: $e');
    }
  }

  void clearCache(String hotelId) {
    _reviewsByHotel.remove(hotelId);
  }
}
