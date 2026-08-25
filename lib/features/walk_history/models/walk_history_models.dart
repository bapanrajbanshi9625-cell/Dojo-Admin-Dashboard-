import 'package:cloud_firestore/cloud_firestore.dart';

class WalkHistoryData {
  final String id;

  final String badge;
  final DateTime? completedAt;
  final int createdAt;
  final String date;

  final double distanceKm;

  final String dogBreed;
  final String dogName;
  final String dogPhoto;

  final double durationMinutes;

  final String ownerId;
  final String ownerName;

  final int peeCount;
  final int poopCount;
  final int rating;

  final DateTime? startedAt;

  final String status;
  final String timeFormatted;

  final String walkId;

  final String walkerId;
  final String walkerName;
  final String walkerNote;
  final String walkerProfileImage;
  final String walkerUid;

  const WalkHistoryData({
    required this.id,
    required this.badge,
    required this.completedAt,
    required this.createdAt,
    required this.date,
    required this.distanceKm,
    required this.dogBreed,
    required this.dogName,
    required this.dogPhoto,
    required this.durationMinutes,
    required this.ownerId,
    required this.ownerName,
    required this.peeCount,
    required this.poopCount,
    required this.rating,
    required this.startedAt,
    required this.status,
    required this.timeFormatted,
    required this.walkId,
    required this.walkerId,
    required this.walkerName,
    required this.walkerNote,
    required this.walkerProfileImage,
    required this.walkerUid,
  });

  factory WalkHistoryData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return WalkHistoryData(
      id: id,

      badge: _string(data['badge']),

      completedAt: _timestamp(
        data['completedAt'],
      ),

      createdAt: _int(
        data['createdAt'],
      ),

      date: _string(data['date']),

      distanceKm: _double(
        data['distanceKm'],
      ),

      dogBreed: _string(
        data['dogBreed'],
      ),

      dogName: _string(
        data['dogName'],
      ),

      dogPhoto: _string(
        data['dogPhoto'],
      ),

      durationMinutes: _double(
        data['durationMinutes'],
      ),

      ownerId: _string(
        data['ownerId'],
      ),

      ownerName: _string(
        data['ownerName'],
      ),

      peeCount: _int(
        data['peeCount'],
      ),

      poopCount: _int(
        data['poopCount'],
      ),

      rating: _int(
        data['rating'],
      ),

      startedAt: _timestamp(
        data['startedAt'],
      ),

      status: _string(
        data['status'],
      ),

      timeFormatted: _string(
        data['timeFormatted'],
      ),

      walkId: _string(
        data['walkId'],
      ),

      walkerId: _string(
        data['walkerId'],
      ),

      walkerName: _string(
        data['walkerName'],
      ),

      walkerNote: _string(
        data['walkerNote'],
      ),

      walkerProfileImage: _string(
        data['walkerProfileImage'],
      ),

      walkerUid: _string(
        data['walkerUid'],
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String _string(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static int _int(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double _double(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }

  static DateTime? _timestamp(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
