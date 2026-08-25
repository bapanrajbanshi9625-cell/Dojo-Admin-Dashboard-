import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignWalkerDialog extends StatefulWidget {
  final String requestId;

  final Map<String, dynamic> requestData;

  final List<
      QueryDocumentSnapshot<
          Map<String, dynamic>>> walkers;

  final FirebaseFirestore firestore;

  const AssignWalkerDialog({
    super.key,
    required this.requestId,
    required this.requestData,
    required this.walkers,
    required this.firestore,
  });

  @override
  State<AssignWalkerDialog> createState() =>
      _AssignWalkerDialogState();
}

class _AssignWalkerDialogState
    extends State<AssignWalkerDialog> {
  String? selectedDocId;

  bool saving = false;

  // ==========================================================
  // VALUE
  // ==========================================================

  String _value(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ==========================================================
  // WALKER NAME
  // ==========================================================

  String _walkerName(
    Map<String, dynamic> data,
  ) {
    final name =
        _value(data, 'name');

    if (name.isNotEmpty) {
      return name;
    }

    final walkerName =
        _value(data, 'walkerName');

    if (walkerName.isNotEmpty) {
      return walkerName;
    }

    return 'Walker';
  }

  // ==========================================================
  // WALKER UID
  // ==========================================================

  String _walkerUid(
    Map<String, dynamic> data,
  ) {
    final authUid =
        _value(data, 'authUid');

    if (authUid.isNotEmpty) {
      return authUid;
    }

    final walkerUid =
        _value(data, 'walkerUid');

    if (walkerUid.isNotEmpty) {
      return walkerUid;
    }

    final uid =
        _value(data, 'uid');

    if (uid.isNotEmpty) {
      return uid;
    }

    return '';
  }

  // ==========================================================
  // ASSIGN
  // ==========================================================

  Future<void> _assign() async {
    if (selectedDocId == null) {
      _showMessage(
        'Please select a walker.',
      );

      return;
    }

    final walker =
        widget.walkers.firstWhere(
      (doc) =>
          doc.id == selectedDocId,
    );

    final data = walker.data();

    final walkerUid =
        _walkerUid(data);

    final walkerId =
        _value(data, 'walkerId');

    final walkerName =
        _walkerName(data);

    if (walkerUid.isEmpty) {
      _showMessage(
        'Selected walker has no valid UID.',
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await widget.firestore
          .collection('walk_requests')
          .doc(widget.requestId)
          .update({
        'status': 'accepted',

        'walkerUid':
            walkerUid,

        'walkerId':
            walkerId,

        'walkerName':
            walkerName,

        'acceptedBy':
            walkerUid,

        'acceptedAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Walker assigned successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      _showMessage(
        'Failed to assign walker: $e',
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.person_add_alt_1,
          ),
          SizedBox(width: 10),
          Text(
            'Assign Walker',
          ),
        ],
      ),

      content: SizedBox(
        width: 520,
        child: widget.walkers.isEmpty
            ? const Padding(
                padding:
                    EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .person_off_outlined,
                      size: 48,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'No walkers found.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxHeight: 500,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount:
                      widget.walkers.length,
                  separatorBuilder:
                      (
                    context,
                    index,
                  ) {
                    return const SizedBox(
                      height: 8,
                    );
                  },
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final doc =
                        widget.walkers[index];

                    final data =
                        doc.data();

                    final name =
                        _walkerName(
                      data,
                    );

                    final walkerId =
                        _value(
                      data,
                      'walkerId',
                    );

                    final uid =
                        _walkerUid(
                      data,
                    );

                    final selected =
                        selectedDocId ==
                            doc.id;

                    return Card(
                      margin:
                          EdgeInsets.zero,
                      elevation:
                          selected
                              ? 2
                              : 0,
                      color: selected
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .primaryContainer
                          : null,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),

                        leading:
                            CircleAvatar(
                          child:
                              const Icon(
                            Icons.person,
                          ),
                        ),

                        title: Text(
                          name,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        subtitle:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            if (walkerId
                                .isNotEmpty)
                              Text(
                                'Walker ID: '
                                '$walkerId',
                              ),

                            if (uid
                                .isNotEmpty)
                              Text(
                                'UID: $uid',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                          ],
                        ),

                        trailing:
                            Radio<String>(
                          value:
                              doc.id,
                          groupValue:
                              selectedDocId,
                          onChanged:
                              saving
                                  ? null
                                  : (
                                      value,
                                    ) {
                                      setState(
                                        () {
                                          selectedDocId =
                                              value;
                                        },
                                      );
                                    },
                        ),

                        selected:
                            selected,

                        onTap: saving
                            ? null
                            : () {
                                setState(
                                  () {
                                    selectedDocId =
                                        doc.id;
                                  },
                                );
                              },
                      ),
                    );
                  },
                ),
              ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop();
                },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton.icon(
          onPressed:
              saving ? null : _assign,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.check,
                ),
          label: Text(
            saving
                ? 'Assigning...'
                : 'Assign Walker',
          ),
        ),
      ],
    );
  }
}
