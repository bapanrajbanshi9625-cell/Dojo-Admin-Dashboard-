import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC62828);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color dojoBackground = Color(0xFFF7F8FA);

class WalkersScreen extends StatefulWidget {
  const WalkersScreen({super.key});

  @override
  State<WalkersScreen> createState() => _WalkersScreenState();
}

class _WalkersScreenState extends State<WalkersScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final CollectionReference<Map<String, dynamic>> _profiles =
      FirebaseFirestore.instance.collection('walkerProfiles');

  String selectedFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _bool(dynamic value) {
    return value == true;
  }

  String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  String _firstValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  String _status(Map<String, dynamic> data) {
    final approval = _firstValue(
      data,
      ['approvalStatus', 'status'],
    ).toLowerCase();

    if (approval == 'approved') {
      return 'Approved';
    }

    if (approval == 'rejected') {
      return 'Rejected';
    }

    return 'Pending';
  }

  String _displayName(
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'Full Name',
        'fullName',
        'name',
      ],
    );
  }

  String _mobile(
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'Mobile number',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );
  }

  String _walkerUid(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'Walker Uid',
        'walkerUid',
        'uid',
      ],
    ).isNotEmpty
        ? _firstValue(
            data,
            [
              'Walker Uid',
              'walkerUid',
              'uid',
            ],
          )
        : doc.id;
  }

  String _walkerId(
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'walkerId',
        'Walker Id',
        'Walker ID',
        'id',
      ],
    );
  }

  String _email(
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'email',
        'Email',
      ],
    );
  }

  String _selfie(
    Map<String, dynamic> data,
  ) {
    return _firstValue(
      data,
      [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'profileImageUrl',
      ],
    );
  }

  bool _isOnline(Map<String, dynamic> data) {
    return _bool(data['isOnline']);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _walkerStream() {
    return _profiles.snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final query = searchController.text.trim().toLowerCase();

    final result = docs.where((doc) {
      final data = doc.data();

      final name = _displayName(data).toLowerCase();
      final phone = _mobile(data).toLowerCase();
      final email = _email(data).toLowerCase();
      final uid = _walkerUid(doc, data).toLowerCase();
      final walkerId = _walkerId(data).toLowerCase();
      final status = _status(data);

      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          phone.contains(query) ||
          email.contains(query) ||
          uid.contains(query) ||
          walkerId.contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    result.sort((a, b) {
      final aCreated = a.data()['createdAt'];
      final bCreated = b.data()['createdAt'];

      if (aCreated is Timestamp && bCreated is Timestamp) {
        return bCreated.compareTo(aCreated);
      }

      return 0;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _walkerStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
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

        final docs = snapshot.data?.docs ?? [];

        final online = docs
            .where((doc) => _isOnline(doc.data()))
            .length;

        final approved = docs
            .where(
              (doc) =>
                  _status(doc.data()) == 'Approved',
            )
            .length;

        final pending = docs
            .where(
              (doc) =>
                  _status(doc.data()) == 'Pending',
            )
            .length;

        final rejected = docs
            .where(
              (doc) =>
                  _status(doc.data()) == 'Rejected',
            )
            .length;

        final filtered = _filterDocs(docs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _summaryCards(
              total: docs.length,
              online: online,
              pending: pending,
              approved: approved,
            ),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _emptyState()
            else
              ...filtered.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _walkerCard(doc),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Walkers',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage walker profiles, verification and approvals',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summaryCards({
    required int total,
    required int online,
    required int pending,
    required int approved,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 600
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
              columns == 1 ? 3.3 : 2.25,
          children: [
            _SummaryCard(
              title: 'Total Walkers',
              value: '$total',
              icon: Icons.badge_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Online',
              value: '$online',
              icon: Icons.wifi,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Pending Approval',
              value: '$pending',
              icon: Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Approved',
              value: '$approved',
              icon: Icons.verified_outlined,
              color: dojoGreen,
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                _searchBox(),
                const SizedBox(height: 12),
                _filters(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _searchBox(),
              ),
              const SizedBox(width: 12),
              _filters(),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText:
            'Search name, UID, Walker ID or phone...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon:
            searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                  )
                : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoOrange,
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('Pending'),
        _filterButton('Approved'),
        _filterButton('Rejected'),
      ],
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
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : const Color(0xFFF8F9FA),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? dojoOrange
                : dojoBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : dojoDark,
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _walkerCard(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data();

    final name = _displayName(data);
    final uid = _walkerUid(doc, data);
    final walkerId = _walkerId(data);
    final phone = _mobile(data);
    final email = _email(data);
    final status = _status(data);
    final online = _isOnline(data);

    final statusColor =
        status == 'Approved'
            ? dojoGreen
            : status == 'Rejected'
                ? dojoRed
                : dojoOrange;

    return Container(
      padding: const EdgeInsets.all(17),
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
          if (constraints.maxWidth < 700) {
            return _mobileCard(
              doc,
              data,
              name,
              uid,
              walkerId,
              phone,
              email,
              status,
              online,
              statusColor,
            );
          }

          return _desktopCard(
            doc,
            data,
            name,
            uid,
            walkerId,
            phone,
            email,
            status,
            online,
            statusColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
    Map<String, dynamic> data,
    String name,
    String uid,
    String walkerId,
    String phone,
    String email,
    String status,
    bool online,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(
          online: online,
          selfieUrl: _selfie(data),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(
            name: name,
            uid: uid,
            walkerId: walkerId,
            email: email,
          ),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            phone.isEmpty ? '—' : phone,
          ),
        ),
        Expanded(
          child: _info(
            Icons.verified_outlined,
            'Aadhaar',
            _bool(
              data['aadhaar_front_uploaded'],
            ) &&
                    _bool(
                      data['aadhaar_back_uploaded'],
                    )
                ? 'Uploaded'
                : 'Pending',
          ),
        ),
        _statusChip(
          status,
          statusColor,
        ),
        const SizedBox(width: 12),
        _viewButton(doc),
      ],
    );
  }

  Widget _mobileCard(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
    Map<String, dynamic> data,
    String name,
    String uid,
    String walkerId,
    String phone,
    String email,
    String status,
    bool online,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(
              online: online,
              selfieUrl: _selfie(data),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(
                name: name,
                uid: uid,
                walkerId: walkerId,
                email: email,
              ),
            ),
            _statusChip(
              status,
              statusColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.phone_outlined,
                'Phone',
                phone.isEmpty
                    ? '—'
                    : phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.verified_outlined,
                'Aadhaar',
                _bool(
                          data[
                              'aadhaar_front_uploaded'],
                        ) &&
                        _bool(
                          data[
                              'aadhaar_back_uploaded'],
                        )
                    ? 'Uploaded'
                    : 'Pending',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(doc),
        ),
      ],
    );
  }

  Widget _avatar({
    required bool online,
    required String selfieUrl,
  }) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF0F7),
            borderRadius:
                BorderRadius.circular(16),
          ),
          clipBehavior:
              Clip.antiAlias,
          child: selfieUrl.isNotEmpty
              ? Image.network(
                  selfieUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.badge_outlined,
                      color: dojoBlue,
                      size: 27,
                    );
                  },
                )
              : const Icon(
                  Icons.badge_outlined,
                  color: dojoBlue,
                  size: 27,
                ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: online
                  ? dojoGreen
                  : dojoGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainInfo({
    required String name,
    required String uid,
    required String walkerId,
    required String email,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          walkerId.isEmpty
              ? 'Walker'
              : walkerId,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          name.isEmpty
              ? 'Unnamed Walker'
              : name,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'UID: $uid',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            email,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),
        ],
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
                style:
                    const TextStyle(
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
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
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
        color:
            color.withOpacity(.09),
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
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkerDetails(doc);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style:
          OutlinedButton.styleFrom(
        foregroundColor:
            dojoOrange,
        side:
            const BorderSide(
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

  void _showWalkerDetails(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return _WalkerDetailsSheet(
          doc: doc,
          data: data,
          onApprove: () {
            Navigator.pop(sheetContext);
            _showApproveSheet(doc);
          },
          onReject: () {
            Navigator.pop(sheetContext);
            _showRejectSheet(doc);
          },
        );
      },
    );
  }

  void _showApproveSheet(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return _ApproveSheet(
          data: doc.data(),
          onConfirm: (
            aadhaarVerified,
            selfieVerified,
          ) async {
            Navigator.pop(sheetContext);

            await _approveWalker(
              doc.id,
              aadhaarVerified,
              selfieVerified,
            );
          },
        );
      },
    );
  }

  void _showRejectSheet(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return _RejectSheet(
          data: doc.data(),
          onConfirm: () async {
            Navigator.pop(sheetContext);

            await _rejectWalker(
              doc.id,
            );
          },
        );
      },
    );
  }

  Future<void> _approveWalker(
    String uid,
    bool aadhaarVerified,
    bool selfieVerified,
  ) async {
    try {
      await _profiles.doc(uid).set(
        {
          'aadhaarVerified':
              aadhaarVerified,
          'selfieVerified':
              selfieVerified,
          'approvalStatus':
              'approved',
          'approvedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Walker approved successfully.',
          ),
          backgroundColor:
              dojoGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Approval failed: $e',
          ),
          backgroundColor:
              dojoRed,
        ),
      );
    }
  }

  Future<void> _rejectWalker(
    String uid,
  ) async {
    try {
      await _profiles.doc(uid).set(
        {
          'approvalStatus':
              'rejected',
          'rejectedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Walker rejected.',
          ),
          backgroundColor:
              dojoRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Rejection failed: $e',
          ),
          backgroundColor:
              dojoRed,
        ),
      );
    }
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
              Icons.badge_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walkers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walker profiles will appear here.',
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: dojoRed,
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load walkers',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkerDetailsSheet
    extends StatelessWidget {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> doc;

  final Map<String, dynamic> data;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _WalkerDetailsSheet({
    required this.doc,
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  String value(
    List<String> keys,
  ) {
    for (final key in keys) {
      final v = data[key];

      if (v != null &&
          v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }

    return '—';
  }

  bool boolValue(String key) {
    return data[key] == true;
  }

  @override
  Widget build(BuildContext context) {
    final name = value([
      'Full Name',
      'fullName',
      'name',
    ]);

    final uid = value([
      'Walker Uid',
      'walkerUid',
      'uid',
    ]).replaceFirst(
      '—',
      doc.id,
    );

    final status = value([
      'approvalStatus',
      'status',
    ]);

    final selfie = value([
      'Profile Selfie',
      'profileSelfie',
      'profileImage',
      'profileImageUrl',
    ]);

    return Container(
      constraints:
          const BoxConstraints(
        maxHeight: 750,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: dojoBorder,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    clipBehavior:
                        Clip.antiAlias,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFEAF0F7,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    child:
                        selfie != '—'
                            ? Image.network(
                                selfie,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) {
                                  return const Icon(
                                    Icons.badge_outlined,
                                    color:
                                        dojoBlue,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.badge_outlined,
                                color:
                                    dojoBlue,
                              ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          status,
                          style:
                              const TextStyle(
                            color:
                                dojoGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle(
                'Identity',
              ),
              _detail(
                'Walker UID',
                uid,
              ),
              _detail(
                'Walker ID',
                value([
                  'walkerId',
                  'Walker Id',
                  'Walker ID',
                  'id',
                ]),
              ),
              _detail(
                'Full Name',
                name,
              ),
              _detail(
                'Mobile',
                value([
                  'Mobile number',
                  'mobile',
                  'phone',
                  'phoneNumber',
                ]),
              ),
              _detail(
                'Date Of Birth',
                value([
                  'Date Of Birth',
                  'dateOfBirth',
                  'dob',
                ]),
              ),
              _detail(
                'Aadhaar Number',
                value([
                  'Aadhar Number',
                  'Aadhaar Number',
                  'aadhaarNumber',
                ]),
              ),
              _detail(
                'Address',
                value([
                  'Adress',
                  'Address',
                  'address',
                ]),
              ),
              _detail(
                'Pincode',
                value([
                  'Pincode',
                  'pincode',
                ]),
              ),
              const SizedBox(height: 10),
              _sectionTitle(
                'Verification',
              ),
              _verificationRow(
                'Aadhaar Front Uploaded',
                boolValue(
                  'aadhaar_front_uploaded',
                ),
              ),
              _verificationRow(
                'Aadhaar Back Uploaded',
                boolValue(
                  'aadhaar_back_uploaded',
                ),
              ),
              _verificationRow(
                'Aadhaar Verified',
                boolValue(
                  'aadhaarVerified',
                ),
              ),
              _verificationRow(
                'Selfie Verified',
                boolValue(
                  'selfieVerified',
                ),
              ),
              const SizedBox(height: 20),
              if (status != 'approved' &&
                  status != 'Approved')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              dojoRed,
                          side:
                              const BorderSide(
                            color: dojoRed,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),
                        ),
                        child:
                            const Text(
                          'Reject',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            onApprove,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoOrange,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),
                        ),
                        child:
                            const Text(
                          'Approve',
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
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight:
              FontWeight.w900,
          color: dojoDark,
        ),
      ),
    );
  }

  Widget _detail(
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
            width: 125,
            child: Text(
              title,
              style:
                  const TextStyle(
                color: dojoGrey,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
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

  Widget _verificationRow(
    String title,
    bool verified,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            verified
                ? Icons.check_circle
                : Icons
                    .radio_button_unchecked,
            color: verified
                ? dojoGreen
                : dojoGrey,
            size: 19,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApproveSheet
    extends StatefulWidget {
  final Map<String, dynamic> data;

  final Future<void> Function(
    bool aadhaarVerified,
    bool selfieVerified,
  ) onConfirm;

  const _ApproveSheet({
    required this.data,
    required this.onConfirm,
  });

  @override
  State<_ApproveSheet> createState() =>
      _ApproveSheetState();
}

class _ApproveSheetState
    extends State<_ApproveSheet> {
  bool aadhaarVerified = false;
  bool selfieVerified = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    aadhaarVerified =
        widget.data[
                'aadhaarVerified'] ==
            true;

    selfieVerified =
        widget.data[
                'selfieVerified'] ==
            true;
  }

  Future<void> confirm() async {
    if (!aadhaarVerified ||
        !selfieVerified ||
        loading) {
      return;
    }

    setState(() {
      loading = true;
    });

    await widget.onConfirm(
      aadhaarVerified,
      selfieVerified,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        aadhaarVerified &&
            selfieVerified;

    return Container(
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        25,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration:
                    BoxDecoration(
                  color: dojoBorder,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Approve Walker',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Verify both documents before confirming approval.',
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            _checkRow(
              title: 'Aadhaar Verified',
              value: aadhaarVerified,
              onChanged: (value) {
                setState(() {
                  aadhaarVerified =
                      value;
                });
              },
            ),
            _checkRow(
              title: 'Selfie Verified',
              value: selfieVerified,
              onChanged: (value) {
                setState(() {
                  selfieVerified =
                      value;
                });
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    canConfirm
                        ? confirm
                        : null,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      dojoGreen,
                  disabledBackgroundColor:
                      const Color(
                    0xFFE0E0E0,
                  ),
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkRow({
    required String title,
    required bool value,
    required ValueChanged<bool>
        onChanged,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: value
            ? const Color(
                0xFFF0F8F3,
              )
            : const Color(
                0xFFF8F9FA,
              ),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? dojoGreen
              : dojoBorder,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (checked) {
          onChanged(
            checked ?? false,
          );
        },
        activeColor: dojoGreen,
        title: Text(
          title,
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        secondary: Icon(
          value
              ? Icons
                  .check_circle
              : Icons
                  .radio_button_unchecked,
          color: value
              ? dojoGreen
              : dojoGrey,
        ),
        controlAffinity:
            ListTileControlAffinity
                .trailing,
      ),
    );
  }
}

class _RejectSheet
    extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<void> Function()
      onConfirm;

  const _RejectSheet({
    required this.data,
    required this.onConfirm,
  });

  @override
  State<_RejectSheet> createState() =>
      _RejectSheetState();
}

class _RejectSheetState
    extends State<_RejectSheet> {
  bool loading = false;

  Future<void> confirm() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    await widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        25,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration:
                    BoxDecoration(
                  color: dojoBorder,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFFFEBEE,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: dojoRed,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Reject Walker?',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Are you sure you want to reject this walker profile?',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        loading
                            ? null
                            : () =>
                                Navigator.pop(
                                  context,
                                ),
                    style:
                        OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                    ),
                    child:
                        const Text(
                      'Cancel',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        loading
                            ? null
                            : confirm,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          dojoRed,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Reject',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
  Widget build(BuildContext context) {
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
              color: color
                  .withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
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
                  MainAxisAlignment
                      .center,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
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
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoDark,
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
