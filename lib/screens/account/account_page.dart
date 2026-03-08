import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../auth/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final user = app.currentUser;
    if (user == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF003B95),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'My account',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sign in to sync your trips and rewards',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('Rewards & Wallet'),
              subtitle: Text('Track your rewards and credits'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help center'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF003B95),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user.name}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => app.signOut(),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_available, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        '${app.bookings.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Text(
                        'Trips',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        '${app.wishlistHotelIds.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Text(
                        'Saved',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, size: 22),
                      SizedBox(height: 4),
                      Text(
                        'Level 1',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Genius',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Account',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Rewards & Wallet'),
            subtitle: Text('Track your rewards and credits'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help center'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ),
      ],
    );
  }
}
