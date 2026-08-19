import 'package:flutter/material.dart';

import 'walkers_details_action_button.dart';
import 'walkers_helpers.dart';

class WalkerDetailsActions extends StatelessWidget {
  final String status;
  final bool isActive;

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const WalkerDetailsActions({
    super.key,
    required this.status,
    required this.isActive,
    required this.onApprove,
    required this.onReject,
    required this.onActivate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[];

    final normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus == 'pending') {
      buttons.add(
        WalkerDetailsActionButton(
          label: 'Reject',
          icon: Icons.close_rounded,
          color: walkerDetailsRed,
          onPressed: onReject,
        ),
      );

      buttons.add(
        WalkerDetailsActionButton(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: walkerDetailsGreen,
          onPressed: onApprove,
          filled: true,
        ),
      );
    } else if (normalizedStatus == 'rejected') {
      buttons.add(
        WalkerDetailsActionButton(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: walkerDetailsGreen,
          onPressed: onApprove,
          filled: true,
        ),
      );
    } else if (normalizedStatus == 'approved' ||
        normalizedStatus == 'active') {
      if (isActive) {
        buttons.add(
          WalkerDetailsActionButton(
            label: 'Deactivate ID',
            icon: Icons.person_off_outlined,
            color: walkerDetailsRed,
            onPressed: onDeactivate,
          ),
        );
      } else {
        buttons.add(
          WalkerDetailsActionButton(
            label: 'Activate ID',
            icon: Icons.person_outline_rounded,
            color: walkerDetailsBlue,
            onPressed: onActivate,
            filled: true,
          ),
        );
      }
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }
}
