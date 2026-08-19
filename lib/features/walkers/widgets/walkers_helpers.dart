import 'package:flutter/material.dart';

/// ============================================================
/// DOJO WALKER DETAILS - COLORS
/// ============================================================

const Color walkerDetailsOrange = Color(0xFFFF6600);
const Color walkerDetailsRed = Color(0xFFE53935);
const Color walkerDetailsGreen = Color(0xFF2E7D32);
const Color walkerDetailsBlue = Color(0xFF1976D2);

const Color walkerDetailsPageBg = Color(0xFFF7F8FA);
const Color walkerDetailsTextDark = Color(0xFF1F2937);
const Color walkerDetailsTextGrey = Color(0xFF6B7280);
const Color walkerDetailsBorder = Color(0xFFE5E7EB);


/// ============================================================
/// SAFE STRING VALUE
/// ============================================================

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


/// ============================================================
/// IMAGE URL
/// ============================================================

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


/// ============================================================
/// BOOLEAN VALUE
/// ============================================================

bool walkerDetailsBool(
  Map<String, dynamic> data,
  String key, {
  bool fallback = false,
}) {
  final value = data[key];

  if (value is bool) {
    return value;
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

  if (value is num) {
    return value != 0;
  }

  return fallback;
}


/// ============================================================
/// WALKER STATUS
/// ============================================================

String walkerDetailsStatus(
  Map<String, dynamic> data,
) {
  final candidates = <String>[
    'status',
    'Status',
    'approvalStatus',
    'approval_status',
    'verificationStatus',
    'verification_status',
  ];

  for (final key in candidates) {
    final value = data[key];

    if (value != null) {
      final text = value.toString().trim();

      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
  }

  final active = walkerDetailsBool(
    data,
    'active',
    fallback: false,
  );

  final approved = walkerDetailsBool(
    data,
    'approved',
    fallback: false,
  );

  if (approved) {
    return 'Approved';
  }

  if (active) {
    return 'Active';
  }

  return 'Pending';
}


/// ============================================================
/// STATUS COLOR
/// ============================================================

Color walkerDetailsStatusColor(String status) {
  final normalized = status.trim().toLowerCase();

  if (normalized.contains('approved') ||
      normalized.contains('approve') ||
      normalized.contains('active') ||
      normalized.contains('verified') ||
      normalized.contains('accepted')) {
    return walkerDetailsGreen;
  }

  if (normalized.contains('reject') ||
      normalized.contains('rejected') ||
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


/// ============================================================
/// NORMALIZE TEXT
/// ============================================================

String walkerDetailsNormalize(String? value) {
  if (value == null) {
    return '';
  }

  return value.trim().toLowerCase();
}


/// ============================================================
/// SAFE MAP VALUE
/// ============================================================

dynamic walkerDetailsRawValue(
  Map<String, dynamic> data,
  String key,
) {
  return data[key];
}


/// ============================================================
/// MULTI-KEY VALUE
/// Useful when Firestore has different field names.
/// ============================================================

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

    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  return fallback;
}


/// ============================================================
/// MULTI-KEY IMAGE
/// ============================================================

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


/// ============================================================
/// STATUS LABEL
/// ============================================================

String walkerDetailsStatusLabel(
  Map<String, dynamic> data,
) {
  final status = walkerDetailsStatus(data);

  if (status.isEmpty) {
    return 'Pending';
  }

  return status;
}


/// ============================================================
/// DOCUMENT STATUS COLOR
/// ============================================================

Color walkerDetailsDocumentStatusColor(bool uploaded) {
  return uploaded ? walkerDetailsGreen : walkerDetailsRed;
}


/// ============================================================
/// DOCUMENT STATUS TEXT
/// ============================================================

String walkerDetailsDocumentStatus(bool uploaded) {
  return uploaded ? 'Uploaded' : 'Not Uploaded';
}
