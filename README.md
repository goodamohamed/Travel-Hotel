# ✈️ TravelMate – Flutter Travel & Hotel Booking App

A full-featured, production-ready Flutter travel booking app similar to Booking.com.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code with Flutter plugin

### Install & Run

```bash
# 1. Navigate to project folder
cd travelmate

# 2. Install dependencies
flutter pub get

# 3. Run on emulator or device
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, typography, gradients
├── models/
│   └── models.dart              # Hotel, Flight, Booking, Review models
├── data/
│   └── mock_data.dart           # Sample data (replace with real API)
├── widgets/
│   └── widgets.dart             # Reusable components
└── screens/
    ├── splash_screen.dart       # Animated launch screen
    ├── main_navigation.dart     # Bottom nav bar
    ├── home_screen.dart         # Home with destinations & featured hotels
    ├── hotel_detail_screen.dart # Hotel gallery, reviews, map, booking CTA
    ├── search_screen.dart       # Hotel & flight search with filters
    ├── booking_screen.dart      # Date picker, guests, price summary
    ├── bookings_screen.dart     # Booking history (upcoming/completed)
    ├── wishlist_screen.dart     # Saved hotels & packages
    └── profile_screen.dart      # User profile & settings
```

---

## ✅ Features Implemented

| Feature | Status |
|---|---|
| Animated Splash Screen | ✅ |
| Home with Hero Banner | ✅ |
| Popular Destinations Carousel | ✅ |
| Featured Hotels List | ✅ |
| Category Filter (Hotel/Resort/Villa…) | ✅ |
| Travel Packages Section | ✅ |
| Hotel Search with Live Filters | ✅ |
| Filter by Price / Rating / Stars | ✅ |
| Sort by Rating / Price | ✅ |
| Flight Search Tab | ✅ |
| Hotel Detail with Image Gallery | ✅ |
| SmoothPageIndicator for Gallery | ✅ |
| Amenities Display | ✅ |
| Map Placeholder | ✅ |
| Guest Reviews | ✅ |
| Booking Flow (Dates + Guests) | ✅ |
| Date Picker | ✅ |
| Price Summary with Taxes | ✅ |
| Booking Confirmation Dialog | ✅ |
| Bookings History (3 tabs) | ✅ |
| Wishlist (Hotels + Packages) | ✅ |
| Profile Screen with Settings | ✅ |
| Dark Mode Toggle | ✅ |
| Bottom Navigation | ✅ |

---

## 📦 Dependencies

```yaml
google_fonts: ^6.1.0              # Playfair Display + Poppins
flutter_rating_bar: ^4.0.1        # Star ratings
cached_network_image: ^3.3.0      # Image loading + caching
smooth_page_indicator: ^1.1.0     # Gallery dots
flutter_staggered_animations: ^1.1.1
shimmer: ^3.0.0                   # Loading skeletons
lottie: ^3.0.0                    # Animations
```

---

## 🔌 Connecting to a Real Backend

Replace `lib/data/mock_data.dart` with API calls:

```dart
// Example: Replace MockData.hotels with API call
Future<List<Hotel>> fetchHotels({String? query, double? maxPrice}) async {
  final response = await http.get(
    Uri.parse('https://your-api.com/hotels?q=$query&maxPrice=$maxPrice'),
  );
  return (jsonDecode(response.body) as List)
      .map((j) => Hotel.fromJson(j))
      .toList();
}
```

### Recommended integrations:
- **Google Maps** → Replace map placeholder with `google_maps_flutter`
- **Firebase Auth** → User authentication
- **Stripe** → Payment processing
- **Firebase Firestore** → Real bookings & reviews
- **Booking.com / Amadeus API** → Real hotel & flight data

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#1A73E8` |
| Accent | `#FF6B35` |
| Background | `#F8F9FE` |
| Font Display | Playfair Display |
| Font Body | Poppins |

---

## 📱 Screens Preview

1. **Splash** → Animated logo + tagline
2. **Home** → Hero banner, search, destinations, hotels, packages  
3. **Search** → Hotels tab (live filter) + Flights tab
4. **Hotel Detail** → Gallery, info, amenities, map, reviews, Book Now CTA
5. **Booking** → Date picker, guest counter, price breakdown, confirm
6. **My Bookings** → Tabs: Upcoming / Completed / Cancelled
7. **Wishlist** → Saved hotels and packages
8. **Profile** → Stats, settings, preferences
