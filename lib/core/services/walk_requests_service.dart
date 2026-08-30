import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalkRequestsService {
  WalkRequestsService._();

  static final WalkRequestsService instance =
      WalkRequestsService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get requestsRef =>
          _firestore.collection('walk_requests');

  CollectionReference<Map<String, dynamic>>
      get walkersRef =>
          _firestore.collection('walkerProfiles');

  // ============================================================
  // CURRENT ADMIN
  // ============================================================

  String? get currentAdminUid =>
      _auth.currentUser?.uid;

  String get currentAdminName {
    final user = _auth.currentUser;

    if (user == null) {
      return 'Admin';
    }

    if (user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user.email != null &&
        user.email!.trim().isNotEmpty) {
      return user.email!.split('@').first;
    }

    return 'Admin';
  }

  String get currentAdminEmail =>
      _auth.currentUser?.email ?? 'Not available';

  // ============================================================
  // ALL REQUESTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get requestsStream {
    return requestsRef
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ============================================================
  // WALKERS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get walkersStream {
    return walkersRef.snapshots();
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> updateStatus({
    required String requestId,
    required String status,
  }) async {
    await requestsRef.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': currentAdminUid,
      'updatedByName': currentAdminName,
    });
  }

  // ============================================================
  // ACCEPT
  // ============================================================

  Future<void> acceptRequest(
    String requestId,
  ) async {
    await _firestore.runTransaction(
      (transaction) async {
        final ref = requestsRef.doc(requestId);

        final snapshot =
            await transaction.get(ref);

        if (!snapshot.exists) {
          throw Exception(
            'Walk request no longer exists.',
          );
        }

        final data = snapshot.data()!;

        final status =
            data['status']?.toString().toLowerCase();

        final locked =
            data['locked'] == true;

        if (locked) {
          throw Exception(
            'This request is locked.',
          );
        }

        if (status != 'searching' &&
            status != 'pending') {
          throw Exception(
            'This request cannot be accepted now.',
          );
        }

        transaction.update(ref, {
          'status': 'accepted',
          'acceptedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
          'updatedBy': currentAdminUid,
          'updatedByName': currentAdminName,
        });
      },
    );
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> rejectRequest(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).update({
      'status': 'rejected',
      'rejectedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
      'updatedBy': currentAdminUid,
      'updatedByName': currentAdminName,
    });
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> cancelRequest(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
      'updatedBy': currentAdminUid,
      'updatedByName': currentAdminName,
    });
  }

  // ============================================================
  // LOCK
  // ============================================================

  Future<void> lockRequest(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).update({
      'locked': true,
      'lockedAt':
          FieldValue.serverTimestamp(),
      'lockedBy': currentAdminUid,
      'lockedByName': currentAdminName,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UNLOCK
  // ============================================================

  Future<void> unlockRequest(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).update({
      'locked': false,
      'lockedAt': null,
      'lockedBy': null,
      'lockedByName': null,
      'updatedAt':
          FieldValue.serverTimestamp(),
      'updatedBy': currentAdminUid,
      'updatedByName': currentAdminName,
    });
  }

  // ============================================================
  // ASSIGN WALKER
  // ============================================================

  Future<void> assignWalker({
    required String requestId,
    required String walkerUid,
    required String walkerName,
  }) async {
    await _firestore.runTransaction(
      (transaction) async {
        final ref = requestsRef.doc(requestId);

        final snapshot =
            await transaction.get(ref);

        if (!snapshot.exists) {
          throw Exception(
            'Walk request no longer exists.',
          );
        }

        final data = snapshot.data()!;

        if (data['locked'] == true) {
          throw Exception(
            'This request is locked.',
          );
        }

        final status =
            data['status']?.toString().toLowerCase();

        if (status == 'cancelled' ||
            status == 'rejected' ||
            status == 'expired') {
          throw Exception(
            'Walker cannot be assigned to this request.',
          );
        }

        transaction.update(ref, {
          'walkerUid': walkerUid,
          'walkerId': walkerUid,
          'walkerName': walkerName,
          'assignedAt':
              FieldValue.serverTimestamp(),
          'assignedBy': currentAdminUid,
          'assignedByName': currentAdminName,
          'updatedAt':
              FieldValue.serverTimestamp(),
        });
      },
    );
  }

  // ============================================================
  // UNASSIGN WALKER
  // ============================================================

  Future<void> unassignWalker(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).update({
      'walkerUid': null,
      'walkerId': null,
      'walkerName': null,
      'assignedAt': null,
      'assignedBy': null,
      'assignedByName': null,
      'updatedAt':
          FieldValue.serverTimestamp(),
      'updatedBy': currentAdminUid,
      'updatedByName': currentAdminName,
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteRequest(
    String requestId,
  ) async {
    await requestsRef.doc(requestId).delete();
  }
}
