import 'package:flutter/material.dart';

import '../models/walker_availability_model.dart';
import 'walker_details.dart';

class WalkerAvailabilityCard extends StatefulWidget {
  const WalkerAvailabilityCard({
    super.key,
    required this.walker,
    required this.isDaily,
  });

  final WalkerAvailabilityModel walker;
  final bool isDaily;

  @override
  State<WalkerAvailabilityCard> createState() =>
      _WalkerAvailabilityCardState();
}

class _WalkerAvailabilityCardState
    extends State<WalkerAvailabilityCard> {
  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF3F6FA5);

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final walker = widget.walker;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(walker),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        walker.walkerName.isEmpty
                            ? 'Unknown Walker'
                            : walker.walkerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        walker.walkerId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isDaily)
                  _buildOnlineIndicator(
                    walker.isInstaWalkAvailable,
                  ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(9),
              ),
              child: widget.isDaily
                  ? _buildDailyInfo(walker)
                  : _buildInstaInfo(walker),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: secondaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                ),
                label: Text(
                  _expanded
                      ? 'Hide Details'
                      : 'View Details',
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 4),
              WalkerDetails(
                walker: walker,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    WalkerAvailabilityModel walker,
  ) {
    final name = walker.walkerName.trim();

    final initial = name.isEmpty
        ? 'W'
        : name.substring(0, 1).toUpperCase();

    final photoUrl = walker.photoUrl;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFFFF1E8),
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFFFF1E8),
      child: Text(
        initial,
        style: const TextStyle(
          color: primaryOrange,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator(
    bool available,
  ) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFF16A34A)
            : const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInstaInfo(
    WalkerAvailabilityModel walker,
  ) {
    final available =
        walker.isInstaWalkAvailable;

    return Row(
      children: [
        const Icon(
          Icons.flash_on_rounded,
          size: 18,
          color: primaryOrange,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Insta Walk Status',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                available
                    ? 'Available for Insta Walk'
                    : 'Not Available',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: available
                      ? const Color(0xFF15803D)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInfo(
    WalkerAvailabilityModel walker,
  ) {
    final slots = _formatSlots(
      walker.dailyWalkSlots,
    );

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.schedule_rounded,
          size: 18,
          color: secondaryBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Booked Time Slots',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                slots,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSlots(
    List<String> slots,
  ) {
    if (slots.isEmpty) {
      return 'No booked slots';
    }

    return slots
        .map(_formatSlot)
        .where((slot) => slot.isNotEmpty)
        .join(', ');
  }

  String _formatSlot(
    String slot,
  ) {
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
}
