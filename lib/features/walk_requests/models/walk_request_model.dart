import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequestModel {
  final String documentId;
  final String requestId;

  final DateTime? acceptedAt;
  final String acceptedBy;

  final String address;
  final String businessId;
  final DateTime? createdAt;

  final String ownerAuthUid;
  final String ownerId;
  final GeoPoint? ownerLocation;
  final String ownerLocationType;
  final String ownerName;

  final double searchRadiusKm;
  final String searchType;

  final String senderRole;
  final String senderUid;

  final String status;
  final DateTime? updatedAt;

  final String walkerId;
  final String? walkerName;
  final String walkerUid;

  const WalkRequestModel({
    required this.documentId,
    required this.requestId,
    required this.acceptedAt,
    required this.acceptedBy,
    required this.address,
    required this.businessId,
    required this.createdAt,
    required this.ownerAuthUid,
    required this.ownerId,
    required this.ownerLocation,
    required this.ownerLocationType,
    required this.ownerName,
    required this.searchRadiusKm,
    required this.searchType,
    required this.senderRole,
    required this.senderUid,
    required this.status,
    required this.updatedAt,
    required this.walkerId,
    required this.walkerName,
    required this.walkerUid,
  });

  factory WalkRequestModel.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return WalkRequestModel(
      documentId: documentId,
      requestId: data['requestId']?.toString() ?? '',

      acceptedAt:
          _dateFrom(data['acceptedAt']),

      acceptedBy:
          data['acceptedBy']?.toString() ?? '',

      address:
          data['address']?.toString() ?? '',

      businessId:
          data['businessId']?.toString() ?? '',

      createdAt:
          _dateFrom(data['createdAt']),

      ownerAuthUid:
          data['ownerAuthUid']?.toString() ?? '',

      ownerId:
          data['ownerId']?.toString() ?? '',

      ownerLocation:
          data['ownerLocation'] is GeoPoint
              ? data['ownerLocation'] as GeoPoint
              : null,

      ownerLocationType:
          data['ownerLocationType']?.toString() ?? '',

      ownerName:
          data['ownerName']?.toString() ?? '',

      searchRadiusKm:
          _doubleFrom(data['searchRadiusKm']),

      searchType:
          data['searchType']?.toString() ?? '',

      senderRole:
          data['senderRole']?.toString() ?? '',

      senderUid:
          data['senderUid']?.toString() ?? '',

      status:
          data['status']?.toString() ?? '',

      updatedAt:
          _dateFrom(data['updatedAt']),

      walkerId:
          data['walkerId']?.toString() ?? '',

      walkerName:
          data['walkerName']?.toString(),

      walkerUid:
          data['walkerUid']?.toString() ?? '',
    );
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static double _doubleFrom(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}
