import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/walk_request_model.dart';

class WalkRequestsService {
  WalkRequestsService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ==========================================================
  // COLLECTION
  // ==========================================================

  CollectionReference<Map<String, dynamic>>
      get _collection {
    return _firestore.collection('walk_request');
  }

  // ==========================================================
  // REALTIME REQUESTS
  // ==========================================================

  Stream<List<WalkRequestModel>>
      watchRequests() {
    return _collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) =>
                      WalkRequestModel
                          .fromFirestore(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList();
          },
        );
  }

  // ==========================================================
  // SINGLE REQUEST
  // ==========================================================

  Stream<WalkRequestModel?>
      watchRequest(
    String requestId,
  ) {
    return _collection
        .doc(requestId)
        .snapshots()
        .map(
          (doc) {
            if (!doc.exists) {
              return null;
            }

            return WalkRequestModel
                .fromFirestore(
              doc.id,
              doc.data() ?? {},
            );
          },
        );
  }
}
