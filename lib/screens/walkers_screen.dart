import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC62828);
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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

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
      _walkerStream() {
    return _walkerProfiles.snapshots();
  }

  bool _bool(
    Map<String, dynamic> data,
    String key, {
    bool fallback = false,
  }) {
    final value = data[key];

    if (value is bool) {
      return value;
    }

    return fallback;
  }

  String _string(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  int _int(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double _double(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _walkerName(
    Map<String, dynamic> data,
  ) {
    final name = _string(data, 'Full Name');

    if (name.isNotEmpty) {
      return name;
    }

    return _string(data, 'name').isNotEmpty
        ? _string(data, 'name')
        : 'Walker';
  }

  String _walkerMobile(
    Map<String, dynamic> data,
  ) {
    final value = _string(data, 'Mobile number');

    if (value.isNotEmpty) {
      return value;
    }

    return _string(data, 'mobile');
  }

  String _walkerEmail(
    Map<String, dynamic> data,
  ) {
    return _string(data, 'email');
  }

  String _walkerId(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final savedId = _string(data, 'walkerId');

    if (savedId.isNotEmpty) {
      return savedId;
    }

    final oldId = _string(data, 'Walker Id');

    if (oldId.isNotEmpty) {
      return oldId;
    }

    final uid = doc.id;

    if (uid.length >= 8) {
      return 'WKR-${uid.substring(0, 8).toUpperCase()}';
    }

    return 'WKR-${uid.toUpperCase()}';
  }

  String _status(
    Map<String, dynamic> data,
  ) {
    final approved = _bool(
      data,
      'isApproved',
    );

    final rejected = _bool(
      data,
      'isRejected',
    );

    final online = _bool(
      data,
      'isOnline',
    );

    if (rejected) {
      return 'Rejected';
    }

    if (!approved) {
      return 'Pending';
    }

    if (online) {
      return 'Online';
    }

    return 'Offline';
  }

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    switch (selectedFilter) {
      case 'Pending':
        return status == 'Pending';

      case 'Approved':
        return _bool(
          data,
          'isApproved',
        );

      case 'Online':
        return status == 'Online';

      case 'Rejected':
        return status == 'Rejected';

      default:
        return true;
    }
  }

  bool _matchesSearch(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final query = searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final values = <String>[
      doc.id,
      _walkerId(doc, data),
      _walkerName(data),
      _walkerMobile(data),
      _walkerEmail(data),
      _string(data, 'Aadhar Number'),
      _string(data, 'Pincode'),
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
      stream: _walkerStream(),
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
              padding: EdgeInsets.all(80),
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        final documents =
            snapshot.data?.docs ?? [];

        final filtered = documents.where(
          (doc) {
            final data =
                doc.data();

            return _matchesFilter(data) &&
                _matchesSearch(
                  doc,
                  data,
                );
          },
        ).toList();

        return _content(
          documents,
          filtered,
        );
      },
    );
  }

  Widget _content(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        documents,
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        filtered,
  ) {
    int online = 0;
    int offline = 0;
    int pending = 0;
    int rejected = 0;

    for (final doc in documents) {
      final data = doc.data();
      final status = _status(data);

      if (status == 'Online') {
        online++;
      } else if (status == 'Offline') {
        offline++;
      } else if (status == 'Pending') {
        pending++;
      } else if (status == 'Rejected') {
        rejected++;
      }
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summaryCards(
          total: documents.length,
          online: online,
          pending: pending,
          rejected: rejected,
        ),
        const SizedBox(height: 20),
        _toolbar(),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _emptyState()
        else
          ...filtered.map(
            (doc) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: _walkerCard(
                doc,
                doc.data(),
              ),
            ),
          ),
      ],
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
          'Manage DOJO walkers, verification and activity',
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
    required int rejected,
  }) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
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
              columns == 1 ? 3.2 : 2.4,
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
              title: 'Rejected',
              value: '$rejected',
              icon: Icons.block_outlined,
              color: dojoRed,
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
          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
            'Search walker, UID, phone, Aadhaar...',
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
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide:
              const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide:
              const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
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
        _filterButton('Online'),
        _filterButton('Rejected'),
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
        decoration:
            BoxDecoration(
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
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    final statusColor =
        status == 'Online'
            ? dojoGreen
            : status == 'Pending'
                ? dojoOrange
                : status == 'Rejected'
                    ? dojoRed
                    : dojoGrey;

    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
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
          if (constraints.maxWidth <
              720) {
            return _mobileCard(
              doc,
              data,
              status,
              statusColor,
            );
          }

          return _desktopCard(
            doc,
            data,
            status,
            statusColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    String status,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(
          data,
          status,
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(
            doc,
            data,
          ),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            _walkerMobile(data).isEmpty
                ? '—'
                : _walkerMobile(data),
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${_int(data, 'totalWalks')}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            _double(data, 'rating')
                .toStringAsFixed(1),
          ),
        ),
        _statusChip(
          status,
          statusColor,
        ),
        const SizedBox(width: 12),
        _viewButton(
          doc,
          data,
        ),
      ],
    );
  }

  Widget _mobileCard(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    String status,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(
              data,
              status,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(
                doc,
                data,
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
                _walkerMobile(data).isEmpty
                    ? '—'
                    : _walkerMobile(data),
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${_int(data, 'totalWalks')}',
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
                _double(data, 'rating')
                    .toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _info(
                Icons.fingerprint,
                'UID',
                doc.id,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(
            doc,
            data,
          ),
        ),
      ],
    );
  }

  Widget _avatar(
    Map<String, dynamic> data,
    String status,
  ) {
    final image =
        _string(data, 'Profile Selfie').isNotEmpty
            ? _string(
                data,
                'Profile Selfie',
              )
            : _string(
                data,
                'profileImage',
              );

    final online =
        status == 'Online';

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFEAF0F7),
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: image.isEmpty
              ? const Icon(
                  Icons.badge_outlined,
                  color: dojoBlue,
                  size: 27,
                )
              : ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.badge_outlined,
                        color: dojoBlue,
                        size: 27,
                      );
                    },
                  ),
                ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 14,
            height: 14,
            decoration:
                BoxDecoration(
              color: online
                  ? dojoGreen
                  : status == 'Pending'
                      ? dojoOrange
                      : status == 'Rejected'
                          ? dojoRed
                          : dojoGrey,
              shape:
                  BoxShape.circle,
              border:
                  Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainInfo(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          _walkerId(
            doc,
            data,
          ),
          style:
              const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _walkerName(data),
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
          'UID: ${doc.id}',
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
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: .09,
        ),
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
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkerDetails(
          doc,
          data,
        );
      },
      icon:
          const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label:
          const Text('View'),
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
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return _walkerDetailsSheet(
          sheetContext,
          doc,
          data,
        );
      },
    );
  }

  Widget _walkerDetailsSheet(
    BuildContext sheetContext,
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final status = _status(data);
    final approved =
        _bool(data, 'isApproved');
    final aadhaarVerified =
        _bool(
      data,
      'aadhaarVerified',
    );
    final selfieVerified =
        _bool(
      data,
      'selfieVerified',
    );

    final selfie =
        _string(data, 'Profile Selfie');

    return SafeArea(
      child: Container(
        constraints:
            const BoxConstraints(
          maxHeight: 700,
        ),
        decoration:
            const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  _largeAvatar(
                    selfie,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _walkerName(data),
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                            color: dojoDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _walkerId(
                            doc,
                            data,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                            color: dojoGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${doc.id}',
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
                    ),
                  ),
                  _statusChip(
                    status,
                    status == 'Online'
                        ? dojoGreen
                        : status == 'Pending'
                            ? dojoOrange
                            : status == 'Rejected'
                                ? dojoRed
                                : dojoGrey,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _sectionTitle(
                'Profile Information',
              ),
              const SizedBox(height: 10),
              _detailRow(
                'Full Name',
                _walkerName(data),
              ),
              _detailRow(
                'Mobile',
                _walkerMobile(data).isEmpty
                    ? '—'
                    : _walkerMobile(data),
              ),
              _detailRow(
                'Email',
                _walkerEmail(data).isEmpty
                    ? '—'
                    : _walkerEmail(data),
              ),
              _detailRow(
                'Date Of Birth',
                _string(
                  data,
                  'Date Of Birth',
                ).isEmpty
                    ? '—'
                    : _string(
                        data,
                        'Date Of Birth',
                      ),
              ),
              _detailRow(
                'Address',
                _string(
                  data,
                  'Adress',
                ).isEmpty
                    ? '—'
                    : _string(
                        data,
                        'Adress',
                      ),
              ),
              _detailRow(
                'Pincode',
                _string(
                  data,
                  'Pincode',
                ).isEmpty
                    ? '—'
                    : _string(
                        data,
                        'Pincode',
                      ),
              ),
              _detailRow(
                'Aadhaar',
                _string(
                  data,
                  'Aadhar Number',
                ).isEmpty
                    ? '—'
                    : _string(
                        data,
                        'Aadhar Number',
                      ),
              ),
              const SizedBox(height: 12),
              _sectionTitle(
                'Verification',
              ),
              const SizedBox(height: 10),
              _verificationRow(
                'Profile Completed',
                _bool(
                  data,
                  'profileCompleted',
                ),
              ),
              _verificationRow(
                'Aadhaar Verified',
                aadhaarVerified,
              ),
              _verificationRow(
                'Selfie Verified',
                selfieVerified,
              ),
              _verificationRow(
                'Approved',
                approved,
              ),
              const SizedBox(height: 20),
              if (!approved &&
                  status != 'Rejected')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                          _showRejectConfirmation(
                            doc,
                            data,
                          );
                        },
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              dojoRed,
                          side:
                              const BorderSide(
                            color: dojoRed,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                          _showApproveSheet(
                            doc,
                            data,
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoGreen,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                        ),
                        child:
                            const Text(
                          'Approve',
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
              if (status == 'Rejected')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        sheetContext,
                      );
                    },
                    child:
                        const Text('Close'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _largeAvatar(
    String image,
  ) {
    return Container(
      width: 68,
      height: 68,
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEAF0F7),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: image.isEmpty
          ? const Icon(
              Icons.badge_outlined,
              color: dojoBlue,
              size: 32,
            )
          : ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.badge_outlined,
                    color: dojoBlue,
                    size: 32,
                  );
                },
              ),
            ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontSize: 14,
        fontWeight:
            FontWeight.w900,
        color: dojoDark,
      ),
    );
  }

  Widget _verificationRow(
    String title,
    bool verified,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration:
          BoxDecoration(
        color: verified
            ? dojoGreen.withValues(
                alpha: .07,
              )
            : const Color(0xFFF8F9FA),
        borderRadius:
            BorderRadius.circular(11),
        border:
            Border.all(
          color: verified
              ? dojoGreen.withValues(
                  alpha: .20,
                )
              : dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            verified
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: verified
                ? dojoGreen
                : dojoGrey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
          Text(
            verified
                ? 'Verified'
                : 'Not Verified',
            style:
                TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color: verified
                  ? dojoGreen
                  : dojoGrey,
            ),
          ),
        ],
      ),
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
            width: 105,
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
                color: dojoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveSheet(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    bool aadhaarVerified =
        _bool(
      data,
      'aadhaarVerified',
    );

    bool selfieVerified =
        _bool(
      data,
      'selfieVerified',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final canConfirm =
                aadhaarVerified &&
                    selfieVerified;

            return SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
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
                    const SizedBox(
                      height: 18,
                    ),
                    const Text(
                      'Approve Walker',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      _walkerName(data),
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color: dojoGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _verifyCheckbox(
                      title:
                          'Aadhaar Verified',
                      value:
                          aadhaarVerified,
                      onChanged: (
                        value,
                      ) {
                        setSheetState(() {
                          aadhaarVerified =
                              value;
                        });
                      },
                    ),
                    _verifyCheckbox(
                      title:
                          'Selfie Verified',
                      value:
                          selfieVerified,
                      onChanged: (
                        value,
                      ) {
                        setSheetState(() {
                          selfieVerified =
                              value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton(
                        onPressed:
                            canConfirm
                                ? () async {
                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    await _approveWalker(
                                      doc,
                                      aadhaarVerified,
                                      selfieVerified,
                                    );
                                  }
                                : null,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              dojoGreen,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              dojoBorder,
                          padding:
                              const EdgeInsets.symmetric(
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
                        child:
                            const Text(
                          'Confirm',
                          style:
                              TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w900,
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

  Widget _verifyCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color: value
            ? dojoGreen.withValues(
                alpha: .07,
              )
            : const Color(0xFFF8F9FA),
        borderRadius:
            BorderRadius.circular(12),
        border:
            Border.all(
          color: value
              ? dojoGreen.withValues(
                  alpha: .25,
                )
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
        activeColor:
            dojoGreen,
        controlAffinity:
            ListTileControlAffinity.leading,
        title: Text(
          title,
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _approveWalker(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool aadhaarVerified,
    bool selfieVerified,
  ) async {
    try {
      await _walkerProfiles
          .doc(doc.id)
          .set(
        {
          'aadhaarVerified':
              aadhaarVerified,
          'selfieVerified':
              selfieVerified,
          'isApproved': true,
          'isRejected': false,
          'approvedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Walker approved successfully.',
          ),
          backgroundColor:
              dojoGreen,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        'Could not approve walker.',
      );
    }
  }

  void _showRejectConfirmation(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            'Reject Walker?',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to reject ${_walkerName(data)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                await _rejectWalker(
                  doc,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    dojoRed,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Confirm Reject',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectWalker(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    try {
      await _walkerProfiles
          .doc(doc.id)
          .set(
        {
          'isApproved': false,
          'isRejected': true,
          'rejectedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Walker rejected.',
          ),
          backgroundColor:
              dojoRed,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        'Could not reject walker.',
      );
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            dojoRed,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width:
          double.infinity,
      height: 300,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border:
            Border.all(
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
            SizedBox(
              height: 12,
            ),
            Text(
              'No walkers found',
              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Walkers will appear here when their profile is created.',
              textAlign:
                  TextAlign.center,
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
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border:
            Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: dojoRed,
            size: 45,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Unable to load walkers',
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            error,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: dojoGrey,
              fontSize: 11,
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border:
            Border.all(
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
          const SizedBox(
            width: 12,
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
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
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
