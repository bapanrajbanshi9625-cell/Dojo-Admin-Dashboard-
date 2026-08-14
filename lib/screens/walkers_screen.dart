import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkersScreen extends StatefulWidget {
  const WalkersScreen({super.key});

  @override
  State<WalkersScreen> createState() => _WalkersScreenState();
}

class _WalkersScreenState extends State<WalkersScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<WalkerData> walkers = const [
    WalkerData(
      id: 'WKR-001',
      name: 'Walker 01',
      phone: '+91 91000 00001',
      email: 'walker01@example.com',
      walks: 32,
      rating: 4.8,
      status: 'Online',
      activeWalks: 1,
    ),
    WalkerData(
      id: 'WKR-002',
      name: 'Walker 02',
      phone: '+91 91000 00002',
      email: 'walker02@example.com',
      walks: 24,
      rating: 4.6,
      status: 'Online',
      activeWalks: 0,
    ),
    WalkerData(
      id: 'WKR-003',
      name: 'Walker 03',
      phone: '+91 91000 00003',
      email: 'walker03@example.com',
      walks: 41,
      rating: 4.9,
      status: 'Offline',
      activeWalks: 0,
    ),
    WalkerData(
      id: 'WKR-004',
      name: 'Walker 04',
      phone: '+91 91000 00004',
      email: 'walker04@example.com',
      walks: 15,
      rating: 4.4,
      status: 'Offline',
      activeWalks: 0,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WalkerData> get filteredWalkers {
    final query = searchController.text.trim().toLowerCase();

    return walkers.where((walker) {
      final matchesSearch =
          query.isEmpty ||
          walker.id.toLowerCase().contains(query) ||
          walker.name.toLowerCase().contains(query) ||
          walker.phone.toLowerCase().contains(query) ||
          walker.email.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          walker.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final online = walkers
        .where((walker) => walker.status == 'Online')
        .length;

    final offline = walkers
        .where((walker) => walker.status == 'Offline')
        .length;

    final activeWalks = walkers.fold<int>(
      0,
      (sum, walker) => sum + walker.activeWalks,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summaryCards(
          online,
          offline,
          activeWalks,
        ),
        const SizedBox(height: 20),
        _toolbar(),
        const SizedBox(height: 16),
        _walkerList(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Walkers',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage DOJO walkers and their activity',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summaryCards(
    int online,
    int offline,
    int activeWalks,
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
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.5,
          children: [
            _SummaryCard(
              title: 'Online Walkers',
              value: '$online',
              icon: Icons.wifi,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Offline Walkers',
              value: '$offline',
              icon: Icons.wifi_off,
              color: dojoGrey,
            ),
            _SummaryCard(
              title: 'Active Walks',
              value: '$activeWalks',
              icon: Icons.directions_walk_outlined,
              color: dojoOrange,
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
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
              Expanded(child: _searchBox()),
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
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search walker, phone or email...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 18),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoOrange),
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
        _filterButton('Online'),
        _filterButton('Offline'),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? dojoOrange : dojoBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : dojoDark,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _walkerList() {
    final list = filteredWalkers;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((walker) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _walkerCard(walker),
        );
      }).toList(),
    );
  }

  Widget _walkerCard(WalkerData walker) {
    final online = walker.status == 'Online';
    final statusColor = online ? dojoGreen : dojoGrey;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(walker, statusColor);
          }

          return _desktopCard(walker, statusColor);
        },
      ),
    );
  }

  Widget _desktopCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(walker.status),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(walker),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            walker.phone,
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${walker.walks}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            walker.rating.toStringAsFixed(1),
          ),
        ),
        _statusChip(
          walker.status,
          statusColor,
        ),
        const SizedBox(width: 12),
        _viewButton(walker),
      ],
    );
  }

  Widget _mobileCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(walker.status),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(walker),
            ),
            _statusChip(
              walker.status,
              statusColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.phone_outlined,
                'Phone',
                walker.phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${walker.walks}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.star_outline,
                'Rating',
                walker.rating.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _info(
                Icons.play_circle_outline,
                'Active Walks',
                '${walker.activeWalks}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(walker),
        ),
      ],
    );
  }

  Widget _avatar(String status) {
    final online = status == 'Online';

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0F7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: dojoBlue,
            size: 26,
          ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: online ? dojoGreen : dojoGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainInfo(WalkerData walker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          walker.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.email,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
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

  Widget _viewButton(WalkerData walker) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkerDetails(walker);
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
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  void _showWalkerDetails(WalkerData walker) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: dojoBlue,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  walker.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Walker ID', walker.id),
              _detailRow('Phone', walker.phone),
              _detailRow('Email', walker.email),
              _detailRow('Walks', '${walker.walks}'),
              _detailRow(
                'Rating',
                walker.rating.toStringAsFixed(1),
              ),
              _detailRow(
                'Active Walks',
                '${walker.activeWalks}',
              ),
              _detailRow('Status', walker.status),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 82,
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

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walkers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walkers will appear here.',
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

class WalkerData {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int walks;
  final double rating;
  final String status;
  final int activeWalks;

  const WalkerData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.walks,
    required this.rating,
    required this.status,
    required this.activeWalks,
  });
}

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w900,
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
