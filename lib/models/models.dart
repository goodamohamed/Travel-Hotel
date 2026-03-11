import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String id;
  final String name;
  final String location;
  final String country;
  final String description;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final int stars;
  final List<String> amenities;
  final List<String> images;
  final double lat;
  final double lng;
  bool isWishlisted;
  final String tag;
  final HotelCategory category;

  Hotel({required this.id, required this.name, required this.location, required this.country, required this.description, required this.pricePerNight, required this.rating, required this.reviewCount, required this.stars, required this.amenities, required this.images, required this.lat, required this.lng, this.isWishlisted = false, this.tag = '', this.category = HotelCategory.hotel});

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Hotel(id: doc.id, name: d['name'] ?? '', location: d['location'] ?? '', country: d['country'] ?? '', description: d['description'] ?? '', pricePerNight: (d['pricePerNight'] ?? 0).toDouble(), rating: (d['rating'] ?? 0).toDouble(), reviewCount: d['reviewCount'] ?? 0, stars: d['stars'] ?? 3, amenities: List<String>.from(d['amenities'] ?? []), images: List<String>.from(d['images'] ?? []), lat: (d['lat'] ?? 0).toDouble(), lng: (d['lng'] ?? 0).toDouble(), tag: d['tag'] ?? '', category: HotelCategory.values.firstWhere((e) => e.name == (d['category'] ?? 'hotel'), orElse: () => HotelCategory.hotel));
  }

  Map<String, dynamic> toFirestore() => {'name': name, 'location': location, 'country': country, 'description': description, 'pricePerNight': pricePerNight, 'rating': rating, 'reviewCount': reviewCount, 'stars': stars, 'amenities': amenities, 'images': images, 'lat': lat, 'lng': lng, 'tag': tag, 'category': category.name};
}

enum HotelCategory { hotel, resort, villa, boutique, hostel }

class Flight {
  final String id;
  final String airline;
  final String airlineCode;
  final String from;
  final String fromCode;
  final String to;
  final String toCode;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final int stops;
  final String flightClass;
  bool isWishlisted;

  Flight({required this.id, required this.airline, required this.airlineCode, required this.from, required this.fromCode, required this.to, required this.toCode, required this.departureTime, required this.arrivalTime, required this.duration, required this.price, required this.stops, required this.flightClass, this.isWishlisted = false});

  factory Flight.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Flight(id: doc.id, airline: d['airline'] ?? '', airlineCode: d['airlineCode'] ?? '', from: d['from'] ?? '', fromCode: d['fromCode'] ?? '', to: d['to'] ?? '', toCode: d['toCode'] ?? '', departureTime: d['departureTime'] ?? '', arrivalTime: d['arrivalTime'] ?? '', duration: d['duration'] ?? '', price: (d['price'] ?? 0).toDouble(), stops: d['stops'] ?? 0, flightClass: d['flightClass'] ?? 'Economy');
  }

  Map<String, dynamic> toFirestore() => {'airline': airline, 'airlineCode': airlineCode, 'from': from, 'fromCode': fromCode, 'to': to, 'toCode': toCode, 'departureTime': departureTime, 'arrivalTime': arrivalTime, 'duration': duration, 'price': price, 'stops': stops, 'flightClass': flightClass};
}

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String hotelLocation;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final double totalPrice;
  final BookingStatus status;
  final String confirmationCode;
  final DateTime createdAt;

  Booking({required this.id, required this.userId, required this.hotelId, required this.hotelName, required this.hotelLocation, required this.checkIn, required this.checkOut, required this.guests, required this.rooms, required this.totalPrice, required this.status, required this.confirmationCode, required this.createdAt});

  int get nights => checkOut.difference(checkIn).inDays;

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Booking(id: doc.id, userId: d['userId'] ?? '', hotelId: d['hotelId'] ?? '', hotelName: d['hotelName'] ?? '', hotelLocation: d['hotelLocation'] ?? '', checkIn: (d['checkIn'] as Timestamp).toDate(), checkOut: (d['checkOut'] as Timestamp).toDate(), guests: d['guests'] ?? 1, rooms: d['rooms'] ?? 1, totalPrice: (d['totalPrice'] ?? 0).toDouble(), status: BookingStatus.values.firstWhere((e) => e.name == (d['status'] ?? 'pending'), orElse: () => BookingStatus.pending), confirmationCode: d['confirmationCode'] ?? '', createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now());
  }

  Map<String, dynamic> toFirestore() => {'userId': userId, 'hotelId': hotelId, 'hotelName': hotelName, 'hotelLocation': hotelLocation, 'checkIn': Timestamp.fromDate(checkIn), 'checkOut': Timestamp.fromDate(checkOut), 'guests': guests, 'rooms': rooms, 'totalPrice': totalPrice, 'status': status.name, 'confirmationCode': confirmationCode, 'createdAt': Timestamp.fromDate(createdAt)};
}

enum BookingStatus { confirmed, pending, cancelled, completed }

class Review {
  final String id;
  final String hotelId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photos;

  Review({required this.id, required this.hotelId, required this.userId, required this.userName, required this.userAvatar, required this.rating, required this.comment, required this.date, this.photos = const []});

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Review(id: doc.id, hotelId: d['hotelId'] ?? '', userId: d['userId'] ?? '', userName: d['userName'] ?? 'Anonymous', userAvatar: d['userAvatar'] ?? 'A', rating: (d['rating'] ?? 0).toDouble(), comment: d['comment'] ?? '', date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(), photos: List<String>.from(d['photos'] ?? []));
  }

  Map<String, dynamic> toFirestore() => {'hotelId': hotelId, 'userId': userId, 'userName': userName, 'userAvatar': userAvatar, 'rating': rating, 'comment': comment, 'date': Timestamp.fromDate(date), 'photos': photos};
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String membershipTier;
  final int points;
  final List<String> wishlistHotelIds;
  final DateTime createdAt;

  AppUser({required this.uid, required this.name, required this.email, this.photoUrl, this.membershipTier = 'Silver', this.points = 0, this.wishlistHotelIds = const [], required this.createdAt});

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(uid: doc.id, name: d['name'] ?? '', email: d['email'] ?? '', photoUrl: d['photoUrl'], membershipTier: d['membershipTier'] ?? 'Silver', points: d['points'] ?? 0, wishlistHotelIds: List<String>.from(d['wishlistHotelIds'] ?? []), createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now());
  }

  AppUser copyWith({String? name, String? photoUrl, String? membershipTier, int? points, List<String>? wishlistHotelIds}) => AppUser(uid: uid, name: name ?? this.name, email: email, photoUrl: photoUrl ?? this.photoUrl, membershipTier: membershipTier ?? this.membershipTier, points: points ?? this.points, wishlistHotelIds: wishlistHotelIds ?? this.wishlistHotelIds, createdAt: createdAt);

  Map<String, dynamic> toFirestore() => {'name': name, 'email': email, 'photoUrl': photoUrl, 'membershipTier': membershipTier, 'points': points, 'wishlistHotelIds': wishlistHotelIds, 'createdAt': Timestamp.fromDate(createdAt)};
}

class TravelPackage {
  final String id;
  final String title;
  final String destination;
  final String description;
  final double price;
  final int nights;
  final String image;
  final List<String> includes;
  final double rating;
  bool isWishlisted;

  TravelPackage({required this.id, required this.title, required this.destination, required this.description, required this.price, required this.nights, required this.image, required this.includes, required this.rating, this.isWishlisted = false});

  factory TravelPackage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TravelPackage(id: doc.id, title: d['title'] ?? '', destination: d['destination'] ?? '', description: d['description'] ?? '', price: (d['price'] ?? 0).toDouble(), nights: d['nights'] ?? 3, image: d['image'] ?? '', includes: List<String>.from(d['includes'] ?? []), rating: (d['rating'] ?? 0).toDouble());
  }

  Map<String, dynamic> toFirestore() => {'title': title, 'destination': destination, 'description': description, 'price': price, 'nights': nights, 'image': image, 'includes': includes, 'rating': rating};
}
