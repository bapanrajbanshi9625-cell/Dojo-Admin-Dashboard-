import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequestsService {
  WalkRequestsService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ==========================================================
  // COLLECTIONS
  // ==========================================================

  CollectionReference<Map<String, dynamic>> get _walkRequests {
    return _firestore.collection('walk_request');
  }

  CollectionReference<Map<String, dynamic>> get _walkers {
    return _firestore.collection('walkers');
  }

  // ==========================================================
  // WATCH WALK REQUESTS
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> watchWalkRequests() {
    return _walkRequests
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ==========================================================
  // GET WALKERS
  // ==========================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getWalkers() async {
    final snapshot = await _walkers.get();

    return snapshot.docs;
  }

  // ==========================================================
  // GET SINGLE WALKER
  // ==========================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getWalker({
    required String walkerId,
  }) async {
    final cleanWalkerId = walkerId.trim();

    if (cleanWalkerId.isEmpty) {
      throw Exception('Walker ID is empty.');
    }

    return _walkers.doc(cleanWalkerId).get();
  }

  // ==========================================================
  // WATCH SINGLE WALKER
  //
  // Used for live/current walker location.
  // ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWalker({
    required String walkerId,
  }) {
    final cleanWalkerId = walkerId.trim();

    if (cleanWalkerId.isEmpty) {
      return const Stream.empty();
    }

    return _walkers
        .doc(cleanWalkerId)
        .snapshots();
  }

  // ==========================================================
  // CANCEL REQUEST
  // ==========================================================

  Future<void> cancelRequest({
    required String requestId,
    required String reason,
  }) async {
    final cleanRequestId = requestId.trim();
    final cleanReason = reason.trim();

    if (cleanRequestId.isEmpty) {
      throw Exception('Request ID is empty.');
    }

    if (cleanReason.isEmpty) {
      throw Exception(
        'Cancellation reason is required.',
      );
    }

    await _walkRequests
        .doc(cleanRequestId)
        .update({
      'status': 'cancelled',
      'cancellationReason': cleanReason,
      'cancelledAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // ASSIGN / CHANGE WALKER
  // ==========================================================

  Future<void> assignWalker({
    required String requestId,
    required String walkerUid,
    required String walkerId,
    required String walkerName,
  }) async {
    final cleanRequestId = requestId.trim();
    final cleanWalkerUid = walkerUid.trim();
    final cleanWalkerId = walkerId.trim();
    final cleanWalkerName = walkerName.trim();

    if (cleanRequestId.isEmpty) {
      throw Exception('Request ID is empty.');
    }

    if (cleanWalkerUid.isEmpty) {
      throw Exception('Walker UID is empty.');
    }

    if (cleanWalkerId.isEmpty) {
      throw Exception('Walker ID is empty.');
    }

    if (cleanWalkerName.isEmpty) {
      throw Exception('Walker name is empty.');
    }

    await _walkRequests
        .doc(cleanRequestId)
        .update({
      'status': 'accepted',
      'walkerUid': cleanWalkerUid,
      'walkerId': cleanWalkerId,
      'walkerName': cleanWalkerName,
      'acceptedBy': cleanWalkerUid,
      'acceptedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // OWNER LOCATION
  //
  // Reads the existing request data without creating
  // new Firestore fields.
  // ==========================================================

  Map<String, double>? getOwnerLocation(
    Map<String, dynamic> data,
  ) {
    return _extractLocation(data);
  }

  // ==========================================================
  // WALKER LOCATION
  //
  // Reads the existing walker document.
  // Supports common location structures without
  // forcing a new Firestore schema.
  // ==========================================================

  Map<String, double>? getWalkerLocation(
    Map<String, dynamic> data,
  ) {
    return _extractLocation(data);
  }

  // ==========================================================
  // LOCATION PARSER
  // ==========================================================

  Map<String, double>? _extractLocation(
    Map<String, dynamic> data,
  ) {
    // --------------------------------------------------------
    // 1. GeoPoint fields
    // --------------------------------------------------------

    final geoPointKeys = [
      'currentLocation',
      'location',
      'pickupLocation',
      'ownerLocation',
      'walkerLocation',
      'current_location',
      'pickup_location',
    ];

    for (final key in geoPointKeys) {
      final value = data[key];

      if (value is GeoPoint) {
        return {
          'latitude': value.latitude,
          'longitude': value.longitude,
        };
      }

      if (value is Map) {
        final nested =
            _extractLatLngFromMap(
          Map<String, dynamic>.from(value),
        );

        if (nested != null) {
          return nested;
        }
      }
    }

    // --------------------------------------------------------
    // 2. Direct latitude / longitude
    // --------------------------------------------------------

    final direct =
        _extractLatLngFromMap(data);

    if (direct != null) {
      return direct;
    }

    return null;
  }

  // ==========================================================
  // LAT / LNG PARSER
  // ==========================================================

  Map<String, double>? _extractLatLngFromMap(
    Map<String, dynamic> data,
  ) {
    final latitudeValue =
        data['latitude'] ??
        data['lat'] ??
        data['currentLatitude'] ??
        data['currentLat'];

    final longitudeValue =
        data['longitude'] ??
        data['lng'] ??
        data['lon'] ??
        data['currentLongitude'] ??
        data['currentLng'];

    final latitude =
        _toDouble(latitudeValue);

    final longitude =
        _toDouble(longitudeValue);

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // ==========================================================
  // DOUBLE CONVERSION
  // ==========================================================

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.trim(),
      );
    }

    return null;
  }

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  Future<void> updateStatus({
    required String requestId,
    required String status,
  }) async {
    final cleanRequestId =
        requestId.trim();

    final cleanStatus =
        status.trim().toLowerCase();

    if (cleanRequestId.isEmpty) {
      throw Exception(
        'Request ID is empty.',
      );
    }

    if (cleanStatus.isEmpty) {
      throw Exception(
        'Status is empty.',
      );
    }

    await _walkRequests
        .doc(cleanRequestId)
        .update({
      'status': cleanStatus,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // DELETE REQUEST
  // ==========================================================

  Future<void> deleteRequest({
    required String requestId,
  }) async {
    final cleanRequestId =
        requestId.trim();

    if (cleanRequestId.isEmpty) {
      throw Exception(
        'Request ID is empty.',
      );
    }

    await _walkRequests
        .doc(cleanRequestId)
        .delete();
  }
}
