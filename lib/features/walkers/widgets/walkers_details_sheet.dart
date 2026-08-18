import 'package:flutter/material.dart';

class WalkerHelpers {
  WalkerHelpers._();

  static String _value(dynamic walker, String key) {
    if (walker == null) return '';

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

  static dynamic _readObjectValue(dynamic object, String key) {
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
    }

    return null;
  }

  static String name(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Full Name'),
      _value(walker, 'fullName'),
      _value(walker, 'name'),
      'Unknown Walker',
    ]);
  }

  static String mobile(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'Mobile number'),
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

  static String status(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'status'),
      _value(walker, 'Status'),
      _value(walker, 'walkerStatus'),
    ]);
  }

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

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

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

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final cleaned = value.trim();

      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return '';
  }
}
