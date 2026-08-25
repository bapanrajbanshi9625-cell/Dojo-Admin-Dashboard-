import 'package:flutter/material.dart';

import '../models/walk_history_models.dart';
import '../utils/walk_history_helpers.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFD64545);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

// ============================================================
// SUMMARY CARD
// ============================================================

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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
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
}

// ============================================================
// LIVE STAT
// ============================================================

class LiveDetailStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const LiveDetailStat({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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
}

// ============================================================
// STATUS
// ============================================================

class LiveStatusChip extends StatelessWidget {
  const LiveStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: dojoRed.withOpacity(.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: dojoRed,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ============================================================
// DOG AVATAR
// ============================================================

class WalkDogAvatar extends StatelessWidget {
  final String photo;

  const WalkDogAvatar({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    if (photo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          photo,
          width: 55,
          height: 55,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _defaultAvatar();
          },
        ),
      );
    }

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 27,
      ),
    );
  }
}

// ============================================================
// RATING
// ============================================================

class WalkRatingChip extends StatelessWidget {
  final int rating;

  const WalkRatingChip({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Color(0xFFD99A00),
          ),
          const SizedBox(width: 4),
          Text(
            rating > 0 ? '$rating' : '-',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF9A6A00),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BADGE
// ============================================================

class WalkBadge extends StatelessWidget {
  final String text;

  const WalkBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF9A6A00),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// HISTORY CARD
// ============================================================

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
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobile();
          }

          return _desktop();
        },
      ),
    );
  }

  Widget _desktop() {
    return Row(
      children: [
        WalkDogAvatar(photo: walk.dogPhoto),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(),
        ),
        Expanded(
          child: _info(
            Icons.timer_outlined,
            'Duration',
            '${walk.durationMinutes} min',
          ),
        ),
        Expanded(
          child: _info(
            Icons.route_outlined,
            'Distance',
            '${walk.distanceKm.toStringAsFixed(1)} km',
          ),
        ),
        WalkRatingChip(rating: walk.rating),
        const SizedBox(width: 12),
        _button(),
      ],
    );
  }

  Widget _mobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            WalkDogAvatar(photo: walk.dogPhoto),
            const SizedBox(width: 12),
            Expanded(child: _mainInfo()),
            WalkRatingChip(rating: walk.rating),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.timer_outlined,
                'Duration',
                '${walk.durationMinutes} min',
              ),
            ),
            Expanded(
              child: _info(
                Icons.route_outlined,
                'Distance',
                '${walk.distanceKm.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${walk.date} • ${walk.timeFormatted}',
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _button(),
        ),
      ],
    );
  }

  Widget _mainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                walk.walkId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: dojoDark,
                ),
              ),
            ),
            if (walk.badge.isNotEmpty) ...[
              const SizedBox(width: 7),
              WalkBadge(text: walk.badge),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          walk.dogName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (walk.dogBreed.isNotEmpty)
          Text(
            walk.dogBreed,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),
        const SizedBox(height: 3),
        Text(
          '${walk.ownerName} • ${walk.walkerName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _info(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 19, color: dojoBlue),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: dojoGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _button() {
    return OutlinedButton.icon(
      onPressed: onView,
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(color: dojoOrange),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class WalkHistoryEmpty extends StatelessWidget {
  const WalkHistoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walk history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Completed walks will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
