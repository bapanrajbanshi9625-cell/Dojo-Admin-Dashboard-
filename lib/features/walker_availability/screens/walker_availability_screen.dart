import 'package:flutter/material.dart';

import '../services/walker_availability_service.dart';
import '../widgets/availability_tabs.dart';
import '../widgets/daily_walk_availability.dart';
import '../widgets/insta_walk_availability.dart';

class WalkerAvailabilityScreen extends StatefulWidget {
  const WalkerAvailabilityScreen({
    super.key,
  });

  @override
  State<WalkerAvailabilityScreen> createState() =>
      _WalkerAvailabilityScreenState();
}

class _WalkerAvailabilityScreenState
    extends State<WalkerAvailabilityScreen> {
  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF3F6FA5);

  final WalkerAvailabilityService _service =
      WalkerAvailabilityService();

  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: Column(
        children: [
          _buildHeader(),
          AvailabilityTabs(
            selectedIndex: _selectedTab,
            onChanged: _onTabChanged,
          ),
          Expanded(
            child: _selectedTab == 0
                ? InstaWalkAvailability(
                    service: _service,
                    searchQuery: _searchQuery,
                  )
                : DailyWalkAvailability(
                    service: _service,
                    searchQuery: _searchQuery,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Walker Availability',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTab == 0
                      ? 'Insta Walk availability'
                      : 'Daily Walk booked slots',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                _buildSearchField(),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Walker Availability',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monitor Insta Walk and Daily Walk availability',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: _buildSearchField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search walker ID or name',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: secondaryBlue,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primaryOrange,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  void _onTabChanged(int index) {
    if (_selectedTab == index) {
      return;
    }

    setState(() {
      _selectedTab = index;
      _searchQuery = '';
    });
  }
}
