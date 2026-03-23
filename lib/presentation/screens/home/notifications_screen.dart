import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_formatter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notifications = [
      _NotifItem(
        icon: Icons.trending_up,
        color: AppTheme.primary,
        title: 'Trending in India',
        subtitle: 'New stories are trending in your region',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _NotifItem(
        icon: Icons.bookmark_added,
        color: const Color(0xFF00E676),
        title: 'Article Saved',
        subtitle: 'Your bookmarked article has been updated',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      _NotifItem(
        icon: Icons.newspaper,
        color: const Color(0xFFFF9800),
        title: 'Breaking News',
        subtitle: 'A major story is developing. Tap to read.',
        time: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      _NotifItem(
        icon: Icons.person_add,
        color: const Color(0xFF9C27B0),
        title: 'New Source Available',
        subtitle: 'Follow NDTV for personalized news updates',
        time: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      _NotifItem(
        icon: Icons.update,
        color: c.textSecondary,
        title: 'App Update',
        subtitle: 'New features and improvements are available',
        time: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style: TextStyle(color: AppTheme.primary, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(
          color: c.divider,
          height: 1,
        ),
        itemBuilder: (_, i) {
          final n = notifications[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: n.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(n.icon, color: n.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        n.subtitle,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.timeAgo(n.time.toIso8601String()),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime time;

  _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
