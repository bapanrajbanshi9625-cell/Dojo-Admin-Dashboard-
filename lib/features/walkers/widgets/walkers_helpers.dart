import 'package:flutter/material.dart';

/// ============================================================
/// DOJO WALKER - COMMON WALKER HELPERS
/// ============================================================

const Color walkerDetailsOrange = Color(0xFFFF6600);
const Color walkerDetailsRed = Color(0xFFE53935);
const Color walkerDetailsGreen = Color(0xFF2E7D32);
const Color walkerDetailsBlue = Color(0xFF1976D2);

const Color walkerDetailsPageBg = Color(0xFFF7F8FA);
const Color walkerDetailsTextDark = Color(0xFF1F2937);
const Color walkerDetailsTextGrey = Color(0xFF6B7280);
const Color walkerDetailsBorder = Color(0xFFE5E7EB);

class WalkersHelpers {
  const WalkersHelpers._();

  static bool isOnline(
    Map<String, dynamic> data,
  ) {
    const keys = <String>[
      'isOnline',
      'is_online',
      'online',
      'onlineStatus',
      'online_status',
    ];

    for (final key in keys) {
      if (walkerDetailsBool(data, key)) {
        return true;
      }
    }

    final status = walkerDetailsNormalize(
      data['status']?.toString(),
    );

    return status == 'online';
  }

  static String verificationStatus(
    Map<String, dynamic> data,
  ) {
    final status = walkerDetailsNormalize(
      walkerDetailsStatus(data),
    );

    if (status.contains('reject') ||
        status.contains('blocked') ||
        status.contains('suspend')) {
      return 'rejected';
    }

    if (status.contains('approve') ||
        status.contains('verified') ||
        status.contains('accepted')) {
      return 'approved';
    }

    if (status.contains('pending') ||
        status.contains('review') ||
        status.contains('waiting')) {
      return 'pending';
    }

    if (walkerDetailsBool(data, 'approved') ||
        walkerDetailsBool(data, 'isApproved') ||
        walkerDetailsBool(data, 'adminApproved')) {
      return 'approved';
    }

    if (walkerDetailsBool(data, 'rejected') ||
        walkerDetailsBool(data, 'isRejected') ||
        walkerDetailsBool(data, 'adminRejected')) {
      return 'rejected';
    }

    return 'pending';
  }
}

String walkerDetailsValue(
  Map<String, dynamic> data,
  String key, {
  String fallback = '—',
}) {
  final value = data[key];

  if (value == null) {
    return fallback;
  }

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return fallback;
  }

  return text;
}

String walkerDetailsImageUrl(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return '';
  }

  final url = value.toString().trim();

  if (url.isEmpty || url.toLowerCase() == 'null') {
    return '';
  }

  return url;
}

bool walkerDetailsBool(
  Map<String, dynamic> data,
  String key, {
  bool fallback = false,
}) {
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

  return fallback;
}

String walkerDetailsStatus(
  Map<String, dynamic> data,
) {
  const candidates = <String>[
    'status',
    'Status',
    'approvalStatus',
    'approval_status',
    'verificationStatus',
    'verification_status',
  ];

  for (final key in candidates) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final text = value.toString().trim();

    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  if (walkerDetailsBool(data, 'rejected') ||
      walkerDetailsBool(data, 'isRejected') ||
      walkerDetailsBool(data, 'adminRejected')) {
    return 'Rejected';
  }

  if (walkerDetailsBool(data, 'approved') ||
      walkerDetailsBool(data, 'isApproved') ||
      walkerDetailsBool(data, 'adminApproved')) {
    return 'Approved';
  }

  if (walkerDetailsBool(data, 'active') ||
      walkerDetailsBool(data, 'isActive')) {
    return 'Active';
  }

  return 'Pending';
}

Color walkerDetailsStatusColor(
  String status,
) {
  final normalized = status.trim().toLowerCase();

  if (normalized.contains('approved') ||
      normalized.contains('approve') ||
      normalized.contains('active') ||
      normalized.contains('verified') ||
      normalized.contains('accepted')) {
    return walkerDetailsGreen;
  }

  if (normalized.contains('reject') ||
      normalized.contains('blocked') ||
      normalized.contains('suspend') ||
      normalized.contains('inactive')) {
    return walkerDetailsRed;
  }

  if (normalized.contains('pending') ||
      normalized.contains('review') ||
      normalized.contains('waiting')) {
    return walkerDetailsOrange;
  }

  return walkerDetailsBlue;
}

String walkerDetailsNormalize(
  String? value,
) {
  return value?.trim().toLowerCase() ?? '';
}

dynamic walkerDetailsRawValue(
  Map<String, dynamic> data,
  String key,
) {
  return data[key];
}

String walkerDetailsFirstValue(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = '—',
}) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final text = value.toString().trim();

    if (text.isNotEmpty &&
        text.toLowerCase() != 'null') {
      return text;
    }
  }

  return fallback;
}

String walkerDetailsFirstImage(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final url = value.toString().trim();

    if (url.isNotEmpty &&
        url.toLowerCase() != 'null' &&
        (url.startsWith('http://') ||
            url.startsWith('https://'))) {
      return url;
    }
  }

  return '';
}

String walkerDetailsStatusLabel(
  Map<String, dynamic> data,
) {
  final status = walkerDetailsStatus(data);

  return status.isEmpty ? 'Pending' : status;
}

Color walkerDetailsDocumentStatusColor(
  bool uploaded,
) {
  return uploaded
      ? walkerDetailsGreen
      : walkerDetailsRed;
}

String walkerDetailsDocumentStatus(
  bool uploaded,
) {
  return uploaded
      ? 'Uploaded'
      : 'Not Uploaded';
}
