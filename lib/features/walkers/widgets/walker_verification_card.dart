import 'package:flutter/material.dart';

const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoDark = Color(0xFF263238);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkerVerificationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WalkerVerificationCard({
    super.key,
    required this.data,
  });

  bool _bool(List<String> keys) {
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

  bool get profileCompleted {
    return _bool([
      'profileCompleted',
      'profile_completed',
    ]);
  }

  bool get aadhaarFrontUploaded {
    return _bool([
      'aadhaar_front_uploaded',
      'aadhaarFrontUploaded',
    ]);
  }

  bool get aadhaarBackUploaded {
    return _bool([
      'aadhaar_back_uploaded',
      'aadhaarBackUploaded',
    ]);
  }

  bool get aadhaarVerified {
    return _bool([
      'aadhaarVerified',
      'aadharVerified',
      'aadhaar_verified',
    ]);
  }

  bool get selfieVerified {
    return _bool([
      'selfieVerified',
      'selfie_verified',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Profile Completed',
            profileCompleted,
          ),
          _row(
            'Aadhaar Front Uploaded',
            aadhaarFrontUploaded,
          ),
          _row(
            'Aadhaar Back Uploaded',
            aadhaarBackUploaded,
          ),
          _row(
            'Aadhaar Verified',
            aadhaarVerified,
          ),
          _row(
            'Selfie Verified',
            selfieVerified,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle
                : Icons.cancel_outlined,
            color:
                value ? dojoGreen : dojoGrey,
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
              color:
                  value ? dojoGreen : dojoGrey,
            ),
          ),
        ],
      ),
    );
  }
}
