import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _watchWalkers() {
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
        return value.toString();
      }
    }

    return '';
  }

  bool _bool(
    Map<String, dynamic> data,
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }
    }

    return fallback;
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

  String _walkerName(
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

  String _walkerMobile(
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

  String _walkerAddress(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Adress',
        'Address',
        'address',
      ],
    );
  }

  String _walkerPincode(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Pincode',
        'pincode',
        'pinCode',
      ],
    );
  }

  String _walkerDob(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Date Of Birth',
        'dateOfBirth',
        'dob',
      ],
    );
  }

  String _walkerAadhaar(
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

  String _walkerSelfie(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'profileImageUrl',
      ],
    );
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

  bool _isApproved(
    Map<String, dynamic> data,
  ) {
    return _bool(
      data,
      [
        'isApproved',
      ],
    );
  }

  String _approvalStatus(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      [
        'approvalStatus',
        'status',
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

  double _rating(
    Map<String, dynamic> data,
  ) {
    return _double(
      data,
      [
        'rating',
      ],
    );
  }

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    if (selectedFilter == 'All') {
      return true;
    }

    if (selectedFilter == 'Online') {
      return _isOnline(data);
    }

    if (selectedFilter == 'Offline') {
      return !_isOnline(data);
    }

    if (selectedFilter == 'Pending') {
      final status =
          _approvalStatus(data).toLowerCase();

      return !_isApproved(data) &&
          status != 'approved';
    }

    if (selectedFilter == 'Approved') {
      return _isApproved(data) ||
          _approvalStatus(data).toLowerCase() ==
              'approved';
    }

    return true;
  }

  bool _matchesSearch(
    String uid,
    Map<String, dynamic> data,
  ) {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final values = [
      uid,
      _walkerName(data),
      _walkerMobile(data),
      _walkerAadhaar(data),
      _walkerAddress(data),
      _walkerPincode(data),
    ];

    return values.any(
      (value) =>
          value.toLowerCase().contains(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _watchWalkers(),
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
          return _loadingState();
        }

        final docs =
            snapshot.data?.docs ?? [];

        final filtered = docs.where((doc) {
          final data = doc.data();

          return _matchesSearch(
                doc.id,
                data,
              ) &&
              _matchesFilter(data);
        }).toList();

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(docs),
            const SizedBox(height: 20),
            _summaryCards(docs),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 16),
            _walkerList(filtered),
          ],
        );
      },
    );
  }

  Widget _header(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Walkers',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: dojoDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${docs.length} registered walker'
                '${docs.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: dojoGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _liveIndicator(),
      ],
    );
  }

  Widget _liveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD2EBDD),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 16,
            color: dojoGreen,
          ),
          SizedBox(width: 6),
          Text(
            'Live Firebase',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: dojoGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCards(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    int online = 0;
    int offline = 0;
    int pending = 0;
    int approved = 0;

    for (final doc in docs) {
      final data = doc.data();

      if (_isOnline(data)) {
        online++;
      } else {
        offline++;
      }

      if (_isApproved(data) ||
          _approvalStatus(data).toLowerCase() ==
              'approved') {
        approved++;
      } else {
        pending++;
      }
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns =
            constraints.maxWidth >= 900
                ? 4
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
              columns == 1 ? 3.3 : 2.4,
          children: [
            _SummaryCard(
              title: 'Total Walkers',
              value: '${docs.length}',
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
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
            'Search UID, walker, phone or Aadhaar...',
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
        fillColor:
            const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
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
        _filterButton('Online'),
        _filterButton('Offline'),
      ],
    );
  }

  Widget _filterButton(
    String title,
  ) {
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
          horizontal: 12,
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
            fontSize: 11,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _walkerList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    if (docs.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: docs.map((doc) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 12,
          ),
          child: _walkerCard(doc),
        );
      }).toList(),
    );
  }

  Widget _walkerCard(
    QueryDocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    final data = doc.data();

    final online = _isOnline(data);
    final approved = _isApproved(data) ||
        _approvalStatus(data).toLowerCase() ==
            'approved';

    final statusColor =
        online ? dojoGreen : dojoGrey;

    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          if (constraints.maxWidth < 700) {
            return _mobileCard(
              doc.id,
              data,
              statusColor,
              approved,
            );
          }

          return _desktopCard(
            doc.id,
            data,
            statusColor,
            approved,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    String uid,
    Map<String, dynamic> data,
    Color statusColor,
    bool approved,
  ) {
    return Row(
      children: [
        _avatar(
          _isOnline(data),
          approved,
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(
            uid,
            data,
            approved,
          ),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            _walkerMobile(data),
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${_totalWalks(data)}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            _rating(data)
                .toStringAsFixed(1),
          ),
        ),
        _statusChip(
          _isOnline(data)
              ? 'Online'
              : 'Offline',
          statusColor,
        ),
        const SizedBox(width: 8),
        _approvalChip(
          data,
          approved,
        ),
        const SizedBox(width: 10),
        _viewButton(
          uid,
          data,
          approved,
        ),
      ],
    );
  }

  Widget _mobileCard(
    String uid,
    Map<String, dynamic> data,
    Color statusColor,
    bool approved,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(
              _isOnline(data),
              approved,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(
                uid,
                data,
                approved,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _statusChip(
              _isOnline(data)
                  ? 'Online'
                  : 'Offline',
              statusColor,
            ),
            _approvalChip(
              data,
              approved,
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
                _walkerMobile(data),
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${_totalWalks(data)}',
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
                _rating(data)
                    .toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _info(
                Icons.fingerprint,
                'UID',
                uid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(
            uid,
            data,
            approved,
          ),
        ),
      ],
    );
  }

  Widget _avatar(
    bool online,
    bool approved,
  ) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF0F7),
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: dojoBlue,
            size: 26,
          ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
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
        if (approved)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 19,
              height: 19,
              decoration:
                  const BoxDecoration(
                color: dojoGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _mainInfo(
    String uid,
    Map<String, dynamic> data,
    bool approved,
  ) {
    final name = _walkerName(data);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name.isEmpty
                    ? 'Walker'
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
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Walker ID: $uid',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _walkerMobile(data).isEmpty
              ? 'Mobile not available'
              : _walkerMobile(data),
          maxLines: 1,
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
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty
                    ? '—'
                    : value,
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
            color.withValues(alpha: .09),
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

  Widget _approvalChip(
    Map<String, dynamic> data,
    bool approved,
  ) {
    final rejected =
        _approvalStatus(data)
                .toLowerCase() ==
            'rejected';

    if (approved) {
      return _statusChip(
        'Approved',
        dojoGreen,
      );
    }

    if (rejected) {
      return _statusChip(
        'Rejected',
        dojoRed,
      );
    }

    return _statusChip(
      'Pending',
      dojoOrange,
    );
  }

  Widget _viewButton(
    String uid,
    Map<String, dynamic> data,
    bool approved,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkerDetails(
          uid,
          data,
          approved,
        );
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
    String uid,
    Map<String, dynamic> data,
    bool approved,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WalkerDetailsSheet(
          uid: uid,
          data: data,
          approved: approved,
          onApprove: () {
            Navigator.pop(context);
            _showApproveSheet(
              uid,
              data,
            );
          },
          onReject: () {
            Navigator.pop(context);
            _showRejectSheet(uid);
          },
        );
      },
    );
  }

  void _showApproveSheet(
    String uid,
    Map<String, dynamic> data,
  ) {
    bool aadhaarVerified = false;
    bool selfieVerified = false;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final canConfirm =
                aadhaarVerified &&
                selfieVerified &&
                !saving;

            return Container(
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: SafeArea(
                top: false,
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
                              BorderRadius
                                  .circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Approve Walker',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _walkerName(data).isEmpty
                          ? 'Verify documents before approval.'
                          : 'Verify ${_walkerName(data)} before approval.',
                      style: const TextStyle(
                        color: dojoGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _verificationTile(
                      title:
                          'Aadhaar Verified',
                      subtitle:
                          'Aadhaar details checked by admin',
                      icon:
                          Icons.badge_outlined,
                      value:
                          aadhaarVerified,
                      onChanged: (value) {
                        setSheetState(() {
                          aadhaarVerified =
                              value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _verificationTile(
                      title:
                          'Selfie Verified',
                      subtitle:
                          'Profile selfie checked by admin',
                      icon:
                          Icons.face_outlined,
                      value:
                          selfieVerified,
                      onChanged: (value) {
                        setSheetState(() {
                          selfieVerified =
                              value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            canConfirm
                                ? () async {
                                    setSheetState(
                                      () {
                                        saving =
                                            true;
                                      },
                                    );

                                    try {
                                      await _approveWalker(
                                        uid,
                                      );

                                      if (!context
                                          .mounted) {
                                        return;
                                      }

                                      Navigator.pop(
                                        context,
                                      );

                                      _showMessage(
                                        'Walker approved successfully.',
                                        dojoGreen,
                                      );
                                    } catch (e) {
                                      setSheetState(
                                        () {
                                          saving =
                                              false;
                                        },
                                      );

                                      _showMessage(
                                        'Approval failed. Please try again.',
                                        dojoRed,
                                      );
                                    }
                                  }
                                : null,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline,
                              ),
                        label: Text(
                          saving
                              ? 'Saving...'
                              : 'CONFIRM',
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoGreen,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              const Color(
                                0xFFDDE5E1,
                              ),
                          disabledForegroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              13,
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

  Widget _verificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFEAF7F0)
              : const Color(0xFFF8F9FA),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? const Color(0xFFB9DEC9)
                : dojoBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: value
                    ? const Color(
                        0xFFD9F0E3,
                      )
                    : const Color(
                        0xFFEAF0F7,
                      ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value
                    ? dojoGreen
                    : dojoBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                      color: dojoDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: dojoGrey,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: value,
              activeColor: dojoGreen,
              onChanged: (checked) {
                onChanged(
                  checked ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectSheet(
    String uid,
  ) {
    bool rejecting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: SafeArea(
                top: false,
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
                            20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(
                          Icons
                              .warning_amber_rounded,
                          color: dojoRed,
                          size: 27,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Reject Walker?',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w900,
                            color: dojoDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Are you sure you want to reject this walker application?',
                      style: TextStyle(
                        fontSize: 13,
                        color: dojoGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            rejecting
                                ? null
                                : () async {
                                    setSheetState(
                                      () {
                                        rejecting =
                                            true;
                                      },
                                    );

                                    try {
                                      await _rejectWalker(
                                        uid,
                                      );

                                      if (!context
                                          .mounted) {
                                        return;
                                      }

                                      Navigator.pop(
                                        context,
                                      );

                                      _showMessage(
                                        'Walker rejected.',
                                        dojoRed,
                                      );
                                    } catch (_) {
                                      setSheetState(
                                        () {
                                          rejecting =
                                              false;
                                        },
                                      );

                                      _showMessage(
                                        'Could not reject walker.',
                                        dojoRed,
                                      );
                                    }
                                  },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoRed,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                          ),
                        ),
                        child: rejecting
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
                                'CONFIRM REJECT',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Cancel',
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
    String uid,
  ) async {
    await _walkerProfiles
        .doc(uid)
        .set(
      {
        'aadhaar_verified': true,
        'selfie_verified': true,
        'isApproved': true,
        'approvalStatus': 'approved',
        'approvedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _rejectWalker(
    String uid,
  ) async {
    await _walkerProfiles
        .doc(uid)
        .set(
      {
        'isApproved': false,
        'approvalStatus': 'rejected',
        'rejectedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),
      );
  }

  Widget _loadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(
          color: dojoOrange,
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
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: dojoRed,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load walkers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
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
              'Walker profiles will appear here automatically.',
              textAlign:
                  TextAlign.center,
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
}

class _WalkerDetailsSheet
    extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;
  final bool approved;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _WalkerDetailsSheet({
    required this.uid,
    required this.data,
    required this.approved,
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
        return value.toString();
      }
    }

    return '—';
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

  @override
  Widget build(BuildContext context) {
    final name = _string([
      'Full Name',
      'fullName',
      'name',
      'walkerName',
    ]);

    final mobile = _string([
      'Mobile number',
      'mobile',
      'phone',
      'phoneNumber',
    ]);

    final dob = _string([
      'Date Of Birth',
      'dateOfBirth',
      'dob',
    ]);

    final address = _string([
      'Adress',
      'Address',
      'address',
    ]);

    final pincode = _string([
      'Pincode',
      'pincode',
      'pinCode',
    ]);

    final aadhaar = _string([
      'Aadhar Number',
      'Aadhaar Number',
      'aadhaarNumber',
      'aadharNumber',
    ]);

    final selfie = _string([
      'Profile Selfie',
      'profileSelfie',
      'profileImage',
      'profileImageUrl',
    ]);

    final profileCompleted =
        _bool(['profileCompleted']);

    final aadhaarUploaded =
        _bool([
      'aadhaar_front_uploaded',
    ]);

    final aadhaarBackUploaded =
        _bool([
      'aadhaar_back_uploaded',
    ]);

    return Container(
      constraints:
          const BoxConstraints(
        maxHeight: 720,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration:
                  BoxDecoration(
                color: dojoBorder,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
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
                    child: const Icon(
                      Icons.badge_outlined,
                      color: dojoBlue,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                dojoDark,
                          ),
                        ),
                        const SizedBox(
                            height: 3),
                        Text(
                          'Walker ID: $uid',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 10,
                            color:
                                dojoGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    _detailCard(
                      'Personal Details',
                      [
                        _row(
                          'Full Name',
                          name,
                        ),
                        _row(
                          'Mobile',
                          mobile,
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
                      ],
                    ),
                    const SizedBox(
                        height: 12),
                    _detailCard(
                      'Verification',
                      [
                        _row(
                          'Aadhaar',
                          aadhaar,
                        ),
                        _row(
                          'Aadhaar Front',
                          aadhaarUploaded
                              ? 'Uploaded ✓'
                              : 'Not uploaded',
                        ),
                        _row(
                          'Aadhaar Back',
                          aadhaarBackUploaded
                              ? 'Uploaded ✓'
                              : 'Not uploaded',
                        ),
                        _row(
                          'Profile Completed',
                          profileCompleted
                              ? 'Yes ✓'
                              : 'No',
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 12),
                    if (selfie != '—')
                      _selfiePreview(
                        context,
                        selfie,
                      ),
                  ],
                ),
              ),
            ),
            if (!approved)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            onReject,
                        icon: const Icon(
                          Icons.close,
                        ),
                        label: const Text(
                          'REJECT',
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              dojoRed,
                          side:
                              const BorderSide(
                            color:
                                dojoRed,
                          ),
                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            onApprove,
                        icon:
                            const Icon(
                          Icons
                              .check_circle_outline,
                        ),
                        label: const Text(
                          'APPROVE',
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoGreen,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF9FAFB),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w900,
              color: dojoDark,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
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
            width: 115,
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
            child: Text(
              value,
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

  Widget _selfiePreview(
    BuildContext context,
    String url,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Selfie',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w900,
              color: dojoDark,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child: Image.network(
              url,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Icon(
                      Icons
                          .broken_image_outlined,
                      color:
                          dojoGrey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: .10,
              ),
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
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
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
