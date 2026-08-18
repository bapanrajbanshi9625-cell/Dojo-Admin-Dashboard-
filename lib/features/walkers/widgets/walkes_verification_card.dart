import 'package:flutter/material.dart';

const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoDark = Color(0xFF263238);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkersVerificationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WalkersVerificationCard({
    super.key,
    required this.data,
  });

  bool _readBool(List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value != 0;
      }

      if (value is String) {
        final normalized =
            value.trim().toLowerCase();

        if (normalized == 'true' ||
            normalized == 'yes' ||
            normalized == '1') {
          return true;
        }

        if (normalized == 'false' ||
            normalized == 'no' ||
            normalized == '0') {
          return false;
        }
      }
    }

    return false;
  }

  bool get profileCompleted {
    return _readBool([
      'profileCompleted',
      'profile_completed',
    ]);
  }

  bool get aadhaarFrontUploaded {
    return _readBool([
      'aadhaar_front_uploaded',
      'aadhaarFrontUploaded',
    ]);
  }

  bool get aadhaarBackUploaded {
    return _readBool([
      'aadhaar_back_uploaded',
      'aadhaarBackUploaded',
    ]);
  }

  bool get aadhaarVerified {
    return _readBool([
      'aadhaarVerified',
      'aadharVerified',
      'aadhaar_verified',
    ]);
  }

  bool get selfieVerified {
    return _readBool([
      'selfieVerified',
      'selfie_verified',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          _row(
            title: 'Profile Completed',
            value: profileCompleted,
          ),
          _row(
            title: 'Aadhaar Front Uploaded',
            value: aadhaarFrontUploaded,
          ),
          _row(
            title: 'Aadhaar Back Uploaded',
            value: aadhaarBackUploaded,
          ),
          _row(
            title: 'Aadhaar Verified',
            value: aadhaarVerified,
          ),
          _row(
            title: 'Selfie Verified',
            value: selfieVerified,
          ),
        ],
      ),
    );
  }

  Widget _row({
    required String title,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle_rounded
                : Icons.cancel_outlined,
            color: value
                ? dojoGreen
                : dojoGrey,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dojoDark,
              ),
            ),
          ),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: value
                  ? dojoGreen
                  : dojoGrey,
            ),
          ),
        ],
      ),
    );
  }
}
