import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

const Color pendingColor = Color(0xFFD99000);
const Color rejectedColor = Color(0xFFC62828);

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _walkerProfiles =>
      _firestore.collection('walkerProfiles');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkerStream {
    return _walkerProfiles.snapshots();
  }

  String _string(
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

  bool _bool(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }

      if (value is String) {
        return value.toLowerCase() == 'true';
      }
    }

    return false;
  }

  int _int(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) {
        return value.toInt();
      }

      final parsed =
          int.tryParse(value?.toString() ?? '');

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  double _double(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) {
        return value.toDouble();
      }

      final parsed =
          double.tryParse(value?.toString() ?? '');

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  String _walkerId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return _string(
      data,
      [
        'walkerId',
        'Walker ID',
        'walker_id',
        'id',
      ],
    );
  }

  String _uid(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final uid = _string(
      data,
      [
        'Walker Uid',
        'walkerUid',
        'walkerUID',
        'uid',
        'authUid',
        'authUID',
      ],
    );

    if (uid.isNotEmpty) {
      return uid;
    }

    return doc.id;
  }

  String _name(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
    );
  }

  String _phone(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Mobile number',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );
  }

  String _email(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'email',
        'Email',
      ],
    );
  }

  String _profileImage(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'profileImageUrl',
        'selfieUrl',
      ],
    );
  }

  String _aadhaarNumber(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Aadhar Number',
        'Aadhaar Number',
        'aadhaarNumber',
        'aadharNumber',
      ],
    );
  }

  String _aadhaarFront(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'aadhaar_front_url',
        'aadhaarFrontUrl',
        'aadhaar_front',
        'aadhaarFront',
        'Aadhar Front',
        'Aadhaar Front',
        'aadhaarFrontImage',
      ],
    );
  }

  String _aadhaarBack(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'aadhaar_back_url',
        'aadhaarBackUrl',
        'aadhaar_back',
        'aadhaarBack',
        'Aadhar Back',
        'Aadhaar Back',
        'aadhaarBackImage',
      ],
    );
  }

  bool _aadhaarFrontUploaded(
    Map<String, dynamic> data,
  ) {
    return _bool(
      data,
      [
        'aadhaar_front_uploaded',
        'aadhaarFrontUploaded',
      ],
    );
  }

  bool _aadhaarBackUploaded(
    Map<String, dynamic> data,
  ) {
    return _bool(
      data,
      [
        'aadhaar_back_uploaded',
        'aadhaarBackUploaded',
      ],
    );
  }

  bool _profileCompleted(
    Map<String, dynamic> data,
  ) {
    return _bool(
      data,
      [
        'profileCompleted',
        'profile_completed',
      ],
    );
  }

  String _verificationStatus(
    Map<String, dynamic> data,
  ) {
    final status = _string(
      data,
      [
        'verificationStatus',
        'verification_status',
        'approvalStatus',
        'approval_status',
      ],
    ).toLowerCase();

    if (status == 'approved' ||
        status == 'rejected' ||
        status == 'pending') {
      return status;
    }

    if (_bool(
      data,
      [
        'approved',
        'isApproved',
      ],
    )) {
      return 'approved';
    }

    if (_bool(
      data,
      [
        'rejected',
        'isRejected',
      ],
    )) {
      return 'rejected';
    }

    return 'pending';
  }

  bool _isOnline(
    Map<String, dynamic> data,
  ) {
    return _bool(
      data,
      [
        'isOnline',
        'online',
      ],
    );
  }

  int _totalWalks(
    Map<String, dynamic> data,
  ) {
    return _int(
      data,
      [
        'totalWalks',
        'completedWalks',
        'walks',
      ],
    );
  }

  int _activeWalks(
    Map<String, dynamic> data,
  ) {
    return _int(
      data,
      [
        'activeWalks',
        'currentActiveWalks',
      ],
    );
  }

  double _rating(
    Map<String, dynamic> data,
  ) {
    return _double(
      data,
      [
        'rating',
        'averageRating',
      ],
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

    final values = <String>[
      _walkerId(doc),
      _uid(doc),
      _name(data),
      _phone(data),
      _email(data),
      _aadhaarNumber(data),
    ];

    final lowerQuery = query.toLowerCase();

    return values.any(
      (value) => value.toLowerCase().contains(
            lowerQuery,
          ),
    );
  }

  bool _matchesFilter(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (selectedFilter == 'All') {
      return true;
    }

    final status =
        _verificationStatus(doc.data() ?? {});

    if (selectedFilter == 'Pending') {
      return status == 'pending';
    }

    if (selectedFilter == 'Approved') {
      return status == 'approved';
    }

    if (selectedFilter == 'Rejected') {
      return status == 'rejected';
    }

    if (selectedFilter == 'Online') {
      return _isOnline(doc.data() ?? {});
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _walkerStream,
      builder: (
        context,
        snapshot,
      ) {
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
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        final allDocs =
            snapshot.data?.docs ??
                <QueryDocumentSnapshot<
                    Map<String, dynamic>>>[];

        final docs = allDocs.where((doc) {
          return _matchesSearch(
                doc,
                searchController.text
                    .trim(),
              ) &&
              _matchesFilter(doc);
        }).toList();

        final online = allDocs.where(
          (doc) => _isOnline(
            doc.data(),
          ),
        ).length;

        final pending = allDocs.where(
          (doc) =>
              _verificationStatus(
                doc.data(),
              ) ==
              'pending',
        ).length;

        final approved = allDocs.where(
          (doc) =>
              _verificationStatus(
                doc.data(),
              ) ==
              'approved',
        ).length;

        final rejected = allDocs.where(
          (doc) =>
              _verificationStatus(
                doc.data(),
              ) ==
              'rejected',
        ).length;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _summaryCards(
              total: allDocs.length,
              online: online,
              pending: pending,
              approved: approved,
              rejected: rejected,
            ),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              _emptyState()
            else
              ...docs.map(
                (doc) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
          'Manage walker profiles, verification and activity',
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
    required int rejected,
  }) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns =
            constraints.maxWidth >= 1100
                ? 5
                : constraints.maxWidth >= 700
                    ? 3
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              columns == 1 ? 4.0 : 1.75,
          children: [
            _SummaryCard(
              title: 'Total',
              value: '$total',
              icon: Icons.people_outline,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Online',
              value: '$online',
              icon: Icons.wifi,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Pending',
              value: '$pending',
              icon: Icons.pending_actions_outlined,
              color: pendingColor,
            ),
            _SummaryCard(
              title: 'Approved',
              value: '$approved',
              icon: Icons.verified_outlined,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Rejected',
              value: '$rejected',
              icon: Icons.block_outlined,
              color: rejectedColor,
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
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
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
            'Search Walker ID, UID, name, phone, email or Aadhaar...',
        hintStyle:
            const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon:
            const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon:
            searchController.text
                    .isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController
                          .clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                  )
                : null,
        filled: true,
        fillColor:
            const Color(0xFFF8F9FA),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              const BorderSide(
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
        _filterButton('Online'),
      ],
    );
  }

  Widget _filterButton(
    String title,
  ) {
    final selected =
        selectedFilter == title;

    Color color = dojoOrange;

    if (title == 'Pending') {
      color = pendingColor;
    } else if (title == 'Approved' ||
        title == 'Online') {
      color = dojoGreen;
    } else if (title == 'Rejected') {
      color = rejectedColor;
    }

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
              ? color
              : const Color(0xFFF8F9FA),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color
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
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data() ?? {};

    final status =
        _verificationStatus(data);

    final statusColor =
        _statusColor(status);

    final online =
        _isOnline(data);

    return InkWell(
      borderRadius:
          BorderRadius.circular(17),
      onTap: () {
        _showWalkerDetails(doc);
      },
      child: Container(
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: status == 'pending'
                ? pendingColor
                    .withOpacity(.35)
                : dojoBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(.025),
              blurRadius: 12,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            if (constraints.maxWidth <
                700) {
              return _mobileCard(
                doc,
                statusColor,
                online,
              );
            }

            return _desktopCard(
              doc,
              statusColor,
              online,
            );
          },
        ),
      ),
    );
  }

  Widget _desktopCard(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
    Color statusColor,
    bool online,
  ) {
    final data = doc.data() ?? {};

    final name = _name(data);
    final walkerId =
        _walkerId(doc);
    final uid = _uid(doc);
    final phone = _phone(data);
    final email = _email(data);
    final walks =
        _totalWalks(data);
    final rating =
        _rating(data);

    return Row(
      children: [
        _avatar(
          _profileImage(data),
          online,
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(
            name: name,
            walkerId: walkerId,
            uid: uid,
            email: email,
          ),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            phone.isEmpty
                ? 'Not set'
                : phone,
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '$walks',
          ),
        ),
        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            rating == 0
                ? '-'
                : rating
                    .toStringAsFixed(
                    1,
                  ),
          ),
        ),
        _statusChip(
          _verificationLabel(
            _verificationStatus(
              data,
            ),
          ),
          statusColor,
        ),
        const SizedBox(width: 10),
        _viewButton(doc),
      ],
    );
  }

  Widget _mobileCard(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
    Color statusColor,
    bool online,
  ) {
    final data = doc.data() ?? {};

    final name = _name(data);
    final walkerId =
        _walkerId(doc);
    final uid = _uid(doc);
    final phone = _phone(data);
    final walks =
        _totalWalks(data);
    final rating =
        _rating(data);
    final status =
        _verificationStatus(data);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(
              _profileImage(data),
              online,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(
                name: name,
                walkerId: walkerId,
                uid: uid,
                email: _email(data),
              ),
            ),
            _statusChip(
              _verificationLabel(status),
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
                    ? 'Not set'
                    : phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '$walks',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.star_outline,
                'Rating',
                rating == 0
                    ? '-'
                    : rating
                        .toStringAsFixed(
                        1,
                      ),
              ),
            ),
            Expanded(
              child: _info(
                Icons.circle_outlined,
                'Presence',
                online
                    ? 'Online'
                    : 'Offline',
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

  Widget _avatar(
    String imageUrl,
    bool online,
  ) {
    return Stack(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF0F7),
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
          clipBehavior:
              Clip.antiAlias,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.person_outline,
                      color: dojoBlue,
                      size: 27,
                    );
                  },
                )
              : const Icon(
                  Icons.person_outline,
                  color: dojoBlue,
                  size: 27,
                ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration:
                BoxDecoration(
              color: online
                  ? dojoGreen
                  : dojoGrey,
              shape:
                  BoxShape.circle,
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
    required String walkerId,
    required String uid,
    required String email,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          walkerId.isEmpty
              ? 'Walker ID not set'
              : walkerId,
          style:
              const TextStyle(
            fontSize: 11,
            color: dojoOrange,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name.isEmpty
              ? 'Unnamed Walker'
              : name,
          style:
              const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'UID: ${uid.isEmpty ? 'Not set' : uid}',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
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
            style:
                const TextStyle(
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
            style:
                TextStyle(
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
    DocumentSnapshot<
            Map<String, dynamic>>
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
              BorderRadius.circular(
            10,
          ),
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
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data() ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return _WalkerDetailsSheet(
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

  Future<void> _showApproveSheet(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) async {
    final data = doc.data() ?? {};

    bool aadhaarVerified =
        _bool(
      data,
      [
        'aadhaarVerified',
        'aadharVerified',
        'aadhaar_verified',
      ],
    );

    bool selfieVerified =
        _bool(
      data,
      [
        'selfieVerified',
        'selfie_verified',
      ],
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Container(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                25,
              ),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top:
                      Radius.circular(24),
                ),
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
                        width: 42,
                        height: 4,
                        decoration:
                            BoxDecoration(
                          color:
                              dojoBorder,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color:
                              dojoGreen,
                          size: 27,
                        ),
                        SizedBox(
                          width: 9,
                        ),
                        Text(
                          'Approve Walker',
                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                dojoDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      _name(data).isEmpty
                          ? 'Walker verification'
                          : _name(data),
                      style:
                          const TextStyle(
                        color:
                            dojoGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    CheckboxListTile(
                      value:
                          aadhaarVerified,
                      activeColor:
                          dojoGreen,
                      contentPadding:
                          EdgeInsets.zero,
                      title:
                          const Text(
                        'Aadhaar Verified',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      subtitle:
                          const Text(
                        'Confirm Aadhaar documents have been checked.',
                      ),
                      onChanged:
                          (value) {
                        setModalState(
                          () {
                            aadhaarVerified =
                                value ??
                                    false;
                          },
                        );
                      },
                    ),
                    CheckboxListTile(
                      value:
                          selfieVerified,
                      activeColor:
                          dojoGreen,
                      contentPadding:
                          EdgeInsets.zero,
                      title:
                          const Text(
                        'Selfie Verified',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      subtitle:
                          const Text(
                        'Confirm profile selfie has been checked.',
                      ),
                      onChanged:
                          (value) {
                        setModalState(
                          () {
                            selfieVerified =
                                value ??
                                    false;
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      height: 50,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            aadhaarVerified &&
                                    selfieVerified
                                ? () async {
                                    Navigator.pop(
                                      context,
                                    );

                                    await _approveWalker(
                                      doc,
                                      aadhaarVerified,
                                      selfieVerified,
                                    );
                                  }
                                : null,
                        icon:
                            const Icon(
                          Icons.check_circle_outline,
                        ),
                        label:
                            const Text(
                          'Confirm',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              dojoGreen,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              dojoBorder,
                          disabledForegroundColor:
                              dojoGrey,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveWalker(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
    bool aadhaarVerified,
    bool selfieVerified,
  ) async {
    try {
      final adminUid =
          FirebaseAuth
              .instance
              .currentUser
              ?.uid;

      await doc.reference.set(
        {
          'verificationStatus':
              'approved',
          'approvalStatus':
              'approved',
          'approved':
              true,
          'isApproved':
              true,
          'aadhaarVerified':
              aadhaarVerified,
          'aadharVerified':
              aadhaarVerified,
          'aadhaar_verified':
              aadhaarVerified,
          'selfieVerified':
              selfieVerified,
          'selfie_verified':
              selfieVerified,
          'profileCompleted':
              true,
          'isActive':
              true,
          'approvedBy':
              adminUid ?? '',
          'approvedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Approval failed: $e',
          ),
          backgroundColor:
              rejectedColor,
        ),
      );
    }
  }

  Future<void> _showRejectSheet(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) async {
    final data = doc.data() ?? {};

    await showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            25,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(24),
            ),
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
                    width: 42,
                    height: 4,
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
                const SizedBox(
                  height: 18,
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color:
                          rejectedColor,
                      size: 28,
                    ),
                    SizedBox(
                      width: 9,
                    ),
                    Text(
                      'Reject Walker?',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Are you sure you want to reject ${_name(data).isEmpty ? 'this walker' : _name(data)}?',
                  style:
                      const TextStyle(
                    color: dojoGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child:
                            const Text(
                          'Cancel',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          ElevatedButton(
                        onPressed:
                            () async {
                          Navigator.pop(
                            context,
                          );

                          await _rejectWalker(
                            doc,
                          );
                        },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              rejectedColor,
                          foregroundColor:
                              Colors.white,
                        ),
                        child:
                            const Text(
                          'Reject',
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rejectWalker(
    DocumentSnapshot<
            Map<String, dynamic>>
        doc,
  ) async {
    try {
      final adminUid =
          FirebaseAuth
              .instance
              .currentUser
              ?.uid;

      await doc.reference.set(
        {
          'verificationStatus':
              'rejected',
          'approvalStatus':
              'rejected',
          'approved':
              false,
          'isApproved':
              false,
          'isActive':
              false,
          'rejected':
              true,
          'isRejected':
              true,
          'rejectedBy':
              adminUid ?? '',
          'rejectedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

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
      if (!mounted) return;

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
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'approved':
        return dojoGreen;
      case 'rejected':
        return rejectedColor;
      default:
        return pendingColor;
    }
  }

  String _verificationLabel(
    String status,
  ) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration:
          BoxDecoration(
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
              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walkers will appear here.',
              style:
                  TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(
    String error,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(25),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: rejectedColor
              .withOpacity(.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: rejectedColor,
            size: 42,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Unable to load walkers',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            error,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
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
  final DocumentSnapshot<
          Map<String, dynamic>>
      doc;

  final Map<String, dynamic> data;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _WalkerDetailsSheet({
    required this.doc,
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  String _string(
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

  bool _bool(
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }
    }

    return false;
  }

  String get walkerId {
    return _string([
      'walkerId',
      'Walker ID',
      'walker_id',
      'id',
    ]);
  }

  String get uid {
    final value = _string([
      'Walker Uid',
      'walkerUid',
      'walkerUID',
      'uid',
      'authUid',
      'authUID',
    ]);

    return value.isEmpty
        ? doc.id
        : value;
  }

  String get name {
    return _string([
      'Full Name',
      'fullName',
      'name',
      'walkerName',
    ]);
  }

  String get phone {
    return _string([
      'Mobile number',
      'mobile',
      'phone',
      'phoneNumber',
    ]);
  }

  String get email {
    return _string([
      'email',
      'Email',
    ]);
  }

  String get dob {
    return _string([
      'Date Of Birth',
      'dateOfBirth',
      'dob',
    ]);
  }

  String get address {
    return _string([
      'Adress',
      'Address',
      'address',
    ]);
  }

  String get pincode {
    return _string([
      'Pincode',
      'pincode',
      'pinCode',
    ]);
  }

  String get aadhaarNumber {
    return _string([
      'Aadhar Number',
      'Aadhaar Number',
      'aadhaarNumber',
      'aadharNumber',
    ]);
  }

  String get profileSelfie {
    return _string([
      'Profile Selfie',
      'profileSelfie',
      'profileImage',
      'profileImageUrl',
      'selfieUrl',
    ]);
  }

  String get aadhaarFront {
    return _string([
      'aadhaar_front_url',
      'aadhaarFrontUrl',
      'aadhaar_front',
      'aadhaarFront',
      'Aadhar Front',
      'Aadhaar Front',
      'aadhaarFrontImage',
    ]);
  }

  String get aadhaarBack {
    return _string([
      'aadhaar_back_url',
      'aadhaarBackUrl',
      'aadhaar_back',
      'aadhaarBack',
      'Aadhar Back',
      'Aadhaar Back',
      'aadhaarBackImage',
    ]);
  }

  bool get aadhaarFrontUploaded {
    return _bool([
      'aadhaar_front_uploaded',
      'aadhaarFrontUploaded',
    ]);
  }

  bool get aadhaarBackUploaded {
    return _bool([
      'aadhaar_back_uploaded',
      'aadhaarBackUploaded',
    ]);
  }

  bool get profileCompleted {
    return _bool([
      'profileCompleted',
      'profile_completed',
    ]);
  }

  String get verificationStatus {
    final status = _string([
      'verificationStatus',
      'verification_status',
      'approvalStatus',
      'approval_status',
    ]).toLowerCase();

    if (status.isNotEmpty) {
      return status;
    }

    return 'pending';
  }

  Color get statusColor {
    if (verificationStatus ==
        'approved') {
      return dojoGreen;
    }

    if (verificationStatus ==
        'rejected') {
      return rejectedColor;
    }

    return pendingColor;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        maxHeight: 720,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              decoration:
                  BoxDecoration(
                color: dojoBorder,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                _profileAvatar(),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty
                            ? 'Walker'
                            : name,
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w900,
                          color: dojoDark,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        walkerId.isEmpty
                            ? 'Walker ID not set'
                            : walkerId,
                        style:
                            const TextStyle(
                          color: dojoOrange,
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(
                  _statusLabel(),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child:
                  SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      'Identity',
                    ),
                    _detailCard([
                      _row(
                        'Walker ID',
                        walkerId,
                      ),
                      _row(
                        'Auth UID',
                        uid,
                      ),
                      _row(
                        'Full Name',
                        name,
                      ),
                      _row(
                        'Mobile',
                        phone,
                      ),
                      _row(
                        'Email',
                        email,
                      ),
                      _row(
                        'Date Of Birth',
                        dob,
                      ),
                      _row(
                        'Address',
                        address,
                      ),
                      _row(
                        'Pincode',
                        pincode,
                      ),
                      _row(
                        'Aadhaar',
                        aadhaarNumber,
                      ),
                    ]),
                    const SizedBox(
                      height: 14,
                    ),
                    _sectionTitle(
                      'Verification',
                    ),
                    _verificationCard(),
                    const SizedBox(
                      height: 14,
                    ),
                    _sectionTitle(
                      'Documents',
                    ),
                    _documents(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            if (verificationStatus !=
                'approved')
              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          onReject,
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                      label:
                          const Text(
                        'Reject',
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            rejectedColor,
                        side:
                            const BorderSide(
                          color:
                              rejectedColor,
                        ),
                        minimumSize:
                            const Size(
                          0,
                          48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          onApprove,
                      icon:
                          const Icon(
                        Icons.check_circle_outline,
                      ),
                      label:
                          const Text(
                        'Approve',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            dojoGreen,
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size(
                          0,
                          48,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width:
                    double.infinity,
                height: 48,
                child:
                    OutlinedButton.icon(
                  onPressed: null,
                  icon:
                      const Icon(
                    Icons.verified,
                  ),
                  label:
                      const Text(
                    'Walker Approved',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    if (verificationStatus ==
        'approved') {
      return 'Approved';
    }

    if (verificationStatus ==
        'rejected') {
      return 'Rejected';
    }

    return 'Pending';
  }

  Widget _profileAvatar() {
    return Container(
      width: 58,
      height: 58,
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEAF0F7),
        borderRadius:
            BorderRadius.circular(16),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: profileSelfie.isNotEmpty
          ? Image.network(
              profileSelfie,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.person_outline,
                  color: dojoBlue,
                  size: 29,
                );
              },
            )
          : const Icon(
              Icons.person_outline,
              color: dojoBlue,
              size: 29,
            ),
    );
  }

  Widget _statusChip(
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            statusColor.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style:
            TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight:
              FontWeight.w900,
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
        style:
            const TextStyle(
          fontSize: 14,
          fontWeight:
              FontWeight.w900,
          color: dojoDark,
        ),
      ),
    );
  }

  Widget _detailCard(
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF8F9FA),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _row(
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
            width: 105,
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty
                  ? 'Not set'
                  : value,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
                color: dojoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationCard() {
    final aadhaarVerified =
        _bool([
      'aadhaarVerified',
      'aadharVerified',
      'aadhaar_verified',
    ]);

    final selfieVerified =
        _bool([
      'selfieVerified',
      'selfie_verified',
    ]);

    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          _verificationRow(
            'Profile Completed',
            profileCompleted,
          ),
          _verificationRow(
            'Aadhaar Front Uploaded',
            aadhaarFrontUploaded,
          ),
          _verificationRow(
            'Aadhaar Back Uploaded',
            aadhaarBackUploaded,
          ),
          _verificationRow(
            'Aadhaar Verified',
            aadhaarVerified,
          ),
          _verificationRow(
            'Selfie Verified',
            selfieVerified,
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(
    String title,
    bool value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle
                : Icons.cancel_outlined,
            color: value
                ? dojoGreen
                : dojoGrey,
            size: 19,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value ? 'Yes' : 'No',
            style:
                TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color: value
                  ? dojoGreen
                  : dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documents() {
    return Column(
      children: [
        _documentCard(
          title: 'Profile Selfie',
          icon: Icons.person_outline,
          url: profileSelfie,
        ),
        const SizedBox(
          height: 10,
        ),
        _documentCard(
          title: 'Aadhaar Front',
          icon: Icons.credit_card_outlined,
          url: aadhaarFront,
        ),
        const SizedBox(
          height: 10,
        ),
        _documentCard(
          title: 'Aadhaar Back',
          icon: Icons.credit_card_outlined,
          url: aadhaarBack,
        ),
      ],
    );
  }

  Widget _documentCard({
    required String title,
    required IconData icon,
    required String url,
  }) {
    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: dojoBlue,
                  size: 19,
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (url.isEmpty)
              Container(
                height: 90,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF8F9FA,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child:
                    const Text(
                  'Document URL not available',
                  style:
                      TextStyle(
                    color:
                        dojoGrey,
                    fontSize: 11,
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                child:
                    Image.network(
                  url,
                  width:
                      double.infinity,
                  height: 180,
                  fit: BoxFit.contain,
                  loadingBuilder:
                      (
                    context,
                    child,
                    progress,
                  ) {
                    if (progress ==
                        null) {
                      return child;
                    }

                    return const SizedBox(
                      height: 180,
                      child:
                          Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              dojoOrange,
                        ),
                      ),
                    );
                  },
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      height: 90,
                      alignment:
                          Alignment.center,
                      child:
                          const Text(
                        'Unable to load document',
                        style:
                            TextStyle(
                          color:
                              dojoGrey,
                          fontSize:
                              11,
                        ),
                      ),
                    );
                  },
                ),
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
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
            width: 45,
            height: 45,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
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
                  height: 3,
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 22,
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
