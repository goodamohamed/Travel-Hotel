// ═══════════════════════════════════════════════════════════════════
//  firestore_seeder.dart
//  Run this ONCE to populate your Firestore with initial data.
//  Call FirestoreSeeder.seedAll() from a temporary admin screen,
//  or run it from a Cloud Function.
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    await Future.wait([
      _seedHotels(),
      _seedFlights(),
      _seedPackages(),
    ]);
  }

  // ── Hotels ──────────────────────────────────────────────────────
  static Future<void> _seedHotels() async {
    final batch = _db.batch();
    final hotels = [
      {
        'name': 'The Grand Nile Palace', 'location': 'Cairo', 'country': 'Egypt',
        'description': 'Overlooking the majestic Nile River, this iconic 5-star hotel offers breathtaking panoramic views and world-class service.',
        'pricePerNight': 180, 'rating': 4.8, 'reviewCount': 2341, 'stars': 5,
        'amenities': ['Free WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant', 'Room Service'],
        'images': ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800'],
        'lat': 30.04, 'lng': 31.23, 'tag': 'Best Value', 'category': 'hotel',
      },
      {
        'name': 'Azure Santorini Resort', 'location': 'Santorini', 'country': 'Greece',
        'description': 'Perched dramatically on volcanic cliffs above the sparkling Aegean Sea, this iconic resort offers cave-style suites with private infinity pools.',
        'pricePerNight': 420, 'rating': 4.9, 'reviewCount': 1876, 'stars': 5,
        'amenities': ['Free WiFi', 'Private Pool', 'Sea View', 'Bar', 'Spa'],
        'images': ['https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800', 'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=800'],
        'lat': 36.39, 'lng': 25.46, 'tag': 'Top Rated', 'category': 'resort',
      },
      {
        'name': 'Urban Loft Dubai', 'location': 'Dubai', 'country': 'UAE',
        'description': 'Sleek minimalist design meets ultra-modern luxury in the heart of Downtown Dubai.',
        'pricePerNight': 290, 'rating': 4.6, 'reviewCount': 987, 'stars': 4,
        'amenities': ['Free WiFi', 'Gym', 'Rooftop Bar', 'Restaurant'],
        'images': ['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800'],
        'lat': 25.20, 'lng': 55.27, 'tag': 'New', 'category': 'boutique',
      },
      {
        'name': 'Kyoto Zen Ryokan', 'location': 'Kyoto', 'country': 'Japan',
        'description': 'Step back in time at this authentic traditional Japanese inn surrounded by bamboo gardens.',
        'pricePerNight': 310, 'rating': 4.7, 'reviewCount': 1453, 'stars': 5,
        'amenities': ['Free WiFi', 'Onsen', 'Japanese Garden', 'Tea Ceremony'],
        'images': ['https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800'],
        'lat': 35.01, 'lng': 135.77, 'tag': 'Cultural Pick', 'category': 'boutique',
      },
      {
        'name': 'Tropical Maldives Villa', 'location': 'Malé', 'country': 'Maldives',
        'description': 'Your own private paradise — an overwater bungalow surrounded by crystal-clear turquoise lagoon waters.',
        'pricePerNight': 890, 'rating': 5.0, 'reviewCount': 642, 'stars': 5,
        'amenities': ['Free WiFi', 'Private Infinity Pool', 'Overwater Bungalow', 'Butler Service'],
        'images': ['https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800'],
        'lat': 4.17, 'lng': 73.51, 'tag': 'Luxury', 'category': 'villa',
      },
      {
        'name': 'Parisian Boutique Hôtel', 'location': 'Paris', 'country': 'France',
        'description': 'Nestled in the charming Le Marais district, just a short walk from the Eiffel Tower.',
        'pricePerNight': 245, 'rating': 4.5, 'reviewCount': 2104, 'stars': 4,
        'amenities': ['Free WiFi', 'French Restaurant', 'Wine Bar', 'Breakfast Included'],
        'images': ['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'],
        'lat': 48.85, 'lng': 2.35, 'tag': 'Popular', 'category': 'boutique',
      },
    ];

    for (final hotel in hotels) {
      final ref = _db.collection('hotels').doc();
      batch.set(ref, hotel);
    }
    await batch.commit();
    print('✅ Hotels seeded!');
  }

  // ── Flights ─────────────────────────────────────────────────────
  static Future<void> _seedFlights() async {
    final batch = _db.batch();
    final flights = [
      {'airline': 'Emirates', 'airlineCode': 'EK', 'from': 'Cairo', 'fromCode': 'CAI', 'to': 'Dubai', 'toCode': 'DXB', 'departureTime': '08:30', 'arrivalTime': '13:45', 'duration': '3h 15m', 'price': 320, 'stops': 0, 'flightClass': 'Economy'},
      {'airline': 'Qatar Airways', 'airlineCode': 'QR', 'from': 'Cairo', 'fromCode': 'CAI', 'to': 'Paris', 'toCode': 'CDG', 'departureTime': '22:00', 'arrivalTime': '06:30', 'duration': '6h 30m', 'price': 580, 'stops': 1, 'flightClass': 'Economy'},
      {'airline': 'EgyptAir', 'airlineCode': 'MS', 'from': 'Cairo', 'fromCode': 'CAI', 'to': 'Athens', 'toCode': 'ATH', 'departureTime': '14:20', 'arrivalTime': '17:10', 'duration': '2h 50m', 'price': 210, 'stops': 0, 'flightClass': 'Economy'},
      {'airline': 'Turkish Airlines', 'airlineCode': 'TK', 'from': 'Cairo', 'fromCode': 'CAI', 'to': 'Tokyo', 'toCode': 'NRT', 'departureTime': '01:15', 'arrivalTime': '19:40', 'duration': '14h 25m', 'price': 920, 'stops': 1, 'flightClass': 'Business'},
    ];
    for (final flight in flights) {
      batch.set(_db.collection('flights').doc(), flight);
    }
    await batch.commit();
    print('✅ Flights seeded!');
  }

  // ── Packages ─────────────────────────────────────────────────────
  static Future<void> _seedPackages() async {
    final batch = _db.batch();
    final packages = [
      {'title': 'Greek Islands Explorer', 'destination': 'Santorini & Mykonos, Greece', 'description': 'Island-hop through the most beautiful islands of Greece with expert guides.', 'price': 2100, 'nights': 7, 'image': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800', 'includes': ['Flights', 'Hotels', 'Ferry', 'Guided Tours', 'Breakfast'], 'rating': 4.9},
      {'title': 'Maldives Escape', 'destination': 'Malé, Maldives', 'description': 'Ultimate all-inclusive luxury escape with overwater villa.', 'price': 4500, 'nights': 5, 'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800', 'includes': ['Flights', 'Overwater Villa', 'All Meals', 'Spa', 'Water Sports'], 'rating': 5.0},
      {'title': 'Japan Culture Journey', 'destination': 'Tokyo & Kyoto, Japan', 'description': 'Discover ancient temples and futuristic cities over 10 days.', 'price': 3200, 'nights': 10, 'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800', 'includes': ['Flights', 'Hotels', 'JR Pass', 'Guided Tours', 'Tea Ceremony'], 'rating': 4.8},
    ];
    for (final pkg in packages) {
      batch.set(_db.collection('packages').doc(), pkg);
    }
    await batch.commit();
    print('✅ Packages seeded!');
  }
}
