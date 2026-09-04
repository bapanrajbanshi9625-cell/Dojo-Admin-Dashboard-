import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'walkers_helpers.dart';

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
    return walkerDetailsFirstValue(
      _data,
      keys,
      fallback: fallback,
    );
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

    final status = WalkersHelpers.verificationStatus(
      _data,
    );

    final selfie = walkerDetailsFirstImage(
      _data,
      const [
        'Profile Selfie',
        'profileSelfie',
        'selfie',
        'selfieUrl',
        'profileImage',
        'profileImageUrl',
      ],
    );

    final initials = _initials(name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: walkerDetailsBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _Avatar(
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
                          color: walkerDetailsTextGrey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _StatusBadge(
                      status: status,
                    ),
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
}

class _Avatar extends StatelessWidget {
  final String initials;
  final String imageUrl;

  const _Avatar({
    required this.initials,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFFFF1E8),
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFFFF1E8),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final label = walkerDetailsStatusLabel({
      'status': status,
    });

    final color = walkerDetailsStatusColor(
      status,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
