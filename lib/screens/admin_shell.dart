import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'live_walk_screen.dart';
import 'walk_requests_screen.dart';
import 'active_walks_screen.dart';
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

import '../features/walk_history/screens/walk_history_screen.dart';

// =============================================================
// DOJO ADMIN COLORS
// =============================================================

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

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
    title: 'Active Walks',
    icon: Icons.directions_walk_outlined,
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

  // Menu default CLOSED.
  bool menuOpen = false;

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
      // =======================================================
      // 0 - DASHBOARD
      // =======================================================

      case 0:
        return DashboardScreen(
          onNavigate: selectPage,
        );

      // =======================================================
      // 1 - LIVE WALK SESSIONS
      // File:
      // lib/screens/live_walk_screen.dart
      // =======================================================

      case 1:
        return const LiveWalkScreen();

      // =======================================================
      // 2 - WALK REQUESTS
      // =======================================================

      case 2:
        return const WalkRequestsScreen();

      // =======================================================
      // 3 - ACTIVE WALKS
      // =======================================================

      case 3:
        return const ActiveWalksScreen();

      // =======================================================
      // 4 - WALK HISTORY
      // =======================================================

      case 4:
        return const WalkHistoryScreen();

      // =======================================================
      // 5 - OWNERS
      // =======================================================

      case 5:
        return const OwnersScreen();

      // =======================================================
      // 6 - WALKERS
      // =======================================================

      case 6:
        return const WalkersScreen();

      // =======================================================
      // 7 - PETS
      // =======================================================

      case 7:
        return const PetsScreen();

      // =======================================================
      // 8 - FINANCE
      // =======================================================

      case 8:
        return const FinanceScreen();

      // =======================================================
      // 9 - PAYMENTS
      // =======================================================

      case 9:
        return const PaymentsScreen();

      // =======================================================
      // 10 - PAYOUTS
      // =======================================================

      case 10:
        return const PayoutsScreen();

      // =======================================================
      // 11 - REVIEWS
      // =======================================================

      case 11:
        return const ReviewsScreen();

      // =======================================================
      // 12 - COMPLAINTS
      // =======================================================

      case 12:
        return const complaints.ComplaintsScreen();

      // =======================================================
      // 13 - SUPPORT
      // =======================================================

      case 13:
        return const SupportScreen();

      // =======================================================
      // 14 - NOTIFICATIONS
      // =======================================================

      case 14:
        return const NotificationsScreen();

      // =======================================================
      // 15 - ADMINS
      // =======================================================

      case 15:
        return const admins.AdminsScreen();

      // =======================================================
      // 16 - ACTIVITY LOGS
      // =======================================================

      case 16:
        return const ActivityLogsScreen();

      // =======================================================
      // 17 - SETTINGS
      // =======================================================

      case 17:
        return const SettingsScreen();

      default:
        return DashboardScreen(
          onNavigate: selectPage,
        );
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

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

  // =============================================================
  // DESKTOP
  // =============================================================

  Widget desktopLayout() {
    return Scaffold(
      backgroundColor: dojoBackground,
      body: Stack(
        children: [
          Column(
            children: [
              webTopBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(26),
                  child: currentScreen(),
                ),
              ),
            ],
          ),

          if (menuOpen) desktopDrawer(),
        ],
      ),
    );
  }

  // =============================================================
  // DESKTOP TOP BAR
  // =============================================================

  Widget webTopBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
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
          // MENU
          IconButton(
            tooltip: 'Menu',
            onPressed: toggleMenu,
            icon: const Icon(
              Icons.menu,
              color: dojoDark,
              size: 25,
            ),
          ),

          const SizedBox(width: 8),

          // PAGE TITLE
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: dojoDark,
            ),
          ),

          const Spacer(),

          // NOTIFICATIONS
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              selectPage(14);
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: dojoGrey,
            ),
          ),

          const SizedBox(width: 4),

          // PROFILE
          _profileMenu(
            compact: true,
          ),
        ],
      ),
    );
  }

  // =============================================================
  // DESKTOP DRAWER
  // =============================================================

  Widget desktopDrawer() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(
          alpha: 0.18,
        ),
        child: Row(
          children: [
            Container(
              width: 245,
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
                    const SizedBox(height: 20),

                    brand(),

                    const SizedBox(height: 22),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        itemCount: adminMenuItems.length,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) {
                          return menuItem(
                            index,
                            adminMenuItems[index],
                          );
                        },
                      ),
                    ),

                    const Divider(
                      height: 1,
                    ),

                    adminProfile(),
                  ],
                ),
              ),
            ),

            // OUTSIDE AREA
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: closeMenu,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // BRAND
  // =============================================================

  Widget brand() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: dojoOrange,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 10),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOJO',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: dojoDark,
                ),
              ),
              Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: dojoGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // MENU ITEM
  // =============================================================

  Widget menuItem(
    int index,
    AdminMenuItem item,
  ) {
    final bool active = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 3,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFFEEE9)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 24,
        leading: Icon(
          item.icon,
          size: 20,
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
                : FontWeight.w500,
            color: active
                ? dojoOrange
                : dojoDark,
          ),
        ),
        onTap: () {
          selectPage(index);
        },
      ),
    );
  }

  // =============================================================
  // ADMIN PROFILE
  // =============================================================

  Widget adminProfile() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFFFEEE9),
            child: Icon(
              Icons.person_outline,
              color: dojoOrange,
              size: 21,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  adminName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: dojoDark,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  adminRole,
                  style: const TextStyle(
                    fontSize: 10,
                    color: dojoGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // MOBILE
  // =============================================================

  Widget mobileLayout() {
    return Scaffold(
      backgroundColor: dojoBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        // MENU BUTTON
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: toggleMenu,
          icon: const Icon(
            Icons.menu,
            color: dojoDark,
          ),
        ),

        // TITLE
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: dojoOrange,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.pets,
                color: Colors.white,
                size: 19,
              ),
            ),

            const SizedBox(width: 9),

            Flexible(
              child: Text(
                pageTitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: dojoDark,
                ),
              ),
            ),
          ],
        ),

        // ONLY NOTIFICATION + PROFILE
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              selectPage(14);
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: dojoGrey,
            ),
          ),

          _profileMenu(),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: currentScreen(),
          ),

          if (menuOpen) mobileDrawer(),
        ],
      ),
    );
  }

  // =============================================================
  // MOBILE DRAWER
  // =============================================================

  Widget mobileDrawer() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(
          alpha: 0.18,
        ),
        child: Row(
          children: [
            Container(
              width: 285,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    brand(),

                    const SizedBox(height: 18),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        itemCount: adminMenuItems.length,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) {
                          return menuItem(
                            index,
                            adminMenuItems[index],
                          );
                        },
                      ),
                    ),

                    const Divider(
                      height: 1,
                    ),

                    adminProfile(),
                  ],
                ),
              ),
            ),

            // OUTSIDE AREA
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: closeMenu,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PROFILE MENU
  // =============================================================

  Widget _profileMenu({
    bool compact = false,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Admin Profile',
      offset: const Offset(
        0,
        48,
      ),
      elevation: 10,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      onSelected: (value) {
        if (value == 'login') {
          _handleLogin();
        }

        if (value == 'logout') {
          _handleLogout();
        }
      },

      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: SizedBox(
              width: 245,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFFFFEEE9),
                    child: const Icon(
                      Icons.person_outline,
                      color: dojoOrange,
                      size: 24,
                    ),
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
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                            color: dojoDark,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          adminRole,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w600,
                            color: dojoOrange,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const PopupMenuDivider(),

          PopupMenuItem<String>(
            value: 'login',
            child: Row(
              children: [
                Icon(
                  Icons.login_outlined,
                  size: 20,
                  color: dojoBlue,
                ),

                const SizedBox(width: 11),

                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(
                  Icons.logout_outlined,
                  size: 20,
                  color: dojoOrange,
                ),

                const SizedBox(width: 11),

                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ];
      },

      child: compact
          ? Container(
              height: 40,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: dojoBackground,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: dojoBorder,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        Color(0xFFFFEEE9),
                    child: Icon(
                      Icons.person_outline,
                      color: dojoOrange,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 8),

                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 110,
                    ),
                    child: Text(
                      adminName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Padding(
              padding: EdgeInsets.only(
                left: 4,
                right: 8,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                    Color(0xFFFFEEE9),
                child: Icon(
                  Icons.person_outline,
                  color: dojoOrange,
                  size: 21,
                ),
              ),
            ),
    );
  }

  // =============================================================
  // LOGIN
  // =============================================================

  void _handleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Admin login is already active.',
        ),
      ),
    );
  }

  // =============================================================
  // LOGOUT
  // =============================================================

  Future<void> _handleLogout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
          ),
          content: const Text(
            'Are you sure you want to sign out?',
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
}
