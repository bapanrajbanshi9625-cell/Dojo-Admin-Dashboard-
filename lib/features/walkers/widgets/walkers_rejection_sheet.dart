import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color rejectedColor = Color(0xFFC62828);

Future<void> showWalkerRejectionSheet({
  required BuildContext context,
  required DocumentSnapshot<Map<String, dynamic>> doc,
}) async {
  final data = doc.data() ?? {};

  final name = _readString(
    data,
    [
      'Full Name',
      'fullName',
      'name',
      'walkerName',
    ],
  );

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
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
                    Icons.warning_amber_rounded,
                    color: rejectedColor,
                    size: 28,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Reject Walker?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: dojoDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                'Are you sure you want to reject '
                '${name.isEmpty ? 'this walker' : name}?',
                style: const TextStyle(
                  color: dojoGrey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          await rejectWalker(doc);

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
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

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Rejection failed: $e',
                              ),
                              backgroundColor:
                                  rejectedColor,
                            ),
                          );
                        }
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            rejectedColor,
                        foregroundColor:
                            Colors.white,
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> rejectWalker(
  DocumentSnapshot<Map<String, dynamic>> doc,
) async {
  final adminUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  await doc.reference.set(
    {
      'verificationStatus': 'rejected',
      'approvalStatus': 'rejected',

      'approved': false,
      'isApproved': false,

      'isActive': false,

      'rejected': true,
      'isRejected': true,

      'rejectedBy': adminUid,
      'rejectedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
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
