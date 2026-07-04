import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_colors.dart';

/// Reusable settings gear button used in screen headers.
class SettingsIconButton extends StatelessWidget {
  final Color backgroundColor;
  const SettingsIconButton({super.key, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.settings, color: AppColors.primary),
      ),
    );
  }
}

/// Notification bell with optional unread badge.
class NotificationIconButton extends StatelessWidget {
  final Stream<int>? unreadStream;
  const NotificationIconButton({super.key, this.unreadStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: unreadStream,
      builder: (context, snapshot) {
        final hasUnread = (snapshot.data ?? 0) > 0;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              if (hasUnread)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
