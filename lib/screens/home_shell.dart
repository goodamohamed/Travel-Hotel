import 'package:flutter/material.dart';
import 'wishlist/wishlist_page.dart';
import 'bookings/bookings_page.dart';
import 'search/search_page.dart';
import 'account/account_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const SearchPage(),
      const WishlistPage(),
      const BookingsPage(),
      const AccountPage(),
    ];
    final titles = <String>[
      'Search',
      'Saved',
      'Bookings',
      'My account',
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003B95),
        foregroundColor: Colors.white,
        title: Text('TravelMate – ${titles[_index]}'),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'My account'),
        ],
      ),
    );
  }
}
