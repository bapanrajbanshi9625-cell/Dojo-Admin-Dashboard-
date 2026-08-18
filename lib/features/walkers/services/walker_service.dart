import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/walker_data.dart';

class WalkerService {
  WalkerService._();

  static final WalkerService instance =
      WalkerService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _walkerProfiles =>
          _firestore.collection('walkerProfiles');

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get walkersStream {
    return _walkerProfiles.snapshots();
  }

  Future<void> approveWalker({
    required WalkerData walker,
    required bool aadhaarVerified,
    required bool selfieVerified,
  }) async {
    final adminUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    await walker.document.reference.set(
      {
        'verificationStatus': 'approved',
        'approvalStatus': 'approved',

        'approved': true,
        'isApproved': true,

        'aadhaarVerified': aadhaarVerified,
        'aadharVerified': aadhaarVerified,
        'aadhaar_verified': aadhaarVerified,

        'selfieVerified': selfieVerified,
        'selfie_verified': selfieVerified,

        'profileCompleted': true,
        'isActive': true,

        'approvedBy': adminUid,

        'approvedAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> rejectWalker({
    required WalkerData walker,
  }) async {
    final adminUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    await walker.document.reference.set(
      {
        'verificationStatus': 'rejected',
        'approvalStatus': 'rejected',

        'approved': false,
        'isApproved': false,

        'isActive': false,

        'rejected': true,
        'isRejected': true,

        'rejectedBy': adminUid,

        'rejectedAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateWalker({
    required WalkerData walker,
    required Map<String, dynamic> data,
  }) async {
    await walker.document.reference.set(
      {
        ...data,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
