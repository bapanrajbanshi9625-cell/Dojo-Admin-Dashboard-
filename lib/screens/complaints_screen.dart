import 'package:cloud_firestore/cloud_firestore.dart';
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

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<ComplaintData>> get _complaintsStream {
    return _firestore
        .collection('complaints')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintData.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  List<ComplaintData> _filterComplaints(
    List<ComplaintData> complaints,
  ) {
    if (selectedFilter == 'All') {
      return complaints;
    }

    return complaints
        .where(
          (item) => item.status == selectedFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ComplaintData>>(
      stream: _complaintsStream,
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
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        final complaints = snapshot.data ?? [];

        final open = complaints
            .where(
              (c) => c.status == 'Open',
            )
            .length;

        final progress = complaints
            .where(
              (c) => c.status == 'In Progress',
            )
            .length;

        final resolved = complaints
            .where(
              (c) => c.status == 'Resolved',
            )
            .length;

        final filtered =
            _filterComplaints(complaints);

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _summary(
              open,
              progress,
              resolved,
            ),
            const SizedBox(height: 20),
            _filters(),
            const SizedBox(height: 16),
            _complaintList(filtered),
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
        final columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 550
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 2.4,
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
              icon:
                  Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Resolved',
              value: '$resolved',
              icon:
                  Icons.check_circle_outline,
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
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: dojoBorder,
        ),
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
    final selected =
        selectedFilter == title;

    return InkWell(
      borderRadius:
          BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10),
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

  Widget _complaintList(
    List<ComplaintData> list,
  ) {
    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((complaint) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 12,
          ),
          child:
              _complaintCard(complaint),
        );
      }).toList(),
    );
  }

  Widget _complaintCard(
    ComplaintData complaint,
  ) {
    final statusColor =
        _statusColor(complaint.status);

    final priorityColor =
        _priorityColor(complaint.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
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
        _complaintIcon(
          complaint.priority,
        ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _complaintIcon(
              complaint.priority,
            ),
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
    final color =
        _priorityColor(priority);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.report_problem_outlined,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _mainInfo(
    ComplaintData complaint,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
          overflow:
              TextOverflow.ellipsis,
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
          overflow:
              TextOverflow.ellipsis,
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
                overflow:
                    TextOverflow.ellipsis,
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius:
            BorderRadius.circular(8),
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
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
              fontWeight:
                  FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(
    ComplaintData complaint,
  ) {
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
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  void _showDetails(
    ComplaintData complaint,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Complaint Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
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
                if (complaint.walkId.isNotEmpty)
                  _detailRow(
                    'Walk ID',
                    complaint.walkId,
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
          ),
          actions: [
            if (complaint.status !=
                'Resolved')
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                  _showUpdateDialog(
                    complaint,
                  );
                },
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      dojoOrange,
                ),
                child:
                    const Text('Update'),
              ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(
    ComplaintData complaint,
  ) {
    String selectedStatus =
        complaint.status;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Update Complaint',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              content:
                  DropdownButtonFormField<
                      String>(
                initialValue:
                    selectedStatus,
                decoration:
                    const InputDecoration(
                  labelText: 'Status',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Open',
                    child:
                        Text('Open'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text(
                      'In Progress',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Resolved',
                    child:
                        Text('Resolved'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedStatus =
                          value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await _firestore
                          .collection(
                            'complaints',
                          )
                          .doc(
                            complaint
                                .documentId,
                          )
                          .update({
                        'status':
                            selectedStatus,
                        'updatedAt':
                            FieldValue
                                .serverTimestamp(),
                      });

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      ScaffoldMessenger
                              .of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Complaint updated successfully.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger
                              .of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update complaint: $e',
                          ),
                        ),
                      );
                    }
                  },
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        dojoOrange,
                  ),
                  child:
                      const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
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
                fontWeight:
                    FontWeight.w700,
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
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .report_problem_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No complaints found',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
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

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
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
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
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

  Color _priorityColor(
    String priority,
  ) {
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
  final String documentId;
  final String id;
  final String user;
  final String subject;
  final String description;
  final String date;
  final String status;
  final String priority;
  final String walkId;

  const ComplaintData({
    required this.documentId,
    required this.id,
    required this.user,
    required this.subject,
    required this.description,
    required this.date,
    required this.status,
    required this.priority,
    required this.walkId,
  });

  factory ComplaintData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    String date = '';

    final dateValue = data['date'];

    if (dateValue is Timestamp) {
      final d = dateValue.toDate();

      date =
          '${d.day.toString().padLeft(2, '0')} '
          '${_monthName(d.month)} '
          '${d.year}';
    } else if (dateValue is String) {
      date = dateValue;
    } else {
      final createdAt =
          data['createdAt'];

      if (createdAt is Timestamp) {
        final d = createdAt.toDate();

        date =
            '${d.day.toString().padLeft(2, '0')} '
            '${_monthName(d.month)} '
            '${d.year}';
      }
    }

    return ComplaintData(
      documentId: documentId,
      id:
          data['id']?.toString() ??
              documentId,
      user:
          data['user']?.toString() ??
              data['userName']?.toString() ??
              'Unknown User',
      subject:
          data['subject']?.toString() ??
              'No subject',
      description:
          data['description']?.toString() ??
              '',
      date: date.isEmpty
          ? 'Unknown date'
          : date,
      status:
          data['status']?.toString() ??
              'Open',
      priority:
          data['priority']?.toString() ??
              'Medium',
      walkId:
          data['walkId']?.toString() ??
              '',
    );
  }

  static String _monthName(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class _SummaryCard
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
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
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w900,
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
