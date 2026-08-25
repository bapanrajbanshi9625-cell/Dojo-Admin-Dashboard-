import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequestsService {
  WalkRequestsService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ==========================================================
  // COLLECTIONS
  // ==========================================================

  CollectionReference<Map<String, dynamic>>
      get _walkRequests =>
          _firestore.collection('walk_requests');

  CollectionReference<Map<String, dynamic>>
      get _walkers =>
          _firestore.collection('walkers');

  // ==========================================================
  // GET WALK REQUESTS
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchWalkRequests() {
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

  Future<
      List<
          QueryDocumentSnapshot<
              Map<String, dynamic>>>>
      getWalkers() async {
    final snapshot =
        await _walkers.get();

    return snapshot.docs;
  }

  // ==========================================================
  // CANCEL REQUEST
  // ==========================================================

  Future<void> cancelRequest({
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
        .update({
      'status': 'cancelled',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // ASSIGN WALKER
  // ==========================================================

  Future<void> assignWalker({
    required String requestId,
    required String walkerUid,
    required String walkerId,
    required String walkerName,
  }) async {
    final cleanRequestId =
        requestId.trim();

    final cleanWalkerUid =
        walkerUid.trim();

    final cleanWalkerId =
        walkerId.trim();

    final cleanWalkerName =
        walkerName.trim();

    if (cleanRequestId.isEmpty) {
      throw Exception(
        'Request ID is empty.',
      );
    }

    if (cleanWalkerUid.isEmpty) {
      throw Exception(
        'Walker UID is empty.',
      );
    }

    await _walkRequests
        .doc(cleanRequestId)
        .update({
      'status': 'accepted',

      'walkerUid':
          cleanWalkerUid,

      'walkerId':
          cleanWalkerId,

      'walkerName':
          cleanWalkerName,

      'acceptedBy':
          cleanWalkerUid,

      'acceptedAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
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
