import 'package:cloud_firestore/cloud_firestore.dart';

class WalkHistoryData {
  final String id;

  final String badge;
  final DateTime? completedAt;
  final DateTime? createdAt;
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

  // ==========================================================
  // OWNER REVIEW
  // Owner -> Walker
  // ==========================================================

  final int ownerReviewRating;
  final String ownerReviewNote;
  final bool ownerReviewSubmitted;
  final DateTime? ownerReviewedAt;
  final String ownerReviewOwnerUid;
  final String ownerReviewWalkerUid;
  final String ownerReviewRequestId;
  final String ownerReviewSessionId;

  // ==========================================================
  // WALKER REVIEW
  // Walker -> Owner
  // ==========================================================

  final int walkerReviewRating;
  final String walkerReviewNote;
  final bool walkerReviewSubmitted;
  final DateTime? walkerReviewedAt;
  final String walkerReviewOwnerUid;
  final String walkerReviewWalkerUid;
  final String walkerReviewRequestId;
  final String walkerReviewSessionId;

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

    // Owner Review
    required this.ownerReviewRating,
    required this.ownerReviewNote,
    required this.ownerReviewSubmitted,
    required this.ownerReviewedAt,
    required this.ownerReviewOwnerUid,
    required this.ownerReviewWalkerUid,
    required this.ownerReviewRequestId,
    required this.ownerReviewSessionId,

    // Walker Review
    required this.walkerReviewRating,
    required this.walkerReviewNote,
    required this.walkerReviewSubmitted,
    required this.walkerReviewedAt,
    required this.walkerReviewOwnerUid,
    required this.walkerReviewWalkerUid,
    required this.walkerReviewRequestId,
    required this.walkerReviewSessionId,
  });

  factory WalkHistoryData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    // ========================================================
    // OWNER REVIEW MAP
    // ========================================================

    final ownerReviewRaw = data['ownerReview'];

    final Map<String, dynamic> ownerReview =
        ownerReviewRaw is Map
            ? Map<String, dynamic>.from(ownerReviewRaw)
            : <String, dynamic>{};

    // ========================================================
    // WALKER REVIEW MAP
    // ========================================================

    final walkerReviewRaw = data['walkerReview'];

    final Map<String, dynamic> walkerReview =
        walkerReviewRaw is Map
            ? Map<String, dynamic>.from(walkerReviewRaw)
            : <String, dynamic>{};

    // ========================================================
    // COMMON WALK ID
    // ========================================================

    final resolvedWalkId = _firstNonEmpty([
      _string(data['walkId']),
      _string(data['requestId']),
      _string(data['sessionId']),
      _string(data['walkRequestId']),
      id,
    ]);

    // ========================================================
    // COMMON OWNER / WALKER IDS
    // ========================================================

    final resolvedOwnerId = _firstNonEmpty([
      _string(data['ownerId']),
      _string(ownerReview['ownerUid']),
      _string(walkerReview['ownerUid']),
    ]);

    final resolvedWalkerId = _firstNonEmpty([
      _string(data['walkerId']),
    ]);

    final resolvedWalkerUid = _firstNonEmpty([
      _string(data['walkerUid']),
      _string(walkerReview['walkerUid']),
      _string(ownerReview['walkerUid']),
    ]);

    // ========================================================
    // OWNER REVIEW VALUES
    // Owner -> Walker
    // ========================================================

    final resolvedOwnerReviewRating = _firstInt([
      data['ownerReviewRating'],
      ownerReview['rating'],
    ]);

    final resolvedOwnerReviewNote = _firstNonEmpty([
      _string(data['ownerReviewNote']),
      _string(ownerReview['note']),
    ]);

    final resolvedOwnerReviewSubmitted =
        _bool(ownerReview['reviewSubmitted']) ||
        _bool(data['ownerReviewSubmitted']);

    final resolvedOwnerReviewedAt = _timestamp(
      ownerReview['reviewedAt'] ??
          data['ownerReviewedAt'],
    );

    // ========================================================
    // WALKER REVIEW VALUES
    // Walker -> Owner
    // ========================================================

    final resolvedWalkerReviewRating = _firstInt([
      data['walkerReviewRating'],
      walkerReview['rating'],
    ]);

    final resolvedWalkerReviewNote = _firstNonEmpty([
      _string(data['walkerReviewNote']),
      _string(walkerReview['note']),
    ]);

    final resolvedWalkerReviewSubmitted =
        _bool(walkerReview['reviewSubmitted']) ||
        _bool(data['walkerReviewSubmitted']);

    final resolvedWalkerReviewedAt = _timestamp(
      walkerReview['reviewedAt'] ??
          data['walkerReviewedAt'],
    );

    // ========================================================
    // LEGACY / GENERAL RATING FALLBACK
    // ========================================================

    final resolvedRating = _firstInt([
      data['rating'],
      ownerReview['rating'],
      walkerReview['rating'],
    ]);

    // ========================================================
    // DURATION
    // ========================================================

    double resolvedDurationMinutes =
        _double(data['durationMinutes']);

    if (resolvedDurationMinutes <= 0) {
      final durationSeconds =
          _double(data['durationSeconds']);

      if (durationSeconds > 0) {
        resolvedDurationMinutes =
            durationSeconds / 60.0;
      }
    }

    if (resolvedDurationMinutes <= 0) {
      final elapsedSeconds =
          _double(data['elapsedSeconds']);

      if (elapsedSeconds > 0) {
        resolvedDurationMinutes =
            elapsedSeconds / 60.0;
      }
    }

    // ========================================================
    // MODEL
    // ========================================================

    return WalkHistoryData(
      id: id,

      badge: _string(
        data['badge'],
      ),

      completedAt: _timestamp(
        data['completedAt'],
      ),

      createdAt: _timestamp(
        data['createdAt'],
      ),

      date: _string(
        data['date'],
      ),

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

      durationMinutes:
          resolvedDurationMinutes,

      ownerId: resolvedOwnerId,

      ownerName: _string(
        data['ownerName'],
      ),

      peeCount: _int(
        data['peeCount'],
      ),

      poopCount: _int(
        data['poopCount'],
      ),

      rating: resolvedRating,

      startedAt: _timestamp(
        data['startedAt'],
      ),

      status: _string(
        data['status'],
      ),

      timeFormatted: _string(
        data['timeFormatted'],
      ),

      walkId: resolvedWalkId,

      walkerId: resolvedWalkerId,

      walkerName: _string(
        data['walkerName'],
      ),

      walkerNote: _firstNonEmpty([
        _string(data['walkerNote']),
        _string(walkerReview['note']),
      ]),

      walkerProfileImage: _string(
        data['walkerProfileImage'],
      ),

      walkerUid: resolvedWalkerUid,

      // ======================================================
      // OWNER REVIEW
      // ======================================================

      ownerReviewRating:
          resolvedOwnerReviewRating,

      ownerReviewNote:
          resolvedOwnerReviewNote,

      ownerReviewSubmitted:
          resolvedOwnerReviewSubmitted,

      ownerReviewedAt:
          resolvedOwnerReviewedAt,

      ownerReviewOwnerUid:
          _string(ownerReview['ownerUid']),

      ownerReviewWalkerUid:
          _string(ownerReview['walkerUid']),

      ownerReviewRequestId:
          _string(ownerReview['requestId']),

      ownerReviewSessionId:
          _string(ownerReview['sessionId']),

      // ======================================================
      // WALKER REVIEW
      // ======================================================

      walkerReviewRating:
          resolvedWalkerReviewRating,

      walkerReviewNote:
          resolvedWalkerReviewNote,

      walkerReviewSubmitted:
          resolvedWalkerReviewSubmitted,

      walkerReviewedAt:
          resolvedWalkerReviewedAt,

      walkerReviewOwnerUid:
          _string(walkerReview['ownerUid']),

      walkerReviewWalkerUid:
          _string(walkerReview['walkerUid']),

      walkerReviewRequestId:
          _string(walkerReview['requestId']),

      walkerReviewSessionId:
          _string(walkerReview['sessionId']),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String _string(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  static String _firstNonEmpty(
    List<String> values,
  ) {
    for (final value in values) {
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
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

  static int _firstInt(
    List<dynamic> values,
  ) {
    for (final value in values) {
      final parsed = _int(value);

      if (parsed > 0) {
        return parsed;
      }
    }

    return 0;
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

  static bool _bool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  static DateTime? _timestamp(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    return null;
  }
}
