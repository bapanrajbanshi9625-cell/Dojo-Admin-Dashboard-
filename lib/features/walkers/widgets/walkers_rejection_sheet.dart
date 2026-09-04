import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color rejectedColor = Color(0xFFC62828);

const List<String> walkerRejectionReasons = [
  'Aadhaar is not clear',
  'Aadhaar details do not match',
  'Aadhaar Front is not clear',
  'Aadhaar Back is not clear',
  'PAN Card is not clear',
  'PAN details do not match',
  'Selfie is not clear',
  'Selfie does not match Aadhaar',
  'Name does not match documents',
  'Invalid document',
  'Incomplete verification',
  'Other',
];

/// Shows the walker rejection sheet.
///
/// Admin must select at least one rejection reason.
/// If "Other" is selected, a custom reason is required.
Future<void> showWalkersRejectionSheet({
  required BuildContext context,
  required DocumentSnapshot<Map<String, dynamic>> doc,
}) async {
  final data = doc.data() ?? <String, dynamic>{};

  final name = _readString(
    data,
    const [
      'Full Name',
      'fullName',
      'name',
      'walkerName',
    ],
  );

  final selectedReasons = <String>{};
  final otherController = TextEditingController();

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
          final otherSelected =
              selectedReasons.contains('Other');

          final hasValidReason =
              selectedReasons.isNotEmpty &&
              (!otherSelected ||
                  otherController.text.trim().isNotEmpty);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext)
                  .viewInsets
                  .bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(sheetContext).size.height *
                        0.88,
              ),
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
                          Icons.warning_amber_rounded,
                          color: rejectedColor,
                          size: 28,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Reject Walker',
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
                      name.isEmpty
                          ? 'Select the reason for rejection.'
                          : 'Select why $name cannot be approved.',
                      style: const TextStyle(
                        color: dojoGrey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            walkerRejectionReasons.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final reason =
                              walkerRejectionReasons[index];

                          final selected =
                              selectedReasons.contains(
                            reason,
                          );

                          return CheckboxListTile(
                            value: selected,
                            activeColor: rejectedColor,
                            contentPadding:
                                EdgeInsets.zero,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            dense: true,
                            title: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: dojoDark,
                              ),
                            ),
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedReasons.add(
                                    reason,
                                  );
                                } else {
                                  selectedReasons.remove(
                                    reason,
                                  );

                                  if (reason == 'Other') {
                                    otherController
                                        .clear();
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    if (otherSelected) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: otherController,
                        maxLines: 3,
                        onChanged: (_) {
                          setModalState(() {});
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Enter custom rejection reason',
                          labelText: 'Other reason',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(
                              color: rejectedColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(
                                sheetContext,
                              ).pop();
                            },
                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor: dojoDark,
                              side: const BorderSide(
                                color: dojoBorder,
                              ),
                              minimumSize:
                                  const Size.fromHeight(50),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: hasValidReason
                                ? () async {
                                    final reasons =
                                        _buildReasons(
                                      selectedReasons,
                                      otherController
                                          .text,
                                    );

                                    Navigator.of(
                                      sheetContext,
                                    ).pop();

                                    try {
                                      await rejectWalkers(
                                        doc: doc,
                                        reasons: reasons,
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                          .of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Walker rejected.',
                                          ),
                                          backgroundColor:
                                              rejectedColor,
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                          .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Rejection failed: $e',
                                          ),
                                          backgroundColor:
                                              rejectedColor,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            icon: const Icon(
                              Icons.block_rounded,
                            ),
                            label: const Text(
                              'Reject Walker',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  rejectedColor,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  dojoBorder,
                              disabledForegroundColor:
                                  dojoGrey,
                              minimumSize:
                                  const Size.fromHeight(50),
                              elevation: 0,
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
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  otherController.dispose();
}

/// Rejects a walker in Firestore.
///
/// The rejection reasons are stored as both:
/// - rejectionReasons: List<String>
/// - rejectionReason: readable joined string
Future<void> rejectWalkers({
  required DocumentSnapshot<Map<String, dynamic>> doc,
  required List<String> reasons,
}) async {
  if (reasons.isEmpty) {
    throw StateError(
      'At least one rejection reason is required.',
    );
  }

  final cleanedReasons = reasons
      .map((reason) => reason.trim())
      .where((reason) => reason.isNotEmpty)
      .toSet()
      .toList();

  if (cleanedReasons.isEmpty) {
    throw StateError(
      'At least one valid rejection reason is required.',
    );
  }

  final adminUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  await doc.reference.set(
    {
      'verificationStatus': 'rejected',
      'approvalStatus': 'rejected',
      'status': 'rejected',

      'approved': false,
      'isApproved': false,
      'adminApproved': false,

      'rejected': true,
      'isRejected': true,
      'adminRejected': true,

      'isActive': false,
      'active': false,

      'rejectionReasons': cleanedReasons,
      'rejectionReason': cleanedReasons.join(', '),

      'rejectedBy': adminUid,
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

List<String> _buildReasons(
  Set<String> selectedReasons,
  String otherText,
) {
  final reasons = <String>[];

  for (final reason in walkerRejectionReasons) {
    if (!selectedReasons.contains(reason)) {
      continue;
    }

    if (reason == 'Other') {
      final customReason = otherText.trim();

      if (customReason.isNotEmpty) {
        reasons.add(customReason);
      }
    } else {
      reasons.add(reason);
    }
  }

  return reasons;
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
