import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/owner_model.dart';

class OwnerService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _owners =>
      _firestore.collection('owners');

  Stream<List<OwnerModel>> watchOwners() {
    return _owners
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                OwnerModel.fromFirestore,
              )
              .toList(),
        );
  }

  Stream<OwnerModel?> watchOwner(
    String uid,
  ) {
    return _owners.doc(uid).snapshots().map(
      (doc) {
        if (!doc.exists) {
          return null;
        }

        return OwnerModel.fromFirestore(doc);
      },
    );
  }

  Future<OwnerModel?> getOwner(
    String uid,
  ) async {
    final doc = await _owners.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return OwnerModel.fromFirestore(doc);
  }

  Future<void> updateOwner(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _owners.doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setOwnerActive(
    String uid,
    bool active,
  ) async {
    await _owners.doc(uid).set(
      {
        'isActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteOwner(
    String uid,
  ) async {
    await _owners.doc(uid).delete();
  }

  Future<int> getOwnerCount() async {
    final snapshot = await _owners.get();
    return snapshot.size;
  }

  Future<int> getActiveOwnerCount() async {
    final snapshot = await _owners
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    return snapshot.size;
  }

  Future<List<OwnerModel>> searchOwners(
    String query,
  ) async {
    final snapshot = await _owners.get();

    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return snapshot.docs
          .map(OwnerModel.fromFirestore)
          .toList();
    }

    return snapshot.docs
        .map(OwnerModel.fromFirestore)
        .where(
          (owner) =>
              owner.name.toLowerCase().contains(search) ||
              owner.mobile
                  .toLowerCase()
                  .contains(search) ||
              owner.email
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
  }
}
