import 'package:flutter/material.dart';

class WalkersHelpers {
  WalkersHelpers._();

  static String _value(
    dynamic walker,
    String key,
  ) {
    if (walker == null) {
      return '';
    }

    if (walker is Map) {
      final value = walker[key];
      return value?.toString().trim() ?? '';
    }

    try {
      final value = _readObjectValue(walker, key);
      return value?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static dynamic _readObjectValue(
    dynamic object,
    String key,
  ) {
    switch (key) {
      case 'Full Name':
        try {
          return object.name;
        } catch (_) {}

      case 'Mobile number':
        try {
          return object.mobile;
        } catch (_) {}

      case 'Adress':
        try {
          return object.address;
        } catch (_) {}

      case 'Pincode':
        try {
          return object.pincode;
        } catch (_) {}

      case 'Date Of Birth':
        try {
          return object.dateOfBirth;
        } catch (_) {}

      case 'Aadhar Number':
        try {
          return object.aadhaarNumber;
        } catch (_) {}

      case 'Walker Uid':
        try {
          return object.walkerUid;
        } catch (_) {}

      case 'Profile Selfie':
        try {
          return object.profileSelfie;
        } catch (_) {}

      case 'status':
        try {
          return object.status;
        } catch (_) {}

      case 'verificationStatus':
        try {
          return object.verificationStatus;
        } catch (_) {}

      case 'isOnline':
        try {
          return object.isOnline;
        } catch (_) {}

      case 'online':
        try {
          return object.online;
        } catch (_) {}
    }

    return null;
  }

  // =========================================================
  // BASIC WALKER DATA
  // =========================================================

  static String name(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Full Name'),
      _value(walker, 'fullName'),
      _value(walker, 'name'),
      _value(walker, 'walkerName'),
      'Unknown Walker',
    ]);
  }

  static String mobile(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Mobile number'),
      _value(walker, 'mobileNumber'),
      _value(walker, 'mobile'),
      _value(walker, 'phone'),
      _value(walker, 'phoneNumber'),
    ]);
  }

  static String address(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Adress'),
      _value(walker, 'Address'),
      _value(walker, 'address'),
    ]);
  }

  static String pincode(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Pincode'),
      _value(walker, 'pincode'),
      _value(walker, 'pinCode'),
      _value(walker, 'postalCode'),
    ]);
  }

  static String dateOfBirth(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Date Of Birth'),
      _value(walker, 'dateOfBirth'),
      _value(walker, 'dob'),
    ]);
  }

  static String aadhaarNumber(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Aadhar Number'),
      _value(walker, 'Aadhaar Number'),
      _value(walker, 'aadhaarNumber'),
      _value(walker, 'aadharNumber'),
    ]);
  }

  static String walkerUid(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Walker Uid'),
      _value(walker, 'walkerUid'),
      _value(walker, 'uid'),
      _value(walker, 'id'),
    ]);
  }

  static String profileSelfie(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Profile Selfie'),
      _value(walker, 'profileSelfie'),
      _value(walker, 'profileImage'),
      _value(walker, 'photoUrl'),
    ]);
  }

  // =========================================================
  // STATUS
  // =========================================================

  static String status(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'status'),
      _value(walker, 'Status'),
      _value(walker, 'walkerStatus'),
      _value(walker, 'verificationStatus'),
      _value(walker, 'approvalStatus'),
      'pending',
    ]);
  }

  static String verificationStatus(dynamic walker) {
    final value = _firstNonEmpty([
      _value(walker, 'verificationStatus'),
      _value(walker, 'approvalStatus'),
      _value(walker, 'status'),
      _value(walker, 'Status'),
      _value(walker, 'walkerStatus'),
      'pending',
    ]);

    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'approved':
      case 'approve':
      case 'active':
        return 'approved';

      case 'rejected':
      case 'reject':
        return 'rejected';

      case 'blocked':
        return 'blocked';

      case 'suspended':
        return 'suspended';

      case 'pending':
      case 'pending approval':
      case 'waiting':
      case 'under review':
        return 'pending';

      default:
        return normalized.isEmpty ? 'pending' : normalized;
    }
  }

  // =========================================================
  // ONLINE STATUS
  // =========================================================

  static bool isOnline(dynamic walker) {
    if (walker == null) {
      return false;
    }

    if (walker is Map) {
      final directValues = <dynamic>[
        walker['isOnline'],
        walker['online'],
        walker['is_online'],
        walker['onlineStatus'],
        walker['walkerOnline'],
      ];

      for (final value in directValues) {
        final result = _toBool(value);

        if (result != null) {
          return result;
        }
      }

      final statusValue = _firstNonEmpty([
        walker['status']?.toString() ?? '',
        walker['walkerStatus']?.toString() ?? '',
      ]).toLowerCase();

      return statusValue == 'online';
    }

    try {
      final objectValue = _readObjectValue(
        walker,
        'isOnline',
      );

      final result = _toBool(objectValue);

      if (result != null) {
        return result;
      }
    } catch (_) {}

    return status(walker).trim().toLowerCase() == 'online';
  }

  static bool? _toBool(dynamic value) {
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
          normalized == '1' ||
          normalized == 'online') {
        return true;
      }

      if (normalized == 'false' ||
          normalized == 'no' ||
          normalized == '0' ||
          normalized == 'offline') {
        return false;
      }
    }

    return null;
  }

  // =========================================================
  // INITIALS
  // =========================================================

  static String initials(dynamic walker) {
    final fullName = name(walker).trim();

    if (fullName.isEmpty ||
        fullName.toLowerCase() == 'unknown walker') {
      return 'W';
    }

    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'W';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // =========================================================
  // STATUS COLOR
  // =========================================================

  static Color statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'approved':
      case 'active':
      case 'online':
        return const Color(0xFF16A34A);

      case 'rejected':
      case 'blocked':
      case 'suspended':
        return const Color(0xFFDC2626);

      case 'pending':
      case 'pending approval':
        return const Color(0xFFF59E0B);

      case 'offline':
        return const Color(0xFF6B7280);

      default:
        return const Color(0xFFF59E0B);
    }
  }

  // =========================================================
  // PRIVATE HELPERS
  // =========================================================

  static String _firstNonEmpty(
    List<String> values,
  ) {
    for (final value in values) {
      final cleaned = value.trim();

      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return '';
  }
}
