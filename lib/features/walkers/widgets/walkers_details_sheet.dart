import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'walkers_document_card.dart';
import 'walkers_header.dart';
import 'walkers_helpers.dart';
import 'walkers_verification_card.dart';

class WalkerDetailsSheet extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic>? data;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const WalkerDetailsSheet({
    super.key,
    required this.doc,
    this.data,
    this.onApprove,
    this.onReject,
  });

  @override
  State<WalkerDetailsSheet> createState() =>
      _WalkerDetailsSheetState();
}

class _WalkerDetailsSheetState
    extends State<WalkerDetailsSheet> {

  // Walker role color
  static const Color walkerOrange =
      Color(0xFFFF6600);

  // states
  late bool nameMatched;
  late bool dobMatched;
  late bool aadhaarVerified;

  bool savingVerification = false;
  bool changingActivation = false;
  bool changingReVerification = false;

  Map<String, dynamic> get _data =>
      widget.data ??
      widget.doc.data() ??
      <String, dynamic>{};

  // ------------------------------------------
  // ALL FIRESTORE READERS
  // ------------------------------------------

  String _readValue(
    List<String> keys, [
    String fallback = '',
  ]) {
    return WalkersHelpers.readValue(
      _data,
      keys,
      fallback,
    );
  }

  bool _readBool(List<String> keys) {
    return WalkersHelpers.readBool(
      _data,
      keys,
    );
  }

  String _readTimestamp(List<String> keys) {
    return WalkersHelpers.readTimestamp(
      _data,
      keys,
    );
  }

  // ------------------------------------------
  // WALKER PROFILE
  // ------------------------------------------

  String get _name => _readValue([
        'fullName',
        'Full Name',
        'name',
        'walkerName',
      ], 'Unknown Walker');

  String get _mobile => _readValue([
        'phoneNumber',
        'Mobile number',
        'mobileNumber',
        'mobile',
        'phone',
      ]);

  String get _walkerId => _readValue([
        'walkerId',
        'Walker ID',
      ]);

  String get _uid => _readValue([
        'authUid',
        'Walker Uid',
        'walkerUid',
        'uid',
      ], widget.doc.id);

  String get _gender => _readValue([
        'gender',
        'Gender',
      ]);

  String get _dateOfBirth => _readValue([
        'dateofbirth',
        'Date Of Birth',
        'dateOfBirth',
        'dob',
      ]);

  String get _aadhaarNumber => _readValue([
        'aadhaarNumber',
        'Aadhar Number',
        'Aadhaar Number',
        'aadharNumber',
      ]);

  String get _selfie => _readValue([
        'selfie',
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'photoUrl',
      ]);

  String get _aadhaarFront => _readValue([
        'aadhaarfront',
        'aadhaarFront',
        'Aadhaar Front',
        'Aadhar Front',
      ]);

  String get _aadhaarBack => _readValue([
        'aadhaarback',
        'aadhaarBack',
        'Aadhaar Back',
        'Aadhar Back',
      ]);

  String get _address => _readValue([
        'address',
        'Adress',
        'Address',
      ]);

  String get _village => _readValue([
        'village',
        'Village',
      ]);

  String get _city => _readValue([
        'city',
        'City',
      ]);

  String get _district => _readValue([
        'district',
        'District',
      ]);

  String get _state => _readValue([
        'state',
        'State',
      ]);

  String get _pincode => _readValue([
        'pincode',
        'Pincode',
        'pinCode',
        'postalCode',
      ]);

  String get _emergencyName => _readValue([
        'emergencyContactName',
        'Emergency Contact Name',
      ]);

  String get _emergencyMobile => _readValue([
        'emergencyContactMobile',
        'Emergency Contact Mobile',
      ]);

  String get _role => _readValue([
        'role',
        'Role',
      ], 'walker');

  String get _verificationStatus =>
      _readValue([
        'verificationStatus',
        'status',
        'approvalStatus',
        'walkerStatus',
      ], 'pending');

  bool get _isApproved =>
      _readBool([
        'adminApproved',
        'approved',
        'isApproved',
      ]) ||
      _verificationStatus.toLowerCase() ==
          'approved';

  bool get _isActive => _readBool([
        'isActive',
        'active',
      ]);

  bool get _reVerificationRequired =>
      _readBool([
        'reVerificationRequired',
        'reverificationRequired',
        'reVerifyRequired',
      ]);

  @override
  void initState() {
    super.initState();

    nameMatched = _readBool([
      'nameMatched',
      'name_match',
    ]);

    dobMatched = _readBool([
      'dobMatched',
      'dob_match',
    ]);

    aadhaarVerified = _readBool([
      'aadhaarVerified',
      'aadharVerified',
      'aadhaar_verified',
    ]);
  }
