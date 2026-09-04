import 'package:flutter/material.dart';

import 'walkers_helpers.dart';

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
      'isProfileCompleted',
    ]);
  }

  bool get selfieVerified {
    return _readBool([
      'selfieVerified',
      'selfie_verified',
    ]);
  }

  bool get aadhaarFrontVerified {
    return _readBool([
      'aadhaarFrontVerified',
      'aadhaar_front_verified',
    ]);
  }

  bool get aadhaarBackVerified {
    return _readBool([
      'aadhaarBackVerified',
      'aadhaar_back_verified',
    ]);
  }

  bool get panVerified {
    return _readBool([
      'panVerified',
      'pan_verified',
    ]);
  }

  bool get allDocumentsVerified {
    return selfieVerified &&
        aadhaarFrontVerified &&
        aadhaarBackVerified &&
        panVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: walkerDetailsBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: walkerDetailsOrange
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: walkerDetailsOrange,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Verification Checklist',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: walkerDetailsTextDark,
                  ),
                ),
              ),
              _overallBadge(),
            ],
          ),

          const SizedBox(height: 16),

          _verificationRow(
            title: 'Profile Completed',
            value: profileCompleted,
            icon: Icons.person_rounded,
          ),

          _verificationRow(
            title: 'Selfie Verified',
            value: selfieVerified,
            icon: Icons.face_rounded,
          ),

          _verificationRow(
            title: 'Aadhaar Front Verified',
            value: aadhaarFrontVerified,
            icon: Icons.credit_card_rounded,
          ),

          _verificationRow(
            title: 'Aadhaar Back Verified',
            value: aadhaarBackVerified,
            icon: Icons.credit_card_rounded,
          ),

          _verificationRow(
            title: 'PAN Verified',
            value: panVerified,
            icon: Icons.badge_rounded,
          ),

          const SizedBox(height: 5),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: allDocumentsVerified
                  ? walkerDetailsGreen
                      .withValues(alpha: 0.08)
                  : walkerDetailsOrange
                      .withValues(alpha: 0.07),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  allDocumentsVerified
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: allDocumentsVerified
                      ? walkerDetailsGreen
                      : walkerDetailsOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allDocumentsVerified
                        ? 'All 4 verification checks are complete.'
                        : 'All 4 checks must be verified before approval.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: allDocumentsVerified
                          ? walkerDetailsGreen
                          : walkerDetailsTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overallBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: allDocumentsVerified
            ? walkerDetailsGreen
                .withValues(alpha: 0.10)
            : Colors.grey.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        allDocumentsVerified
            ? 'READY'
            : 'PENDING',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: allDocumentsVerified
              ? walkerDetailsGreen
              : walkerDetailsTextGrey,
        ),
      ),
    );
  }

  Widget _verificationRow({
    required String title,
    required bool value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: value
              ? walkerDetailsGreen
                  .withValues(alpha: 0.045)
              : const Color(0xFFF9FAFB),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: value
                ? walkerDetailsGreen
                    .withValues(alpha: 0.18)
                : walkerDetailsBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value
                  ? walkerDetailsGreen
                  : walkerDetailsTextGrey,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: walkerDetailsTextDark,
                ),
              ),
            ),
            Icon(
              value
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 19,
              color: value
                  ? walkerDetailsGreen
                  : walkerDetailsTextGrey,
            ),
            const SizedBox(width: 5),
            Text(
              value ? 'Verified' : 'Pending',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: value
                    ? walkerDetailsGreen
                    : walkerDetailsTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
