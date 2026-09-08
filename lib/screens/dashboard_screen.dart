// File: lib/screens/dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/dashboard/dashboard_components.dart';
import '../widgets/dashboard/dashboard_live_map.dart';
import '../widgets/dashboard/dashboard_tabs.dart';

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
  late final TabController _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // DOJO ADMIN DESIGN
  // ============================================================

  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF2563EB);

  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  // Compatibility aliases for existing dashboard widgets.
  Color get orange => primaryOrange;
  Color get blue => secondaryBlue;
  Color get green => success;
  Color get grey => textSecondary;
  Color get dark => textPrimary;
  Color get border => borderColor;

  // ============================================================
  // FIRESTORE STREAMS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> get _ownersStream {
    return _firestore.collection('owners').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkersStream {
    return _firestore.collection('walkers').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _activeWalksStream {
    return _firestore.collection('active_walks').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _historyStream {
    return _firestore.collection('walk_history').snapshots();
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: DashboardTabs.tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dashboardHeader(isMobile),
              const SizedBox(height: 16),
              DashboardTabs(
                controller: _tabController,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _overviewTab(isMobile),
                    _financeTab(isMobile),
                    _liveWalksTab(isMobile),
                    _recentActivityTab(isMobile),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DASHBOARD HEADER
  // ============================================================

  Widget _dashboardHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 2 : 4,
        vertical: 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor your Dojo Walker platform in real time.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _liveStatusBadge(),
        ],
      ),
    );
  }

  Widget _liveStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: success.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success.withValues(alpha: .20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'Live',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: success,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _overviewTab(bool isMobile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: isMobile ? 0 : 2,
        right: isMobile ? 0 : 2,
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardLiveMap(
            activeWalksStream: _activeWalksStream,
          ),
          const SizedBox(height: 18),
          _statsGrid(),
          const SizedBox(height: 18),
          _quickActions(isMobile),
          const SizedBox(height: 18),
          _overviewPanels(),
        ],
      ),
    );
  }

  // ============================================================
  // STATS GRID
  // ============================================================

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 1050) {
          columns = 4;
        } else if (constraints.maxWidth >= 650) {
          columns = 2;
        }

        final aspectRatio = columns == 1
            ? 3.1
            : columns == 2
                ? 2.35
                : 2.15;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _ownersStream,
          builder: (context, ownerSnapshot) {
            final ownerCount = ownerSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _walkersStream,
              builder: (context, walkerSnapshot) {
                final walkerCount = walkerSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _activeWalksStream,
                  builder: (context, activeSnapshot) {
                    final activeCount = _activeWalkCount(
                      activeSnapshot.data?.docs,
                    );

                    return StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _historyStream,
                      builder: (context, historySnapshot) {
                        final historyDocs = _sortedHistoryDocs(
                          historySnapshot.data?.docs,
                        );

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: aspectRatio,
                          children: [
                            _buildPremiumStatCard(
                              title: 'Total Owners',
                              value: '$ownerCount',
                              subtitle: 'Registered owners',
                              icon: Icons.people_outline,
                              iconColor: secondaryBlue,
                              onTap: () => widget.onNavigate(4),
                            ),
                            _buildPremiumStatCard(
                              title: 'Total Walkers',
                              value: '$walkerCount',
                              subtitle: 'Registered walkers',
                              icon: Icons.badge_outlined,
                              iconColor: success,
                              onTap: () => widget.onNavigate(5),
                            ),
                            _buildPremiumStatCard(
                              title: 'Active Walks',
                              value: '$activeCount',
                              subtitle: 'Currently running',
                              icon: Icons.directions_walk_outlined,
                              iconColor: primaryOrange,
                              onTap: () => widget.onNavigate(2),
                            ),
                            _buildPremiumStatCard(
                              title: 'Completed Walks',
                              value: '${historyDocs.length}',
                              subtitle: 'Walk history',
                              icon: Icons.check_circle_outline,
                              iconColor: success,
                              onTap: () => widget.onNavigate(3),
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

  Widget _buildPremiumStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return _HoverCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  int _activeWalkCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
  ) {
    final list = docs ?? const [];

    return list.where((doc) {
      final status = _readString(
        doc.data(),
        'status',
      )?.toLowerCase();

      return status == 'active' ||
          status == 'on_the_way' ||
          status == 'walking' ||
          status == 'started';
    }).length;
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: secondaryBlue.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: secondaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Jump directly to important sections',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _quickActionButton(
                title: 'Owners',
                icon: Icons.people_outline,
                color: secondaryBlue,
                onTap: () => widget.onNavigate(4),
              ),
              _quickActionButton(
                title: 'Walkers',
                icon: Icons.badge_outlined,
                color: success,
                onTap: () => widget.onNavigate(5),
              ),
              _quickActionButton(
                title: 'Active Walks',
                icon: Icons.directions_walk_outlined,
                color: primaryOrange,
                onTap: () => widget.onNavigate(2),
              ),
              _quickActionButton(
                title: 'Walk History',
                icon: Icons.history_outlined,
                color: textSecondary,
                onTap: () => widget.onNavigate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: .15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW PANELS
  // ============================================================

  Widget _overviewPanels() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              _activeWalkPanel(),
              const SizedBox(height: 14),
              _recentActivityPanel(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _activeWalkPanel(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _recentActivityPanel(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ACTIVE WALKS PANEL
  // ============================================================

  Widget _activeWalkPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataPanel(
            title: 'Active Walks',
            icon: Icons.directions_walk_outlined,
            color: primaryOrange,
            child: const EmptyMessage(
              text: 'Unable to load active walks.',
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return DataPanel(
            title: 'Active Walks',
            icon: Icons.directions_walk_outlined,
            color: primaryOrange,
            child: const _PanelLoading(),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return DataPanel(
          title: 'Active Walks',
          icon: Icons.directions_walk_outlined,
          color: primaryOrange,
          child: docs.isEmpty
              ? const EmptyMessage(
                  text: 'No active walks right now.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 4 ? 4 : docs.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 18,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
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
    final walkerUid = _firstString(
      data,
      ['walkerUid', 'walkerId'],
    );

    final ownerUid = _firstString(
      data,
      ['ownerId'],
    );

    final walkerName = _firstString(
      data,
      ['walkerName'],
    );

    final ownerName = _firstString(
      data,
      ['ownerName'],
    );

    final dogName = _firstString(
      data,
      ['dogName'],
    );

    final distance = _firstValue(
          data,
          ['distanceKm'],
        ) ??
        '0';

    final duration = _firstValue(
          data,
          ['durationMinutes'],
        ) ??
        '0';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => widget.onNavigate(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 2,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.pets,
                  color: primaryOrange,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      walkerName ??
                          (walkerUid != null
                              ? 'Walker ${_shortId(walkerUid)}'
                              : 'Active Walk'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ownerName ??
                          (ownerUid != null
                              ? 'Owner ${_shortId(ownerUid)}'
                              : 'Live walk'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                    if (dogName != null)
                      Text(
                        dogName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$distance km',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$duration min',
                    style: const TextStyle(
                      fontSize: 10,
                      color: textSecondary,
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

  // ============================================================
  // RECENT ACTIVITY PANEL
  // ============================================================

  Widget _recentActivityPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataPanel(
            title: 'Recent Activity',
            icon: Icons.history_outlined,
            color: secondaryBlue,
            child: const EmptyMessage(
              text: 'Unable to load recent activity.',
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return DataPanel(
            title: 'Recent Activity',
            icon: Icons.history_outlined,
            color: secondaryBlue,
            child: const _PanelLoading(),
          );
        }

        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        return DataPanel(
          title: 'Recent Activity',
          icon: Icons.history_outlined,
          color: secondaryBlue,
          child: docs.isEmpty
              ? const EmptyMessage(
                  text: 'No recent activity.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 4 ? 4 : docs.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 18,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
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
        _readString(data, 'dogName') ?? 'Dog';

    final walkerName =
        _readString(data, 'walkerName') ?? 'Walker';

    final distance =
        _firstValue(
              data,
              ['distanceKm'],
            ) ??
            '0';

    final duration =
        _firstValue(
              data,
              ['durationMinutes'],
            ) ??
            '0';

    final rating = _readInt(
      data,
      'rating',
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => widget.onNavigate(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 2,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: secondaryBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.history,
                  color: secondaryBlue,
                  size: 19,
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
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      walkerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '$duration min',
                    style: const TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                  if (rating != null)
                    Text(
                      '★ $rating',
                      style: const TextStyle(
                        fontSize: 10,
                        color: primaryOrange,
                        fontWeight: FontWeight.w800,
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

  // ============================================================
  // FINANCE TAB
  // ============================================================

  Widget _financeTab(bool isMobile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _financeHero(isMobile),
          const SizedBox(height: 16),
          _financeCards(),
          const SizedBox(height: 16),
          _financeActions(),
        ],
      ),
    );
  }

  Widget _financeHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryBlue,
            secondaryBlue.withValues(alpha: .88),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finance Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage payments, payouts and platform revenue.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
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
          childAspectRatio: columns == 1 ? 3.2 : 1.9,
          children: [
            _financeCard(
              title: 'Payments',
              subtitle: 'Payment management',
              icon: Icons.payments_outlined,
              color: secondaryBlue,
              index: 9,
            ),
            _financeCard(
              title: 'Payouts',
              subtitle: 'Walker payouts',
              icon: Icons.currency_rupee_rounded,
              color: success,
              index: 10,
            ),
            _financeCard(
              title: 'Finance',
              subtitle: 'Financial reports',
              icon: Icons.analytics_outlined,
              color: primaryOrange,
              index: 8,
            ),
          ],
        );
      },
    );
  }

  Widget _financeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return _HoverCard(
      onTap: () => widget.onNavigate(index),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _financeActions() {
    return DataPanel(
      title: 'Finance Actions',
      icon: Icons.flash_on_rounded,
      color: primaryOrange,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _outlineAction(
            'Open Payments',
            Icons.payments_outlined,
            secondaryBlue,
            () => widget.onNavigate(9),
          ),
          _outlineAction(
            'Open Payouts',
            Icons.currency_rupee_rounded,
            success,
            () => widget.onNavigate(10),
          ),
          _outlineAction(
            'Finance Reports',
            Icons.analytics_outlined,
            primaryOrange,
            () => widget.onNavigate(8),
          ),
        ],
      ),
    );
  }

  Widget _outlineAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: color.withValues(alpha: .20),
            ),
            color: color.withValues(alpha: .04),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIVE WALKS TAB
  // ============================================================

  Widget _liveWalksTab(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardLiveMap(
                activeWalksStream: _activeWalksStream,
              ),
              const SizedBox(height: 18),
              DataPanel(
                title: 'Active Walks',
                icon: Icons.directions_walk_outlined,
                color: primaryOrange,
                child: snapshot.hasError
                    ? const EmptyMessage(
                        text: 'Unable to load live walks.',
                      )
                    : snapshot.connectionState ==
                            ConnectionState.waiting
                        ? const _PanelLoading()
                        : docs.isEmpty
                            ? const EmptyMessage(
                                text:
                                    'Live walks will appear here.',
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(
                                  color: borderColor,
                                ),
                                itemBuilder: (context, index) {
                                  return _liveWalkDetailedRow(
                                    docs[index].data(),
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
        _readString(data, 'ownerId') ?? '-';

    final walkerUid =
        _firstString(
              data,
              ['walkerUid', 'walkerId'],
            ) ??
            '-';

    final ownerName =
        _readString(data, 'ownerName');

    final walkerName =
        _readString(data, 'walkerName');

    final dogName =
        _readString(data, 'dogName');

    final distance =
        _firstValue(
              data,
              ['distanceKm'],
            ) ??
            '-';

    final duration =
        _firstValue(
              data,
              ['durationMinutes'],
            ) ??
            '-';

    final pee =
        _firstInt(
              data,
              ['peeCount'],
            ) ??
            0;

    final poop =
        _firstInt(
              data,
              ['poopCount'],
            ) ??
            0;

    final status =
        _readString(data, 'status') ??
            'active';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onNavigate(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 4,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.pets,
                  color: primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      walkerName ??
                          'Walker ${_shortId(walkerUid)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ownerName ??
                          'Owner ${_shortId(ownerUid)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                    if (dogName != null)
                      Text(
                        dogName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: textSecondary,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _miniBadge(
                          status.toUpperCase(),
                          success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$distance km • $duration min',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pee $pee',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Poop $poop',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY TAB
  // ============================================================

  Widget _recentActivityTab(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: DataPanel(
            title: 'Recent Activity',
            icon: Icons.history_outlined,
            color: secondaryBlue,
            child: snapshot.hasError
                ? const EmptyMessage(
                    text:
                        'Unable to load recent activity.',
                  )
                : snapshot.connectionState ==
                        ConnectionState.waiting
                    ? const _PanelLoading()
                    : docs.isEmpty
                        ? const EmptyMessage(
                            text:
                                'Recent platform activity will appear here.',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(
                              color: borderColor,
                            ),
                            itemBuilder: (context, index) {
                              return _historyDetailedRow(
                                docs[index].data(),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }

  Widget _historyDetailedRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(data, 'dogName') ?? 'Dog';

    final walkerName =
        _readString(data, 'walkerName') ?? 'Walker';

    final ownerName =
        _readString(data, 'ownerName');

    final date =
        _readString(data, 'date');

    final distance =
        _firstDouble(
          data,
          ['distanceKm'],
        );

    final duration =
        _firstDouble(
          data,
          ['durationMinutes'],
        );

    final rating =
        _readInt(data, 'rating');

    final dogPhoto =
        _readString(data, 'dogPhoto');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onNavigate(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 4,
          ),
          child: Row(
            children: [
              photoAvatar(
                imageUrl: dogPhoto,
                icon: Icons.pets,
                color: secondaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dogName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      walkerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                    if (ownerName != null)
                      Text(
                        ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: textSecondary,
                        ),
                      ),
                    if (date != null && date.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  if (distance != null)
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  if (duration != null)
                    Text(
                      '${duration.toStringAsFixed(0)} min',
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                  if (rating != null)
                    Text(
                      '★ $rating',
                      style: const TextStyle(
                        fontSize: 10,
                        color: primaryOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIRESTORE HELPERS
  // ============================================================

  String? _readString(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  String? _firstString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readString(
        data,
        key,
      );

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  dynamic _firstExistingValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (data.containsKey(key) &&
          data[key] != null) {
        return data[key];
      }
    }

    return null;
  }

  String? _firstValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    final value = _firstExistingValue(
      data,
      keys,
    );

    return value?.toString();
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
      return double.tryParse(value);
    }

    return null;
  }

  double? _firstDouble(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readDouble(
        data,
        key,
      );

      if (value != null) {
        return value;
      }
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
      return int.tryParse(value);
    }

    return null;
  }

  int? _firstInt(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readInt(
        data,
        key,
      );

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  // ============================================================
  // DATE
  // ============================================================

  DateTime? _toDateTime(
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

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // HISTORY SORT
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _sortedHistoryDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>?
        docs,
  ) {
    final result =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      docs ?? const [],
    );

    result.sort(
      (a, b) {
        final aDate = _toDateTime(
          _firstExistingValue(
            a.data(),
            [
              'completedAt',
              'startedAt',
              'createdAt',
            ],
          ),
        );

        final bDate = _toDateTime(
          _firstExistingValue(
            b.data(),
            [
              'completedAt',
              'startedAt',
              'createdAt',
            ],
          ),
        );

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

    return result;
  }

  // ============================================================
  // ID
  // ============================================================

  String _shortId(
    String value,
  ) {
    if (value.length <= 10) {
      return value;
    }

    return '${value.substring(0, 6)}...';
  }
}

// ================================================================
// HOVER CARD
// ================================================================

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() {
            _hovered = true;
          });
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _hovered = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hovered ? -2.0 : 0.0,
          ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PANEL LOADING
// ================================================================

class _PanelLoading extends StatelessWidget {
  const _PanelLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 90,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: _DashboardScreenState.secondaryBlue,
          ),
        ),
      ),
    );
  }
}
