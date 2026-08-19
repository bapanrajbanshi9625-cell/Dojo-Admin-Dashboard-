import 'package:cloud_firestore/cloud_firestore.dart';

class WalkersHelpers {
  static String readValue(
    Map<String, dynamic> data,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  static bool readBool(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value != 0;
      }

      if (value is String) {
        final normalized = value.trim().toLowerCase();

        if (normalized == 'true' ||
            normalized == 'yes' ||
            normalized == '1') {
          return true;
        }

        if (normalized == 'false' ||
            normalized == 'no' ||
            normalized == '0') {
          return false;
        }
      }
    }

    return false;
  }

  static String readTimestamp(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) continue;

      if (value is Timestamp) {
        return formatDateTime(value.toDate());
      }

      if (value is DateTime) {
        return formatDateTime(value);
      }

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static String formatDateTime(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$d/$m/$y $hour:$minute';
  }

  static String initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() == 'unknown walker') {
      return 'W';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // =========================================================
  // ONLINE STATUS
  // =========================================================

  static bool isOnline(
    Map<String, dynamic> data,
  ) {
    return readBool(
      data,
      const [
        'isOnline',
        'online',
        'walkerOnline',
        'onlineStatus',
      ],
    );
  }

  // =========================================================
  // VERIFICATION STATUS
  // =========================================================

  static String verificationStatus(
    Map<String, dynamic> data,
  ) {
    final status = readValue(
      data,
      const [
        'verificationStatus',
        'status',
        'approvalStatus',
        'walkerStatus',
      ],
      'pending',
    ).trim().toLowerCase();

    switch (status) {
      case 'approved':
      case 'active':
      case 'online':
        return 'approved';

      case 'rejected':
      case 'blocked':
      case 'suspended':
        return 'rejected';

      default:
        return 'pending';
    }
  }
}
