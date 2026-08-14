import 'package:flutter/material.dart';
import '../helpers/admin_colors.dart';

class AdminsHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const AdminsHeader({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admins',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w900,
                color: dojoBlack,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Manage DOJO administrator accounts and access',
              style: TextStyle(
                color: dojoGrey,
                fontSize: 14,
              ),
            ),
          ],
        );

        final button = FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(
            Icons.person_add_alt_1_outlined,
          ),
          label: const Text('Add Admin'),
          style: FilledButton.styleFrom(
            backgroundColor: dojoOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        );

        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 14),
              button,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            button,
          ],
        );
      },
    );
  }
}
