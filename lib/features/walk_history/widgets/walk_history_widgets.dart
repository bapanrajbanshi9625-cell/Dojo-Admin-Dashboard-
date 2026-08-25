import 'package:flutter/material.dart';

import '../models/walk_history_models.dart';
import '../utils/walk_history_helpers.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const WalkSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dojoGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dojoDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WALK HISTORY CARD
// ==========================================================

class WalkHistoryCard extends StatelessWidget {
  final WalkHistoryData walk;
  final VoidCallback onView;

  const WalkHistoryCard({
    super.key,
    required this.walk,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        walkStatusColor(walk.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _dogImage(),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      walk.dogName.isEmpty
                          ? 'Unknown Dog'
                          : walk.dogName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      walk.dogBreed.isEmpty
                          ? 'Breed not available'
                          : walk.dogBreed,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: dojoGrey,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      displayWalkId(walk),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                        color: dojoGrey,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                statusColor,
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(
            height: 1,
            color: dojoBorder,
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _info(
                Icons.calendar_today_outlined,
                formatWalkDate(walk),
              ),
              _info(
                Icons.access_time_outlined,
                formatWalkTime(walk),
              ),
              _info(
                Icons.timer_outlined,
                formatDuration(
                  walk.durationMinutes,
                ),
              ),
              _info(
                Icons.route_outlined,
                formatDistance(
                  walk.distanceKm,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _personInfo(
                  icon: Icons.person_outline,
                  label: 'Owner',
                  value: walk.ownerName.isEmpty
                      ? walk.ownerId
                      : walk.ownerName,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _personInfo(
                  icon: Icons.badge_outlined,
                  label: 'Walker',
                  value: walk.walkerName.isEmpty
                      ? walk.walkerId
                      : walk.walkerName,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _count(
                icon: Icons.water_drop_outlined,
                label: 'Pee',
                value: walk.peeCount,
              ),
              const SizedBox(width: 16),
              _count(
                icon: Icons.circle_outlined,
                label: 'Poop',
                value: walk.poopCount,
              ),
              const SizedBox(width: 16),
              _rating(),
              const Spacer(),
              TextButton.icon(
                onPressed: onView,
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                ),
                label: const Text(
                  'View',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: dojoOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dogImage() {
    final image = walk.dogPhoto.trim();

    if (image.isEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE9),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.pets,
          color: dojoOrange,
          size: 27,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(14),
      child: Image.network(
        image,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return Container(
            width: 58,
            height: 58,
            color: const Color(0xFFFFEEE9),
            child: const Icon(
              Icons.pets,
              color: dojoOrange,
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        formatWalkStatus(walk.status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(
    IconData icon,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: dojoGrey,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _personInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: dojoGrey,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _count({
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: dojoGrey,
        ),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _rating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          formatRating(walk.rating),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: dojoDark,
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// EMPTY
// ==========================================================

class WalkHistoryEmpty extends StatelessWidget {
  const WalkHistoryEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: dojoGrey,
          ),
          SizedBox(height: 12),
          Text(
            'No completed walks found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: dojoDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Completed walks will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }
}
