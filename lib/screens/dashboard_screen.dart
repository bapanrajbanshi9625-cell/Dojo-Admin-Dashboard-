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
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    'Overview',
    'Finance',
    'Live Walks',
    'Recent Activity',
  ];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _dashboardTabs(),
        const SizedBox(height: 20),

        SizedBox(
          height: 850,
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
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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
  // DASHBOARD TABS
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
        tabs: tabs.map((tab) {
          return Tab(
            text: tab,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _overviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _mapContainer(),

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
  // MAP
  // ============================================================

  Widget _mapContainer() {
    return Container(
      height: 300,
      width: double.infinity,
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
              painter: DashboardMapPainter(),
            ),
          ),

          Positioned(
            top: 15,
            left: 15,
            child: _mapLabel(),
          ),

          const Positioned(
            left: 80,
            top: 90,
            child: _MapMarker(
              title: 'Walk 01',
            ),
          ),

          const Positioned(
            right: 100,
            top: 145,
            child: _MapMarker(
              title: 'Walk 02',
            ),
          ),

          const Positioned(
            left: 180,
            bottom: 55,
            child: _MapMarker(
              title: 'Walk 03',
            ),
          ),

          Positioned(
            right: 15,
            bottom: 15,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(.08),
                    blurRadius: 10,
                  ),
                ],
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
  }

  Widget _mapLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
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
      child: const Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: green,
          ),
          SizedBox(width: 7),
          Text(
            'Live Walk Map',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 1000) {
          columns = 4;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.3 : 2.2,
          children: const [
            _StatCard(
              title: 'Total Owners',
              value: '0',
              icon: Icons.people_outline,
              iconColor: blue,
            ),
            _StatCard(
              title: 'Total Walkers',
              value: '0',
              icon: Icons.badge_outlined,
              iconColor: green,
            ),
            _StatCard(
              title: 'Active Walks',
              value: '0',
              icon: Icons.directions_walk_outlined,
              iconColor: orange,
            ),
            _StatCard(
              title: 'Completed Walks',
              value: '0',
              icon: Icons.check_circle_outline,
              iconColor: green,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                title: 'Owners',
                icon: Icons.people_outline,
                color: blue,
                onTap: () {
                  widget.onNavigate(4);
                },
              ),
              _ActionButton(
                title: 'Walkers',
                icon: Icons.badge_outlined,
                color: green,
                onTap: () {
                  widget.onNavigate(5);
                },
              ),
              _ActionButton(
                title: 'Active Walks',
                icon:
                    Icons.directions_walk_outlined,
                color: orange,
                onTap: () {
                  widget.onNavigate(2);
                },
              ),
              _ActionButton(
                title: 'Walk History',
                icon: Icons.history_outlined,
                color: grey,
                onTap: () {
                  widget.onNavigate(3);
                },
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
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: const [
              _InfoPanel(
                title: 'Active Walks',
                icon:
                    Icons.directions_walk_outlined,
                color: orange,
                message:
                    'No active walks right now.',
              ),
              SizedBox(height: 14),
              _InfoPanel(
                title: 'Recent Activity',
                icon: Icons.history_outlined,
                color: blue,
                message:
                    'No recent activity.',
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: _InfoPanel(
                title: 'Active Walks',
                icon:
                    Icons.directions_walk_outlined,
                color: orange,
                message:
                    'No active walks right now.',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _InfoPanel(
                title: 'Recent Activity',
                icon: Icons.history_outlined,
                color: blue,
                message:
                    'No recent activity.',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FINANCE TAB
  // ============================================================

  Widget _financeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _financeStats(),

          const SizedBox(height: 18),

          _financePanel(
            title: 'Revenue Overview',
            icon: Icons.trending_up,
            color: green,
            text:
                'Revenue data will appear here after Firebase connection.',
          ),

          const SizedBox(height: 14),

          _financePanel(
            title: 'Pending Payouts',
            icon:
                Icons.account_balance_wallet_outlined,
            color: orange,
            text:
                'Pending walker payouts will appear here.',
          ),
        ],
      ),
    );
  }

  Widget _financeStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns =
            constraints.maxWidth >= 800 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3 : 2,
          children: const [
            _StatCard(
              title: 'Today Revenue',
              value: '₹0',
              icon: Icons.currency_rupee,
              iconColor: green,
            ),
            _StatCard(
              title: 'Total Payments',
              value: '₹0',
              icon: Icons.payments_outlined,
              iconColor: blue,
            ),
            _StatCard(
              title: 'Pending Payouts',
              value: '₹0',
              icon:
                  Icons.account_balance_wallet_outlined,
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
      padding: const EdgeInsets.all(20),
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
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _mapContainer(),

          const SizedBox(height: 18),

          const _InfoPanel(
            title: 'Active Walks',
            icon:
                Icons.directions_walk_outlined,
            color: orange,
            message:
                'Live walks will appear here.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY TAB
  // ============================================================

  Widget _recentActivityTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _InfoPanel(
            title: 'Recent Activity',
            icon: Icons.history_outlined,
            color: blue,
            message:
                'Recent platform activity will appear here.',
          ),

          const SizedBox(height: 14),

          const _InfoPanel(
            title: 'System Activity',
            icon: Icons.receipt_long_outlined,
            color: green,
            message:
                'System activity logs will appear here.',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
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
            decoration: BoxDecoration(
              color:
                  iconColor.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 13),

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
                  style: const TextStyle(
                    fontSize: 12,
                    color: grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
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

class _ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius:
              BorderRadius.circular(11),
          border: Border.all(
            color: color.withOpacity(.18),
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
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFO PANEL
// ============================================================

class _InfoPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String message;

  const _InfoPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.all(20),
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
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
}

// ============================================================
// MAP MARKER
// ============================================================

class _MapMarker extends StatelessWidget {
  final String title;

  const _MapMarker({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.10),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 4),

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
