import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../features/walkers/widgets/walker_card.dart';
import '../features/walkers/widgets/walker_details_sheet.dart';
import '../features/walkers/widgets/walker_helpers.dart';
import '../features/walkers/widgets/walker_summary_cards.dart';
import '../features/walkers/widgets/walker_toolbar.dart';

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

  CollectionReference<Map<String, dynamic>>
      get _walkerProfiles =>
          _firestore.collection('walkerProfiles');

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _walkerStream =>
          _walkerProfiles.snapshots();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
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
          final searchMatch =
              _matchesSearch(
            doc,
            searchController.text.trim(),
          );

          final filterMatch =
              _matchesFilter(
            doc,
            selectedFilter,
          );

          return searchMatch && filterMatch;
        }).toList();

        final online = allDocs.where((doc) {
          return WalkerHelpers.isOnline(doc.data());
        }).length;

        final pending = allDocs.where((doc) {
          return WalkerHelpers.verificationStatus(
                doc.data(),
              ) ==
              'pending';
        }).length;

        final approved = allDocs.where((doc) {
          return WalkerHelpers.verificationStatus(
                doc.data(),
              ) ==
              'approved';
        }).length;

        final rejected = allDocs.where((doc) {
          return WalkerHelpers.verificationStatus(
                doc.data(),
              ) ==
              'rejected';
        }).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _WalkersHeader(),

            const SizedBox(height: 20),

            WalkerSummaryCards(
              total: allDocs.length,
              online: online,
              pending: pending,
              approved: approved,
              rejected: rejected,
            ),

            const SizedBox(height: 20),

            WalkerToolbar(
              searchController: searchController,
              selectedFilter: selectedFilter,
              onStatusChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 16),

            if (filteredDocs.isEmpty)
              _emptyState()
            else
              ...filteredDocs.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: WalkerCard(
                    doc: doc,
                    onView: () {
                      _showWalkerDetails(doc);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _matchesSearch(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String query,
  ) {
    if (query.isEmpty) {
      return true;
    }

    final data = doc.data() ?? {};

    final values = [
      doc.id,
      data['Full Name'],
      data['fullName'],
      data['name'],
      data['Mobile number'],
      data['mobile'],
      data['phone'],
      data['Walker Uid'],
      data['walkerUid'],
      data['uid'],
      data['Aadhar Number'],
      data['aadhaarNumber'],
      data['Adress'],
      data['Address'],
      data['address'],
      data['Pincode'],
      data['pincode'],
    ];

    final searchText = values
        .where((value) => value != null)
        .map((value) => value.toString().toLowerCase())
        .join(' ');

    return searchText.contains(query.toLowerCase());
  }

  bool _matchesFilter(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String filter,
  ) {
    if (filter == 'All') {
      return true;
    }

    final data = doc.data() ?? {};

    final status =
        WalkerHelpers.verificationStatus(data);

    if (filter.toLowerCase() ==
        status.toLowerCase()) {
      return true;
    }

    if (filter == 'Online') {
      return WalkerHelpers.isOnline(data);
    }

    return false;
  }

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
              textAlign: TextAlign.center,
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

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  void _showWalkerDetails(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WalkerDetailsSheet(
          doc: doc,
          data: data,
          onApprove: () {
            Navigator.of(context).pop();
            _showApproveDialog(doc);
          },
          onReject: () {
            Navigator.of(context).pop();
            _showRejectDialog(doc);
          },
        );
      },
    );
  }

  Future<void> _showApproveDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Walker'),
          content: const Text(
            'Are you sure you want to approve this walker?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Approve'),
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

  Future<void> _showRejectDialog(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Walker'),
          content: const Text(
            'Are you sure you want to reject this walker?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Reject'),
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

  Future<void> _updateWalkerStatus(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String status,
  ) async {
    try {
      await _walkerProfiles.doc(doc.id).update({
        'status': status,
        'verificationStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Walker ${status == 'approved' ? 'approved' : 'rejected'} successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update walker: $e',
          ),
        ),
      );
    }
  }
}

class _WalkersHeader extends StatelessWidget {
  const _WalkersHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Walkers',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: Color(0xFF263238),
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage walker profiles, verification and activity',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
