import 'package:flutter/foundation.dart';

class Review {
  final String user;
  final String comment;
  final double rating;
  final DateTime date;
  Review({
    required this.user,
    required this.comment,
    required this.rating,
    required this.date,
  });
}

class User {
  final String name;
  final String email;
  User({required this.name, required this.email});
}

class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String? imagePath;
  final double pricePerNight;
  final double rating;
  final List<Review> reviews;
  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    this.imagePath,
    required this.pricePerNight,
    required this.rating,
    List<Review>? reviews,
  }) : reviews = reviews ?? <Review>[];
}

class Flight {
  final String id;
  final String from;
  final String to;
  final DateTime departAt;
  final double price;
  final double rating;
  Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.departAt,
    required this.price,
    required this.rating,
  });
}

class TravelPackage {
  final String id;
  final String title;
  final String description;
  final int days;
  final double price;
  final double rating;
  final String imageUrl;
  final String? imagePath;
  TravelPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.days,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.imagePath,
  });
}

enum BookingKind { hotel, flight, travelPackage }

@immutable
class Booking {
  final String id;
  final BookingKind kind;
  final String title;
  final double price;
  final DateTime date;
  const Booking({
    required this.id,
    required this.kind,
    required this.title,
    required this.price,
    required this.date,
  });
}

