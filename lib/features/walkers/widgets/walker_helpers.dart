import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerHelpers {
  static String string(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static bool boolValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
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

  static int intValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
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

  static double doubleValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
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

  static String walkerId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return string(
      data,
      [
        'walkerId',
        'Walker ID',
        'walker_id',
        'id',
      ],
    );
  }

  static String uid(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final value = string(
      data,
      [
        'Walker Uid',
        'walkerUid',
        'walkerUID',
        'uid',
        'authUid',
        'authUID',
      ],
    );

    return value.isNotEmpty ? value : doc.id;
  }

  static String name(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
    );
  }

  static String phone(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'Mobile number',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );
  }

  static String email(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'email',
        'Email',
      ],
    );
  }

  static String profileImage(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'profileImageUrl',
        'selfieUrl',
      ],
    );
  }

  static String aadhaarNumber(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'Aadhar Number',
        'Aadhaar Number',
        'aadhaarNumber',
        'aadharNumber',
      ],
    );
  }

  static String aadhaarFront(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'aadhaar_front_url',
        'aadhaarFrontUrl',
        'aadhaar_front',
        'aadhaarFront',
        'Aadhar Front',
        'Aadhaar Front',
        'aadhaarFrontImage',
      ],
    );
  }

  static String aadhaarBack(
    Map<String, dynamic> data,
  ) {
    return string(
      data,
      [
        'aadhaar_back_url',
        'aadhaarBackUrl',
        'aadhaar_back',
        'aadhaarBack',
        'Aadhar Back',
        'Aadhaar Back',
        'aadhaarBackImage',
      ],
    );
  }

  static bool aadhaarFrontUploaded(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'aadhaar_front_uploaded',
        'aadhaarFrontUploaded',
      ],
    );
  }

  static bool aadhaarBackUploaded(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'aadhaar_back_uploaded',
        'aadhaarBackUploaded',
      ],
    );
  }

  static bool profileCompleted(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'profileCompleted',
        'profile_completed',
      ],
    );
  }

  static bool isOnline(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'isOnline',
        'online',
      ],
    );
  }

  static int totalWalks(
    Map<String, dynamic> data,
  ) {
    return intValue(
      data,
      [
        'totalWalks',
        'completedWalks',
        'walks',
      ],
    );
  }

  static int activeWalks(
    Map<String, dynamic> data,
  ) {
    return intValue(
      data,
      [
        'activeWalks',
        'currentActiveWalks',
      ],
    );
  }

  static double rating(
    Map<String, dynamic> data,
  ) {
    return doubleValue(
      data,
      [
        'rating',
        'averageRating',
      ],
    );
  }

  static String verificationStatus(
    Map<String, dynamic> data,
  ) {
    final status = string(
      data,
      [
        'verificationStatus',
        'verification_status',
        'approvalStatus',
        'approval_status',
      ],
    ).toLowerCase();

    if (status == 'approved' ||
        status == 'rejected' ||
        status == 'pending') {
      return status;
    }

    if (boolValue(
      data,
      [
        'approved',
        'isApproved',
      ],
    )) {
      return 'approved';
    }

    if (boolValue(
      data,
      [
        'rejected',
        'isRejected',
      ],
    )) {
      return 'rejected';
    }

    return 'pending';
  }

  static bool aadhaarVerified(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'aadhaarVerified',
        'aadharVerified',
        'aadhaar_verified',
      ],
    );
  }

  static bool selfieVerified(
    Map<String, dynamic> data,
  ) {
    return boolValue(
      data,
      [
        'selfieVerified',
        'selfie_verified',
      ],
    );
  }
}
