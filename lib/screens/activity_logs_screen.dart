import 'package:cloud_firestore/cloud_firestore.dart';
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

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String selectedFilter = 'All';

  final CollectionReference<Map<String, dynamic>> _logsRef =
      FirebaseFirestore.instance.collection('activity_logs');

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

  // ==========================================================
  // HEADER
  // ==========================================================

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

  // ==========================================================
  // FILTERS
  // ==========================================================

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
    final bool active = selectedFilter == title;

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

  // ==========================================================
  // FIREBASE LOGS
  // ==========================================================

  Widget _logs() {
    Query<Map<String, dynamic>> query = _logsRef;

    if (selectedFilter != 'All') {
      query = query.where(
        'category',
        isEqualTo: selectedFilter,
      );
    }

    query = query.orderBy(
      'timestamp',
      descending: true,
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        if (snapshot.hasError) {
          return _error(snapshot.error.toString());
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return _empty();
        }

        return Column(
          children: documents.map((doc) {
            final log = ActivityLog.fromFirestore(
              doc.id,
              doc.data(),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _logCard(log),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================================
  // LOG CARD
  // ==========================================================

  Widget _logCard(ActivityLog log) {
    final Color color = _categoryColor(log.category);

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

  // ==========================================================
  // DESKTOP
  // ==========================================================

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
          _formatTime(log.timestamp),
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _content(log),
              const SizedBox(height: 9),
              Row(
                children: [
                  _categoryChip(log.category, color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _formatTime(log.timestamp),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: dojoGrey,
                      ),
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

  // ==========================================================
  // ICON
  // ==========================================================

  Widget _icon(
    String category,
    Color color,
  ) {
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

  // ==========================================================
  // CONTENT
  // ==========================================================

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
                log.userName.isEmpty
                    ? 'System'
                    : log.userName,
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

  // ==========================================================
  // CATEGORY CHIP
  // ==========================================================

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

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _loading() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: dojoOrange,
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _error(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: dojoRed,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load activity logs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: dojoBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

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

  // ==========================================================
  // CATEGORY COLOR
  // ==========================================================

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

  // ==========================================================
  // CATEGORY ICON
  // ==========================================================

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

  // ==========================================================
  // TIME FORMAT
  // ==========================================================

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown time';
    }

    final date = timestamp.toDate();
    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hour'
          '${difference.inHours == 1 ? '' : 's'} ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day'
          '${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================
// FIRESTORE MODEL
// ============================================================

class ActivityLog {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final String category;
  final Timestamp? timestamp;
  final String walkId;
  final String ownerId;
  final String walkeruid;

  const ActivityLog({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.category,
    required this.timestamp,
    required this.walkId,
    required this.ownerId,
    required this.walkeruid,
  });

  factory ActivityLog.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ActivityLog(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Admin',
      timestamp: data['timestamp'] is Timestamp
          ? data['timestamp'] as Timestamp
          : null,
      walkId: data['walkId']?.toString() ?? '',
      ownerId: data['ownerId']?.toString() ?? '',
      walkeruid: data['walkeruid']?.toString() ?? '',
    );
  }
}
