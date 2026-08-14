import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection('admins');

  // =========================================================
  // GET ADMIN
  // =========================================================

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

  // =========================================================
  // WATCH ADMIN
  // =========================================================

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

  // =========================================================
  // CHECK ADMIN
  // =========================================================

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

    // Rules ke saath same field:
    // active == true
    final active = data['active'];

    if (active != true) {
      return false;
    }

    final role =
        data['role']?.toString().trim();

    // Rules ke saath same role values.
    return role == 'admin' ||
        role == 'superAdmin';
  }

  // =========================================================
  // CREATE ADMIN
  // =========================================================

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
        'active': true,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // UPDATE ADMIN
  // =========================================================

  Future<void> updateAdmin(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final updatedData =
        Map<String, dynamic>.from(data);

    // Old field isActive aaye to
    // automatically active me convert karo.
    if (updatedData.containsKey('isActive')) {
      updatedData['active'] =
          updatedData.remove('isActive');
    }

    await _admins.doc(uid).set(
      {
        ...updatedData,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // SET ADMIN ACTIVE
  // =========================================================

  Future<void> setAdminActive(
    String uid,
    bool active,
  ) async {
    await _admins.doc(uid).set(
      {
        'active': active,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // WATCH ALL ADMINS
  // =========================================================

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
