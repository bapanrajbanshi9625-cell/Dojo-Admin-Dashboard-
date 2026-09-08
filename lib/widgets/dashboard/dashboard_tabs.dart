import 'package:flutter/material.dart';

import 'dashboard_components.dart';

class DashboardTabs extends StatelessWidget {
  final TabController controller;

  const DashboardTabs({
    super.key,
    required this.controller,
  });

  static const List<String> tabs = [
    'Overview',
    'Finance',
    'Live Walks',
    'Recent Activity',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      height: isMobile ? 50 : 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isMobile,
        tabAlignment:
            isMobile ? TabAlignment.start : TabAlignment.fill,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 12,
        ),
        indicator: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: blue.withValues(alpha: 0.18),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: grey,
        splashBorderRadius: BorderRadius.circular(10),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return blue.withValues(alpha: 0.08);
            }

            if (states.contains(WidgetState.hovered)) {
              return blue.withValues(alpha: 0.05);
            }

            return null;
          },
        ),
        labelStyle: TextStyle(
          fontSize: isMobile ? 11.5 : 12,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isMobile ? 11.5 : 12,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
        tabs: const [
          Tab(
            text: 'Overview',
          ),
          Tab(
            text: 'Finance',
          ),
          Tab(
            text: 'Live Walks',
          ),
          Tab(
            text: 'Recent Activity',
          ),
        ],
      ),
    );
  }
}
