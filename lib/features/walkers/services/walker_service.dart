import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/walker_data.dart';

class WalkerService {
  WalkerService._();

  static final WalkerService instance = WalkerService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _walkers =>
      _firestore.collection('walkers');

  Stream<QuerySnapshot<Map<String, dynamic>>> get walkersStream {
    return _walkers.snapshots();
  }

  Future<void> approveWalker({
    required WalkerData walker,
    required bool selfieVerified,
    required bool aadhaarFrontVerified,
    required bool aadhaarBackVerified,
    required bool panVerified,
  }) async {
    if (!selfieVerified ||
        !aadhaarFrontVerified ||
        !aadhaarBackVerified ||
        !panVerified) {
      throw Exception(
        'Selfie, Aadhaar Front, Aadhaar Back and PAN '
        'must all be verified before approval.',
      );
    }

    final adminUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    await walker.document.reference.set(
      {
        'verificationStatus': 'approved',
        'verification_status': 'approved',
        'approvalStatus': 'approved',
        'approval_status': 'approved',
        'status': 'approved',

        'approved': true,
        'isApproved': true,
        'adminApproved': true,

        'rejected': false,
        'isRejected': false,
        'adminRejected': false,

        'selfieVerified': true,
        'selfie_verified': true,

        'aadhaarFrontVerified': true,
        'aadhaar_front_verified': true,

        'aadhaarBackVerified': true,
        'aadhaar_back_verified': true,

        'aadhaarVerified': true,
        'aadharVerified': true,
        'aadhaar_verified': true,

        'panVerified': true,
        'pan_verified': true,

        'profileCompleted': true,

        'isActive': true,
        'active': true,

        'approvedBy': adminUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        'rejectionReasons': FieldValue.delete(),
        'rejectionReason': FieldValue.delete(),
        'rejectedBy': FieldValue.delete(),
        'rejectedAt': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> rejectWalker({
    required WalkerData walker,
    required List<String> reasons,
  }) async {
    if (reasons.isEmpty) {
      throw Exception(
        'At least one rejection reason is required.',
      );
    }

    final adminUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    final readableReason = reasons
        .map((reason) => reason.trim())
        .where((reason) => reason.isNotEmpty)
        .join(', ');

    await walker.document.reference.set(
      {
        'verificationStatus': 'rejected',
        'verification_status': 'rejected',
        'approvalStatus': 'rejected',
        'approval_status': 'rejected',
        'status': 'rejected',

        'approved': false,
        'isApproved': false,
        'adminApproved': false,

        'rejected': true,
        'isRejected': true,
        'adminRejected': true,

        'isActive': false,
        'active': false,

        'rejectionReasons': reasons,
        'rejectionReason': readableReason,

        'rejectedBy': adminUid,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setActive({
    required WalkerData walker,
    required bool active,
  }) async {
    await walker.document.reference.set(
      {
        'isActive': active,
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
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
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
