import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});

  @override
  State<WalkHistoryScreen> createState() =>
      _WalkHistoryScreenState();
}

class _WalkHistoryScreenState
    extends State<WalkHistoryScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<WalkHistoryData> walks = const [
    WalkHistoryData(
      walkId: 'WALK-1001',
      ownerName: 'Owner 01',
      walkerName: 'Walker 01',
      petName: 'Buddy',
      date: '14 Aug 2026',
      duration: '32 min',
      distance: '2.4 km',
      amount: '₹250',
      status: 'Completed',
    ),
    WalkHistoryData(
      walkId: 'WALK-1002',
      ownerName: 'Owner 02',
      walkerName: 'Walker 02',
      petName: 'Max',
      date: '14 Aug 2026',
      duration: '28 min',
      distance: '2.1 km',
      amount: '₹220',
      status: 'Completed',
    ),
    WalkHistoryData(
      walkId: 'WALK-1003',
      ownerName: 'Owner 03',
      walkerName: 'Walker 03',
      petName: 'Rocky',
      date: '13 Aug 2026',
      duration: '25 min',
      distance: '1.9 km',
      amount: '₹200',
      status: 'Completed',
    ),
    WalkHistoryData(
      walkId: 'WALK-1004',
      ownerName: 'Owner 04',
      walkerName: 'Walker 04',
      petName: 'Bruno',
      date: '13 Aug 2026',
      duration: '18 min',
      distance: '1.2 km',
      amount: '₹150',
      status: 'Cancelled',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WalkHistoryData> get filteredWalks {
    final query =
        searchController.text.trim().toLowerCase();

    return walks.where((walk) {
      final matchesSearch =
          query.isEmpty ||
          walk.walkId.toLowerCase().contains(query) ||
          walk.ownerName.toLowerCase().contains(query) ||
          walk.walkerName.toLowerCase().contains(query) ||
          walk.petName.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          walk.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final completed = walks
        .where((w) => w.status == 'Completed')
        .length;

    final cancelled = walks
        .where((w) => w.status == 'Cancelled')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(
          completed,
          cancelled,
        ),

        const SizedBox(height: 20),

        _toolbar(),

        const SizedBox(height: 16),

        _historyList(),
      ],
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Walk History',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'View and manage all past walks',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _summaryCards(
    int completed,
    int cancelled,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 550
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 2.5,
          children: [
            _SummaryCard(
              title: 'Completed',
              value: '$completed',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Cancelled',
              value: '$cancelled',
              icon: Icons.cancel_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total History',
              value: '${walks.length}',
              icon: Icons.history,
              color: dojoBlue,
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // TOOLBAR
  // ==========================================================

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
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
              _filters(),
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
            'Search walk, owner, walker or pet...',
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
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
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
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('Completed'),
        _filterButton('Cancelled'),
      ],
    );
  }

  Widget _filterButton(String title) {
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
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
            color:
                selected ? Colors.white : dojoDark,
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HISTORY LIST
  // ==========================================================

  Widget _historyList() {
    final list = filteredWalks;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((walk) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 12),
          child: _historyCard(walk),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // HISTORY CARD
  // ==========================================================

  Widget _historyCard(WalkHistoryData walk) {
    final completed =
        walk.status == 'Completed';

    final statusColor =
        completed ? dojoGreen : dojoOrange;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(
              walk,
              statusColor,
            );
          }

          return _desktopCard(
            walk,
            statusColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    WalkHistoryData walk,
    Color statusColor,
  ) {
    return Row(
      children: [
        _petAvatar(),

        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _mainInfo(walk),
        ),

        Expanded(
          child: _info(
            Icons.calendar_today_outlined,
            'Date',
            walk.date,
          ),
        ),

        Expanded(
          child: _info(
            Icons.timer_outlined,
            'Duration',
            walk.duration,
          ),
        ),

        Expanded(
          child: _info(
            Icons.route_outlined,
            'Distance',
            walk.distance,
          ),
        ),

        Expanded(
          child: _info(
            Icons.currency_rupee,
            'Amount',
            walk.amount,
          ),
        ),

        _statusChip(
          walk.status,
          statusColor,
        ),

        const SizedBox(width: 12),

        _viewButton(walk),
      ],
    );
  }

  Widget _mobileCard(
    WalkHistoryData walk,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _petAvatar(),

            const SizedBox(width: 12),

            Expanded(
              child: _mainInfo(walk),
            ),

            _statusChip(
              walk.status,
              statusColor,
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _info(
                Icons.calendar_today_outlined,
                'Date',
                walk.date,
              ),
            ),
            Expanded(
              child: _info(
                Icons.timer_outlined,
                'Duration',
                walk.duration,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _info(
                Icons.route_outlined,
                'Distance',
                walk.distance,
              ),
            ),
            Expanded(
              child: _info(
                Icons.currency_rupee,
                'Amount',
                walk.amount,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _viewButton(walk),
        ),
      ],
    );
  }

  Widget _petAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 25,
      ),
    );
  }

  Widget _mainInfo(
    WalkHistoryData walk,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          walk.walkId,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          walk.petName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${walk.ownerName} • ${walk.walkerName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
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
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
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
        color: color.withOpacity(.09),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(
    WalkHistoryData walk,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showDetails(walk);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showDetails(
    WalkHistoryData walk,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.history,
                color: dojoOrange,
              ),
              const SizedBox(width: 9),
              Text(
                walk.walkId,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Owner',
                walk.ownerName,
              ),
              _detailRow(
                'Walker',
                walk.walkerName,
              ),
              _detailRow(
                'Pet',
                walk.petName,
              ),
              _detailRow(
                'Date',
                walk.date,
              ),
              _detailRow(
                'Duration',
                walk.duration,
              ),
              _detailRow(
                'Distance',
                walk.distance,
              ),
              _detailRow(
                'Amount',
                walk.amount,
              ),
              _detailRow(
                'Status',
                walk.status,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walk history found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Completed walks will appear here.',
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

// ============================================================
// MODEL
// ============================================================

class WalkHistoryData {
  final String walkId;
  final String ownerName;
  final String walkerName;
  final String petName;
  final String date;
  final String duration;
  final String distance;
  final String amount;
  final String status;

  const WalkHistoryData({
    required this.walkId,
    required this.ownerName,
    required this.walkerName,
    required this.petName,
    required this.date,
    required this.duration,
    required this.distance,
    required this.amount,
    required this.status,
  });
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
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
            decoration: BoxDecoration(
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
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
