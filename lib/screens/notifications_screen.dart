import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  String selectedFilter = 'All';

  final List<NotificationData> notifications = [
    NotificationData(
      title: 'New owner registered',
      message: 'A new owner has completed registration.',
      time: '2 min ago',
      type: 'Owner',
      read: false,
    ),
    NotificationData(
      title: 'Walk completed',
      message: 'A walk has been successfully completed.',
      time: '15 min ago',
      type: 'Walk',
      read: false,
    ),
    NotificationData(
      title: 'New walker registered',
      message: 'A new walker profile is waiting for review.',
      time: '1 hour ago',
      type: 'Walker',
      read: true,
    ),
    NotificationData(
      title: 'Payment received',
      message: 'A new payment has been recorded.',
      time: '2 hours ago',
      type: 'Payment',
      read: true,
    ),
  ];

  List<NotificationData> get filteredNotifications {
    if (selectedFilter == 'All') {
      return notifications;
    }

    if (selectedFilter == 'Unread') {
      return notifications.where((n) => !n.read).toList();
    }

    return notifications
        .where((n) => n.type == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final unread =
        notifications.where((n) => !n.read).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(unread),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _notificationList(),
      ],
    );
  }

  Widget _header(int unread) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: dojoBlack,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Monitor important DOJO platform notifications',
                style: TextStyle(
                  color: dojoGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (unread > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$unread Unread',
              style: const TextStyle(
                color: dojoOrange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('Unread'),
          _filterButton('Owner'),
          _filterButton('Walker'),
          _filterButton('Walk'),
          _filterButton('Payment'),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final active = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active ? dojoOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : dojoBlack,
          ),
        ),
      ),
    );
  }

  Widget _notificationList() {
    final list = filteredNotifications;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.asMap().entries.map((entry) {
        final index = entry.key;
        final notification = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _notificationCard(
            notification,
            index,
          ),
        );
      }).toList(),
    );
  }

  Widget _notificationCard(
    NotificationData notification,
    int index,
  ) {
    final color = _typeColor(notification.type);

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        setState(() {
          notification.read = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: notification.read
              ? Colors.white
              : const Color(0xFFFFFAF8),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: notification.read
                ? dojoBorder
                : color.withOpacity(.35),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 500) {
              return _mobileCard(notification, color);
            }

            return _desktopCard(notification, color);
          },
        ),
      ),
    );
  }

  Widget _desktopCard(
    NotificationData notification,
    Color color,
  ) {
    return Row(
      children: [
        _notificationIcon(notification.type, color),
        const SizedBox(width: 14),
        Expanded(
          child: _notificationContent(notification),
        ),
        const SizedBox(width: 12),
        _time(notification.time),
        const SizedBox(width: 12),
        if (!notification.read) _unreadDot(color),
      ],
    );
  }

  Widget _mobileCard(
    NotificationData notification,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _notificationIcon(notification.type, color),
        const SizedBox(width: 12),
        Expanded(
          child: _notificationContent(notification),
        ),
        const SizedBox(width: 8),
        if (!notification.read) _unreadDot(color),
      ],
    );
  }

  Widget _notificationIcon(
    String type,
    Color color,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        _typeIcon(type),
        color: color,
        size: 23,
      ),
    );
  }

  Widget _notificationContent(
    NotificationData notification,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.read
                ? FontWeight.w700
                : FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          notification.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: dojoGrey,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          notification.time,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _time(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 10,
        color: dojoGrey,
      ),
    );
  }

  Widget _unreadDot(Color color) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 52,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'New notifications will appear here.',
              style: TextStyle(
                fontSize: 12,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Owner':
        return dojoBlue;
      case 'Walker':
        return dojoGreen;
      case 'Walk':
        return dojoOrange;
      case 'Payment':
        return const Color(0xFF7567A8);
      default:
        return dojoGrey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Owner':
        return Icons.person_outline;
      case 'Walker':
        return Icons.badge_outlined;
      case 'Walk':
        return Icons.directions_walk_outlined;
      case 'Payment':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }
}

class NotificationData {
  final String title;
  final String message;
  final String time;
  final String type;
  bool read;

  NotificationData({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
  });
}
