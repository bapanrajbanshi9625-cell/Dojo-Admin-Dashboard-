import 'package:flutter/material.dart';

import 'owner_data.dart';

const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGrey = Color(0xFF6B7280);

Future<void> showOwnerDetailsDialog(
  BuildContext context,
  OwnerData owner,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: dojoBlue,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                owner.name.isEmpty
                    ? 'Owner Details'
                    : owner.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _detail('Owner ID', owner.uid),
            _detail('Phone', owner.phone),
            _detail('Email', owner.email),
            _detail('Pets', '${owner.pets}'),
            _detail('Walks', '${owner.walks}'),
            _detail('Status', owner.status),
          ],
        ),
        actions: [
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
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            title,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 12,
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
