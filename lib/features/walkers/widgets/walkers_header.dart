import 'package:flutter/material.dart';

class WalkersHeader extends StatelessWidget {
  final String name;
  final String mobile;
  final String selfie;
  final String status;
  final Color roleColor;
  final Color statusColor;

  const WalkersHeader({
    super.key,
    required this.name,
    required this.mobile,
    required this.selfie,
    required this.status,
    required this.roleColor,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          _avatar(),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),

                if (mobile.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    mobile,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.isEmpty
                        ? 'Pending'
                        : status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (selfie.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor:
            const Color(0xFFFFF1E8),
        backgroundImage:
            NetworkImage(selfie),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor:
          const Color(0xFFFFF1E8),
      child: Icon(
        Icons.person,
        color: roleColor,
        size: 30,
      ),
    );
  }
}
