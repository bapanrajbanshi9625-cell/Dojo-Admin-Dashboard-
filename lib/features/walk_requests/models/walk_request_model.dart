import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequestModel {
  final String documentId;
  final String requestId;

  final DateTime? acceptedAt;
  final String acceptedBy;
  final String acceptedByUid;

  final String address;

  final double arrivalDistanceKm;
  final int arrivalDistanceMeters;
  final int arrivalDurationMinutes;

  final String businessId;
  final DateTime? createdAt;

  final String dogBreed;
  final String dogName;

  final DateTime? locationUpdatedAt;

  final String ownerAuthUid;
  final String ownerId;
  final GeoPoint? ownerLocation;
  final String ownerLocationType;
  final String ownerName;

  final bool reached;
  final DateTime? reachedAt;

  final double searchRadiusKm;
  final String searchType;

  final String senderRole;
  final String senderUid;

  final String status;
  final DateTime? updatedAt;

  final double walkerHeading;
  final String walkerId;
  final GeoPoint? walkerLocation;
  final String walkerName;
  final String walkerPhone;
  final String walkerProfileImage;
  final double walkerSpeed;
  final String walkerUid;

  const WalkRequestModel({
    required this.documentId,
    required this.requestId,
    required this.acceptedAt,
    required this.acceptedBy,
    required this.acceptedByUid,
    required this.address,
    required this.arrivalDistanceKm,
    required this.arrivalDistanceMeters,
    required this.arrivalDurationMinutes,
    required this.businessId,
    required this.createdAt,
    required this.dogBreed,
    required this.dogName,
    required this.locationUpdatedAt,
    required this.ownerAuthUid,
    required this.ownerId,
    required this.ownerLocation,
    required this.ownerLocationType,
    required this.ownerName,
    required this.reached,
    required this.reachedAt,
    required this.searchRadiusKm,
    required this.searchType,
    required this.senderRole,
    required this.senderUid,
    required this.status,
    required this.updatedAt,
    required this.walkerHeading,
    required this.walkerId,
    required this.walkerLocation,
    required this.walkerName,
    required this.walkerPhone,
    required this.walkerProfileImage,
    required this.walkerSpeed,
    required this.walkerUid,
  });

  factory WalkRequestModel.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return WalkRequestModel(
      documentId: documentId,

      requestId: _stringFrom(data['requestId']),

      acceptedAt: _dateFrom(data['acceptedAt']),
      acceptedBy: _stringFrom(data['acceptedBy']),
      acceptedByUid: _stringFrom(data['acceptedByUid']),

      address: _stringFrom(data['address']),

      arrivalDistanceKm:
          _doubleFrom(data['arrivalDistanceKm']),

      arrivalDistanceMeters:
          _intFrom(data['arrivalDistanceMeters']),

      arrivalDurationMinutes:
          _intFrom(data['arrivalDurationMinutes']),

      businessId:
          _stringFrom(data['businessId']),

      createdAt:
          _dateFrom(data['createdAt']),

      dogBreed:
          _stringFrom(data['dogBreed']),

      dogName:
          _stringFrom(data['dogName']),

      locationUpdatedAt:
          _dateFrom(data['locationUpdatedAt']),

      ownerAuthUid:
          _stringFrom(data['ownerAuthUid']),

      ownerId:
          _stringFrom(data['ownerId']),

      ownerLocation:
          _geoPointFrom(data['ownerLocation']),

      ownerLocationType:
          _stringFrom(data['ownerLocationType']),

      ownerName:
          _stringFrom(data['ownerName']),

      reached:
          _boolFrom(data['reached']),

      reachedAt:
          _dateFrom(data['reachedAt']),

      searchRadiusKm:
          _doubleFrom(data['searchRadiusKm']),

      searchType:
          _stringFrom(data['searchType']),

      senderRole:
          _stringFrom(data['senderRole']),

      senderUid:
          _stringFrom(data['senderUid']),

      status:
          _stringFrom(data['status']),

      updatedAt:
          _dateFrom(data['updatedAt']),

      walkerHeading:
          _doubleFrom(data['walkerHeading']),

      walkerId:
          _stringFrom(data['walkerId']),

      walkerLocation:
          _geoPointFrom(data['walkerLocation']),

      walkerName:
          _stringFrom(data['walkerName']),

      walkerPhone:
          _stringFrom(data['walkerPhone']),

      walkerProfileImage:
          _stringFrom(data['walkerProfileImage']),

      walkerSpeed:
          _doubleFrom(data['walkerSpeed']),

      walkerUid:
          _stringFrom(data['walkerUid']),
    );
  }

  // ------------------------------------------------------------
  // Date / Time helpers
  // ------------------------------------------------------------

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ------------------------------------------------------------
  // GeoPoint helper
  // ------------------------------------------------------------

  static GeoPoint? _geoPointFrom(dynamic value) {
    if (value is GeoPoint) {
      return value;
    }

    return null;
  }

  // ------------------------------------------------------------
  // String helper
  // ------------------------------------------------------------

  static String _stringFrom(dynamic value) {
    return value?.toString() ?? '';
  }

  // ------------------------------------------------------------
  // Double helper
  // ------------------------------------------------------------

  static double _doubleFrom(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ------------------------------------------------------------
  // Int helper
  // ------------------------------------------------------------

  static int _intFrom(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ------------------------------------------------------------
  // Boolean helper
  // ------------------------------------------------------------

  static bool _boolFrom(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  // ------------------------------------------------------------
  // Owner location
  // ------------------------------------------------------------

  double? get ownerLatitude {
    return ownerLocation?.latitude;
  }

  double? get ownerLongitude {
    return ownerLocation?.longitude;
  }

  // ------------------------------------------------------------
  // Walker location
  // ------------------------------------------------------------

  double? get walkerLatitude {
    return walkerLocation?.latitude;
  }

  double? get walkerLongitude {
    return walkerLocation?.longitude;
  }

  // ------------------------------------------------------------
  // Location availability
  // ------------------------------------------------------------

  bool get hasOwnerLocation {
    return ownerLocation != null;
  }

  bool get hasWalkerLocation {
    return walkerLocation != null;
  }

  // ------------------------------------------------------------
  // Status helpers
  // ------------------------------------------------------------

  String get normalizedStatus {
    return status.trim().toLowerCase();
  }

  bool get isSearching {
    return normalizedStatus == 'searching';
  }

  bool get isAccepted {
    return normalizedStatus == 'accepted';
  }

  bool get isInProgress {
    return normalizedStatus == 'in_progress' ||
        normalizedStatus == 'in-progress' ||
        normalizedStatus == 'live' ||
        normalizedStatus == 'started';
  }

  bool get isCompleted {
    return normalizedStatus == 'completed' ||
        normalizedStatus == 'complete';
  }

  bool get isCancelled {
    return normalizedStatus == 'cancelled' ||
        normalizedStatus == 'canceled';
  }

  // ------------------------------------------------------------
  // Walk state
  // ------------------------------------------------------------

  bool get isLive {
    return isAccepted || isInProgress;
  }

  bool get isFinished {
    return isCompleted || isCancelled;
  }
}
