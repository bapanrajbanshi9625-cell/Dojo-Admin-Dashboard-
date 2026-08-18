import 'package:flutter/material.dart';

class WalkerHelpers {
  static String stringValue(
    dynamic walker,
    String key, [
    String fallback = '',
  ]) {
    try {
      if (walker is Map) {
        final value = walker[key];
        return value?.toString() ?? fallback;
      }

      final map = walker.toMap();
      final value = map[key];
      return value?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String name(dynamic walker) {
    return stringValue(
      walker,
      'Full Name',
      stringValue(
        walker,
        'fullName',
        'Unknown Walker',
      ),
    );
  }

  static String mobile(dynamic walker) {
    return stringValue(
      walker,
      'Mobile number',
      stringValue(
        walker,
        'mobileNumber',
      ),
    );
  }

  static String address(dynamic walker) {
    return stringValue(
      walker,
      'Adress',
      stringValue(
        walker,
        'Address',
      ),
    );
  }

  static String pincode(dynamic walker) {
    return stringValue(
      walker,
      'Pincode',
      stringValue(
        walker,
        'pincode',
      ),
    );
  }

  static String dateOfBirth(dynamic walker) {
    return stringValue(
      walker,
      'Date Of Birth',
      stringValue(
        walker,
        'dateOfBirth',
      ),
    );
  }

  static String aadhaarNumber(dynamic walker) {
    return stringValue(
      walker,
      'Aadhar Number',
      stringValue(
        walker,
        'aadhaarNumber',
      ),
    );
  }

  static String walkerUid(dynamic walker) {
    return stringValue(
      walker,
      'Walker Uid',
      stringValue(
        walker,
        'walkerUid',
      ),
    );
  }

  static String profileSelfie(dynamic walker) {
    return stringValue(
      walker,
      'Profile Selfie',
      stringValue(
        walker,
        'profileSelfie',
      ),
    );
  }

  static String status(dynamic walker) {
    return stringValue(
      walker,
      'status',
      'Pending',
    );
  }

  static bool boolValue(
    dynamic walker,
    String key, [
    bool fallback = false,
  ]) {
    try {
      if (walker is Map) {
        final value = walker[key];

        if (value is bool) {
          return value;
        }

        if (value is String) {
          return value.toLowerCase() == 'true';
        }

        return fallback;
      }

      final map = walker.toMap();
      final value = map[key];

      if (value is bool) {
        return value;
      }

      if (value is String) {
        return value.toLowerCase() == 'true';
      }

      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  static bool isOnline(dynamic walker) {
    return boolValue(walker, 'online') ||
        boolValue(walker, 'isOnline');
  }

  static bool isApproved(dynamic walker) {
    final value = status(walker).toLowerCase();

    return value == 'approved' ||
        value == 'active';
  }

  static bool isPending(dynamic walker) {
    return status(walker).toLowerCase() == 'pending';
  }

  static bool isRejected(dynamic walker) {
    return status(walker).toLowerCase() == 'rejected';
  }

  static Color statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
      case 'active':
        return const Color(0xFF16A34A);

      case 'online':
        return const Color(0xFF059669);

      case 'rejected':
        return const Color(0xFFDC2626);

      case 'pending':
        return const Color(0xFFF59E0B);

      default:
        return const Color(0xFF6B7280);
    }
  }

  static String initials(dynamic walker) {
    final value = name(walker).trim();

    if (value.isEmpty) {
      return 'W';
    }

    final parts = value.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
