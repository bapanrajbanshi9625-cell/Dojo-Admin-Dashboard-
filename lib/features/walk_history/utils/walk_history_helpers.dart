import 'package:flutter/material.dart';

import '../models/walk_history_models.dart';

String formatWalkStatus(String status) {
  final value = status.trim();

  if (value.isEmpty) {
    return 'Unknown';
  }

  return value;
}

Color walkStatusColor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
      return const Color(0xFF3F8F68);

    case 'active':
    case 'started':
    case 'ongoing':
      return const Color(0xFF3F6FA5);

    case 'cancelled':
    case 'canceled':
      return const Color(0xFFD35435);

    default:
      return const Color(0xFF6B7280);
  }
}

String formatDistance(double distanceKm) {
  return '${distanceKm.toStringAsFixed(2)} km';
}

String formatDuration(double durationMinutes) {
  if (durationMinutes <= 0) {
    return '0 min';
  }

  final int totalMinutes = durationMinutes.round();

  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;

  if (hours > 0) {
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${hours}h';
  }

  return '$minutes min';
}

String formatRating(int rating) {
  if (rating <= 0) {
    return '-';
  }

  if (rating > 5) {
    return '5/5';
  }

  return '$rating/5';
}

String formatWalkDate(WalkHistoryData walk) {
  if (walk.date.trim().isNotEmpty) {
    return walk.date.trim();
  }

  final dateTime = walk.completedAt ?? walk.startedAt;

  if (dateTime == null) {
    return '-';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$day/$month/$year';
}

String formatWalkTime(WalkHistoryData walk) {
  if (walk.timeFormatted.trim().isNotEmpty) {
    return walk.timeFormatted.trim();
  }

  final dateTime = walk.startedAt;

  if (dateTime == null) {
    return '-';
  }

  final hour = dateTime.hour;
  final minute =
      dateTime.minute.toString().padLeft(2, '0');

  final period = hour >= 12 ? 'PM' : 'AM';

  final displayHour = hour % 12 == 0
      ? 12
      : hour % 12;

  return '$displayHour:$minute $period';
}

String displayWalkId(WalkHistoryData walk) {
  if (walk.walkId.trim().isNotEmpty) {
    return walk.walkId.trim();
  }

  if (walk.id.trim().isNotEmpty) {
    return walk.id.trim();
  }

  return '-';
}
