import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() =>
      _ActivityLogsScreenState();
}

class _ActivityLogsScreenState
    extends State<ActivityLogsScreen> {
  String selectedFilter = 'All';

  final List<ActivityLog> logs = [
    ActivityLog(
      title: 'Owner profile created',
      description: 'A new owner account was created.',
      user: 'Super Admin',
      category: 'Owner',
      time: '2 min ago',
    ),
    ActivityLog(
      title: 'Walker profile updated',
      description: 'Walker information was updated.',
      user: 'Admin 01',
      category: 'Walker',
      time: '15 min ago',
    ),
    ActivityLog(
      title: 'Walk completed',
      description: 'A walk was marked as completed.',
      user: 'System',
      category: 'Walk',
      time: '32 min ago',
    ),
    ActivityLog(
      title: 'Payment recorded',
      description: 'A payment transaction was recorded.',
      user: 'Finance Admin',
      category: 'Payment',
      time: '1 hour ago',
    ),
    ActivityLog(
      title: 'Admin login',
      description: 'Administrator signed into the dashboard.',
      user: 'Super Admin',
      category: 'Admin',
      time: '2 hours ago',
    ),
  ];

  List<ActivityLog> get filteredLogs {
    if (selectedFilter == 'All') {
      return logs;
    }

    return logs
        .where((log) => log.category == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _logs(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Logs',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Track important actions across the DOJO platform',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
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
          _filter('All'),
          _filter('Owner'),
          _filter('Walker'),
          _filter('Walk'),
          _filter('Payment'),
          _filter('Admin'),
        ],
      ),
    );
  }

  Widget _filter(String title) {
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
          horizontal: 14,
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

  Widget _logs() {
    final list = filteredLogs;

    if (list.isEmpty) {
      return _empty();
    }

    return Column(
      children: list.map((log) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _logCard(log),
        );
      }).toList(),
    );
  }

  Widget _logCard(ActivityLog log) {
    final color = _categoryColor(log.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return _mobileLog(log, color);
          }

          return _desktopLog(log, color);
        },
      ),
    );
  }

  Widget _desktopLog(
    ActivityLog log,
    Color color,
  ) {
    return Row(
      children: [
        _icon(log.category, color),
        const SizedBox(width: 14),
        Expanded(
          child: _content(log),
        ),
        const SizedBox(width: 12),
        _categoryChip(log.category, color),
        const SizedBox(width: 15),
        Text(
          log.time,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _mobileLog(
    ActivityLog log,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _icon(log.category, color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _content(log),
              const SizedBox(height: 9),
              Row(
                children: [
                  _categoryChip(log.category, color),
                  const SizedBox(width: 8),
                  Text(
                    log.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: dojoGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon(String category, Color color) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        _categoryIcon(category),
        color: color,
        size: 22,
      ),
    );
  }

  Widget _content(ActivityLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          log.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          log.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 13,
              color: dojoGrey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                log.user,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryChip(
    String category,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _empty() {
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
              Icons.receipt_long_outlined,
              size: 52,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No activity found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Activity logs will appear here.',
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

  Color _categoryColor(String category) {
    switch (category) {
      case 'Owner':
        return dojoBlue;
      case 'Walker':
        return dojoGreen;
      case 'Walk':
        return dojoOrange;
      case 'Payment':
        return const Color(0xFF7567A8);
      case 'Admin':
        return dojoRed;
      default:
        return dojoGrey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Owner':
        return Icons.person_outline;
      case 'Walker':
        return Icons.badge_outlined;
      case 'Walk':
        return Icons.directions_walk_outlined;
      case 'Payment':
        return Icons.payments_outlined;
      case 'Admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

class ActivityLog {
  final String title;
  final String description;
  final String user;
  final String category;
  final String time;

  const ActivityLog({
    required this.title,
    required this.description,
    required this.user,
    required this.category,
    required this.time,
  });
}
