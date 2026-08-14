import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection('admins');

  Future<Map<String, dynamic>?> getAdmin(
    String uid,
  ) async {
    final doc = await _admins.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return {
      'uid': doc.id,
      ...?doc.data(),
    };
  }

  Stream<Map<String, dynamic>?> watchAdmin(
    String uid,
  ) {
    return _admins.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      return {
        'uid': doc.id,
        ...?doc.data(),
      };
    });
  }

  Future<bool> isAdmin(
    String uid,
  ) async {
    final doc = await _admins.doc(uid).get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data();

    if (data == null) {
      return false;
    }

    final role = data['role']?.toString().toLowerCase();

    final active = data['isActive'];

    if (active is bool && !active) {
      return false;
    }

    return role == 'admin' ||
        role == 'super_admin' ||
        role == 'super admin';
  }

  Future<void> createAdmin({
    required String uid,
    required String name,
    required String email,
    String mobile = '',
    String role = 'admin',
  }) async {
    await _admins.doc(uid).set(
      {
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateAdmin(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _admins.doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setAdminActive(
    String uid,
    bool active,
  ) async {
    await _admins.doc(uid).set(
      {
        'isActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAdmins() {
    return _admins
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }
}
