import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'owners_screen.dart';
import 'walkers_screen.dart';
import 'pets_screen.dart';
import 'finance_screen.dart';
import 'payments_screen.dart';
import 'payouts_screen.dart';
import 'reviews_screen.dart';
import 'complaints_screen.dart' as complaints;
import 'support_screen.dart';
import 'notifications_screen.dart';
import 'admins_screen.dart' as admins;
import 'activity_logs_screen.dart';
import 'settings_screen.dart';

import '../features/live_walk/screens/live_walk_screen.dart';
import '../features/walk_history/screens/walk_history_screen.dart';
import '../features/walk_requests/screens/walk_requests_screen.dart';

// =============================================================
// DOJO ADMIN DESIGN SYSTEM
// Primary  : Orange
// Secondary: Blue
// Style    : Light / Professional
// =============================================================

const Color dojoOrange = Color(0xFFD35435);
const Color dojoOrangeLight = Color(0xFFFFF0EB);

const Color dojoBlue = Color(0xFF2563EB);
const Color dojoBlueLight = Color(0xFFEFF6FF);

const Color dojoGreen = Color(0xFF16A34A);
const Color dojoGreenLight = Color(0xFFECFDF3);

const Color dojoRed = Color(0xFFDC2626);
const Color dojoRedLight = Color(0xFFFEF2F2);

const Color dojoYellow = Color(0xFFF59E0B);
const Color dojoYellowLight = Color(0xFFFFFBEB);

const Color dojoDark = Color(0xFF0F172A);
const Color dojoText = Color(0xFF334155);
const Color dojoGrey = Color(0xFF64748B);
const Color dojoMuted = Color(0xFF94A3B8);

const Color dojoBackground = Color(0xFFF8FAFC);
const Color dojoCard = Color(0xFFFFFFFF);
const Color dojoBorder = Color(0xFFE2E8F0);
const Color dojoDivider = Color(0xFFF1F5F9);

// =============================================================
// ADMIN MENU ITEM
// =============================================================

class AdminMenuItem {
  final String title;
  final IconData icon;

  const AdminMenuItem({
    required this.title,
    required this.icon,
  });
}

// =============================================================
// ADMIN MENU
// =============================================================

const List<AdminMenuItem> adminMenuItems = [
  AdminMenuItem(
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
  ),
  AdminMenuItem(
    title: 'Live Walk Sessions',
    icon: Icons.directions_walk_outlined,
  ),
  AdminMenuItem(
    title: 'Walk Requests',
    icon: Icons.assignment_outlined,
  ),
  AdminMenuItem(
    title: 'Walk History',
    icon: Icons.history_outlined,
  ),
  AdminMenuItem(
    title: 'Owners',
    icon: Icons.people_outline,
  ),
  AdminMenuItem(
    title: 'Walkers',
    icon: Icons.badge_outlined,
  ),
  AdminMenuItem(
    title: 'Pets',
    icon: Icons.pets_outlined,
  ),
  AdminMenuItem(
    title: 'Finance',
    icon: Icons.analytics_outlined,
  ),
  AdminMenuItem(
    title: 'Payments',
    icon: Icons.payments_outlined,
  ),
  AdminMenuItem(
    title: 'Payouts',
    icon: Icons.account_balance_wallet_outlined,
  ),
  AdminMenuItem(
    title: 'Reviews',
    icon: Icons.star_outline,
  ),
  AdminMenuItem(
    title: 'Complaints',
    icon: Icons.report_problem_outlined,
  ),
  AdminMenuItem(
    title: 'Support',
    icon: Icons.support_agent_outlined,
  ),
  AdminMenuItem(
    title: 'Notifications',
    icon: Icons.notifications_none_outlined,
  ),
  AdminMenuItem(
    title: 'Admins',
    icon: Icons.admin_panel_settings_outlined,
  ),
  AdminMenuItem(
    title: 'Activity Logs',
    icon: Icons.receipt_long_outlined,
  ),
  AdminMenuItem(
    title: 'Settings',
    icon: Icons.settings_outlined,
  ),
];

// =============================================================
// ADMIN SHELL
// =============================================================

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedIndex = 0;

  bool menuOpen = false;
  bool sidebarCollapsed = false;

  // ===========================================================
  // CURRENT ADMIN
  // ===========================================================

  User? get currentAdmin {
    return FirebaseAuth.instance.currentUser;
  }

  String get adminName {
    final user = currentAdmin;

    if (user == null) {
      return 'Admin';
    }

    final name = user.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user.email?.trim();

    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Admin';
  }

  String get adminEmail {
    final user = currentAdmin;

    if (user == null) {
      return 'No email';
    }

    final email = user.email?.trim();

    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'No email';
  }

  String get adminRole {
    return 'Super Admin';
  }

  String get pageTitle {
    if (selectedIndex < 0 ||
        selectedIndex >= adminMenuItems.length) {
      return 'Dashboard';
    }

    return adminMenuItems[selectedIndex].title;
  }

  // ===========================================================
  // NAVIGATION
  // ===========================================================

  void selectPage(int index) {
    if (index < 0 || index >= adminMenuItems.length) {
      return;
    }

    setState(() {
      selectedIndex = index;
      menuOpen = false;
    });
  }

  void toggleMenu() {
    setState(() {
      menuOpen = !menuOpen;
    });
  }

  void closeMenu() {
    if (!menuOpen) {
      return;
    }

    setState(() {
      menuOpen = false;
    });
  }

  // ===========================================================
  // CURRENT SCREEN
  // ===========================================================

  Widget currentScreen() {
    switch (selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigate: selectPage,
        );

      case 1:
        return const LiveWalkScreen();

      case 2:
        return const WalkRequestsScreen();

      case 3:
        return const WalkHistoryScreen();

      case 4:
        return const OwnersScreen();

      case 5:
        return const WalkersScreen();

      case 6:
        return const PetsScreen();

      case 7:
        return const FinanceScreen();

      case 8:
        return const PaymentsScreen();

      case 9:
        return const PayoutsScreen();

      case 10:
        return const ReviewsScreen();

      case 11:
        return const complaints.ComplaintsScreen();

      case 12:
        return const SupportScreen();

      case 13:
        return const NotificationsScreen();

      case 14:
        return const admins.AdminsScreen();

      case 15:
        return const ActivityLogsScreen();

      case 16:
        return const SettingsScreen();

      default:
        return DashboardScreen(
          onNavigate: selectPage,
        );
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        if (constraints.maxWidth < 800) {
          return mobileLayout();
        }

        return desktopLayout();
      },
    );
  }

  // ===========================================================
  // DESKTOP LAYOUT
  // ===========================================================
  // DO NOT CHANGE THIS SECTION
  // ===========================================================

  Widget desktopLayout() {
    final double sidebarWidth =
        sidebarCollapsed ? 78 : 258;

    return Scaffold(
      backgroundColor: dojoBackground,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: sidebarWidth,
            child: desktopSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                desktopTopBar(),
                Expanded(
                  child: Container(
                    color: dojoBackground,
                    padding: const EdgeInsets.all(24),
                    child: currentScreen(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DESKTOP SIDEBAR
  // ===========================================================

  Widget desktopSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: dojoBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            _desktopBrand(),

            const SizedBox(height: 22),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                children: [
                  if (!sidebarCollapsed)
                    _sectionLabel('OVERVIEW'),

                  _desktopMenuItem(0),
                  _desktopMenuItem(1),

                  if (!sidebarCollapsed)
                    _sectionLabel('OPERATIONS'),

                  _desktopMenuItem(2),
                  _desktopMenuItem(3),
                  _desktopMenuItem(4),
                  _desktopMenuItem(5),
                  _desktopMenuItem(6),

                  if (!sidebarCollapsed)
                    _sectionLabel('FINANCE'),

                  _desktopMenuItem(7),
                  _desktopMenuItem(8),
                  _desktopMenuItem(9),

                  if (!sidebarCollapsed)
                    _sectionLabel('TRUST & SAFETY'),

                  _desktopMenuItem(10),
                  _desktopMenuItem(11),
                  _desktopMenuItem(12),

                  if (!sidebarCollapsed)
                    _sectionLabel('SYSTEM'),

                  _desktopMenuItem(13),
                  _desktopMenuItem(14),
                  _desktopMenuItem(15),
                  _desktopMenuItem(16),
                ],
              ),
            ),

            _sidebarBottomProfile(),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // DESKTOP BRAND
  // ===========================================================

  Widget _desktopBrand() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sidebarCollapsed ? 12 : 18,
      ),
      child: Row(
        mainAxisAlignment: sidebarCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: dojoOrange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: dojoOrange.withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          if (!sidebarCollapsed) ...[
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'DOJO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: dojoDark,
                  ),
                ),
                Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: dojoBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================
  // SECTION LABEL
  // ===========================================================

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        13,
        12,
        13,
        7,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: dojoMuted,
        ),
      ),
    );
  }

  // ===========================================================
  // DESKTOP MENU ITEM
  // ===========================================================

  Widget _desktopMenuItem(int index) {
    final item = adminMenuItems[index];
    final bool active = selectedIndex == index;

    return Tooltip(
      message: sidebarCollapsed ? item.title : '',
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 3,
        ),
        decoration: BoxDecoration(
          color: active
              ? dojoOrangeLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            hoverColor: dojoBlueLight,
            onTap: () {
              selectPage(index);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sidebarCollapsed ? 0 : 12,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: sidebarCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: active
                        ? dojoOrange
                        : dojoGrey,
                  ),
                  if (!sidebarCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: active
                              ? dojoOrange
                              : dojoText,
                        ),
                      ),
                    ),
                    if (active)
                      Container(
                        width: 5,
                        height: 5,
                        decoration:
                            const BoxDecoration(
                          color: dojoOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // SIDEBAR BOTTOM PROFILE
  // ===========================================================

  Widget _sidebarBottomProfile() {
    return Container(
      padding: EdgeInsets.all(
        sidebarCollapsed ? 10 : 14,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: dojoDivider,
          ),
        ),
      ),
      child: sidebarCollapsed
          ? Center(
              child: _avatar(
                size: 38,
              ),
            )
          : Row(
              children: [
                _avatar(
                  size: 38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                          color: dojoDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        adminRole,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: dojoGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Account',
                  onPressed: _showProfileMenu,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: dojoGrey,
                  ),
                ),
              ],
            ),
    );
  }

  // ===========================================================
  // AVATAR
  // ===========================================================

  Widget _avatar({
    double size = 36,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dojoBlueLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD7E6FF),
        ),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.52,
        color: dojoBlue,
      ),
    );
  }

  // ===========================================================
  // DESKTOP TOP BAR
  // ===========================================================

  Widget desktopTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: dojoBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: sidebarCollapsed
                ? 'Expand sidebar'
                : 'Collapse sidebar',
            onPressed: () {
              setState(() {
                sidebarCollapsed =
                    !sidebarCollapsed;
              });
            },
            icon: Icon(
              sidebarCollapsed
                  ? Icons.menu_open_rounded
                  : Icons.menu_rounded,
              color: dojoDark,
              size: 23,
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 1,
            height: 28,
            color: dojoBorder,
          ),

          const SizedBox(width: 18),

          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dojoDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Dojo Admin / $pageTitle',
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
            ],
          ),

          const Spacer(),

          _desktopSearch(),

          const SizedBox(width: 10),

          _notificationButton(),

          const SizedBox(width: 8),

          _desktopProfileButton(),
        ],
      ),
    );
  }

  // ===========================================================
  // DESKTOP SEARCH
  // ===========================================================

  Widget _desktopSearch() {
    return Container(
      width: 220,
      height: 40,
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 19,
            color: dojoGrey,
          ),
          SizedBox(width: 8),
          Text(
            'Search...',
            style: TextStyle(
              fontSize: 12,
              color: dojoMuted,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(right: 9),
            child: Text(
              '⌘ K',
              style: TextStyle(
                fontSize: 9,
                color: dojoMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // NOTIFICATION BUTTON
  // ===========================================================

  Widget _notificationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () {
          selectPage(13);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dojoBackground,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: dojoBorder,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 21,
                color: dojoText,
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(
                    color: dojoOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // DESKTOP PROFILE BUTTON
  // ===========================================================

  Widget _desktopProfileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showProfileMenu,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dojoBorder,
            ),
          ),
          child: Row(
            children: [
              _avatar(
                size: 32,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 115,
                ),
                child: Text(
                  adminName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: dojoDark,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: dojoGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // MOBILE LAYOUT
  // ===========================================================
  // ONLY MOBILE MENU BEHAVIOR IS CHANGED
  // ===========================================================

  Widget mobileLayout() {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    final double drawerWidth =
        screenWidth < 360
            ? screenWidth * 0.88
            : 320;

    return Scaffold(
      backgroundColor: dojoBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // =================================================
            // MOBILE MAIN CONTENT
            // =================================================

            Column(
              children: [
                _mobileTopBar(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: currentScreen(),
                  ),
                ),
              ],
            ),

            // =================================================
            // MOBILE DRAWER
            // =================================================

            if (menuOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: closeMenu,
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.28,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: drawerWidth,
                child: Material(
                  color: Colors.white,
                  elevation: 20,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight:
                          Radius.circular(24),
                    ),
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
                              10,
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
                              const Expanded(
                                child: Text(
                                  'Admin Menu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: dojoDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: closeMenu,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: dojoDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(
                          child: ListView(
                            padding:
                                const EdgeInsets.fromLTRB(
                              12,
                              4,
                              12,
                              20,
                            ),
                            children: [
                              _mobileSection(
                                'OVERVIEW',
                              ),

                              _mobileMenuItem(0),
                              _mobileMenuItem(1),

                              _mobileSection(
                                'OPERATIONS',
                              ),

                              _mobileMenuItem(2),
                              _mobileMenuItem(3),
                              _mobileMenuItem(4),
                              _mobileMenuItem(5),
                              _mobileMenuItem(6),

                              _mobileSection(
                                'FINANCE',
                              ),

                              _mobileMenuItem(7),
                              _mobileMenuItem(8),
                              _mobileMenuItem(9),

                              _mobileSection(
                                'TRUST & SAFETY',
                              ),

                              _mobileMenuItem(10),
                              _mobileMenuItem(11),
                              _mobileMenuItem(12),

                              _mobileSection(
                                'SYSTEM',
                              ),

                              _mobileMenuItem(13),
                              _mobileMenuItem(14),
                              _mobileMenuItem(15),
                              _mobileMenuItem(16),

                              const SizedBox(height: 14),

                              _mobileAccountCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // MOBILE TOP BAR
  // ===========================================================

  Widget _mobileTopBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: dojoBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(10),
              onTap: toggleMenu,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dojoBackground,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: dojoBorder,
                  ),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: dojoDark,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dojoOrange,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  pageTitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dojo Admin',
                  style: TextStyle(
                    fontSize: 9,
                    color: dojoGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _mobileNotificationButton(),

          const SizedBox(width: 4),

          GestureDetector(
            onTap: _showProfileMenu,
            child: _avatar(
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // MOBILE NOTIFICATION
  // ===========================================================

  Widget _mobileNotificationButton() {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () {
        selectPage(13);
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: dojoText,
            size: 22,
          ),
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 7,
              height: 7,
              decoration:
                  const BoxDecoration(
                color: dojoOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // MOBILE SECTION
  // ===========================================================

  Widget _mobileSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        14,
        10,
        7,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: dojoMuted,
        ),
      ),
    );
  }

  // ===========================================================
  // MOBILE MENU ITEM
  // ===========================================================

  Widget _mobileMenuItem(int index) {
    final item = adminMenuItems[index];
    final bool active = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 3,
      ),
      decoration: BoxDecoration(
        color: active
            ? dojoOrangeLight
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(
          item.icon,
          size: 21,
          color: active
              ? dojoOrange
              : dojoGrey,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active
                ? FontWeight.w800
                : FontWeight.w600,
            color: active
                ? dojoOrange
                : dojoText,
          ),
        ),
        trailing: active
            ? const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: dojoOrange,
              )
            : const Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: dojoMuted,
              ),
        onTap: () {
          selectPage(index);
        },
      ),
    );
  }

  // ===========================================================
  // MOBILE ACCOUNT CARD
  // ===========================================================

  Widget _mobileAccountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          _avatar(
            size: 42,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  adminName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  adminRole,
                  style: const TextStyle(
                    fontSize: 10,
                    color: dojoBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: () {
              closeMenu();
              _showProfileMenu();
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // PROFILE MENU
  // ===========================================================

  void _showProfileMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dojoBorder,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    _avatar(
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                              color: dojoDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            adminEmail,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: dojoGrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Super Admin',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w700,
                              color: dojoOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(
                  color: dojoDivider,
                ),

                const SizedBox(height: 6),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: dojoBlue,
                  ),
                  title: const Text(
                    'Admin Settings',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: dojoMuted,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    selectPage(16);
                  },
                ),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: dojoRed,
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: dojoRed,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // LOGIN
  // ===========================================================

  void _handleLogin() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin is already logged in.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please use the Admin Login screen.',
        ),
      ),
    );
  }

  // ===========================================================
  // LOGOUT
  // ===========================================================

  Future<void> _handleLogout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: dojoDark,
            ),
          ),
          content: Text(
            'Sign out from $adminEmail?',
            style: const TextStyle(
              color: dojoGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dojoOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Sign Out',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signed out successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign out failed: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================
  // MOBILE / DESKTOP MENU COMPATIBILITY
  // ===========================================================

  void openMenu() {
    if (MediaQuery.of(context).size.width < 800) {
      toggleMenu();
    } else {
      setState(() {
        sidebarCollapsed = false;
      });
    }
  }
}
