import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'walker_approve_sheet.dart';
import 'walker_card.dart';
import 'walker_details_sheet.dart';
import 'walker_reject_sheet.dart';
import 'walkers_helpers.dart';
import 'walkers_summary.dart';
import 'walkers_toolbar.dart';

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
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _walkerStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return WalkerHelpers.errorState(
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

        final allDocs = snapshot.data?.docs ??
            <QueryDocumentSnapshot<
                Map<String, dynamic>>>[];

        final filteredDocs = allDocs.where((doc) {
          final searchMatch =
              WalkerHelpers.matchesSearch(
            doc,
            searchController.text.trim(),
          );

          final filterMatch =
              WalkerHelpers.matchesFilter(
            doc,
            selectedFilter,
          );

          return searchMatch && filterMatch;
        }).toList();

        final online = allDocs
            .where(
              (doc) => WalkerHelpers.isOnline(
                doc.data(),
              ),
            )
            .length;

        final pending = allDocs
            .where(
              (doc) =>
                  WalkerHelpers.verificationStatus(
                    doc.data(),
                  ) ==
                  'pending',
            )
            .length;

        final approved = allDocs
            .where(
              (doc) =>
                  WalkerHelpers.verificationStatus(
                    doc.data(),
                  ) ==
                  'approved',
            )
            .length;

        final rejected = allDocs
            .where(
              (doc) =>
                  WalkerHelpers.verificationStatus(
                    doc.data(),
                  ) ==
                  'rejected',
            )
            .length;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 20),

            WalkersSummary(
              total: allDocs.length,
              online: online,
              pending: pending,
              approved: approved,
              rejected: rejected,
            ),

            const SizedBox(height: 20),

            WalkersToolbar(
              controller: searchController,
              selectedFilter: selectedFilter,
              onSearchChanged: (_) {
                setState(() {});
              },
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 16),

            if (filteredDocs.isEmpty)
              WalkerHelpers.emptyState()
            else
              ...filteredDocs.map(
                (doc) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
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

  Widget _header() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
            Navigator.pop(context);
            _showApproveSheet(doc);
          },
          onReject: () {
            Navigator.pop(context);
            _showRejectSheet(doc);
          },
        );
      },
    );
  }

  void _showApproveSheet(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return WalkerApproveSheet(
          doc: doc,
          onApproved: () {
            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }

  void _showRejectSheet(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return WalkerRejectSheet(
          doc: doc,
          onRejected: () {
            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}
