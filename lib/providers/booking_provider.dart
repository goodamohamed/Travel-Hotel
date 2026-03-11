import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;

  List<Booking> get upcomingBookings => _bookings
      .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending)
      .toList()
    ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

  List<Booking> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  // ─── Fetch User Bookings ──────────────────────────────────────────
  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _bookings = snap.docs.map((d) => Booking.fromFirestore(d)).toList();
    } catch (e) {
      _error = 'Failed to load bookings.';
      debugPrint('BookingProvider error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Real-time Bookings Stream ────────────────────────────────────
  Stream<List<Booking>> bookingsStream(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  // ─── Create Booking ───────────────────────────────────────────────
  Future<Booking?> createBooking({
    required String userId,
    required String hotelId,
    required String hotelName,
    required String hotelLocation,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int rooms,
    required double totalPrice,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final confirmationCode = 'TM-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final now = DateTime.now();
      final docRef = _db.collection('bookings').doc();
      final booking = Booking(
        id: docRef.id,
        userId: userId,
        hotelId: hotelId,
        hotelName: hotelName,
        hotelLocation: hotelLocation,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        rooms: rooms,
        totalPrice: totalPrice,
        status: BookingStatus.confirmed,
        confirmationCode: confirmationCode,
        createdAt: now,
      );

      final batch = _db.batch();
      batch.set(docRef, booking.toFirestore());

      // Update user points
      final userRef = _db.collection('users').doc(userId);
      batch.set(
        userRef,
        {'points': FieldValue.increment((totalPrice * 0.1).toInt())},
        SetOptions(merge: true),
      );

      await batch.commit();

      _bookings.insert(0, booking);
      _isCreating = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = 'Booking failed. Please try again.';
      _isCreating = false;
      debugPrint('Create booking error: $e');
      notifyListeners();
      return null;
    }
  }

  // ─── Cancel Booking ───────────────────────────────────────────────
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
      });
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          hotelId: _bookings[index].hotelId,
          hotelName: _bookings[index].hotelName,
          hotelLocation: _bookings[index].hotelLocation,
          checkIn: _bookings[index].checkIn,
          checkOut: _bookings[index].checkOut,
          guests: _bookings[index].guests,
          rooms: _bookings[index].rooms,
          totalPrice: _bookings[index].totalPrice,
          status: BookingStatus.cancelled,
          confirmationCode: _bookings[index].confirmationCode,
          createdAt: _bookings[index].createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to cancel booking.';
      notifyListeners();
      return false;
    }
  }

  // ─── Complete Booking ─────────────────────────────────────────────
  Future<bool> completeBooking(String bookingId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.completed.name,
      });
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          hotelId: _bookings[index].hotelId,
          hotelName: _bookings[index].hotelName,
          hotelLocation: _bookings[index].hotelLocation,
          checkIn: _bookings[index].checkIn,
          checkOut: _bookings[index].checkOut,
          guests: _bookings[index].guests,
          rooms: _bookings[index].rooms,
          totalPrice: _bookings[index].totalPrice,
          status: BookingStatus.completed,
          confirmationCode: _bookings[index].confirmationCode,
          createdAt: _bookings[index].createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to complete booking.';
      notifyListeners();
      return false;
    }
  }
}
