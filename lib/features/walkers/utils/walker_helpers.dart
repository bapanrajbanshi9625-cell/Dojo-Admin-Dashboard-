import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color pendingColor = Color(0xFFD99000);
const Color rejectedColor = Color(0xFFC62828);

String normalizeWalkerStatus(String status) {
  final value = status.trim().toLowerCase();

  if (value == 'approved') {
    return 'approved';
  }

  if (value == 'rejected') {
    return 'rejected';
  }

  return 'pending';
}

Color walkerStatusColor(String status) {
  switch (normalizeWalkerStatus(status)) {
    case 'approved':
      return dojoGreen;

    case 'rejected':
      return rejectedColor;

    default:
      return pendingColor;
  }
}

String walkerStatusLabel(String status) {
  switch (normalizeWalkerStatus(status)) {
    case 'approved':
      return 'Approved';

    case 'rejected':
      return 'Rejected';

    default:
      return 'Pending';
  }
}

bool isWalkerApproved(String status) {
  return normalizeWalkerStatus(status) == 'approved';
}

bool isWalkerRejected(String status) {
  return normalizeWalkerStatus(status) == 'rejected';
}

bool isWalkerPending(String status) {
  return normalizeWalkerStatus(status) == 'pending';
}

String safeText(String? value) {
  final text = value?.trim() ?? '';

  return text.isEmpty ? '—' : text;
}

String maskAadhaar(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');

  if (digits.length < 4) {
    return value.isEmpty ? '—' : value;
  }

  return 'XXXX XXXX ${digits.substring(digits.length - 4)}';
}

String maskPan(String value) {
  final text = value.trim();

  if (text.length <= 4) {
    return text.isEmpty ? '—' : text;
  }

  return '${'*' * (text.length - 4)}${text.substring(text.length - 4)}';
}
