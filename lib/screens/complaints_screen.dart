import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'complaints/complaint_card.dart';
import 'complaints/complaint_data.dart';
import 'complaints/complaint_dialogs.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>> get _complaintsRef =>
      _firestore.collection('complaints');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _complaintsRef
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: dojoOrange,
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final complaints = snapshot.data?.docs
                .map(
                  (doc) => ComplaintData.fromFirestore(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList() ??
            [];

        final filtered = complaints.where((complaint) {
          if (selectedFilter == 'All') return true;
          return complaint.status == selectedFilter;
        }).toList();

        final pending = complaints
            .where((c) => c.status == 'Pending')
            .length;

        final resolved = complaints
            .where((c) => c.status == 'Resolved')
            .length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _summary(
                complaints.length,
                pending,
                resolved,
              ),
              const SizedBox(height: 20),
              _filters(),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                _emptyState()
              else
                ...filtered.map(
                  (complaint) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ComplaintCard(
                      complaint: complaint,
                      onView: () {
                        showComplaintDetails(
                          context,
                          complaint,
                        );
                      },
                      onUpdateStatus: (status) async {
                        await _updateStatus(
                          complaint,
                          status,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complaints',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage customer complaints and support requests',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(
    int total,
    int pending,
    int resolved,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 550
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.4,
          children: [
            _SummaryCard(
              title: 'Total Complaints',
              value: '$total',
              icon: Icons.report_problem_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Pending',
              value: '$pending',
              icon: Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Resolved',
              value: '$resolved',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
          ],
        );
      },
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
      ),
      child: Wrap(
        spacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('Pending'),
          _filterButton('Resolved'),
          _filterButton('Closed'),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : dojoBlack,
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    ComplaintData complaint,
    String status,
  ) async {
    try {
      await _complaintsRef.doc(complaint.id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complaint marked as $status.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update complaint: $e'),
        ),
      );
    }
  }

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: dojoRed,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load complaints',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 52,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No complaints found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Customer complaints will appear here.',
              style: TextStyle(
                fontSize: 12,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: dojoBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
