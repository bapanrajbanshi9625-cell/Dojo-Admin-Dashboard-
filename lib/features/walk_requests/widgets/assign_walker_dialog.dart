import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignWalkerDialog extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const AssignWalkerDialog({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  State<AssignWalkerDialog> createState() =>
      _AssignWalkerDialogState();
}

class _AssignWalkerDialogState
    extends State<AssignWalkerDialog> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String? _selectedWalkerDocId;

  bool _loading = true;
  bool _saving = false;

  List<QueryDocumentSnapshot<
      Map<String, dynamic>>> _walkers = [];

  // ==========================================================
  // LOAD WALKERS
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadWalkers();
  }

  Future<void> _loadWalkers() async {
    try {
      final snapshot = await _firestore
          .collection('walkers')
          .get();

      if (!mounted) {
        return;
      }

      setState(() {
        _walkers = snapshot.docs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load walkers: $e',
          ),
        ),
      );
    }
  }

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

    return uid;
  }

  // ==========================================================
  // WALKER ID
  // ==========================================================

  String _walkerId(
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        doc,
    Map<String, dynamic> data,
  ) {
    final walkerId =
        _value(data, 'walkerId');

    if (walkerId.isNotEmpty) {
      return walkerId;
    }

    return doc.id;
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

    return _value(
      data,
      'walkerName',
    );
  }

  // ==========================================================
  // ASSIGN
  // ==========================================================

  Future<void> _assignWalker() async {
    final selectedId =
        _selectedWalkerDocId;

    if (selectedId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a walker.',
          ),
        ),
      );

      return;
    }

    QueryDocumentSnapshot<
            Map<String, dynamic>>?
        selectedWalker;

    for (final walker in _walkers) {
      if (walker.id == selectedId) {
        selectedWalker = walker;
        break;
      }
    }

    if (selectedWalker == null) {
      return;
    }

    final walkerData =
        selectedWalker.data();

    final walkerUid =
        _walkerUid(walkerData);

    final walkerId =
        _walkerId(
      selectedWalker,
      walkerData,
    );

    final walkerName =
        _walkerName(walkerData);

    if (walkerUid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selected walker has no valid UID.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore
          .collection('walk_requests')
          .doc(widget.requestId)
          .update({
        'status': 'accepted',

        'walkerUid': walkerUid,
        'walkerId': walkerId,
        'walkerName': walkerName,

        'acceptedBy': walkerUid,

        'acceptedAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
        _saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to assign walker: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Assign Walker',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),

      content: SizedBox(
        width: 500,
        child: _buildContent(),
      ),

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context)
                      .pop();
                },
          child:
              const Text('Cancel'),
        ),

        FilledButton(
          onPressed:
              _saving
                  ? null
                  : _assignWalker,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Assign Walker',
                ),
        ),
      ],
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_walkers.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.all(20),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .person_off_outlined,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'No walkers found.',
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints:
          const BoxConstraints(
        maxHeight: 420,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _walkers.length,
        itemBuilder: (
          context,
          index,
        ) {
          final doc =
              _walkers[index];

          final data =
              doc.data();

          final name =
              _walkerName(data);

          final walkerId =
              _walkerId(
            doc,
            data,
          );

          final selected =
              _selectedWalkerDocId ==
                  doc.id;

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 8,
            ),
            child: ListTile(
              leading:
                  CircleAvatar(
                child: const Icon(
                  Icons.person,
                ),
              ),

              title: Text(
                name.isEmpty
                    ? 'Walker'
                    : name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              subtitle: Text(
                walkerId,
              ),

              trailing:
                  Radio<String>(
                value: doc.id,
                groupValue:
                    _selectedWalkerDocId,
                onChanged:
                    _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedWalkerDocId =
                                  value;
                            });
                          },
              ),

              selected: selected,

              onTap: _saving
                  ? null
                  : () {
                      setState(() {
                        _selectedWalkerDocId =
                            doc.id;
                      });
                    },
            ),
          );
        },
      ),
    );
  }
}
