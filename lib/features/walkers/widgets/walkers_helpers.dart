import 'package:flutter/material.dart';

// ============================================================
// WALKER DETAILS COLORS
// ============================================================

const Color walkerDetailsOrange = Color(0xFFFF6600);
const Color walkerDetailsGreen = Color(0xFF16A34A);
const Color walkerDetailsRed = Color(0xFFDC2626);
const Color walkerDetailsBlue = Color(0xFF2563EB);

const Color walkerDetailsTextDark = Color(0xFF111827);
const Color walkerDetailsTextGrey = Color(0xFF6B7280);
const Color walkerDetailsBorder = Color(0xFFE5E7EB);
const Color walkerDetailsPageBg = Color(0xFFF7F8FA);

// ============================================================
// READ STRING VALUE
// ============================================================

String walkerValue(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = 'Not available',
}) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) {
      continue;
    }

    final text = value.toString().trim();

    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  return fallback;
}

// ============================================================
// READ BOOLEAN VALUE
// ============================================================

bool walkerBool(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value != null) {
      final text = value.toString().trim().toLowerCase();

      if (text == 'true' ||
          text == '1' ||
          text == 'yes') {
        return true;
      }

      if (text == 'false' ||
          text == '0' ||
          text == 'no') {
        return false;
      }
    }
  }

  return false;
}

// ============================================================
// IMAGE URL
// ============================================================

String walkerImageUrl(
  Map<String, dynamic> data,
  List<String> keys,
) {
  return walkerValue(
    data,
    keys,
    fallback: '',
  );
}

// ============================================================
// STATUS
// ============================================================

String walkerStatus(
  Map<String, dynamic> data,
) {
  final status = walkerValue(
    data,
    const [
      'verificationStatus',
      'approvalStatus',
      'status',
    ],
    fallback: '',
  ).toLowerCase().trim();

  if (status == 'approved') {
    return 'Approved';
  }

  if (status == 'rejected') {
    return 'Rejected';
  }

  if (status == 'pending') {
    return 'Pending';
  }

  if (walkerBool(
    data,
    const [
      'approved',
      'isApproved',
      'adminApproved',
    ],
  )) {
    return 'Approved';
  }

  if (walkerBool(
    data,
    const [
      'rejected',
      'isRejected',
      'adminRejected',
    ],
  )) {
    return 'Rejected';
  }

  return 'Pending';
}

// ============================================================
// ACTIVE STATUS
// ============================================================

bool walkerIsActive(
  Map<String, dynamic> data,
) {
  return walkerBool(
    data,
    const [
      'isActive',
      'active',
    ],
  );
}

// ============================================================
// STATUS COLOR
// ============================================================

Color walkerStatusColor(
  String status,
) {
  switch (status) {
    case 'Approved':
      return walkerDetailsGreen;

    case 'Rejected':
      return walkerDetailsRed;

    default:
      return walkerDetailsOrange;
  }
}

// ============================================================
// WALKER NAME
// ============================================================

String walkerName(
  Map<String, dynamic> data,
) {
  return walkerValue(
    data,
    const [
      'Full Name',
      'fullName',
      'name',
      'walkerName',
    ],
    fallback: 'Walker',
  );
}

// ============================================================
// MOBILE
// ============================================================

String walkerMobile(
  Map<String, dynamic> data,
) {
  return walkerValue(
    data,
    const [
      'Mobile number',
      'mobileNumber',
      'mobile',
      'phone',
      'phoneNumber',
    ],
  );
}

// ============================================================
// WALKER ID
// ============================================================

String walkerId(
  Map<String, dynamic> data, {
  String fallback = 'Not available',
}) {
  return walkerValue(
    data,
    const [
      'Walker ID',
      'walkerId',
    ],
    fallback: fallback,
  );
}

// ============================================================
// WALKER UID
// ============================================================

String walkerUid(
  Map<String, dynamic> data,
) {
  return walkerValue(
    data,
    const [
      'Walker Uid',
      'walkerUid',
      'authUid',
      'uid',
    ],
  );
}

// ============================================================
// PROFILE SELFIE
// ============================================================

String walkerSelfie(
  Map<String, dynamic> data,
) {
  return walkerImageUrl(
    data,
    const [
      'Profile Selfie',
      'profileSelfie',
      'profileSelfieUrl',
      'profile_selfie',
      'profile_selfie_url',
      'selfie',
      'selfieUrl',
    ],
  );
}

// ============================================================
// AADHAAR FRONT
// ============================================================

String walkerAadhaarFront(
  Map<String, dynamic> data,
) {
  return walkerImageUrl(
    data,
    const [
      'Aadhar Front',
      'Aadhaar Front',
      'Aadhar Front URL',
      'Aadhaar Front URL',
      'aadhaarFront',
      'aadhaarFrontUrl',
      'aadhaar_front',
      'aadhaar_front_url',
    ],
  );
}

// ============================================================
// AADHAAR BACK
// ============================================================

String walkerAadhaarBack(
  Map<String, dynamic> data,
) {
  return walkerImageUrl(
    data,
    const [
      'Aadhar Back',
      'Aadhaar Back',
      'Aadhar Back URL',
      'Aadhaar Back URL',
      'aadhaarBack',
      'aadhaarBackUrl',
      'aadhaar_back',
      'aadhaar_back_url',
    ],
  );
}

// ============================================================
// PROFILE COMPLETED
// ============================================================

bool walkerProfileCompleted(
  Map<String, dynamic> data,
) {
  return walkerBool(
    data,
    const [
      'profileCompleted',
      'profile_completed',
    ],
  );
}

// ============================================================
// AADHAAR FRONT UPLOADED
// ============================================================

bool walkerAadhaarFrontUploaded(
  Map<String, dynamic> data,
) {
  return walkerBool(
    data,
    const [
      'aadhaar_front_uploaded',
      'aadhar_front_uploaded',
      'aadhaarFrontUploaded',
      'aadharFrontUploaded',
    ],
  );
}

// ============================================================
// AADHAAR BACK UPLOADED
// ============================================================

bool walkerAadhaarBackUploaded(
  Map<String, dynamic> data,
) {
  return walkerBool(
    data,
    const [
      'aadhaar_back_uploaded',
      'aadhar_back_uploaded',
      'aadhaarBackUploaded',
      'aadharBackUploaded',
    ],
  );
}
