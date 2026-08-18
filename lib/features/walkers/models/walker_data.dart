import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerData {
  final DocumentSnapshot<Map<String, dynamic>> document;

  final String walkerId;
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String dob;
  final String address;
  final String pincode;
  final String aadhaarNumber;

  final String profileSelfie;
  final String aadhaarFront;
  final String aadhaarBack;

  final bool aadhaarFrontUploaded;
  final bool aadhaarBackUploaded;
  final bool profileCompleted;

  final bool aadhaarVerified;
  final bool selfieVerified;

  final String verificationStatus;

  final bool isOnline;
  final bool isActive;

  final int totalWalks;
  final int activeWalks;

  final double rating;

  const WalkerData({
    required this.document,
    required this.walkerId,
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.address,
    required this.pincode,
    required this.aadhaarNumber,
    required this.profileSelfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.aadhaarFrontUploaded,
    required this.aadhaarBackUploaded,
    required this.profileCompleted,
    required this.aadhaarVerified,
    required this.selfieVerified,
    required this.verificationStatus,
    required this.isOnline,
    required this.isActive,
    required this.totalWalks,
    required this.activeWalks,
    required this.rating,
  });

  factory WalkerData.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    String stringValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value != null &&
            value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }

      return '';
    }

    bool boolValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value is bool) {
          return value;
        }

        if (value is String) {
          return value.toLowerCase() == 'true';
        }
      }

      return false;
    }

    int intValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value is num) {
          return value.toInt();
        }

        final parsed = int.tryParse(
          value?.toString() ?? '',
        );

        if (parsed != null) {
          return parsed;
        }
      }

      return 0;
    }

    double doubleValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value is num) {
          return value.toDouble();
        }

        final parsed = double.tryParse(
          value?.toString() ?? '',
        );

        if (parsed != null) {
          return parsed;
        }
      }

      return 0;
    }

    final uidValue = stringValue([
      'Walker Uid',
      'walkerUid',
      'walkerUID',
      'uid',
      'authUid',
      'authUID',
    ]);

    String verificationStatus() {
      final status = stringValue([
        'verificationStatus',
        'verification_status',
        'approvalStatus',
        'approval_status',
      ]).toLowerCase();

      if (status == 'approved' ||
          status == 'rejected' ||
          status == 'pending') {
        return status;
      }

      if (boolValue([
        'approved',
        'isApproved',
      ])) {
        return 'approved';
      }

      if (boolValue([
        'rejected',
        'isRejected',
      ])) {
        return 'rejected';
      }

      return 'pending';
    }

    return WalkerData(
      document: document,

      walkerId: stringValue([
        'walkerId',
        'Walker ID',
        'walker_id',
        'id',
      ]),

      uid: uidValue.isNotEmpty
          ? uidValue
          : document.id,

      name: stringValue([
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ]),

      phone: stringValue([
        'Mobile number',
        'mobile',
        'phone',
        'phoneNumber',
      ]),

      email: stringValue([
        'email',
        'Email',
      ]),

      dob: stringValue([
        'Date Of Birth',
        'dateOfBirth',
        'dob',
      ]),

      address: stringValue([
        'Adress',
        'Address',
        'address',
      ]),

      pincode: stringValue([
        'Pincode',
        'pincode',
        'pinCode',
      ]),

      aadhaarNumber: stringValue([
        'Aadhar Number',
        'Aadhaar Number',
        'aadhaarNumber',
        'aadharNumber',
      ]),

      profileSelfie: stringValue([
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'profileImageUrl',
        'selfieUrl',
      ]),

      aadhaarFront: stringValue([
        'aadhaar_front_url',
        'aadhaarFrontUrl',
        'aadhaar_front',
        'aadhaarFront',
        'Aadhar Front',
        'Aadhaar Front',
        'aadhaarFrontImage',
      ]),

      aadhaarBack: stringValue([
        'aadhaar_back_url',
        'aadhaarBackUrl',
        'aadhaar_back',
        'aadhaarBack',
        'Aadhar Back',
        'Aadhaar Back',
        'aadhaarBackImage',
      ]),

      aadhaarFrontUploaded: boolValue([
        'aadhaar_front_uploaded',
        'aadhaarFrontUploaded',
      ]),

      aadhaarBackUploaded: boolValue([
        'aadhaar_back_uploaded',
        'aadhaarBackUploaded',
      ]),

      profileCompleted: boolValue([
        'profileCompleted',
        'profile_completed',
      ]),

      aadhaarVerified: boolValue([
        'aadhaarVerified',
        'aadharVerified',
        'aadhaar_verified',
      ]),

      selfieVerified: boolValue([
        'selfieVerified',
        'selfie_verified',
      ]),

      verificationStatus: verificationStatus(),

      isOnline: boolValue([
        'isOnline',
        'online',
      ]),

      isActive: boolValue([
        'isActive',
        'active',
      ]),

      totalWalks: intValue([
        'totalWalks',
        'completedWalks',
        'walks',
      ]),

      activeWalks: intValue([
        'activeWalks',
        'currentActiveWalks',
      ]),

      rating: doubleValue([
        'rating',
        'averageRating',
      ]),
    );
  }

  bool get isApproved =>
      verificationStatus == 'approved';

  bool get isRejected =>
      verificationStatus == 'rejected';

  bool get isPending =>
      verificationStatus == 'pending';
}
