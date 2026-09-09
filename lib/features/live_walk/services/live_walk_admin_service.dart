import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiveWalkAdminService {
  LiveWalkAdminService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('liveWalkSessions');

  CollectionReference<Map<String, dynamic>> get _walkRequests =>
      _firestore.collection('walk_request');

  String get _adminUid => _auth.currentUser?.uid ?? 'admin';

  Future<void> completeWalk({
    required String sessionId,
    required String requestId,
  }) async {
    final sessionRef = _sessions.doc(sessionId);
    final requestRef =
        requestId.trim().isEmpty ? null : _walkRequests.doc(requestId);

    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();

    batch.update(sessionRef, {
      'status': 'completed',
      'walkEnded': true,
      'trackingEnded': true,
      'endedAt': now,
      'completedAt': now,
      'updatedAt': now,
      'adminAction': 'complete_walk',
      'adminActionBy': _adminUid,
      'adminActionAt': now,
    });

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'status': 'completed',
          'completedAt': now,
          'updatedAt': now,
          'adminAction': 'complete_walk',
          'adminActionBy': _adminUid,
          'adminActionAt': now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> cancelWalk({
    required String sessionId,
    required String requestId,
  }) async {
    final sessionRef = _sessions.doc(sessionId);
    final requestRef =
        requestId.trim().isEmpty ? null : _walkRequests.doc(requestId);

    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();

    batch.update(sessionRef, {
      'status': 'cancelled',
      'walkEnded': true,
      'trackingEnded': true,
      'endedAt': now,
      'cancelledAt': now,
      'updatedAt': now,
      'adminAction': 'cancel_walk',
      'adminActionBy': _adminUid,
      'adminActionAt': now,
    });

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'status': 'cancelled',
          'cancelledAt': now,
          'updatedAt': now,
          'adminAction': 'cancel_walk',
          'adminActionBy': _adminUid,
          'adminActionAt': now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
