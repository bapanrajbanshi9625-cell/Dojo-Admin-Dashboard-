import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'live_map_screen.dart';
import 'active_walks_screen.dart';
import 'walk_history_screen.dart';
import 'owners_screen.dart';
import 'walkers_screen.dart';
import 'pets_screen.dart';
import 'finance_screen.dart';
import 'payments_screen.dart';
import 'payouts_screen.dart';
import 'reviews_screen.dart';
import 'complaints_screen.dart';
import 'support_screen.dart';
import 'notifications_screen.dart';
import 'admins_screen.dart';
import 'activity_logs_screen.dart';
import 'settings_screen.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

class AdminMenuItem {
  final String title;
  final IconData icon;

  const AdminMenuItem({
    required this.title,
    required this.icon,
  });
}

const List<AdminMenuItem> adminMenuItems = [
  AdminMenuItem(
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
  ),
  AdminMenuItem(
    title: 'Live Map',
    icon: Icons.map_outlined,
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

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedIndex = 0;
  bool mobileMenuOpen = false;

  String get pageTitle {
    if (selectedIndex < 0 ||
        selectedIndex >= adminMenuItems.length) {
      return 'Dashboard';
    }

    return adminMenuItems[selectedIndex].title;
  }

  void selectPage(int index) {
    if (index < 0 || index >= adminMenuItems.length) {
      return;
    }

    setState(() {
      selectedIndex = index;
      mobileMenuOpen = false;
    });
  }

  Widget currentScreen() {
    switch (selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigate: selectPage,
        );

      case 1:
        return const LiveMapScreen();

      case 2:
        return const ActiveWalksScreen();

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
        return const ComplaintsScreen();

      case 12:
        return const SupportScreen();

      case 13:
        return const NotificationsScreen();

      case 14:
        return const AdminsScreen();

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

  Widget desktopLayout() {
    return Scaffold(
      backgroundColor: dojoBackground,
      body: Row(
        children: [
          desktopSidebar(),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget desktopSidebar() {
    return Container(
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
            const Divider(height: 1),
            adminProfile(),
          ],
        ),
      ),
    );
  }

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

  Widget menuItem(
    int index,
    AdminMenuItem item,
  ) {
    final bool active = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
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
          color: active ? dojoOrange : dojoGrey,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active
                ? FontWeight.w800
                : FontWeight.w500,
            color: active ? dojoOrange : dojoDark,
          ),
        ),
        onTap: () => selectPage(index),
      ),
    );
  }

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Administrator',
                  style: TextStyle(
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

  Widget webTopBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 26,
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
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: dojoDark,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => selectPage(13),
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: dojoGrey,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: dojoBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: dojoBorder,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFFFEEE9),
                  child: Icon(
                    Icons.person_outline,
                    color: dojoOrange,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mobileLayout() {
    return Scaffold(
      backgroundColor: dojoBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () {
            setState(() {
              mobileMenuOpen = !mobileMenuOpen;
            });
          },
          icon: const Icon(
            Icons.menu,
            color: dojoDark,
          ),
        ),
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
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => selectPage(13),
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: dojoGrey,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: currentScreen(),
          ),
          if (mobileMenuOpen) mobileDrawer(),
        ],
      ),
    );
  }

  Widget mobileDrawer() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(.18),
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
                    adminProfile(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    mobileMenuOpen = false;
                  });
                },
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
}
