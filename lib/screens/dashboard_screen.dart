import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color orange = Color(0xFFD35435);
const Color blue = Color(0xFF3F6FA5);
const Color green = Color(0xFF3F8F68);
const Color dark = Color(0xFF263238);
const Color grey = Color(0xFF6B7280);
const Color background = Color(0xFFF7F8FA);
const Color border = Color(0xFFE7E9ED);

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final List<String> tabs = const [
    'Overview',
    'Finance',
    'Live Walks',
    'Recent Activity',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // FIREBASE STREAMS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _ownersStream {
    return _firestore
        .collection('users')
        .where(
          'role',
          isEqualTo: 'owner',
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _walkersStream {
    return _firestore
        .collection('walkerProfiles')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _activeWalksStream {
    return _firestore
        .collection('active_walk')
        .where(
          'status',
          isEqualTo: 'active',
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _historyStream {
    return _firestore
        .collection('walkHistory')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(50)
        .snapshots();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),

          const SizedBox(height: 20),

          _dashboardTabs(),

          const SizedBox(height: 20),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _overviewTab(),
                _financeTab(),
                _liveWalksTab(),
                _recentActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Complete overview of the DOJO platform',
          style: TextStyle(
            color: grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _dashboardTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: border,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: orange,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: grey,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: tabs
            .map(
              (tab) => Tab(
                text: tab,
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _overviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _liveMapContainer(),

          const SizedBox(height: 18),

          _statsGrid(),

          const SizedBox(height: 18),

          _quickActions(),

          const SizedBox(height: 18),

          _overviewPanels(),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        int columns;

        if (constraints.maxWidth >= 1000) {
          columns = 4;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _ownersStream,
          builder: (
            context,
            ownerSnapshot,
          ) {
            final ownerCount =
                ownerSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _walkersStream,
              builder: (
                context,
                walkerSnapshot,
              ) {
                final walkerCount =
                    walkerSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: _activeWalksStream,
                  builder: (
                    context,
                    activeSnapshot,
                  ) {
                    final activeCount =
                        activeSnapshot.data?.docs.length ?? 0;

                    return StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _historyStream,
                      builder: (
                        context,
                        historySnapshot,
                      ) {
                        final completedCount =
                            historySnapshot.data?.docs.length ?? 0;

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio:
                              columns == 1 ? 3.3 : 2.2,
                          children: [
                            _StatCard(
                              title: 'Total Owners',
                              value: '$ownerCount',
                              icon:
                                  Icons.people_outline,
                              iconColor: blue,
                            ),
                            _StatCard(
                              title: 'Total Walkers',
                              value: '$walkerCount',
                              icon:
                                  Icons.badge_outlined,
                              iconColor: green,
                            ),
                            _StatCard(
                              title: 'Active Walks',
                              value: '$activeCount',
                              icon: Icons
                                  .directions_walk_outlined,
                              iconColor: orange,
                            ),
                            _StatCard(
                              title:
                                  'Completed Walks',
                              value:
                                  '$completedCount',
                              icon: Icons
                                  .check_circle_outline,
                              iconColor: green,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // LIVE MAP
  // ============================================================

  Widget _liveMapContainer() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        return Container(
          height: 300,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F0),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: border,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter:
                      DashboardMapPainter(),
                ),
              ),

              Positioned(
                top: 15,
                left: 15,
                child:
                    _mapLabel(docs.length),
              ),

              if (docs.isEmpty)
                const Center(
                  child: Text(
                    'No active walks right now.',
                    style: TextStyle(
                      color: grey,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                )
              else
                ..._buildMapMarkers(
                  docs,
                ),

              Positioned(
                right: 15,
                bottom: 15,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapLabel(
    int count,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.07),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 10,
            color: green,
          ),
          const SizedBox(width: 7),
          Text(
            count == 0
                ? 'Live Walk Map'
                : '$count Active Walk'
                    '${count == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMapMarkers(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    final positions = <Offset>[
      const Offset(70, 80),
      const Offset(210, 130),
      const Offset(145, 195),
      const Offset(300, 75),
      const Offset(55, 205),
      const Offset(330, 180),
    ];

    final count = docs.length >
            positions.length
        ? positions.length
        : docs.length;

    return List.generate(
      count,
      (index) {
        final data =
            docs[index].data();

        final walkerUid =
            _readString(
                  data,
                  'walkerUid',
                ) ??
                _readString(
                  data,
                  'walkerId',
                ) ??
                '';

        final ownerUid =
            _readString(
                  data,
                  'ownerUid',
                ) ??
                _readString(
                  data,
                  'ownerId',
                ) ??
                '';

        final title =
            walkerUid.isNotEmpty
                ? 'Walker ${_shortId(walkerUid)}'
                : ownerUid.isNotEmpty
                    ? 'Walk ${_shortId(ownerUid)}'
                    : 'Active Walk';

        return Positioned(
          left: positions[index].dx,
          top: positions[index].dy,
          child: _MapMarker(
            title: title,
          ),
        );
      },
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                title: 'Owners',
                icon:
                    Icons.people_outline,
                color: blue,
                onTap: () =>
                    widget.onNavigate(4),
              ),
              _ActionButton(
                title: 'Walkers',
                icon:
                    Icons.badge_outlined,
                color: green,
                onTap: () =>
                    widget.onNavigate(5),
              ),
              _ActionButton(
                title: 'Active Walks',
                icon: Icons
                    .directions_walk_outlined,
                color: orange,
                onTap: () =>
                    widget.onNavigate(2),
              ),
              _ActionButton(
                title: 'Walk History',
                icon:
                    Icons.history_outlined,
                color: grey,
                onTap: () =>
                    widget.onNavigate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW PANELS
  // ============================================================

  Widget _overviewPanels() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        if (constraints.maxWidth <
            650) {
          return Column(
            children: [
              _activeWalkPanel(),
              const SizedBox(height: 14),
              _recentActivityPanel(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  _activeWalkPanel(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child:
                  _recentActivityPanel(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ACTIVE WALK PANEL
  // ============================================================

  Widget _activeWalkPanel() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        return _DataPanel(
          title: 'Active Walks',
          icon: Icons
              .directions_walk_outlined,
          color: orange,
          child: docs.isEmpty
              ? const _EmptyMessage(
                  text:
                      'No active walks right now.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 5
                      ? 5
                      : docs.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(
                    height: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    return _activeWalkRow(
                      docs[index].data(),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _activeWalkRow(
    Map<String, dynamic> data,
  ) {
    final walkerUid =
        _readString(
              data,
              'walkerUid',
            ) ??
            _readString(
              data,
              'walkerId',
            );

    final ownerUid =
        _readString(
              data,
              'ownerUid',
            ) ??
            _readString(
              data,
              'ownerId',
            );

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final dogName =
        _readString(
              data,
              'dogName',
            ) ??
            'Dog';

    final distance =
        _readNumber(
              data,
              'distanceKm',
            ) ??
            _readNumber(
              data,
              'distance',
            ) ??
            '0';

    final duration =
        _readNumber(
              data,
              'durationMinutes',
            ) ??
            _readNumber(
              data,
              'duration',
            ) ??
            '0';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(
            color:
                orange.withOpacity(.10),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.pets,
            color: orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                walkerName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  fontSize: 12,
                  color: dark,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                '$dogName • '
                '${ownerUid == null ? 'Owner' : 'Owner ${_shortId(ownerUid)}'}',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
              if (walkerUid != null)
                Text(
                  'Walker ID: ${_shortId(walkerUid)}',
                  style:
                      const TextStyle(
                    fontSize: 9,
                    color: grey,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '$distance km',
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            Text(
              '$duration min',
              style:
                  const TextStyle(
                fontSize: 10,
                color: grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RECENT ACTIVITY PANEL
  // ============================================================

  Widget _recentActivityPanel() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        return _DataPanel(
          title: 'Recent Activity',
          icon:
              Icons.history_outlined,
          color: blue,
          child: docs.isEmpty
              ? const _EmptyMessage(
                  text:
                      'No recent activity.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 5
                      ? 5
                      : docs.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(
                    height: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    return _historyRow(
                      docs[index].data(),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _historyRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(
              data,
              'dogName',
            ) ??
            'Dog';

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final distance =
        _readNumber(
              data,
              'distanceKm',
            ) ??
            '0';

    final duration =
        _readNumber(
              data,
              'durationMinutes',
            ) ??
            '0';

    final rating =
        _readNumber(
          data,
          'rating',
        );

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color:
                blue.withOpacity(.10),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.history,
            color: blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                dogName,
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
              const SizedBox(
                height: 3,
              ),
              Text(
                walkerName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '$distance km',
              style:
                  const TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            Text(
              '$duration min',
              style:
                  const TextStyle(
                fontSize: 10,
                color: grey,
              ),
            ),
            if (rating != null)
              Text(
                '★ $rating',
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: orange,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // FINANCE
  // ============================================================

  Widget _financeTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        double total = 0;
        double today = 0;

        for (final doc in docs) {
          final data = doc.data();

          final payout =
              _readDouble(
                    data,
                    'payoutAmount',
                  ) ??
                  _readDouble(
                    data,
                    'walkerPayout',
                  ) ??
                  0;

          total += payout;

          final dateValue =
              data['createdAt'] ??
                  data['completedAt'] ??
                  data['timestamp'];

          if (_isToday(dateValue)) {
            today += payout;
          }
        }

        return SingleChildScrollView(
          padding:
              const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _financeStats(
                todayRevenue: today,
                totalPayments: total,
                pendingPayouts: 0,
              ),

              const SizedBox(
                height: 18,
              ),

              _financePanel(
                title:
                    'Revenue Overview',
                icon:
                    Icons.trending_up,
                color: green,
                text: docs.isEmpty
                    ? 'No completed walk payments yet.'
                    : 'Completed walk revenue\n₹${_money(total)}',
              ),

              const SizedBox(
                height: 14,
              ),

              _financePanel(
                title:
                    'Pending Payouts',
                icon: Icons
                    .account_balance_wallet_outlined,
                color: orange,
                text:
                    'Pending payout data is not available yet.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _financeStats({
    required double todayRevenue,
    required double totalPayments,
    required double pendingPayouts,
  }) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns =
            constraints.maxWidth >=
                    800
                ? 3
                : 1;

        return GridView.count(
          crossAxisCount:
              columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1
                  ? 3
                  : 2,
          children: [
            _StatCard(
              title:
                  'Today Revenue',
              value:
                  '₹${_money(todayRevenue)}',
              icon:
                  Icons.currency_rupee,
              iconColor: green,
            ),
            _StatCard(
              title:
                  'Total Payments',
              value:
                  '₹${_money(totalPayments)}',
              icon:
                  Icons.payments_outlined,
              iconColor: blue,
            ),
            _StatCard(
              title:
                  'Pending Payouts',
              value:
                  '₹${_money(pendingPayouts)}',
              icon: Icons
                  .account_balance_wallet_outlined,
              iconColor: orange,
            ),
          ],
        );
      },
    );
  }

  Widget _financePanel({
    required String title,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 220,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: grey,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE WALKS TAB
  // ============================================================

  Widget _liveWalksTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding:
              const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _liveMapContainer(),

              const SizedBox(
                height: 18,
              ),

              _DataPanel(
                title: 'Active Walks',
                icon: Icons
                    .directions_walk_outlined,
                color: orange,
                child: docs.isEmpty
                    ? const _EmptyMessage(
                        text:
                            'Live walks will appear here.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount:
                            docs.length,
                        separatorBuilder:
                            (_, __) =>
                                const Divider(),
                        itemBuilder:
                            (context, index) {
                          return _liveWalkDetailedRow(
                            docs[index]
                                .data(),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _liveWalkDetailedRow(
    Map<String, dynamic> data,
  ) {
    final ownerUid =
        _readString(
              data,
              'ownerUid',
            ) ??
            _readString(
              data,
              'ownerId',
            );

    final walkerUid =
        _readString(
              data,
              'walkerUid',
            ) ??
            _readString(
              data,
              'walkerId',
            );

    final ownerName =
        _readString(
              data,
              'ownerName',
            ) ??
            'Owner';

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final dogName =
        _readString(
              data,
              'dogName',
            ) ??
            'Dog';

    final dogBreed =
        _readString(
              data,
              'dogBreed',
            );

    final walkerPhone =
        _readString(
              data,
              'walkerPhone',
            ) ??
            _readString(
              data,
              'walkerMobile',
            ) ??
            _readString(
              data,
              'mobileNumber',
            );

    final lat =
        _readDouble(
          data,
          'currentLat',
        ) ??
            _readDouble(
              data,
              'latitude',
            );

    final lng =
        _readDouble(
          data,
          'currentLng',
        ) ??
            _readDouble(
              data,
              'longitude',
            );

    final distance =
        _readNumber(
              data,
              'distanceKm',
            ) ??
            _readNumber(
              data,
              'distance',
            ) ??
            '0';

    final duration =
        _readNumber(
              data,
              'durationMinutes',
            ) ??
            _readNumber(
              data,
              'duration',
            ) ??
            '0';

    final pee =
        _readInt(
              data,
              'peeCount',
            ) ??
            0;

    final poop =
        _readInt(
              data,
              'poopCount',
            ) ??
            0;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  orange.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.pets,
              color: orange,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  walkerName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  'Owner: $ownerName',
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),

                Text(
                  'Dog: $dogName'
                  '${dogBreed == null ? '' : ' • $dogBreed'}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),

                if (walkerUid != null)
                  Text(
                    'Walker ID: ${_shortId(walkerUid)}',
                    style:
                        const TextStyle(
                      fontSize: 9,
                      color: grey,
                    ),
                  ),

                if (ownerUid != null)
                  Text(
                    'Owner ID: ${_shortId(ownerUid)}',
                    style:
                        const TextStyle(
                      fontSize: 9,
                      color: grey,
                    ),
                  ),

                if (walkerPhone != null)
                  Text(
                    '📞 $walkerPhone',
                    style:
                        const TextStyle(
                      fontSize: 9,
                      color: green,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  lat == null ||
                          lng == null
                      ? 'Location unavailable'
                      : '📍 ${lat.toStringAsFixed(5)}, '
                          '${lng.toStringAsFixed(5)}',
                  style:
                      const TextStyle(
                    fontSize: 9,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '$distance km',
                style:
                    const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              Text(
                '$duration min',
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Pee $pee • Poop $poop',
                style:
                    const TextStyle(
                  fontSize: 9,
                  color: grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY TAB
  // ============================================================

  Widget _recentActivityTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (
        context,
        snapshot,
      ) {
        final docs =
            snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding:
              const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _DataPanel(
                title:
                    'Recent Activity',
                icon:
                    Icons.history_outlined,
                color: blue,
                child: docs.isEmpty
                    ? const _EmptyMessage(
                        text:
                            'Recent platform activity will appear here.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount:
                            docs.length,
                        separatorBuilder:
                            (_, __) =>
                                const Divider(),
                        itemBuilder:
                            (context, index) {
                          return _historyDetailedRow(
                            docs[index]
                                .data(),
                          );
                        },
                      ),
              ),

              const SizedBox(
                height: 14,
              ),

              const _DataPanel(
                title:
                    'System Activity',
                icon: Icons
                    .receipt_long_outlined,
                color: green,
                child:
                    _EmptyMessage(
                  text:
                      'System activity logs are not connected yet.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _historyDetailedRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(
              data,
              'dogName',
            ) ??
            'Dog';

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final date =
        _readString(
              data,
              'date',
            ) ??
            '';

    final badge =
        _readString(
          data,
          'badge',
        );

    final distance =
        _readDouble(
          data,
          'distanceKm',
        );

    final duration =
        _readInt(
          data,
          'durationMinutes',
        );

    final rating =
        _readDouble(
          data,
          'rating',
        );

    final dogBreed =
        _readString(
          data,
          'dogBreed',
        );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  blue.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.pets,
              color: blue,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  dogName,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                if (dogBreed != null)
                  Text(
                    dogBreed,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  walkerName,
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),

                if (date.isNotEmpty)
                  Text(
                    date,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),

                if (badge != null)
                  Text(
                    badge,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: orange,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              if (distance != null)
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style:
                      const TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

              if (duration != null)
                Text(
                  '$duration min',
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),

              if (rating != null)
                Text(
                  '★ ${rating.toStringAsFixed(1)}',
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color: orange,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA PANEL
// ============================================================

class _DataPanel
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _DataPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 21,
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          child,
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyMessage
    extends StatelessWidget {
  final String text;

  const _EmptyMessage({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 90,
      child: Center(
        child: Text(
          text,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color: grey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
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
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: iconColor
                  .withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(
            width: 13,
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
                    color: grey,
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
                    color: dark,
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

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color:
              color.withOpacity(.08),
          borderRadius:
              BorderRadius.circular(11),
          border: Border.all(
            color:
                color.withOpacity(.18),
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(
              width: 7,
            ),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAP MARKER
// ============================================================

class _MapMarker
    extends StatelessWidget {
  final String title;

  const _MapMarker({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.10),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            title,
            style:
                const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Container(
          width: 28,
          height: 28,
          decoration:
              const BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MAP PAINTER
// ============================================================

class DashboardMapPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final gridPaint = Paint()
      ..color =
          const Color(0xFFDDE3DF)
      ..strokeWidth = 1.5;

    for (
      double x = 0;
      x < size.width;
      x += 55
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x + 70,
          size.height,
        ),
        gridPaint,
      );
    }

    for (
      double y = 20;
      y < size.height;
      y += 60
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width,
          y - 20,
        ),
        gridPaint,
      );
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style =
          PaintingStyle.stroke;

    final road = Path()
      ..moveTo(
        0,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .25,
        size.width,
        size.height * .55,
      );

    canvas.drawPath(
      road,
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// FIREBASE HELPERS
// ============================================================

String? _readString(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  final text =
      value.toString().trim();

  return text.isEmpty
      ? null
      : text;
}

String? _readNumber(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toString();
  }

  final text =
      value.toString().trim();

  return text.isEmpty
      ? null
      : text;
}

double? _readDouble(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(
      value,
    );
  }

  return null;
}

int? _readInt(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(
      value,
    );
  }

  return null;
}

bool _isToday(
  dynamic value,
) {
  DateTime? date;

  if (value is Timestamp) {
    date = value.toDate();
  } else if (value is DateTime) {
    date = value;
  } else if (value is int) {
    date =
        DateTime.fromMillisecondsSinceEpoch(
      value,
      isUtc: false,
    );
  } else if (value is String) {
    date =
        DateTime.tryParse(value);
  }

  if (date == null) {
    return false;
  }

  final now =
      DateTime.now();

  return date.year ==
          now.year &&
      date.month ==
          now.month &&
      date.day ==
          now.day;
}

String _shortId(
  String value,
) {
  if (value == '-' ||
      value.length <= 10) {
    return value;
  }

  return '${value.substring(0, 6)}...';
}

String _money(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value.toStringAsFixed(2);
}
