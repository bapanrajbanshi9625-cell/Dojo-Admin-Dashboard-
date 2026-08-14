import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activity_logs');

  Stream<List<Map<String, dynamic>>> watchActivities({
    int limit = 50,
  }) {
    return _activities
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getActivities({
    int limit = 50,
  }) async {
    final snapshot = await _activities
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> addActivity({
    required String action,
    required String description,
    String actorId = '',
    String actorName = '',
    String type = 'system',
    Map<String, dynamic>? metadata,
  }) async {
    await _activities.add({
      'action': action,
      'description': description,
      'actorId': actorId,
      'actorName': actorName,
      'type': type,
      'metadata': metadata ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> logLogin({
    required String adminId,
    required String adminName,
  }) async {
    await addActivity(
      action: 'admin_login',
      description:
          '$adminName logged into the admin panel.',
      actorId: adminId,
      actorName: adminName,
      type: 'auth',
    );
  }

  Future<void> logLogout({
    required String adminId,
    required String adminName,
  }) async {
    await addActivity(
      action: 'admin_logout',
      description:
          '$adminName logged out of the admin panel.',
      actorId: adminId,
      actorName: adminName,
      type: 'auth',
    );
  }

  Future<void> logWalkAction({
    required String action,
    required String walkId,
    String actorId = '',
    String actorName = '',
    String description = '',
  }) async {
    await addActivity(
      action: action,
      description: description.isEmpty
          ? 'Walk $walkId was updated.'
          : description,
      actorId: actorId,
      actorName: actorName,
      type: 'walk',
      metadata: {
        'walkId': walkId,
      },
    );
  }

  Future<void> logUserAction({
    required String action,
    required String userId,
    String userName = '',
    String role = '',
    String description = '',
  }) async {
    await addActivity(
      action: action,
      description: description.isEmpty
          ? '$role user $userName was updated.'
          : description,
      actorId: userId,
      actorName: userName,
      type: role.isEmpty ? 'user' : role,
      metadata: {
        'userId': userId,
        'role': role,
      },
    );
  }

  Future<void> clearActivities() async {
    final snapshot = await _activities.get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
