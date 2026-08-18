import 'package:flutter/material.dart';

class WalkerHelpers {
  WalkerHelpers._();

  // ============================================================
  // BASIC VALUE READER
  // ============================================================

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
        break;

      case 'Mobile number':
        try {
          return object.mobile;
        } catch (_) {}
        break;

      case 'Adress':
        try {
          return object.address;
        } catch (_) {}
        break;

      case 'Pincode':
        try {
          return object.pincode;
        } catch (_) {}
        break;

      case 'Date Of Birth':
        try {
          return object.dateOfBirth;
        } catch (_) {}
        break;

      case 'Aadhar Number':
        try {
          return object.aadhaarNumber;
        } catch (_) {}
        break;

      case 'Walker Uid':
        try {
          return object.walkerUid;
        } catch (_) {}
        break;

      case 'Profile Selfie':
        try {
          return object.profileSelfie;
        } catch (_) {}
        break;

      case 'status':
        try {
          return object.status;
        } catch (_) {}
        break;
    }

    return null;
  }

  // ============================================================
  // WALKER INFORMATION
  // ============================================================

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

  // ============================================================
  // STATUS
  // ============================================================

  static String status(dynamic walker) {
    return _firstNonEmpty([
      _value(walker, 'status'),
      _value(walker, 'Status'),
      _value(walker, 'walkerStatus'),
      _value(walker, 'verificationStatus'),
      _value(walker, 'Verification Status'),
      'Pending',
    ]);
  }

  static String verificationStatus(dynamic walker) {
    final value = status(walker).trim().toLowerCase();

    if (value.isEmpty) {
      return 'pending';
    }

    switch (value) {
      case 'approved':
      case 'approve':
      case 'active':
      case 'verified':
        return 'approved';

      case 'rejected':
      case 'reject':
        return 'rejected';

      case 'pending':
      case 'pending approval':
      case 'waiting':
      case 'under review':
        return 'pending';

      default:
        return value;
    }
  }

  // ============================================================
  // ONLINE STATUS
  // ============================================================

  static bool isOnline(dynamic walker) {
    if (walker == null) return false;

    if (walker is Map) {
      final value = walker['isOnline'];

      if (value is bool) {
        return value;
      }

      if (value != null) {
        return value.toString().toLowerCase() == 'true';
      }

      final statusValue =
          walker['status'] ?? walker['Status'];

      if (statusValue != null) {
        return statusValue
                .toString()
                .trim()
                .toLowerCase() ==
            'online';
      }

      return false;
    }

    try {
      final value = walker.isOnline;

      if (value is bool) {
        return value;
      }

      return value?.toString().toLowerCase() == 'true';
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  static bool matchesSearch(
    dynamic walker,
    String search,
  ) {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final searchableValues = <String>[
      name(walker),
      mobile(walker),
      address(walker),
      pincode(walker),
      dateOfBirth(walker),
      aadhaarNumber(walker),
      walkerUid(walker),
      status(walker),
    ];

    return searchableValues.any(
      (value) => value.toLowerCase().contains(query),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  static bool matchesFilter(
    dynamic walker,
    String filter,
  ) {
    final normalizedFilter =
        filter.trim().toLowerCase();

    if (normalizedFilter.isEmpty ||
        normalizedFilter == 'all') {
      return true;
    }

    switch (normalizedFilter) {
      case 'online':
        return isOnline(walker);

      case 'offline':
        return !isOnline(walker);

      case 'pending':
        return verificationStatus(walker) ==
            'pending';

      case 'approved':
        return verificationStatus(walker) ==
            'approved';

      case 'rejected':
        return verificationStatus(walker) ==
            'rejected';

      default:
        return true;
    }
  }

  // ============================================================
  // INITIALS
  // ============================================================

  static String initials(dynamic walker) {
    final fullName = name(walker).trim();

    if (fullName.isEmpty ||
        fullName.toLowerCase() ==
            'unknown walker') {
      return 'W';
    }

    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  static Widget emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 52,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 14),
          Text(
            'No walkers found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing your search or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  static Widget errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFECACA),
            ),
          ),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIRST NON-EMPTY
  // ============================================================

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
