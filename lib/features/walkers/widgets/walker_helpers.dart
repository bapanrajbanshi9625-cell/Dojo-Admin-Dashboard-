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
        } catch (_) {
          return null;
        }

      case 'Mobile number':
        try {
          return object.mobile;
        } catch (_) {
          return null;
        }

      case 'Adress':
        try {
          return object.address;
        } catch (_) {
          return null;
        }

      case 'Pincode':
        try {
          return object.pincode;
        } catch (_) {
          return null;
        }

      case 'Date Of Birth':
        try {
          return object.dateOfBirth;
        } catch (_) {
          return null;
        }

      case 'Aadhar Number':
        try {
          return object.aadhaarNumber;
        } catch (_) {
          return null;
        }

      case 'Walker Uid':
        try {
          return object.walkerUid;
        } catch (_) {
          return null;
        }

      case 'Profile Selfie':
        try {
          return object.profileSelfie;
        } catch (_) {
          return null;
        }

      case 'status':
        try {
          return object.status;
        } catch (_) {
          return null;
        }
    }

    return null;
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
      _value(walker, 'verificationStatus'),
    ]);
  }

  static String verificationStatus(dynamic walker) {
    final value = status(walker).toLowerCase();

    if (value.contains('approved') || value == 'active') {
      return 'approved';
    }

    if (value.contains('rejected') ||
        value == 'blocked' ||
        value == 'suspended') {
      return 'rejected';
    }

    return 'pending';
  }

  static bool isOnline(dynamic walker) {
    final online = _value(walker, 'online').toLowerCase();

    if (online == 'true') return true;

    final statusValue = status(walker).toLowerCase();

    return statusValue == 'online';
  }

  static bool matchesSearch(
    dynamic walker,
    String search,
  ) {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) return true;

    final values = <String>[
      name(walker),
      mobile(walker),
      address(walker),
      pincode(walker),
      walkerUid(walker),
      aadhaarNumber(walker),
    ];

    return values.any(
      (value) => value.toLowerCase().contains(query),
    );
  }

  static bool matchesFilter(
    dynamic walker,
    String filter,
  ) {
    switch (filter.toLowerCase()) {
      case 'all':
        return true;

      case 'online':
        return isOnline(walker);

      case 'pending':
        return verificationStatus(walker) == 'pending';

      case 'approved':
        return verificationStatus(walker) == 'approved';

      case 'rejected':
        return verificationStatus(walker) == 'rejected';

      default:
        return true;
    }
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

  static Widget emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 52,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 12),
            Text(
              'No walkers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load walkers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
