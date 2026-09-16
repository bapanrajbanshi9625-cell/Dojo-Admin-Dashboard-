import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerAvailabilityModel {
  final String walkerId;
  final String walkerName;
  final String? photoUrl;

  // Insta Walk
  final bool instaWalkOnline;
  final bool instaWalkSearching;
  final bool hasActiveWalk;
  final String? status;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

  // Daily Walk
  final List<String> dailyWalkSlots;

  const WalkerAvailabilityModel({
    required this.walkerId,
    required this.walkerName,
    this.photoUrl,
    this.instaWalkOnline = false,
    this.instaWalkSearching = false,
    this.hasActiveWalk = false,
    this.status,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.dailyWalkSlots = const [],
  });

  factory WalkerAvailabilityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final location = data['location'];
    final geoPoint = location is GeoPoint ? location : null;

    return WalkerAvailabilityModel(
      // uid = Walker ID
      walkerId: _stringValue(
        data['uid'] ?? doc.id,
      ),

      walkerName: _stringValue(
        data['walkerName'] ??
            data['name'] ??
            data['displayName'] ??
            'Unknown Walker',
      ),

      photoUrl: _nullableString(
        data['photoUrl'] ??
            data['profileImage'] ??
            data['profileImageUrl'],
      ),

      // Insta Walk
      instaWalkOnline: _boolValue(
        data['instaWalkOnline'] ??
            data['online'] ??
            data['isOnline'] ??
            false,
      ),

      instaWalkSearching: _boolValue(
        data['instaWalkSearching'] ??
            data['searching'] ??
            data['availableForInstaWalk'] ??
            false,
      ),

      hasActiveWalk: _boolValue(
        data['hasActiveWalk'] ??
            data['activeWalk'] ??
            data['walkAccepted'] ??
            false,
      ),

      status: _nullableString(
        data['status'],
      ),

      latitude: _doubleValue(
        data['latitude'] ?? geoPoint?.latitude,
      ),

      longitude: _doubleValue(
        data['longitude'] ?? geoPoint?.longitude,
      ),

      lastLocationUpdate: _dateValue(
        data['lastLocationUpdate'] ??
            data['lastLocationAt'] ??
            data['updatedAt'],
      ),

      // Daily Walk
      dailyWalkSlots: _parseSlots(
        data['dailyWalkSlots'] ??
            data['bookedSlots'] ??
            data['availabilitySlots'] ??
            data['timeSlots'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': walkerId,
      'walkerName': walkerName,

      if (photoUrl != null) 'photoUrl': photoUrl,

      'instaWalkOnline': instaWalkOnline,
      'instaWalkSearching': instaWalkSearching,
      'hasActiveWalk': hasActiveWalk,

      if (status != null) 'status': status,

      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,

      if (lastLocationUpdate != null)
        'lastLocationUpdate': Timestamp.fromDate(
          lastLocationUpdate!,
        ),

      'dailyWalkSlots': dailyWalkSlots,
    };
  }

  WalkerAvailabilityModel copyWith({
    String? walkerId,
    String? walkerName,
    String? photoUrl,
    bool? instaWalkOnline,
    bool? instaWalkSearching,
    bool? hasActiveWalk,
    String? status,
    double? latitude,
    double? longitude,
    DateTime? lastLocationUpdate,
    List<String>? dailyWalkSlots,
  }) {
    return WalkerAvailabilityModel(
      walkerId: walkerId ?? this.walkerId,
      walkerName: walkerName ?? this.walkerName,
      photoUrl: photoUrl ?? this.photoUrl,
      instaWalkOnline:
          instaWalkOnline ?? this.instaWalkOnline,
      instaWalkSearching:
          instaWalkSearching ?? this.instaWalkSearching,
      hasActiveWalk:
          hasActiveWalk ?? this.hasActiveWalk,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastLocationUpdate:
          lastLocationUpdate ?? this.lastLocationUpdate,
      dailyWalkSlots:
          dailyWalkSlots ?? this.dailyWalkSlots,
    );
  }

  /// Walker should appear in Admin > Walker Availability > Insta Walk
  /// only when:
  /// - Online
  /// - Searching for Insta Walk
  /// - No active/accepted walk
  bool get isInstaWalkAvailable {
    return instaWalkOnline &&
        instaWalkSearching &&
        !hasActiveWalk;
  }

  bool get hasDailyWalkAvailability {
    return dailyWalkSlots.isNotEmpty;
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';

    return value.toString().trim();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }

  static double? _doubleValue(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static List<String> _parseSlots(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is List) {
      return value
          .map(
            (slot) => slot.toString().trim(),
          )
          .where(
            (slot) => slot.isNotEmpty,
          )
          .toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map(
            (slot) => slot.trim(),
          )
          .where(
            (slot) => slot.isNotEmpty,
          )
          .toList();
    }

    return const [];
  }
}
