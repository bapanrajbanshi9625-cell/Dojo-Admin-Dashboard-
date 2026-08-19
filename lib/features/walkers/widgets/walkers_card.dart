import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalkersCard extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final VoidCallback? onView;

  const WalkersCard({
    super.key,
    required this.doc,
    this.onView,
  });

  Map<String, dynamic> get _data {
    return doc.data() ?? <String, dynamic>{};
  }

  String _readValue(
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = _data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final name = _readValue(
      const [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
      'Unknown Walker',
    );

    final mobile = _readValue(
      const [
        'Mobile number',
        'mobileNumber',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );

    final status = _readValue(
      const [
        'status',
        'verificationStatus',
        'approvalStatus',
        'walkerStatus',
      ],
      'Pending',
    );

    final selfie = _readValue(
      const [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'photoUrl',
      ],
    );

    final initials = _initials(name);

    return InkWell(
      onTap: onView,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _avatar(
              initials: initials,
              imageUrl: selfie,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),

                  if (mobile.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      mobile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  _statusBadge(status),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() == 'unknown walker') {
      return 'W';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Widget _avatar({
    required String initials,
    required String imageUrl,
  }) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor:
            const Color(0xFFFFF1E8),
        backgroundImage:
            NetworkImage(imageUrl),
        onBackgroundImageError:
            (_, __) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor:
          const Color(0xFFFFF1E8),
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final displayStatus =
        status.trim().isEmpty
            ? 'Pending'
            : status.trim();

    final normalized =
        displayStatus.toLowerCase();

    final Color color;

    switch (normalized) {
      case 'approved':
      case 'active':
        color = const Color(0xFF16A34A);
        break;

      case 'online':
        color = const Color(0xFF059669);
        break;

      case 'rejected':
      case 'blocked':
      case 'suspended':
        color = const Color(0xFFDC2626);
        break;

      case 'pending':
      case 'pending approval':
        color = const Color(0xFFF59E0B);
        break;

      default:
        color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
