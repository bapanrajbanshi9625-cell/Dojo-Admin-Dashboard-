import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerData {
  final DocumentSnapshot<Map<String, dynamic>> document;

  final String walkerId;
  final String uid;
  final String name;
  final String phone;
  final String email;

  final String dob;
  final String gender;

  final String address;
  final String village;
  final String city;
  final String district;
  final String state;
  final String pincode;

  final String emergencyContactName;
  final String emergencyContactMobile;

  final String aadhaarNumber;
  final String panNumber;

  final String profileSelfie;
  final String aadhaarFront;
  final String aadhaarBack;
  final String panCard;

  final bool profileCompleted;
  final bool aadhaarFrontUploaded;
  final bool aadhaarBackUploaded;
  final bool panCardUploaded;

  final bool selfieVerified;
  final bool aadhaarFrontVerified;
  final bool aadhaarBackVerified;
  final bool aadhaarVerified;
  final bool panVerified;

  final String verificationStatus;

  final bool isOnline;
  final bool isAvailable;
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
    required this.gender,
    required this.address,
    required this.village,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
    required this.emergencyContactName,
    required this.emergencyContactMobile,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.profileSelfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.panCard,
    required this.profileCompleted,
    required this.aadhaarFrontUploaded,
    required this.aadhaarBackUploaded,
    required this.panCardUploaded,
    required this.selfieVerified,
    required this.aadhaarFrontVerified,
    required this.aadhaarBackVerified,
    required this.aadhaarVerified,
    required this.panVerified,
    required this.verificationStatus,
    required this.isOnline,
    required this.isAvailable,
    required this.isActive,
    required this.totalWalks,
    required this.activeWalks,
    required this.rating,
  });

  factory WalkerData.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    String stringValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];

        if (value == null) {
          continue;
        }

        if (value is Timestamp) {
          return value.toDate().toIso8601String();
        }

        final text = value.toString().trim();

        if (text.isNotEmpty) {
          return text;
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

        if (value is num) {
          return value != 0;
        }

        if (value is String) {
          final text = value.trim().toLowerCase();

          if (text == 'true' || text == 'yes' || text == '1') {
            return true;
          }

          if (text == 'false' || text == 'no' || text == '0') {
            return false;
          }
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

    String statusValue() {
      final status = stringValue([
        'verificationStatus',
        'verification_status',
        'approvalStatus',
        'approval_status',
        'status',
      ]).toLowerCase();

      if (status == 'approved' ||
          status == 'rejected' ||
          status == 'pending') {
        return status;
      }

      if (boolValue([
        'approved',
        'isApproved',
        'adminApproved',
      ])) {
        return 'approved';
      }

      if (boolValue([
        'rejected',
        'isRejected',
        'adminRejected',
      ])) {
        return 'rejected';
      }

      return 'pending';
    }

    return WalkerData(
      document: document,

      walkerId: stringValue([
        'Walker ID',
        'walkerId',
        'walker_id',
        'id',
      ]),

      uid: stringValue([
        'Walker Uid',
        'walkerUid',
        'walkerUID',
        'uid',
        'authUid',
        'authUID',
      ]).isNotEmpty
          ? stringValue([
              'Walker Uid',
              'walkerUid',
              'walkerUID',
              'uid',
              'authUid',
              'authUID',
            ])
          : document.id,

      name: stringValue([
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ]),

      phone: stringValue([
        'Mobile number',
        'mobileNumber',
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
        'dateofbirth',
        'dob',
      ]),

      gender: stringValue([
        'Gender',
        'gender',
      ]),

      address: stringValue([
        'Address',
        'Adress',
        'address',
      ]),

      village: stringValue([
        'Village',
        'village',
      ]),

      city: stringValue([
        'City',
        'city',
      ]),

      district: stringValue([
        'District',
        'district',
      ]),

      state: stringValue([
        'State',
        'state',
      ]),

      pincode: stringValue([
        'Pincode',
        'pincode',
        'pinCode',
      ]),

      emergencyContactName: stringValue([
        'emergencyContactName',
        'Emergency Contact Name',
      ]),

      emergencyContactMobile: stringValue([
        'emergencyContactMobile',
        'Emergency Contact Mobile',
      ]),

      aadhaarNumber: stringValue([
        'Aadhaar Number',
        'Aadhar Number',
        'aadhaarNumber',
        'aadharNumber',
      ]),

      panNumber: stringValue([
        'panNumber',
        'PAN Number',
        'Pan Number',
      ]),

      profileSelfie: stringValue([
        'Profile Selfie',
        'profileSelfie',
        'selfie',
        'selfieUrl',
        'profileImageUrl',
        'profileImage',
      ]),

      aadhaarFront: stringValue([
        'Aadhaar Front',
        'Aadhar Front',
        'aadhaarFrontUrl',
        'aadhaarFront',
        'aadhaarfront',
        'aadhaar_front',
      ]),

      aadhaarBack: stringValue([
        'Aadhaar Back',
        'Aadhar Back',
        'aadhaarBackUrl',
        'aadhaarBack',
        'aadhaarback',
        'aadhaar_back',
      ]),

      panCard: stringValue([
        'PAN Card URL',
        'panCardUrl',
        'panCard',
        'pan_card_url',
        'pan_card',
      ]),

      profileCompleted: boolValue([
        'profileCompleted',
        'profile_completed',
        'isProfileCompleted',
      ]),

      aadhaarFrontUploaded: boolValue([
        'aadhaarFrontUploaded',
        'aadhaar_front_uploaded',
      ]),

      aadhaarBackUploaded: boolValue([
        'aadhaarBackUploaded',
        'aadhaar_back_uploaded',
      ]),

      panCardUploaded: boolValue([
        'panCardUploaded',
        'pan_card_uploaded',
      ]),

      selfieVerified: boolValue([
        'selfieVerified',
        'selfie_verified',
      ]),

      aadhaarFrontVerified: boolValue([
        'aadhaarFrontVerified',
        'aadhaar_front_verified',
      ]),

      aadhaarBackVerified: boolValue([
        'aadhaarBackVerified',
        'aadhaar_back_verified',
      ]),

      aadhaarVerified: boolValue([
        'aadhaarVerified',
        'aadharVerified',
        'aadhaar_verified',
      ]),

      panVerified: boolValue([
        'panVerified',
        'pan_verified',
      ]),

      verificationStatus: statusValue(),

      isOnline: boolValue([
        'isOnline',
        'online',
      ]),

      isAvailable: boolValue([
        'isAvailable',
        'available',
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

  bool get isApproved => verificationStatus == 'approved';

  bool get isRejected => verificationStatus == 'rejected';

  bool get isPending => verificationStatus == 'pending';
}
