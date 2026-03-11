import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  AppUser? _appUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get userId => _firebaseUser?.uid ?? '';
  List<String> get wishlistHotelIds => _appUser?.wishlistHotelIds ?? const [];

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ─── Auth State Listener ──────────────────────────────────────────
  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _appUser = null;
    } else {
      await _loadAppUser(user.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // ─── Load Firestore User Profile ──────────────────────────────────
  Future<void> _loadAppUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromFirestore(doc);
      } else {
        final fallback = AppUser(
          uid: uid,
          name: _firebaseUser?.displayName ?? 'Traveler',
          email: _firebaseUser?.email ?? '',
          membershipTier: 'Silver',
          points: 0,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(uid).set(fallback.toFirestore());
        _appUser = fallback;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // ─── Sign Up with Email & Password ───────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create Firestore user document
      final newUser = AppUser(
        uid: credential.user!.uid,
        name: name,
        email: email.trim(),
        membershipTier: 'Silver',
        points: 100, // Welcome points
        createdAt: DateTime.now(),
      );
      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toFirestore());
      _appUser = newUser;

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authErrorMessage(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign In with Email & Password ───────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authErrorMessage(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Reset Password ───────────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Check the address.';
      notifyListeners();
      return false;
    }
  }

  // ─── Update Profile ───────────────────────────────────────────────
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    if (_appUser == null || _firebaseUser == null) return false;
    try {
      final updated = _appUser!.copyWith(name: name, photoUrl: photoUrl);
      await _db.collection('users').doc(userId).update(updated.toFirestore());
      if (name != null) await _firebaseUser!.updateDisplayName(name);
      _appUser = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      notifyListeners();
      return false;
    }
  }

  // ─── Wishlist (Hotels) ────────────────────────────────────────────
  Future<void> toggleWishlistHotel(String hotelId) async {
    if (_firebaseUser == null) return;
    final uid = _firebaseUser!.uid;
    final userRef = _db.collection('users').doc(uid);

    final current = List<String>.from(_appUser?.wishlistHotelIds ?? const []);
    final already = current.contains(hotelId);

    try {
      await userRef.update({
        'wishlistHotelIds': already
            ? FieldValue.arrayRemove([hotelId])
            : FieldValue.arrayUnion([hotelId]),
      });

      if (already) {
        current.remove(hotelId);
      } else {
        current.add(hotelId);
      }

      if (_appUser != null) {
        _appUser = _appUser!.copyWith(wishlistHotelIds: current);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('toggleWishlistHotel error: $e');
    }
  }

  // ─── Error Messages ───────────────────────────────────────────────
  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
