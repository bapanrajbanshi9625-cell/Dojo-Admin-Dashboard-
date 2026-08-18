import 'package:flutter/material.dart';

class WalkerCard extends StatelessWidget {
  final Map<String, dynamic> walker;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const WalkerCard({
    super.key,
    required this.walker,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  String _value(String key, [String fallback = '—']) {
    final value = walker[key];
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  String _status() {
    final value = walker['status'] ??
        walker['Status'] ??
        walker['approvalStatus'] ??
        'Pending';

    return value.toString();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return const Color(0xFF16A34A);
      case 'rejected':
      case 'blocked':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _value(
      'Full Name',
      _value('fullName', _value('name', 'Unknown Walker')),
    );

    final mobile = _value(
      'Mobile number',
      _value('mobileNumber', _value('phone')),
    );

    final uid = _value(
      'Walker Uid',
      _value('walkerUid', _value('uid')),
    );

    final selfie = _value(
      'Profile Selfie',
      _value('profileSelfie', ''),
    );

    final status = _status();
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProfileImage(
                imageUrl: selfie,
                name: name,
              ),
              const SizedBox(width: 13),
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
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            mobile,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UID: $uid',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onApprove != null)
                        _ActionButton(
                          icon: Icons.check_rounded,
                          color: const Color(0xFF16A34A),
                          onTap: onApprove!,
                        ),
                      if (onApprove != null && onReject != null)
                        const SizedBox(width: 6),
                      if (onReject != null)
                        _ActionButton(
                          icon: Icons.close_rounded,
                          color: const Color(0xFFDC2626),
                          onTap: onReject!,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _ProfileImage({
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isEmpty
        ? 'W'
        : name.trim()[0].toUpperCase();

    if (imageUrl.trim().isEmpty) {
      return _FallbackAvatar(letter: firstLetter);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _FallbackAvatar(letter: firstLetter);
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6600)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF6600),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String letter;

  const _FallbackAvatar({
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6600)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}
