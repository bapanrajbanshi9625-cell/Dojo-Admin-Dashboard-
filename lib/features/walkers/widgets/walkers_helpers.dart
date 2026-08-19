import 'package:flutter/material.dart';

// ============================================================
// WALKER DETAILS COLORS
// ============================================================

const Color walkerDetailsOrange = Color(0xFFFF6600);
const Color walkerDetailsGreen = Color(0xFF16A34A);
const Color walkerDetailsRed = Color(0xFFDC2626);
const Color walkerDetailsBlue = Color(0xFF2563EB);

const Color walkerDetailsTextDark = Color(0xFF111827);
const Color walkerDetailsTextGrey = Color(0xFF6B7280);
const Color walkerDetailsBorder = Color(0xFFE5E7EB);
const Color walkerDetailsPageBg = Color(0xFFF7F8FA);

// ============================================================
// READ VALUE
// ============================================================

String walkerDetailsValue(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = 'Not available',
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

// ============================================================
// READ BOOLEAN
// ============================================================

bool walkerDetailsBool(
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

    if (value != null) {
      final text = value.toString().trim().toLowerCase();

      if (text == 'true' ||
          text == '1' ||
          text == 'yes') {
        return true;
      }

      if (text == 'false' ||
          text == '0' ||
          text == 'no') {
        return false;
      }
    }
  }

  return false;
}

// ============================================================
// IMAGE URL
// ============================================================

String walkerDetailsImageUrl(
  Map<String, dynamic> data,
  List<String> keys,
) {
  return walkerDetailsValue(
    data,
    keys,
    fallback: '',
  );
}

// ============================================================
// STATUS
// ============================================================

String walkerDetailsStatus(
  Map<String, dynamic> data,
) {
  final status = walkerDetailsValue(
    data,
    const [
      'verificationStatus',
      'approvalStatus',
      'status',
    ],
    fallback: '',
  ).toLowerCase().trim();

  if (status == 'approved') {
    return 'Approved';
  }

  if (status == 'rejected') {
    return 'Rejected';
  }

  if (status == 'pending') {
    return 'Pending';
  }

  if (walkerDetailsBool(
    data,
    const [
      'approved',
      'isApproved',
      'adminApproved',
    ],
  )) {
    return 'Approved';
  }

  if (walkerDetailsBool(
    data,
    const [
      'rejected',
      'isRejected',
      'adminRejected',
    ],
  )) {
    return 'Rejected';
  }

  return 'Pending';
}

// ============================================================
// STATUS COLOR
// ============================================================

Color walkerDetailsStatusColor(
  String status,
) {
  switch (status) {
    case 'Approved':
      return walkerDetailsGreen;

    case 'Rejected':
      return walkerDetailsRed;

    default:
      return walkerDetailsOrange;
  }
}
