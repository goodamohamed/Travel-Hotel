class FirestorePaths {
  static String userDoc(String uid) => 'users/$uid';
  static String userBookings(String uid) => 'users/$uid/bookings';
  static String userWishlist(String uid) => 'users/$uid/wishlist';
  static String hotelReviews(String hotelId) => 'hotels/$hotelId/reviews';
}

