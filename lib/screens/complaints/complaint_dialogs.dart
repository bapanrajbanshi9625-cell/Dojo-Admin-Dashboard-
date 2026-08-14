import 'package:flutter/material.dart';

import '../complaints_screen.dart';
import 'complaint_data.dart';

void showComplaintDetails(
  BuildContext context,
  ComplaintData complaint,
) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Complaint Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Subject', complaint.subject),
              _detail('User', complaint.userName),
              _detail('User ID', complaint.userId),
              _detail('Category', complaint.category),
              _detail('Status', complaint.status),
              _detail('Date', complaint.createdAt),
              const SizedBox(height: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                complaint.description.isEmpty
                    ? '-'
                    : complaint.description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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

Widget _detail(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
