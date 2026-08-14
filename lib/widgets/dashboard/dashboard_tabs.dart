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
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: TabBar(
        controller: controller,
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
        tabs: tabs.map((e) {
          return Tab(text: e);
        }).toList(),
      ),
    );
  }
}
