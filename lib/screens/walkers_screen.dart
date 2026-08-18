import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String selectedFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkerStream {
    return _firestore
        .collection('walkerProfiles')
        .snapshots();
  }

  List<WalkerData> _convertWalkers(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final walkers = snapshot.docs
        .map(
          (doc) => WalkerData.fromFirestore(
            doc,
          ),
        )
        .toList();

    walkers.sort(
      (a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      },
    );

    return walkers;
  }

  List<WalkerData> _filteredWalkers(
    List<WalkerData> walkers,
  ) {
    final query =
        searchController.text.trim().toLowerCase();

    return walkers.where(
      (walker) {
        final matchesSearch =
            query.isEmpty ||
            walker.walkerId
                .toLowerCase()
                .contains(query) ||
            walker.name
                .toLowerCase()
                .contains(query) ||
            walker.phone
                .toLowerCase()
                .contains(query) ||
            walker.aadhaar
                .contains(query) ||
            walker.authUid
                .toLowerCase()
                .contains(query);

        final matchesFilter =
            _matchesFilter(walker);

        return matchesSearch && matchesFilter;
      },
    ).toList();
  }

  bool _matchesFilter(WalkerData walker) {
    switch (selectedFilter) {
      case 'Pending':
        return walker.verificationStatus == 'pending';

      case 'Approved':
        return walker.verificationStatus == 'approved';

      case 'Rejected':
        return walker.verificationStatus == 'rejected';

      case 'Online':
        return walker.isOnline;

      case 'Offline':
        return !walker.isOnline;

      case 'All':
      default:
        return true;
    }
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
          return _loadingState();
        }

        final walkers =
            _convertWalkers(snapshot.data!);

        final filtered =
            _filteredWalkers(walkers);

        final online = walkers
            .where(
              (walker) => walker.isOnline,
            )
            .length;

        final offline =
            walkers.length - online;

        final pending = walkers
            .where(
              (walker) =>
                  walker.verificationStatus ==
                  'pending',
            )
            .length;

        final approved = walkers
            .where(
              (walker) =>
                  walker.verificationStatus ==
                  'approved',
            )
            .length;

        final activeWalks = walkers.fold<int>(
          0,
          (sum, walker) =>
              sum + walker.activeWalks,
        );

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),

            _summaryCards(
              online: online,
              offline: offline,
              pending: pending,
              approved: approved,
              activeWalks: activeWalks,
            ),

            const SizedBox(height: 20),

            _toolbar(),

            const SizedBox(height: 16),

            if (filtered.isEmpty)
              _emptyState()
            else
              _walkerList(filtered),
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
          'Manage DOJO walkers and verify their profiles',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summaryCards({
    required int online,
    required int offline,
    required int pending,
    required int approved,
    required int activeWalks,
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
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 1.75,
          children: [
            _SummaryCard(
              title: 'Online',
              value: '$online',
              icon: Icons.wifi,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Offline',
              value: '$offline',
              icon: Icons.wifi_off,
              color: dojoGrey,
            ),
            _SummaryCard(
              title: 'Pending',
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
            _SummaryCard(
              title: 'Active Walks',
              value: '$activeWalks',
              icon:
                  Icons.directions_walk_outlined,
              color: dojoBlue,
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
              Flexible(
                child: _filters(),
              ),
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
            'Search walker, phone, Aadhaar or UID...',
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('All'),
          _filterButton('Pending'),
          _filterButton('Approved'),
          _filterButton('Rejected'),
          _filterButton('Online'),
          _filterButton('Offline'),
        ],
      ),
    );
  }

  Widget _filterButton(
    String title,
  ) {
    final selected =
        selectedFilter == title;

    return Padding(
      padding:
          const EdgeInsets.only(right: 7),
      child: InkWell(
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
      ),
    );
  }

  Widget _walkerList(
    List<WalkerData> walkers,
  ) {
    return Column(
      children: walkers.map(
        (walker) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: _walkerCard(walker),
          );
        },
      ).toList(),
    );
  }

  Widget _walkerCard(
    WalkerData walker,
  ) {
    final online =
        walker.isOnline;

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
              walker,
              statusColor,
            );
          }

          return _desktopCard(
            walker,
            statusColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(walker),
        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _mainInfo(walker),
        ),

        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            walker.phone,
          ),
        ),

        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${walker.walks}',
          ),
        ),

        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            walker.rating
                .toStringAsFixed(1),
          ),
        ),

        _verificationChip(
          walker.verificationStatus,
        ),

        const SizedBox(width: 8),

        _statusChip(
          walker.isOnline
              ? 'Online'
              : 'Offline',
          statusColor,
        ),

        const SizedBox(width: 12),

        _viewButton(walker),
      ],
    );
  }

  Widget _mobileCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(walker),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(walker),
            ),
            _verificationChip(
              walker.verificationStatus,
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
                walker.phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${walker.walks}',
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
                walker.rating
                    .toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _info(
                Icons.play_circle_outline,
                'Active Walks',
                '${walker.activeWalks}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            _statusChip(
              walker.isOnline
                  ? 'Online'
                  : 'Offline',
              statusColor,
            ),
            const Spacer(),
            _viewButton(walker),
          ],
        ),
      ],
    );
  }

  Widget _avatar(
    WalkerData walker,
  ) {
    final online =
        walker.isOnline;

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
          child: walker.profileSelfie
                  .isNotEmpty
              ? ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  child: Image.network(
                    walker.profileSelfie,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.badge_outlined,
                        color: dojoBlue,
                        size: 26,
                      );
                    },
                  ),
                )
              : const Icon(
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
      ],
    );
  }

  Widget _mainInfo(
    WalkerData walker,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          walker.walkerId.isEmpty
              ? walker.authUid
              : walker.walkerId,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.name.isEmpty
              ? 'Unnamed Walker'
              : walker.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.authUid,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
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
                value.isEmpty
                    ? '-'
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

  Widget _verificationChip(
    String status,
  ) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = dojoGreen;
        text = 'Approved';
        break;

      case 'rejected':
        color = dojoRed;
        text = 'Rejected';
        break;

      default:
        color = dojoOrange;
        text = 'Pending';
    }

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
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w900,
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

  Widget _viewButton(
    WalkerData walker,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkerDetails(
          walker,
        );
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label:
          const Text('View / Verify'),
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
    WalkerData walker,
  ) {
    showDialog(
      context: context,
      builder: (
        dialogContext,
      ) {
        return Dialog(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
              maxHeight: 760,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(
                22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        _dialogAvatar(
                          walker,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                walker.name
                                        .isEmpty
                                    ? 'Walker'
                                    : walker.name,
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      dojoDark,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                walker.walkerId
                                        .isEmpty
                                    ? walker.authUid
                                    : walker.walkerId,
                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                  color:
                                      dojoGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                            );
                          },
                          icon:
                              const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _sectionTitle(
                      'Personal Information',
                    ),

                    _detailRow(
                      'Full Name',
                      walker.name,
                    ),
                    _detailRow(
                      'Mobile',
                      walker.phone,
                    ),
                    _detailRow(
                      'Date Of Birth',
                      walker.dateOfBirth,
                    ),
                    _detailRow(
                      'Walker UID',
                      walker.authUid,
                    ),
                    _detailRow(
                      'Walker ID',
                      walker.walkerId,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _sectionTitle(
                      'Address',
                    ),

                    _detailRow(
                      'Village',
                      walker.village,
                    ),
                    _detailRow(
                      'City',
                      walker.city,
                    ),
                    _detailRow(
                      'District',
                      walker.district,
                    ),
                    _detailRow(
                      'State',
                      walker.state,
                    ),
                    _detailRow(
                      'Pincode',
                      walker.pinCode,
                    ),
                    _detailRow(
                      'Address',
                      walker.address,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _sectionTitle(
                      'Aadhaar Verification',
                    ),

                    _detailRow(
                      'Aadhaar Number',
                      walker.aadhaar,
                    ),

                    _verificationRow(
                      'Aadhaar Verified',
                      walker.aadhaarVerified,
                    ),

                    _verificationRow(
                      'Name Matched',
                      walker.nameMatched,
                    ),

                    _verificationRow(
                      'DOB Matched',
                      walker.dobMatched,
                    ),

                    _detailRow(
                      'Status',
                      walker.verificationStatus,
                    ),

                    if (walker
                        .verificationMessage
                        .isNotEmpty)
                      _detailRow(
                        'Message',
                        walker.verificationMessage,
                      ),

                    const SizedBox(
                      height: 18,
                    ),

                    _sectionTitle(
                      'Documents',
                    ),

                    _documentGrid(
                      walker,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    if (walker.verificationStatus ==
                        'pending')
                      _approvalButtons(
                        walker,
                        dialogContext,
                      )
                    else
                      _alreadyVerified(
                        walker,
                      ),

                    const SizedBox(
                      height: 8,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        child:
                            const Text(
                          'Close',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dialogAvatar(
    WalkerData walker,
  ) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color:
            const Color(0xFFEAF0F7),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: walker.profileSelfie
              .isNotEmpty
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              child: Image.network(
                walker.profileSelfie,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.person,
                    color: dojoBlue,
                    size: 30,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person,
              color: dojoBlue,
              size: 30,
            ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight:
              FontWeight.w900,
          color: dojoDark,
        ),
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
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
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty
                  ? '-'
                  : value,
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

  Widget _verificationRow(
    String title,
    bool value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle
                : Icons.cancel,
            size: 18,
            color: value
                ? dojoGreen
                : dojoRed,
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
            value
                ? 'YES'
                : 'NO',
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w900,
              color: value
                  ? dojoGreen
                  : dojoRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentGrid(
    WalkerData walker,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final twoColumns =
            constraints.maxWidth >=
                480;

        final children = [
          _documentCard(
            'Profile Selfie',
            walker.profileSelfie,
            Icons.person,
          ),
          _documentCard(
            'Aadhaar Front',
            walker.aadhaarFront,
            Icons.credit_card,
          ),
          _documentCard(
            'Aadhaar Back',
            walker.aadhaarBack,
            Icons.credit_card,
          ),
        ];

        if (!twoColumns) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: children,
        );
      },
    );
  }

  Widget _documentCard(
    String title,
    String url,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F9FA),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  13,
                ),
              ),
              child: url.isEmpty
                  ? Center(
                      child: Icon(
                        icon,
                        size: 38,
                        color: dojoGrey,
                      ),
                    )
                  : Image.network(
                      url,
                      width:
                          double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Center(
                          child: Icon(
                            Icons
                                .broken_image_outlined,
                            size: 38,
                            color:
                                dojoGrey,
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(9),
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalButtons(
    WalkerData walker,
    BuildContext dialogContext,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await _confirmReject(
                walker,
                dialogContext,
              );
            },
            icon: const Icon(
              Icons.close,
            ),
            label:
                const Text('Reject'),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  dojoRed,
              foregroundColor:
                  Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 13,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await _confirmApprove(
                walker,
                dialogContext,
              );
            },
            icon: const Icon(
              Icons.check,
            ),
            label:
                const Text('Approve'),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  dojoGreen,
              foregroundColor:
                  Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _alreadyVerified(
    WalkerData walker,
  ) {
    final approved =
        walker.verificationStatus ==
            'approved';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: approved
            ? dojoGreen.withValues(
                alpha: .08,
              )
            : dojoRed.withValues(
                alpha: .08,
              ),
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(
            approved
                ? Icons.verified
                : Icons.cancel,
            color: approved
                ? dojoGreen
                : dojoRed,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              approved
                  ? 'This walker is approved.'
                  : 'This walker is rejected.',
              style:
                  TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
                color: approved
                    ? dojoGreen
                    : dojoRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmApprove(
    WalkerData walker,
    BuildContext dialogContext,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        context,
      ) {
        return AlertDialog(
          title: const Text(
            'Approve Walker?',
          ),
          content: Text(
            'Are you sure you want to approve ${walker.name}?\n\n'
            'This will mark the Aadhaar verification as approved and allow the Walker app to complete profile verification.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    dojoGreen,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _approveWalker(
      walker,
      dialogContext,
    );
  }

  Future<void> _confirmReject(
    WalkerData walker,
    BuildContext dialogContext,
  ) async {
    final controller =
        TextEditingController();

    final reason =
        await showDialog<String>(
      context: context,
      builder: (
        context,
      ) {
        return AlertDialog(
          title: const Text(
            'Reject Walker',
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration:
                const InputDecoration(
              labelText:
                  'Rejection reason',
              hintText:
                  'Enter reason for rejection...',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text
                      .trim(),
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
                  const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null) {
      return;
    }

    await _rejectWalker(
      walker,
      dialogContext,
      reason.isEmpty
          ? 'Profile rejected by admin.'
          : reason,
    );
  }

  Future<void> _approveWalker(
    WalkerData walker,
    BuildContext dialogContext,
  ) async {
    try {
      final adminUid =
          _auth.currentUser?.uid;

      if (adminUid == null ||
          adminUid.trim().isEmpty) {
        throw Exception(
          'Admin authentication UID not found.',
        );
      }

      await _firestore
          .collection('walkerProfiles')
          .doc(walker.authUid)
          .set(
        {
          'aadhaarVerified': true,
          'nameMatched': true,
          'dobMatched': true,
          'verificationStatus':
              'approved',
          'verificationMessage':
              'Walker profile approved by admin.',
          'verifiedBy':
              adminUid,
          'verifiedAt':
              FieldValue.serverTimestamp(),
          'profileCompleted': true,
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

      Navigator.pop(
        dialogContext,
      );

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
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
    WalkerData walker,
    BuildContext dialogContext,
    String reason,
  ) async {
    try {
      final adminUid =
          _auth.currentUser?.uid;

      if (adminUid == null ||
          adminUid.trim().isEmpty) {
        throw Exception(
          'Admin authentication UID not found.',
        );
      }

      await _firestore
          .collection('walkerProfiles')
          .doc(walker.authUid)
          .set(
        {
          'aadhaarVerified': false,
          'nameMatched': false,
          'dobMatched': false,
          'verificationStatus':
              'rejected',
          'verificationMessage':
              reason,
          'verifiedBy':
              adminUid,
          'verifiedAt':
              FieldValue.serverTimestamp(),
          'profileCompleted': false,
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

      Navigator.pop(
        dialogContext,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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

  Widget _loadingState() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(60),
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
          const EdgeInsets.all(25),
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
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Unable to load walkers',
            style: TextStyle(
              fontSize: 16,
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
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 11,
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
            SizedBox(
              height: 12,
            ),
            Text(
              'No walkers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(
              height: 5,
            ),
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
}

class WalkerData {
  final String authUid;
  final String walkerId;
  final String name;
  final String phone;
  final String dateOfBirth;
  final String address;
  final String pinCode;

  final String village;
  final String city;
  final String district;
  final String state;

  final String aadhaar;

  final String profileSelfie;
  final String aadhaarFront;
  final String aadhaarBack;

  final bool aadhaarVerified;
  final bool nameMatched;
  final bool dobMatched;
  final bool profileCompleted;

  final String verificationStatus;
  final String verificationMessage;
  final String verifiedBy;

  final bool isOnline;
  final bool isActive;

  final int walks;
  final int activeWalks;
  final double rating;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkerData({
    required this.authUid,
    required this.walkerId,
    required this.name,
    required this.phone,
    required this.dateOfBirth,
    required this.address,
    required this.pinCode,
    required this.village,
    required this.city,
    required this.district,
    required this.state,
    required this.aadhaar,
    required this.profileSelfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.aadhaarVerified,
    required this.nameMatched,
    required this.dobMatched,
    required this.profileCompleted,
    required this.verificationStatus,
    required this.verificationMessage,
    required this.verifiedBy,
    required this.isOnline,
    required this.isActive,
    required this.walks,
    required this.activeWalks,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalkerData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
  ) {
    final data =
        doc.data() ??
            <String, dynamic>{};

    return WalkerData(
      authUid: _string(
        data['authUid'] ??
            data['Walker Uid'] ??
            doc.id,
      ),
      walkerId: _string(
        data['Walker Uid'],
      ),
      name: _string(
        data['Full Name'],
      ),
      phone: _string(
        data['Mobile number'],
      ),
      dateOfBirth: _string(
        data['Date Of Birth'],
      ),
      address: _string(
        data['Adress'],
      ),
      pinCode: _string(
        data['Pincode'],
      ),
      village: _string(
        data['Village'],
      ),
      city: _string(
        data['City'],
      ),
      district: _string(
        data['District'],
      ),
      state: _string(
        data['State'],
      ),
      aadhaar: _string(
        data['Aadhar Number'],
      ),
      profileSelfie: _string(
        data['Profile Selfie'],
      ),
      aadhaarFront: _string(
        data['Aadhaar Front'],
      ),
      aadhaarBack: _string(
        data['Aadhaar Back'],
      ),
      aadhaarVerified:
          _bool(
        data['aadhaarVerified'],
      ),
      nameMatched: _bool(
        data['nameMatched'],
      ),
      dobMatched: _bool(
        data['dobMatched'],
      ),
      profileCompleted:
          _bool(
        data['profileCompleted'],
      ),
      verificationStatus:
          _string(
        data['verificationStatus'],
      ).toLowerCase().isEmpty
              ? 'pending'
              : _string(
                  data['verificationStatus'],
                ).toLowerCase(),
      verificationMessage:
          _string(
        data['verificationMessage'],
      ),
      verifiedBy: _string(
        data['verifiedBy'],
      ),
      isOnline: _bool(
        data['isOnline'],
      ),
      isActive: _bool(
        data['isActive'],
        fallback: true,
      ),
      walks: _int(
        data['totalWalks'] ??
            data['walks'],
      ),
      activeWalks: _int(
        data['activeWalks'],
      ),
      rating: _double(
        data['rating'],
      ),
      createdAt: _date(
        data['createdAt'],
      ),
      updatedAt: _date(
        data['updatedAt'],
      ),
    );
  }

  static String _string(
    dynamic value,
  ) {
    return value?.toString().trim() ??
        '';
  }

  static bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    return fallback;
  }

  static int _int(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _double(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _date(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
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
                  color.withValues(
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
