import 'package:flutter/material.dart';

import '../complaints_screen.dart';
import 'complaint_data.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintData complaint;
  final VoidCallback onView;
  final Future<void> Function(String status) onUpdateStatus;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onView,
    required this.onUpdateStatus,
  });

  Color _statusColor() {
    switch (complaint.status) {
      case 'Resolved':
        return dojoGreen;
      case 'Closed':
        return dojoGrey;
      default:
        return dojoOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _mobile(color);
          }

          return _desktop(color);
        },
      ),
    );
  }

  Widget _desktop(Color color) {
    return Row(
      children: [
        _icon(color),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _info(),
        ),
        _category(),
        const SizedBox(width: 12),
        _status(color),
        const SizedBox(width: 14),
        _viewButton(),
      ],
    );
  }

  Widget _mobile(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _icon(color),
            const SizedBox(width: 12),
            Expanded(child: _info()),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _category(),
            _status(color),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(),
        ),
      ],
    );
  }

  Widget _icon(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.report_problem_outlined,
        color: color,
        size: 27,
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          complaint.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          complaint.userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          complaint.createdAt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _category() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: dojoBlue.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        complaint.category,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: dojoBlue,
        ),
      ),
    );
  }

  Widget _status(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        complaint.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _viewButton() {
    return OutlinedButton.icon(
      onPressed: onView,
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
