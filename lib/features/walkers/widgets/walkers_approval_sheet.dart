import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

/// Walker approval bottom sheet.
///
/// Approval is allowed only when all four documents are verified:
/// - Profile Selfie
/// - Aadhaar Front
/// - Aadhaar Back
/// - PAN Card
Future<void> showWalkersApprovalSheet({
  required BuildContext context,
  required DocumentSnapshot<Map<String, dynamic>> doc,
}) async {
  final data = doc.data() ?? {};

  bool selfieVerified = _readBool(
    data,
    const [
      'selfieVerified',
      'selfie_verified',
    ],
  );

  bool aadhaarFrontVerified = _readBool(
    data,
    const [
      'aadhaarFrontVerified',
      'aadhaar_front_verified',
    ],
  );

  bool aadhaarBackVerified = _readBool(
    data,
    const [
      'aadhaarBackVerified',
      'aadhaar_back_verified',
    ],
  );

  bool panVerified = _readBool(
    data,
    const [
      'panVerified',
      'pan_verified',
    ],
  );

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (
          modalContext,
          setModalState,
        ) {
          final canApprove =
              selfieVerified &&
              aadhaarFrontVerified &&
              aadhaarBackVerified &&
              panVerified;

          final walkerName = _readString(
            data,
            const [
              'Full Name',
              'fullName',
              'name',
              'walkerName',
            ],
          );

          return Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              25,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _handle(),

                  const SizedBox(height: 18),

                  const Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: dojoGreen,
                        size: 27,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Approve Walker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: dojoDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    walkerName.isEmpty
                        ? 'Walker verification'
                        : walkerName,
                    style: const TextStyle(
                      color: dojoGrey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _verificationTile(
                    title: 'Profile Selfie',
                    subtitle:
                        'Confirm the walker selfie has been checked.',
                    value: selfieVerified,
                    onChanged: (value) {
                      setModalState(() {
                        selfieVerified = value;
                      });
                    },
                  ),

                  _verificationTile(
                    title: 'Aadhaar Front',
                    subtitle:
                        'Confirm the Aadhaar front side has been checked.',
                    value: aadhaarFrontVerified,
                    onChanged: (value) {
                      setModalState(() {
                        aadhaarFrontVerified = value;
                      });
                    },
                  ),

                  _verificationTile(
                    title: 'Aadhaar Back',
                    subtitle:
                        'Confirm the Aadhaar back side has been checked.',
                    value: aadhaarBackVerified,
                    onChanged: (value) {
                      setModalState(() {
                        aadhaarBackVerified = value;
                      });
                    },
                  ),

                  _verificationTile(
                    title: 'PAN Card',
                    subtitle:
                        'Confirm the PAN card has been checked.',
                    value: panVerified,
                    onChanged: (value) {
                      setModalState(() {
                        panVerified = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  if (!canApprove)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(
                            alpha: 0.20,
                          ),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'All four verification checks are required before approval.',
                              style: TextStyle(
                                color: dojoDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: canApprove
                          ? () async {
                              try {
                                await approveWalkers(
                                  doc: doc,
                                  selfieVerified:
                                      selfieVerified,
                                  aadhaarFrontVerified:
                                      aadhaarFrontVerified,
                                  aadhaarBackVerified:
                                      aadhaarBackVerified,
                                  panVerified:
                                      panVerified,
                                );

                                if (sheetContext.mounted) {
                                  Navigator.of(
                                    sheetContext,
                                  ).pop();
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Walker approved successfully.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (modalContext.mounted) {
                                  ScaffoldMessenger.of(
                                    modalContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Approval failed: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),
                      label: const Text(
                        'Confirm Approval',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dojoGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            dojoBorder,
                        disabledForegroundColor:
                            dojoGrey,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Approves a walker in Firestore.
///
/// The four verification selections from the approval
/// sheet are validated and saved together with approval.
Future<void> approveWalkers({
  required DocumentSnapshot<Map<String, dynamic>> doc,
  required bool selfieVerified,
  required bool aadhaarFrontVerified,
  required bool aadhaarBackVerified,
  required bool panVerified,
}) async {
  if (!selfieVerified ||
      !aadhaarFrontVerified ||
      !aadhaarBackVerified ||
      !panVerified) {
    throw StateError(
      'All four documents must be verified before approval.',
    );
  }

  final adminUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  await doc.reference.set(
    {
      'verificationStatus': 'approved',
      'approvalStatus': 'approved',
      'status': 'approved',

      'approved': true,
      'isApproved': true,
      'adminApproved': true,

      // Profile Selfie
      'selfieVerified': true,
      'selfie_verified': true,

      // Aadhaar Front
      'aadhaarFrontVerified': true,
      'aadhaar_front_verified': true,

      // Aadhaar Back
      'aadhaarBackVerified': true,
      'aadhaar_back_verified': true,

      // Overall Aadhaar compatibility flags
      'aadhaarVerified': true,
      'aadharVerified': true,
      'aadhaar_verified': true,

      // PAN
      'panVerified': true,
      'pan_verified': true,

      // Profile
      'profileCompleted': true,
      'isProfileCompleted': true,

      // Walker becomes active after approval
      'isActive': true,
      'active': true,

      // Clear rejection state
      'adminRejected': false,
      'rejected': false,
      'isRejected': false,

      'rejectionReasons': FieldValue.delete(),
      'rejectionReason': FieldValue.delete(),
      'rejectedAt': FieldValue.delete(),

      // Admin audit
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

Widget _verificationTile({
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return CheckboxListTile(
    value: value,
    activeColor: dojoGreen,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: dojoDark,
      ),
    ),
    subtitle: Text(subtitle),
    onChanged: (newValue) {
      onChanged(newValue ?? false);
    },
  );
}

bool _readBool(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized =
          value.trim().toLowerCase();

      if (normalized == 'true') {
        return true;
      }

      if (normalized == 'false') {
        return false;
      }
    }

    if (value is num) {
      return value != 0;
    }
  }

  return false;
}

String _readString(
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

Widget _handle() {
  return Center(
    child: Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: dojoBorder,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
