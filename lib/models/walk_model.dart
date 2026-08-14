import 'package:cloud_firestore/cloud_firestore.dart';

class WalkModel {
  final String id;
  final String ownerId;
  final String walkerId;
  final String petId;
  final String ownerName;
  final String walkerName;
  final String petName;

  final String status;
  final String pickupAddress;
  final String dropAddress;

  final double distanceKm;
  final int durationMinutes;
  final double amount;

  final double? latitude;
  final double? longitude;

  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkModel({
    required this.id,
    this.ownerId = '',
    this.walkerId = '',
    this.petId = '',
    this.ownerName = '',
    this.walkerName = '',
    this.petName = '',
    this.status = 'pending',
    this.pickupAddress = '',
    this.dropAddress = '',
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.amount = 0,
    this.latitude,
    this.longitude,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WalkModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return WalkModel.fromMap(
      doc.data() ?? {},
      documentId: doc.id,
    );
  }

  factory WalkModel.fromMap(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    return WalkModel(
      id: documentId ?? _string(data['id']),
      ownerId: _string(data['ownerId']),
      walkerId: _string(data['walkerId']),
      petId: _string(data['petId']),
      ownerName: _string(data['ownerName']),
      walkerName: _string(data['walkerName']),
      petName: _string(data['petName']),
      status: _string(data['status']).isEmpty
          ? 'pending'
          : _string(data['status']),
      pickupAddress: _string(
        data['pickupAddress'] ??
            data['startAddress'],
      ),
      dropAddress: _string(
        data['dropAddress'] ??
            data['endAddress'],
      ),
      distanceKm: _double(
        data['distanceKm'] ??
            data['distance'],
      ),
      durationMinutes: _int(
        data['durationMinutes'] ??
            data['duration'],
      ),
      amount: _double(
        data['amount'] ??
            data['price'] ??
            data['fare'],
      ),
      latitude: _nullableDouble(
        data['latitude'],
      ),
      longitude: _nullableDouble(
        data['longitude'],
      ),
      startedAt: _date(data['startedAt']),
      completedAt: _date(data['completedAt']),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'walkerId': walkerId,
      'petId': petId,
      'ownerName': ownerName,
      'walkerName': walkerName,
      'petName': petName,
      'status': status,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'amount': amount,
      'latitude': latitude,
      'longitude': longitude,
      'startedAt': startedAt == null
          ? null
          : Timestamp.fromDate(startedAt!),
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
    };
  }

  WalkModel copyWith({
    String? id,
    String? ownerId,
    String? walkerId,
    String? petId,
    String? ownerName,
    String? walkerName,
    String? petName,
    String? status,
    String? pickupAddress,
    String? dropAddress,
    double? distanceKm,
    int? durationMinutes,
    double? amount,
    double? latitude,
    double? longitude,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      walkerId: walkerId ?? this.walkerId,
      petId: petId ?? this.petId,
      ownerName: ownerName ?? this.ownerName,
      walkerName: walkerName ?? this.walkerName,
      petName: petName ?? this.petName,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes:
          durationMinutes ?? this.durationMinutes,
      amount: amount ?? this.amount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startedAt: startedAt ?? this.startedAt,
      completedAt:
          completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLive =>
      status.toLowerCase() == 'active' ||
      status.toLowerCase() == 'live' ||
      status.toLowerCase() == 'started';

  bool get isCompleted =>
      status.toLowerCase() == 'completed' ||
      status.toLowerCase() == 'complete';

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _int(dynamic value) {
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _date(dynamic value) {
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
}
