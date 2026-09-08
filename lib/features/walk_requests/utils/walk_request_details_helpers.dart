// File:
// lib/features/walk_requests/utils/walk_request_details_helpers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class WalkRequestDetailsHelpers {
  const WalkRequestDetailsHelpers._();

  static String value(
    Map<String, dynamic> data,
    String key, [
    String fallback = '—',
  ]) {
    final value = data[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

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
      final value = data[key];

      if (value == null) {
        continue;
      }

      final text = value.toString().trim();

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return fallback;
  }

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
        'walkerUid',
        'walkerAuthUid',
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
        'phone',
        'mobile',
      ],
    );
  }

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
    final radius = data['searchRadiusKm'];

    if (radius == null) {
      return '—';
    }

    return '$radius km';
  }

  static String createdAt(
    Map<String, dynamic> data,
  ) {
    final value = data['createdAt'];

    if (value == null) {
      return '—';
    }

    if (value is Timestamp) {
      return formatDate(value.toDate());
    }

    if (value is DateTime) {
      return formatDate(value);
    }

    return value.toString();
  }

  static String formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  static bool hasWalker(
    Map<String, dynamic> data,
  ) {
    final name = walkerName(data);
    final id = walkerId(data);

    return name != '—' ||
        id != '—' ||
        data['walkerId'] != null;
  }

  static bool isPending(
    Map<String, dynamic> data,
  ) {
    final status = value(
      data,
      'status',
      'pending',
    ).toLowerCase();

    return status == 'pending' ||
        status == 'searching' ||
        status == 'requested';
  }

  static LatLng? ownerLocation(
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      data['ownerLocation'],
      data['pickupLocation'],
      data['location'],
      data['currentLocation'],
    ];

    for (final candidate in candidates) {
      final location = parseLocation(candidate);

      if (location != null) {
        return location;
      }
    }

    final latitude = toDouble(data['latitude']);
    final longitude = toDouble(data['longitude']);

    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    final lat = toDouble(data['lat']);
    final lng = toDouble(data['lng']);

    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }

    final lon = toDouble(data['lon']);

    if (lat != null && lon != null) {
      return LatLng(lat, lon);
    }

    return null;
  }

  static LatLng? parseLocation(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is GeoPoint) {
      return LatLng(
        value.latitude,
        value.longitude,
      );
    }

    if (value is LatLng) {
      return value;
    }

    if (value is Map) {
      final latitude = toDouble(
        value['latitude'] ?? value['lat'],
      );

      final longitude = toDouble(
        value['longitude'] ??
            value['lng'] ??
            value['lon'],
      );

      if (latitude != null && longitude != null) {
        return LatLng(
          latitude,
          longitude,
        );
      }
    }

    if (value is List && value.length >= 2) {
      final latitude = toDouble(value[0]);
      final longitude = toDouble(value[1]);

      if (latitude != null && longitude != null) {
        return LatLng(
          latitude,
          longitude,
        );
      }
    }

    return null;
  }

  static double? toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}
