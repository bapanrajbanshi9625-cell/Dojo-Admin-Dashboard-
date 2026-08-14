import 'package:flutter/material.dart';

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
  State<ComplaintsScreen> createState() =>
      _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String selectedFilter = 'All';

  final List<ComplaintData> complaints = const [
    ComplaintData(
      id: 'CMP-001',
      user: 'Owner 01',
      subject: 'Walker arrived late',
      description:
          'The walker arrived later than the scheduled walk time.',
      date: '14 Aug 2026',
      status: 'Open',
      priority: 'High',
    ),
    ComplaintData(
      id: 'CMP-002',
      user: 'Owner 02',
      subject: 'Walk duration issue',
      description:
          'The completed walk duration was shorter than expected.',
      date: '14 Aug 2026',
      status: 'In Progress',
      priority: 'Medium',
    ),
    ComplaintData(
      id: 'CMP-003',
      user: 'Walker 01',
      subject: 'Payment clarification',
      description:
          'Walker requested clarification about a completed walk payment.',
      date: '13 Aug 2026',
      status: 'Resolved',
      priority: 'Low',
    ),
    ComplaintData(
      id: 'CMP-004',
      user: 'Owner 03',
      subject: 'Service complaint',
      description:
          'Owner reported an issue with the walking service.',
      date: '13 Aug 2026',
      status: 'Open',
      priority: 'High',
    ),
  ];

  List<ComplaintData> get filteredComplaints {
    if (selectedFilter == 'All') {
      return complaints;
    }

    return complaints
        .where((item) => item.status == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final open = complaints
        .where((c) => c.status == 'Open')
        .length;

    final progress = complaints
        .where((c) => c.status == 'In Progress')
        .length;

    final resolved = complaints
        .where((c) => c.status == 'Resolved')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(open, progress, resolved),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _complaintList(),
      ],
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
          'Review and manage DOJO user complaints',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(
    int open,
    int progress,
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
              title: 'Open',
              value: '$open',
              icon: Icons.error_outline,
              color: dojoRed,
            ),
            _SummaryCard(
              title: 'In Progress',
              value: '$progress',
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
        runSpacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('Open'),
          _filterButton('In Progress'),
          _filterButton('Resolved'),
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
          horizontal: 14,
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

  Widget _complaintList() {
    final list = filteredComplaints;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((complaint) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _complaintCard(complaint),
        );
      }).toList(),
    );
  }

  Widget _complaintCard(ComplaintData complaint) {
    final statusColor = _statusColor(complaint.status);
    final priorityColor = _priorityColor(complaint.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(
              complaint,
              statusColor,
              priorityColor,
            );
          }

          return _desktopCard(
            complaint,
            statusColor,
            priorityColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    ComplaintData complaint,
    Color statusColor,
    Color priorityColor,
  ) {
    return Row(
      children: [
        _complaintIcon(complaint.priority),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(complaint),
        ),
        Expanded(
          child: _info(
            Icons.person_outline,
            'User',
            complaint.user,
          ),
        ),
        _priorityChip(
          complaint.priority,
          priorityColor,
        ),
        const SizedBox(width: 10),
        _statusChip(
          complaint.status,
          statusColor,
        ),
        const SizedBox(width: 12),
        _viewButton(complaint),
      ],
    );
  }

  Widget _mobileCard(
    ComplaintData complaint,
    Color statusColor,
    Color priorityColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _complaintIcon(complaint.priority),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(complaint),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.person_outline,
                'User',
                complaint.user,
              ),
            ),
            _priorityChip(
              complaint.priority,
              priorityColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statusChip(
              complaint.status,
              statusColor,
            ),
            const Spacer(),
            Text(
              complaint.date,
              style: const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(complaint),
        ),
      ],
    );
  }

  Widget _complaintIcon(String priority) {
    final color = _priorityColor(priority);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.report_problem_outlined,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _mainInfo(ComplaintData complaint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          complaint.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          complaint.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          complaint.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _info(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: dojoBlue,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priorityChip(
    String priority,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _statusChip(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(ComplaintData complaint) {
    return OutlinedButton.icon(
      onPressed: () {
        _showDetails(complaint);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  void _showDetails(ComplaintData complaint) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Complaint Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Complaint ID',
                complaint.id,
              ),
              _detailRow(
                'User',
                complaint.user,
              ),
              _detailRow(
                'Subject',
                complaint.subject,
              ),
              _detailRow(
                'Priority',
                complaint.priority,
              ),
              _detailRow(
                'Status',
                complaint.status,
              ),
              _detailRow(
                'Date',
                complaint.date,
              ),
              const SizedBox(height: 8),
              const Text(
                'Description',
                style: TextStyle(
                  color: dojoGrey,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                complaint.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            if (complaint.status != 'Resolved')
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Complaint action will connect to Firebase.',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: dojoOrange,
                ),
                child: const Text('Update'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
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
              size: 50,
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
              'Complaints will appear here.',
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return dojoRed;
      case 'In Progress':
        return dojoOrange;
      case 'Resolved':
        return dojoGreen;
      default:
        return dojoGrey;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return dojoRed;
      case 'Medium':
        return dojoOrange;
      case 'Low':
        return dojoGreen;
      default:
        return dojoGrey;
    }
  }
}

class ComplaintData {
  final String id;
  final String user;
  final String subject;
  final String description;
  final String date;
  final String status;
  final String priority;

  const ComplaintData({
    required this.id,
    required this.user,
    required this.subject,
    required this.description,
    required this.date,
    required this.status,
    required this.priority,
  });
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
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }
}
