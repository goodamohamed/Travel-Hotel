import 'dart:math';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'firestore_paths.dart';

class AppState extends ChangeNotifier {
  final List<Hotel> hotels = <Hotel>[];
  final List<Flight> flights = <Flight>[];
  final List<TravelPackage> packages = <TravelPackage>[];
  final List<Booking> bookings = <Booking>[];
  final Set<String> wishlistHotelIds = <String>{};
  bool geniusSeen = false;
  User? currentUser;
  bool firebaseReady = false;
  bool isLoadingUserData = false;

  AppState() {
    _seedData();
  }

  void toggleWishlistHotel(String hotelId) {
    if (wishlistHotelIds.contains(hotelId)) {
      wishlistHotelIds.remove(hotelId);
    } else {
      wishlistHotelIds.add(hotelId);
    }
    _persistWishlistIfNeeded();
    notifyListeners();
  }

  bool isWishlisted(String hotelId) => wishlistHotelIds.contains(hotelId);

  void addBookingFromHotel(Hotel hotel) {
    final booking = Booking(
      id: 'b_${DateTime.now().microsecondsSinceEpoch}',
      kind: BookingKind.hotel,
      title: hotel.name,
      price: hotel.pricePerNight,
      date: DateTime.now(),
    );
    bookings.add(booking);
    _persistBookingIfNeeded(booking);
    notifyListeners();
  }

  void markGeniusSeen() {
    if (!geniusSeen) {
      geniusSeen = true;
      notifyListeners();
    }
  }

  void signIn({required String email, required String password}) {
    if (firebaseReady) {
      _signInFirebase(email, password);
    } else {
      if (email.isEmpty || password.isEmpty) return;
      currentUser = User(name: email.split('@').first, email: email);
      notifyListeners();
    }
  }

  void register({required String name, required String email, required String password}) {
    if (firebaseReady) {
      _registerFirebase(name, email, password);
    } else {
      if (name.isEmpty || email.isEmpty || password.isEmpty) return;
      currentUser = User(name: name, email: email);
      notifyListeners();
    }
  }

  void signOut() {
    if (firebaseReady) {
      fb.FirebaseAuth.instance.signOut();
    } else {
      currentUser = null;
      notifyListeners();
    }
  }

  void resetPassword(String email) {
    if (firebaseReady) {
      fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
    notifyListeners();
  }

  void setFirebaseReady(bool ready) {
    firebaseReady = ready;
    if (ready) {
      fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) {
        if (fbUser != null) {
          currentUser = User(
            name: fbUser.email?.split('@').first ?? 'User',
            email: fbUser.email ?? '',
          );
          _loadUserData(fbUser);
        } else {
          currentUser = null;
          bookings.clear();
          wishlistHotelIds.clear();
        }
        notifyListeners();
      });
    }
  }

  Future<void> _signInFirebase(String email, String password) async {
    await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> _registerFirebase(String name, String email, String password) async {
    final cred = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
  }

  void addBookingFromFlight(Flight flight) {
    final booking = Booking(
      id: 'b_${DateTime.now().microsecondsSinceEpoch}',
      kind: BookingKind.flight,
      title: '${flight.from} → ${flight.to}',
      price: flight.price,
      date: flight.departAt,
    );
    bookings.add(booking);
    _persistBookingIfNeeded(booking);
    notifyListeners();
  }

  void addBookingFromPackage(TravelPackage p) {
    final booking = Booking(
      id: 'b_${DateTime.now().microsecondsSinceEpoch}',
      kind: BookingKind.travelPackage,
      title: p.title,
      price: p.price,
      date: DateTime.now(),
    );
    bookings.add(booking);
    _persistBookingIfNeeded(booking);
    notifyListeners();
  }

  void addReview(String hotelId, Review review) {
    final idx = hotels.indexWhere((h) => h.id == hotelId);
    if (idx != -1) {
      hotels[idx].reviews.add(review);
      notifyListeners();
    }
  }

  Future<void> _loadUserData(fb.User fbUser) async {
    isLoadingUserData = true;
    notifyListeners();
    final db = fs.FirebaseFirestore.instance;
    final uid = fbUser.uid;
    try {
      final userDoc = await db.doc(FirestorePaths.userDoc(uid)).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final wishlist = (data['wishlistHotelIds'] as List<dynamic>?) ?? const [];
        wishlistHotelIds
          ..clear()
          ..addAll(wishlist.cast<String>());
      }

      final bookingsSnap = await db
          .collection(FirestorePaths.userBookings(uid))
          .orderBy('date', descending: true)
          .get();
      bookings
        ..clear()
        ..addAll(bookingsSnap.docs.map((d) {
          final data = d.data();
          final kindStr = data['kind'] as String? ?? 'hotel';
          final kind = switch (kindStr) {
            'flight' => BookingKind.flight,
            'package' => BookingKind.travelPackage,
            _ => BookingKind.hotel,
          };
          return Booking(
            id: d.id,
            kind: kind,
            title: data['title'] as String? ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0,
            date: (data['date'] as fs.Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }));
    } catch (_) {
      // ignore load errors for now
    } finally {
      isLoadingUserData = false;
      notifyListeners();
    }
  }

  void _persistBookingIfNeeded(Booking booking) {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (!firebaseReady || fbUser == null) return;
    final db = fs.FirebaseFirestore.instance;
    db.collection(FirestorePaths.userBookings(fbUser.uid)).doc(booking.id).set({
      'kind': switch (booking.kind) {
        BookingKind.flight => 'flight',
        BookingKind.travelPackage => 'package',
        BookingKind.hotel => 'hotel',
      },
      'title': booking.title,
      'price': booking.price,
      'date': booking.date,
    });
  }

  void _persistWishlistIfNeeded() {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (!firebaseReady || fbUser == null) return;
    final db = fs.FirebaseFirestore.instance;
    db.doc(FirestorePaths.userDoc(fbUser.uid)).set(
      {
        'wishlistHotelIds': wishlistHotelIds.toList(),
        'email': fbUser.email,
      },
      fs.SetOptions(merge: true),
    );
  }

  void _seedData() {
    final random = Random(42);
    for (int i = 1; i <= 12; i++) {
      hotels.add(
        Hotel(
          id: 'h$i',
          name: 'Hotel $i',
          location: ['Cairo', 'Dubai', 'Istanbul', 'Paris', 'London'][i % 5],
          imageUrl: 'assets/images/hotels/h$i.jpg',
          pricePerNight: 40 + random.nextInt(200) + random.nextDouble(),
          rating: 3 + random.nextDouble() * 2,
          reviews: <Review>[
            Review(
              user: 'User ${i}A',
              comment: 'Nice stay',
              rating: 3 + random.nextDouble() * 2,
              date: DateTime.now().subtract(Duration(days: random.nextInt(100))),
            ),
          ],
        ),
      );
    }

    for (int i = 1; i <= 8; i++) {
      flights.add(
        Flight(
          id: 'f$i',
          from: ['CAI', 'DXB', 'IST', 'CDG'][i % 4],
          to: ['DXB', 'IST', 'CDG', 'LHR'][i % 4],
          departAt: DateTime.now().add(Duration(days: i)),
          price: 120 + random.nextInt(500) + random.nextDouble(),
          rating: 3 + random.nextDouble() * 2,
        ),
      );
    }

    for (int i = 1; i <= 6; i++) {
      packages.add(
        TravelPackage(
          id: 'p$i',
          title: 'Package $i',
          description: 'City tours and activities',
          days: 3 + i,
          price: 200 + random.nextInt(800) + random.nextDouble(),
          rating: 3 + random.nextDouble() * 2,
          imageUrl: 'assets/images/packages/p$i.jpg',
        ),
      );
    }
  }
}
