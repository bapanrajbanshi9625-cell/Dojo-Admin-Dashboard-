import 'package:flutter/material.dart';

import '../models/walker_availability_model.dart';

class WalkerDetails extends StatelessWidget {
  const WalkerDetails({
    super.key,
    required this.walker,
  });

  final WalkerAvailabilityModel walker;

  static const Color secondaryBlue = Color(0xFF3F6FA5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 12,
        children: [
          _Detail(
            label: 'Walker ID',
            value: walker.walkerId,
          ),
          _Detail(
            label: 'Walker Name',
            value: walker.walkerName.isEmpty
                ? 'Unknown Walker'
                : walker.walkerName,
          ),
          _Detail(
            label: 'Insta Walk',
            value: walker.isInstaWalkAvailable
                ? 'Available'
                : 'Not Available',
          ),
          if (walker.latitude != null &&
              walker.longitude != null)
            _Detail(
              label: 'Location',
              value:
                  '${walker.latitude!.toStringAsFixed(5)}, '
                  '${walker.longitude!.toStringAsFixed(5)}',
            ),
          if (walker.lastLocationUpdate != null)
            _Detail(
              label: 'Last Update',
              value: _formatDateTime(
                walker.lastLocationUpdate!,
              ),
            ),
          if (walker.dailyWalkSlots.isNotEmpty)
            _Detail(
              label: 'Booked Slots',
              value: _formatSlots(
                walker.dailyWalkSlots,
              ),
            ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 170,
        maxWidth: 360,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatSlots(List<String> slots) {
  if (slots.isEmpty) {
    return 'No booked slots';
  }

  return slots
      .map(_formatSingleSlot)
      .where((slot) => slot.isNotEmpty)
      .join(', ');
}

String _formatSingleSlot(String slot) {
  final value = slot.trim();

  if (value.isEmpty) {
    return '';
  }

  if (value.contains('–')) {
    return value;
  }

  if (value.contains(' - ')) {
    return value.replaceAll(
      ' - ',
      '–',
    );
  }

  return value;
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();

  final hour = local.hour == 0
      ? 12
      : local.hour > 12
          ? local.hour - 12
          : local.hour;

  final minute =
      local.minute.toString().padLeft(2, '0');

  final period =
      local.hour >= 12 ? 'PM' : 'AM';

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} $hour:$minute $period';
}
