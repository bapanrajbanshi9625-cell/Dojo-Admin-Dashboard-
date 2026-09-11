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

  // ============================================================
  // START WALK
  // ============================================================

  Future<void> startWalk({
    required String sessionId,
    required String requestId,
  }) async {
    final cleanSessionId = sessionId.trim();
    final cleanRequestId = requestId.trim();

    if (cleanSessionId.isEmpty) {
      throw Exception('Session ID is empty.');
    }

    final sessionRef = _sessions.doc(cleanSessionId);

    final requestRef = cleanRequestId.isEmpty
        ? null
        : _walkRequests.doc(cleanRequestId);

    final now = FieldValue.serverTimestamp();

    final batch = _firestore.batch();

    batch.set(
      sessionRef,
      {
        'status': 'active',
        'walkStarted': true,
        'trackingStarted': true,
        'walkEnded': false,
        'trackingEnded': false,
        'startedAt': now,
        'updatedAt': now,
        'adminAction': 'start_walk',
        'adminActionBy': _adminUid,
        'adminActionAt': now,
      },
      SetOptions(merge: true),
    );

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'status': 'active',
          'walkStarted': true,
          'trackingStarted': true,
          'startedAt': now,
          'updatedAt': now,
          'adminAction': 'start_walk',
          'adminActionBy': _adminUid,
          'adminActionAt': now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  // ============================================================
  // COMPLETE WALK
  // ============================================================

  Future<void> completeWalk({
    required String sessionId,
    required String requestId,
  }) async {
    final cleanSessionId = sessionId.trim();
    final cleanRequestId = requestId.trim();

    if (cleanSessionId.isEmpty) {
      throw Exception('Session ID is empty.');
    }

    final sessionRef = _sessions.doc(cleanSessionId);

    final requestRef = cleanRequestId.isEmpty
        ? null
        : _walkRequests.doc(cleanRequestId);

    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();

    batch.set(
      sessionRef,
      {
        'status': 'completed',
        'walkEnded': true,
        'trackingEnded': true,
        'endedAt': now,
        'completedAt': now,
        'updatedAt': now,
        'adminAction': 'complete_walk',
        'adminActionBy': _adminUid,
        'adminActionAt': now,
      },
      SetOptions(merge: true),
    );

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'status': 'completed',
          'walkEnded': true,
          'trackingEnded': true,
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

  // ============================================================
  // CANCEL WALK
  // ============================================================

  Future<void> cancelWalk({
    required String sessionId,
    required String requestId,
  }) async {
    final cleanSessionId = sessionId.trim();
    final cleanRequestId = requestId.trim();

    if (cleanSessionId.isEmpty) {
      throw Exception('Session ID is empty.');
    }

    final sessionRef = _sessions.doc(cleanSessionId);

    final requestRef = cleanRequestId.isEmpty
        ? null
        : _walkRequests.doc(cleanRequestId);

    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();

    batch.set(
      sessionRef,
      {
        'status': 'cancelled',
        'walkEnded': true,
        'trackingEnded': true,
        'endedAt': now,
        'cancelledAt': now,
        'updatedAt': now,
        'adminAction': 'cancel_walk',
        'adminActionBy': _adminUid,
        'adminActionAt': now,
      },
      SetOptions(merge: true),
    );

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'status': 'cancelled',
          'walkEnded': true,
          'trackingEnded': true,
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

  // ============================================================
  // CHANGE WALKER
  //
  // Updates both the canonical walk request and the existing
  // live session. No new session is created.
  // ============================================================

  Future<void> changeWalker({
    required String sessionId,
    required String requestId,
    required String walkerUid,
    required String walkerId,
    required String walkerName,
  }) async {
    final cleanSessionId = sessionId.trim();
    final cleanRequestId = requestId.trim();
    final cleanWalkerUid = walkerUid.trim();
    final cleanWalkerId = walkerId.trim();
    final cleanWalkerName = walkerName.trim();

    if (cleanSessionId.isEmpty) {
      throw Exception('Session ID is empty.');
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

    final sessionRef = _sessions.doc(cleanSessionId);

    final requestRef = cleanRequestId.isEmpty
        ? null
        : _walkRequests.doc(cleanRequestId);

    final batch = _firestore.batch();

    final now = FieldValue.serverTimestamp();

    batch.set(
      sessionRef,
      {
        'walkerUid': cleanWalkerUid,
        'walkerId': cleanWalkerId,
        'walkerName': cleanWalkerName,
        'updatedAt': now,
        'adminAction': 'change_walker',
        'adminActionBy': _adminUid,
        'adminActionAt': now,
      },
      SetOptions(merge: true),
    );

    if (requestRef != null) {
      batch.set(
        requestRef,
        {
          'walkerUid': cleanWalkerUid,
          'walkerId': cleanWalkerId,
          'walkerName': cleanWalkerName,
          'acceptedBy': cleanWalkerUid,
          'updatedAt': now,
          'adminAction': 'change_walker',
          'adminActionBy': _adminUid,
          'adminActionAt': now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
