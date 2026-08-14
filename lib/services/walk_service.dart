import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/walk_model.dart';

class WalkService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _walks =>
      _firestore.collection('walks');

  Stream<List<WalkModel>> watchWalks() {
    return _walks
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalkModel.fromFirestore)
              .toList(),
        );
  }

  Stream<List<WalkModel>> watchActiveWalks() {
    return _walks
        .where(
          'status',
          whereIn: [
            'active',
            'live',
            'started',
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalkModel.fromFirestore)
              .toList(),
        );
  }

  Stream<List<WalkModel>> watchCompletedWalks() {
    return _walks
        .where(
          'status',
          whereIn: [
            'completed',
            'complete',
          ],
        )
        .orderBy(
          'completedAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalkModel.fromFirestore)
              .toList(),
        );
  }

  Stream<WalkModel?> watchWalk(
    String walkId,
  ) {
    return _walks.doc(walkId).snapshots().map(
      (doc) {
        if (!doc.exists) {
          return null;
        }

        return WalkModel.fromFirestore(doc);
      },
    );
  }

  Future<WalkModel?> getWalk(
    String walkId,
  ) async {
    final doc = await _walks.doc(walkId).get();

    if (!doc.exists) {
      return null;
    }

    return WalkModel.fromFirestore(doc);
  }

  Future<void> updateWalk(
    String walkId,
    Map<String, dynamic> data,
  ) async {
    await _walks.doc(walkId).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateWalkStatus(
    String walkId,
    String status,
  ) async {
    await _walks.doc(walkId).set(
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<int> getWalkCount() async {
    final snapshot = await _walks.get();
    return snapshot.size;
  }

  Future<int> getActiveWalkCount() async {
    final snapshot = await _walks
        .where(
          'status',
          whereIn: [
            'active',
            'live',
            'started',
          ],
        )
        .get();

    return snapshot.size;
  }

  Future<int> getCompletedWalkCount() async {
    final snapshot = await _walks
        .where(
          'status',
          whereIn: [
            'completed',
            'complete',
          ],
        )
        .get();

    return snapshot.size;
  }

  Future<double> getTotalRevenue() async {
    final snapshot = await _walks
        .where(
          'status',
          whereIn: [
            'completed',
            'complete',
          ],
        )
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final value =
          data['amount'] ??
          data['price'] ??
          data['fare'];

      if (value is num) {
        total += value.toDouble();
      } else {
        total +=
            double.tryParse(
              value?.toString() ?? '',
            ) ??
            0;
      }
    }

    return total;
  }
}
