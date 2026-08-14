import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/walker_model.dart';

class WalkerService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _walkers =>
      _firestore.collection('walkers');

  Stream<List<WalkerModel>> watchWalkers() {
    return _walkers
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalkerModel.fromFirestore)
              .toList(),
        );
  }

  Stream<WalkerModel?> watchWalker(
    String uid,
  ) {
    return _walkers.doc(uid).snapshots().map(
      (doc) {
        if (!doc.exists) {
          return null;
        }

        return WalkerModel.fromFirestore(doc);
      },
    );
  }

  Future<WalkerModel?> getWalker(
    String uid,
  ) async {
    final doc = await _walkers.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return WalkerModel.fromFirestore(doc);
  }

  Future<void> updateWalker(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _walkers.doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setWalkerActive(
    String uid,
    bool active,
  ) async {
    await _walkers.doc(uid).set(
      {
        'isActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setWalkerOnline(
    String uid,
    bool online,
  ) async {
    await _walkers.doc(uid).set(
      {
        'isOnline': online,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setWalkerVerified(
    String uid,
    bool verified,
  ) async {
    await _walkers.doc(uid).set(
      {
        'isVerified': verified,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<int> getWalkerCount() async {
    final snapshot = await _walkers.get();
    return snapshot.size;
  }

  Future<int> getActiveWalkerCount() async {
    final snapshot = await _walkers
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    return snapshot.size;
  }

  Future<int> getOnlineWalkerCount() async {
    final snapshot = await _walkers
        .where(
          'isOnline',
          isEqualTo: true,
        )
        .get();

    return snapshot.size;
  }

  Future<List<WalkerModel>> searchWalkers(
    String query,
  ) async {
    final snapshot = await _walkers.get();

    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return snapshot.docs
          .map(WalkerModel.fromFirestore)
          .toList();
    }

    return snapshot.docs
        .map(WalkerModel.fromFirestore)
        .where(
          (walker) =>
              walker.name.toLowerCase().contains(search) ||
              walker.mobile
                  .toLowerCase()
                  .contains(search) ||
              walker.email
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
  }
}
