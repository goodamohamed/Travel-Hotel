import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class HotelProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  double _maxPrice = 1000;
  double _minRating = 0;
  int _selectedStars = 0;
  String _sortBy = 'rating';
  String _searchQuery = '';
  HotelCategory? _selectedCategory;

  List<Hotel> get hotels => _hotels;
  List<Hotel> get filteredHotels => _filteredHotels;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get maxPrice => _maxPrice;
  double get minRating => _minRating;
  int get selectedStars => _selectedStars;
  String get sortBy => _sortBy;

  // ─── Fetch Hotels from Firestore ──────────────────────────────────
  Future<void> fetchHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _db.collection('hotels').get();
      _hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load hotels. Check your connection.';
      debugPrint('HotelProvider error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //Real-time Stream
  Stream<List<Hotel>> hotelsStream() {
    return _db.collection('hotels').snapshots().map(
      (snap) => snap.docs.map((d) => Hotel.fromFirestore(d)).toList(),
    );
  }

  //Get Single Hotel 
  Future<Hotel?> getHotelById(String id) async {
    try {
      final doc = await _db.collection('hotels').doc(id).get();
      if (doc.exists) return Hotel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching hotel $id: $e');
    }
    return null;
  }

  // ─── Toggle Wishlist ──────────────────────────────────────────────
  Future<void> toggleWishlist(String hotelId, String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final index = _hotels.indexWhere((h) => h.id == hotelId);
    if (index == -1) return;

    final isWishlisted = _hotels[index].isWishlisted;

    try {
      if (isWishlisted) {
        await userRef.update({
          'wishlistHotelIds': FieldValue.arrayRemove([hotelId]),
        });
      } else {
        await userRef.update({
          'wishlistHotelIds': FieldValue.arrayUnion([hotelId]),
        });
      }
      _hotels[index].isWishlisted = !isWishlisted;
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
    }
  }

  // ─── Sync Wishlist from User Profile ─────────────────────────────
  void syncWishlist(List<String> wishlistIds) {
    for (final hotel in _hotels) {
      hotel.isWishlisted = wishlistIds.contains(hotel.id);
    }
    notifyListeners();
  }

  // ─── Filter & Sort ────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    _applyFilters();
  }

  void setMinRating(double rating) {
    _minRating = rating;
    _applyFilters();
  }

  void setStars(int stars) {
    _selectedStars = stars;
    _applyFilters();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
  }

  void setCategory(HotelCategory? cat) {
    _selectedCategory = cat;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredHotels = _hotels.where((h) {
      final matchSearch = _searchQuery.isEmpty ||
          h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.country.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchPrice = h.pricePerNight <= _maxPrice;
      final matchRating = h.rating >= _minRating;
      final matchStars = _selectedStars == 0 || h.stars == _selectedStars;
      final matchCat = _selectedCategory == null || h.category == _selectedCategory;
      return matchSearch && matchPrice && matchRating && matchStars && matchCat;
    }).toList();

    _filteredHotels.sort((a, b) {
      switch (_sortBy) {
        case 'price_asc': return a.pricePerNight.compareTo(b.pricePerNight);
        case 'price_desc': return b.pricePerNight.compareTo(a.pricePerNight);
        case 'rating': return b.rating.compareTo(a.rating);
        default: return 0;
      }
    });

    notifyListeners();
  }

  List<Hotel> get wishlistedHotels => _hotels.where((h) => h.isWishlisted).toList();
}
