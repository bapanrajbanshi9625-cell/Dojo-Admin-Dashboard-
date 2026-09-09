// File:
// lib/features/walk_requests/utils/walk_request_details_helpers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class WalkRequestDetailsHelpers {
  const WalkRequestDetailsHelpers._();

  // ==========================================================
  // GENERIC VALUE HELPERS
  // ==========================================================

  static String value(
    Map<String, dynamic> data,
    String key, [
    String fallback = '—',
  ]) {
    final raw = data[key];

    if (raw == null) {
      return fallback;
    }

    final text = raw.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  static String firstAvailable(
    Map<String, dynamic> data,
    List<String> keys, [
    String fallback = '—',
  ]) {
    for (final key in keys) {
      final raw = data[key];

      if (raw == null) {
        continue;
      }

      final text = raw.toString().trim();

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return fallback;
  }

  // ==========================================================
  // OWNER
  // ==========================================================

  static String ownerName(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'ownerName',
        'ownerDisplayName',
        'name',
      ],
      'Unknown Owner',
    );
  }

  static String ownerId(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'ownerId',
        'ownerAuthUid',
        'ownerUid',
      ],
    );
  }

  static String ownerPhone(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'ownerPhone',
        'ownerMobile',
        'ownerPhoneNumber',
        'phone',
        'mobile',
      ],
    );
  }

  // ==========================================================
  // WALKER
  // ==========================================================

  static String walkerName(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'walkerName',
        'walkerDisplayName',
      ],
    );
  }

  static String walkerId(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'walkerId',
      ],
    );
  }

  static String walkerUid(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'walkerUid',
        'walkerAuthUid',
        'acceptedByUid',
      ],
    );
  }

  static String walkerPhone(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'walkerPhone',
        'walkerMobile',
        'walkerPhoneNumber',
        'walkerMobileNumber',
      ],
    );
  }

  // ==========================================================
  // DOG
  // ==========================================================

  static String dogName(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'dogName',
        'petName',
      ],
      'Dog',
    );
  }

  static String dogBreed(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'dogBreed',
        'petBreed',
        'breed',
      ],
    );
  }

  static String dogPhoto(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'dogPhoto',
        'petPhoto',
        'dogImage',
        'petImage',
      ],
    );
  }

  // ==========================================================
  // REQUEST
  // ==========================================================

  static String address(
    Map<String, dynamic> data,
  ) {
    return firstAvailable(
      data,
      const [
        'address',
        'pickupAddress',
        'location',
      ],
      'Pickup address unavailable',
    );
  }

  static String searchType(
    Map<String, dynamic> data,
  ) {
    return value(
      data,
      'searchType',
      'Instant Walk',
    );
  }

  static String radius(
    Map<String, dynamic> data,
  ) {
    final raw = data['searchRadiusKm'];

    if (raw == null) {
      return '—';
    }

    final number = toDouble(raw);

    if (number == null) {
      return raw.toString();
    }

    return '${number.toStringAsFixed(1)} km';
  }

  // ==========================================================
  // DATE / TIME
  // ==========================================================

  /// Converts Firestore Timestamp, DateTime, String or numeric
  /// timestamp into DateTime.
  static DateTime? dateTime(
    dynamic raw,
  ) {
    if (raw == null) {
      return null;
    }

    if (raw is Timestamp) {
      return raw.toDate();
    }

    if (raw is DateTime) {
      return raw;
    }

    if (raw is String) {
      return DateTime.tryParse(
        raw.trim(),
      );
    }

    if (raw is num) {
      final number = raw.toInt();

      // Small numeric timestamps are treated as seconds.
      // Larger values are treated as milliseconds.
      if (number.abs() < 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(
          number * 1000,
        );
      }

      return DateTime.fromMillisecondsSinceEpoch(
        number,
      );
    }

    return null;
  }

  /// Returns the raw DateTime of request creation.
  static DateTime? createdAt(
    Map<String, dynamic> data,
  ) {
    return dateTime(
      data['createdAt'],
    );
  }

  /// Returns the raw DateTime of walker acceptance.
  static DateTime? acceptedAt(
    Map<String, dynamic> data,
  ) {
    return dateTime(
      data['acceptedAt'],
    );
  }

  /// Returns the raw DateTime when walker reached pickup.
  static DateTime? reachedAt(
    Map<String, dynamic> data,
  ) {
    return dateTime(
      data['reachedAt'],
    );
  }

  /// Returns the raw DateTime of the latest walker location update.
  static DateTime? locationUpdatedAt(
    Map<String, dynamic> data,
  ) {
    return dateTime(
      data['locationUpdatedAt'],
    );
  }

  /// Returns the raw DateTime of the latest request update.
  static DateTime? updatedAt(
    Map<String, dynamic> data,
  ) {
    return dateTime(
      data['updatedAt'],
    );
  }

  /// Finds the first valid DateTime from the supplied keys.
  static DateTime? firstDateTime(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final parsed = dateTime(
        data[key],
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  static String formatDate(
    DateTime date,
  ) {
    final local = date.toLocal();

    final day =
        local.day.toString().padLeft(2, '0');

    final month =
        local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  static String formatTime(
    DateTime date,
  ) {
    final local = date.toLocal();

    final hour =
        local.hour.toString().padLeft(2, '0');

    final minute =
        local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  static String formatDateTime(
    DateTime date,
  ) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  static String status(
    Map<String, dynamic> data,
  ) {
    return value(
      data,
      'status',
      'pending',
    ).trim().toLowerCase();
  }

  static bool isPending(
    Map<String, dynamic> data,
  ) {
    final current = status(data);

    return current == 'pending' ||
        current == 'searching' ||
        current == 'requested';
  }

  static bool isAccepted(
    Map<String, dynamic> data,
  ) {
    final current = status(data);

    return current == 'accepted' ||
        current == 'assigned';
  }

  static bool isActive(
    Map<String, dynamic> data,
  ) {
    final current = status(data);

    return current == 'active' ||
        current == 'started' ||
        current == 'in_progress' ||
        current == 'in-progress' ||
        current == 'live';
  }

  static bool isCompleted(
    Map<String, dynamic> data,
  ) {
    final current = status(data);

    return current == 'completed' ||
        current == 'complete';
  }

  static bool isCancelled(
    Map<String, dynamic> data,
  ) {
    final current = status(data);

    return current == 'cancelled' ||
        current == 'canceled' ||
        current == 'rejected';
  }

  static bool isFinished(
    Map<String, dynamic> data,
  ) {
    return isCompleted(data) ||
        isCancelled(data);
  }

  // ==========================================================
  // WALKER ASSIGNMENT
  // ==========================================================

  static bool hasWalker(
    Map<String, dynamic> data,
  ) {
    return walkerName(data) != '—' ||
        walkerId(data) != '—' ||
        walkerUid(data) != '—';
  }

  // ==========================================================
  // OWNER LOCATION
  // ==========================================================

  static LatLng? ownerLocation(
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      data['ownerLocation'],
      data['pickupLocation'],
      data['owner_location'],
      data['pickup_location'],
    ];

    for (final candidate in candidates) {
      final location = parseLocation(
        candidate,
      );

      if (location != null) {
        return location;
      }
    }

    return _latLngFromFields(
      data,
      latitudeKeys: const [
        'ownerLatitude',
        'pickupLatitude',
      ],
      longitudeKeys: const [
        'ownerLongitude',
        'pickupLongitude',
      ],
    );
  }

  // ==========================================================
  // WALKER LIVE LOCATION
  // ==========================================================

  static LatLng? walkerLocation(
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      data['walkerLocation'],
      data['walker_location'],
      data['currentWalkerLocation'],
      data['current_walker_location'],
    ];

    for (final candidate in candidates) {
      final location = parseLocation(
        candidate,
      );

      if (location != null) {
        return location;
      }
    }

    return _latLngFromFields(
      data,
      latitudeKeys: const [
        'walkerLatitude',
        'walkerLat',
        'currentWalkerLatitude',
        'currentWalkerLat',
      ],
      longitudeKeys: const [
        'walkerLongitude',
        'walkerLng',
        'currentWalkerLongitude',
        'currentWalkerLng',
      ],
    );
  }

  // ==========================================================
  // LOCATION PARSER
  // ==========================================================

  static LatLng? parseLocation(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    // Firestore GeoPoint.
    if (value is GeoPoint) {
      return _safeLatLng(
        value.latitude,
        value.longitude,
      );
    }

    // Already parsed LatLng.
    if (value is LatLng) {
      return _safeLatLng(
        value.latitude,
        value.longitude,
      );
    }

    // Map-based location.
    if (value is Map) {
      final map =
          Map<String, dynamic>.from(value);

      final latitude = toDouble(
        map['latitude'] ??
            map['lat'] ??
            map['currentLatitude'] ??
            map['currentLat'],
      );

      final longitude = toDouble(
        map['longitude'] ??
            map['lng'] ??
            map['lon'] ??
            map['currentLongitude'] ??
            map['currentLng'],
      );

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    // [latitude, longitude]
    if (value is List &&
        value.length >= 2) {
      final latitude =
          toDouble(value[0]);

      final longitude =
          toDouble(value[1]);

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    return null;
  }

  static LatLng? _latLngFromFields(
    Map<String, dynamic> data, {
    required List<String> latitudeKeys,
    required List<String> longitudeKeys,
  }) {
    dynamic latitudeValue;
    dynamic longitudeValue;

    for (final key in latitudeKeys) {
      if (data[key] != null) {
        latitudeValue = data[key];
        break;
      }
    }

    for (final key in longitudeKeys) {
      if (data[key] != null) {
        longitudeValue = data[key];
        break;
      }
    }

    final latitude =
        toDouble(latitudeValue);

    final longitude =
        toDouble(longitudeValue);

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    return _safeLatLng(
      latitude,
      longitude,
    );
  }

  static LatLng? _safeLatLng(
    double latitude,
    double longitude,
  ) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return LatLng(
      latitude,
      longitude,
    );
  }

  // ==========================================================
  // NUMBER
  // ==========================================================

  static double? toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final text = value
        .toString()
        .trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(
      text,
    );
  }
}
