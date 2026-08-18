import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color rejectedColor = Color(0xFFC62828);

/// Shows the walker approval bottom sheet.
///
/// Approval is allowed only after both:
/// - Aadhaar verification
/// - Selfie verification
Future<void> showWalkersApprovalSheet({
  required BuildContext context,
  required DocumentSnapshot<Map<String, dynamic>> doc,
}) async {
  final data = doc.data() ?? {};

  bool aadhaarVerified = _readBool(
    data,
    const [
      'aadhaarVerified',
      'aadharVerified',
      'aadhaar_verified',
    ],
  );

  bool selfieVerified = _readBool(
    data,
    const [
      'selfieVerified',
      'selfie_verified',
    ],
  );

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (
          context,
          setModalState,
        ) {
          final canApprove =
              aadhaarVerified && selfieVerified;

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

                  CheckboxListTile(
                    value: aadhaarVerified,
                    activeColor: dojoGreen,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Aadhaar Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Confirm Aadhaar documents have been checked.',
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        aadhaarVerified =
                            value ?? false;
                      });
                    },
                  ),

                  CheckboxListTile(
                    value: selfieVerified,
                    activeColor: dojoGreen,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Selfie Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Confirm profile selfie has been checked.',
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        selfieVerified =
                            value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: canApprove
                          ? () async {
                              Navigator.of(
                                sheetContext,
                              ).pop();

                              await approveWalkers(
                                doc: doc,
                                aadhaarVerified:
                                    aadhaarVerified,
                                selfieVerified:
                                    selfieVerified,
                              );
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
/// Existing fields are preserved because [SetOptions]
/// with merge is used.
Future<void> approveWalkers({
  required DocumentSnapshot<Map<String, dynamic>> doc,
  required bool aadhaarVerified,
  required bool selfieVerified,
}) async {
  final adminUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  await doc.reference.set(
    {
      'verificationStatus': 'approved',
      'approvalStatus': 'approved',
      'status': 'approved',

      'approved': true,
      'isApproved': true,

      'aadhaarVerified': aadhaarVerified,
      'aadharVerified': aadhaarVerified,
      'aadhaar_verified': aadhaarVerified,

      'selfieVerified': selfieVerified,
      'selfie_verified': selfieVerified,

      'profileCompleted': true,
      'isActive': true,

      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
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
      return value.trim().toLowerCase() == 'true';
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
