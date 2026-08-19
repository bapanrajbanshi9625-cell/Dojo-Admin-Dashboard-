import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../features/walkers/widgets/walkers_card.dart';
import '../features/walkers/widgets/walkers_helpers.dart';
import '../features/walkers/widgets/walkers_summary_cards.dart';
import '../features/walkers/widgets/walkers_toolbar.dart';
import '../features/walkers/widgets/walker_details_screen.dart';

class WalkersScreen extends StatefulWidget {
  const WalkersScreen({super.key});

  @override
  State<WalkersScreen> createState() => _WalkersScreenState();
}

class _WalkersScreenState extends State<WalkersScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>> get _walkers =>
      _firestore.collection('walkers');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkerStream =>
      _walkers.snapshots();

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _walkerStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState(
            snapshot.error.toString(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allDocs =
            snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        final filteredDocs = allDocs.where((doc) {
          return _matchesSearch(
                doc,
                searchController.text.trim(),
              ) &&
              _matchesFilter(
                doc,
                selectedFilter,
              );
        }).toList();

        final online = allDocs.where((doc) {
          return WalkersHelpers.isOnline(
            doc.data(),
          );
        }).length;

        final pending = allDocs.where((doc) {
          return WalkersHelpers.verificationStatus(
                doc.data(),
              ) ==
              'pending';
        }).length;

        final approved = allDocs.where((doc) {
          return WalkersHelpers.verificationStatus(
                doc.data(),
              ) ==
              'approved';
        }).length;

        final rejected = allDocs.where((doc) {
          return WalkersHelpers.verificationStatus(
                doc.data(),
              ) ==
              'rejected';
        }).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WalkersSummaryCards(
              total: allDocs.length,
              online: online,
              pending: pending,
              approved: approved,
              rejected: rejected,
            ),

            const SizedBox(height: 20),

            WalkersToolbar(
              searchController: searchController,
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
              onClearSearch: () {
                searchController.clear();
              },
            ),

            const SizedBox(height: 16),

            if (filteredDocs.isEmpty)
              _emptyState()
            else
              ...filteredDocs.map(
                (doc) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: WalkersCard(
                      doc: doc,
                      onView: () {
                        _openWalkerDetails(doc);
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool _matchesSearch(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String query,
  ) {
    if (query.isEmpty) {
      return true;
    }

    final data =
        doc.data() ??
        <String, dynamic>{};

    final values = <dynamic>[
      doc.id,

      data['Full Name'],
      data['fullName'],
      data['name'],
      data['walkerName'],

      data['Mobile number'],
      data['mobileNumber'],
      data['mobile'],
      data['phone'],
      data['phoneNumber'],

      data['Walker ID'],
      data['walkerId'],

      data['Walker Uid'],
      data['walkerUid'],
      data['authUid'],
      data['uid'],

      data['Aadhar Number'],
      data['Aadhaar Number'],
      data['aadhaarNumber'],
      data['aadharNumber'],

      data['Adress'],
      data['Address'],
      data['address'],

      data['Pincode'],
      data['pincode'],
      data['pinCode'],
      data['postalCode'],
    ];

    final searchText = values
        .where((value) => value != null)
        .map(
          (value) => value
              .toString()
              .toLowerCase(),
        )
        .join(' ');

    return searchText.contains(
      query.toLowerCase(),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  bool _matchesFilter(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String filter,
  ) {
    if (filter == 'All') {
      return true;
    }

    final data =
        doc.data() ??
        <String, dynamic>{};

    if (filter == 'Online') {
      return WalkersHelpers.isOnline(data);
    }

    final status =
        WalkersHelpers.verificationStatus(data);

    switch (filter) {
      case 'Pending':
        return status == 'pending';

      case 'Approved':
        return status == 'approved';

      case 'Rejected':
        return status == 'rejected';

      default:
        return true;
    }
  }

  // ============================================================
  // OPEN WALKER DETAILS
  // ============================================================

  Future<void> _openWalkerDetails(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data =
        doc.data() ??
        <String, dynamic>{};

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return WalkerDetailsScreen(
            doc: doc,
            data: data,

            // --------------------------------------------------
            // APPROVE
            // --------------------------------------------------
            onApprove: () {
              _showApproveDialog(doc);
            },

            // --------------------------------------------------
            // REJECT
            // --------------------------------------------------
            onReject: () {
              _showRejectDialog(doc);
            },

            // --------------------------------------------------
            // ACTIVATE
            // --------------------------------------------------
            onActivate: () {
              _showActivateDialog(doc);
            },

            // --------------------------------------------------
            // DEACTIVATE
            // --------------------------------------------------
            onDeactivate: () {
              _showDeactivateDialog(doc);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // APPROVE DIALOG
  // ============================================================

  Future<void> _showApproveDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Approve Walker',
          ),
          content: const Text(
            'Are you sure you want to approve this walker?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF16A34A),
              ),
              child: const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _updateWalkerStatus(
      doc,
      'approved',
    );
  }

  // ============================================================
  // REJECT DIALOG
  // ============================================================

  Future<void> _showRejectDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reject Walker',
          ),
          content: const Text(
            'Are you sure you want to reject this walker?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _updateWalkerStatus(
      doc,
      'rejected',
    );
  }

  // ============================================================
  // ACTIVATE DIALOG
  // ============================================================

  Future<void> _showActivateDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Activate Walker ID',
          ),
          content: const Text(
            'Are you sure you want to activate this walker ID?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
              ),
              child: const Text(
                'Activate',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _setWalkerActive(
      doc,
      true,
    );
  }

  // ============================================================
  // DEACTIVATE DIALOG
  // ============================================================

  Future<void> _showDeactivateDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Deactivate Walker ID',
          ),
          content: const Text(
            'Are you sure you want to deactivate this walker ID?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _setWalkerActive(
      doc,
      false,
    );
  }

  // ============================================================
  // SET WALKER ACTIVE / INACTIVE
  // ============================================================

  Future<void> _setWalkerActive(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool active,
  ) async {
    try {
      final updateData =
          <String, dynamic>{
        'isActive': active,
        'active': active,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (active) {
        updateData.addAll({
          'deactivatedAt':
              FieldValue.delete(),

          // Keep approval state untouched.
          'approved': true,
          'isApproved': true,
          'adminApproved': true,

          'rejected': false,
          'isRejected': false,
          'adminRejected': false,
        });
      } else {
        updateData.addAll({
          'deactivatedAt':
              FieldValue.serverTimestamp(),
        });
      }

      await doc.reference.set(
        updateData,
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            active
                ? 'Walker ID activated successfully.'
                : 'Walker ID deactivated successfully.',
          ),
          backgroundColor: active
              ? const Color(0xFF2563EB)
              : const Color(0xFFDC2626),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update Walker ID: $e',
          ),
          backgroundColor:
              const Color(0xFFDC2626),
        ),
      );
    }
  }

  // ============================================================
  // APPROVE / REJECT STATUS
  // ============================================================

  Future<void> _updateWalkerStatus(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String status,
  ) async {
    try {
      final updateData =
          <String, dynamic>{
        'status': status,
        'verificationStatus': status,
        'approvalStatus': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      // --------------------------------------------------------
      // APPROVED
      // --------------------------------------------------------

      if (status == 'approved') {
        updateData.addAll({
          'approved': true,
          'isApproved': true,
          'adminApproved': true,

          // Approved walker becomes active.
          'isActive': true,
          'active': true,

          'rejected': false,
          'isRejected': false,
          'adminRejected': false,

          'approvedAt':
              FieldValue.serverTimestamp(),

          'rejectedAt':
              FieldValue.delete(),

          'deactivatedAt':
              FieldValue.delete(),
        });
      }

      // --------------------------------------------------------
      // REJECTED
      // --------------------------------------------------------

      if (status == 'rejected') {
        updateData.addAll({
          'approved': false,
          'isApproved': false,
          'adminApproved': false,

          // Rejected walker becomes inactive.
          'isActive': false,
          'active': false,

          'rejected': true,
          'isRejected': true,
          'adminRejected': true,

          'rejectedAt':
              FieldValue.serverTimestamp(),
        });
      }

      await doc.reference.set(
        updateData,
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Walker approved successfully.'
                : 'Walker rejected successfully.',
          ),
          backgroundColor: status == 'approved'
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update walker: $e',
          ),
          backgroundColor:
              const Color(0xFFDC2626),
        ),
      );
    }
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load walkers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.directions_walk_outlined,
            size: 50,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'No walkers found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing the search or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
