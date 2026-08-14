import 'package:flutter/material.dart';

import '../models/admin_data.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoGrey = Color(0xFF6B7280);

Future<void> showAdminDetailsDialog({
  required BuildContext context,
  required AdminData admin,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Admin Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        content: SizedBox(
          width: 430,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE9),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: dojoOrange,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                _detail(
                  'Name',
                  admin.name,
                ),

                _detail(
                  'Email',
                  admin.email,
                ),

                _detail(
                  'Role',
                  admin.role,
                ),

                _detail(
                  'Status',
                  admin.status,
                ),

                _detail(
                  'Last Active',
                  admin.lastActive,
                ),

                _detail(
                  'UID',
                  admin.uid,
                ),
              ],
            ),
          ),
        ),

        actions: [
          if (onEdit != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onEdit();
              },
              child: const Text('Edit'),
            ),

          if (onDelete != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onDelete();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: dojoRed,
                ),
              ),
            ),

          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _detail(
  String title,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 11,
    ),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
