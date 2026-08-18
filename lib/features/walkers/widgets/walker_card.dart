import 'package:flutter/material.dart';

class WalkerCard extends StatelessWidget {
  final dynamic walker;
  final VoidCallback? onTap;

  const WalkerCard({
    super.key,
    required this.walker,
    this.onTap,
  });

  String _readValue(String key, [String fallback = '']) {
    try {
      final value = walker.toMap()[key];
      if (value == null) return fallback;
      return value.toString();
    } catch (_) {
      try {
        final value = walker[key];
        if (value == null) return fallback;
        return value.toString();
      } catch (_) {
        return fallback;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _readValue(
      'Full Name',
      _readValue('fullName', 'Unknown Walker'),
    );

    final mobile = _readValue(
      'Mobile number',
      _readValue('mobileNumber', ''),
    );

    final status = _readValue(
      'status',
      'Pending',
    );

    final selfie = _readValue(
      'Profile Selfie',
      _readValue('profileSelfie', ''),
    );

    final initials = name.trim().isEmpty
        ? 'W'
        : name.trim().substring(0, 1).toUpperCase();

    return InkWell(
      onTap: onTap,
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _avatar(
              name: initials,
              imageUrl: selfie,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _avatar({
    required String name,
    required String imageUrl,
  }) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFFFF1E8),
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFFFF1E8),
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    Color color;

    if (normalized == 'approved' || normalized == 'active') {
      color = const Color(0xFF16A34A);
    } else if (normalized == 'online') {
      color = const Color(0xFF059669);
    } else if (normalized == 'rejected') {
      color = const Color(0xFFDC2626);
    } else {
      color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Pending' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
