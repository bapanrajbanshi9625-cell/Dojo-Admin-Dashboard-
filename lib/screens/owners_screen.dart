import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({super.key});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<OwnerData> owners = const [
    OwnerData(
      id: 'OWN-001',
      name: 'Owner 01',
      phone: '+91 90000 00001',
      email: 'owner01@example.com',
      pets: 2,
      walks: 18,
      status: 'Active',
    ),
    OwnerData(
      id: 'OWN-002',
      name: 'Owner 02',
      phone: '+91 90000 00002',
      email: 'owner02@example.com',
      pets: 1,
      walks: 12,
      status: 'Active',
    ),
    OwnerData(
      id: 'OWN-003',
      name: 'Owner 03',
      phone: '+91 90000 00003',
      email: 'owner03@example.com',
      pets: 3,
      walks: 27,
      status: 'Active',
    ),
    OwnerData(
      id: 'OWN-004',
      name: 'Owner 04',
      phone: '+91 90000 00004',
      email: 'owner04@example.com',
      pets: 1,
      walks: 4,
      status: 'Inactive',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<OwnerData> get filteredOwners {
    final query =
        searchController.text.trim().toLowerCase();

    return owners.where((owner) {
      final matchesSearch =
          query.isEmpty ||
          owner.id.toLowerCase().contains(query) ||
          owner.name.toLowerCase().contains(query) ||
          owner.phone.toLowerCase().contains(query) ||
          owner.email.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          owner.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = owners
        .where((owner) => owner.status == 'Active')
        .length;

    final inactive = owners
        .where((owner) => owner.status == 'Inactive')
        .length;

    final totalPets =
        owners.fold<int>(0, (sum, owner) => sum + owner.pets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(
          active,
          inactive,
          totalPets,
        ),

        const SizedBox(height: 20),

        _toolbar(),

        const SizedBox(height: 16),

        _ownerList(),
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
          'Owners',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage all DOJO pet owners',
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
    int active,
    int inactive,
    int totalPets,
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
              title: 'Active Owners',
              value: '$active',
              icon: Icons.people_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Inactive Owners',
              value: '$inactive',
              icon: Icons.person_off_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total Pets',
              value: '$totalPets',
              icon: Icons.pets_outlined,
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
        hintText:
            'Search owner, phone or email...',
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
          borderRadius: BorderRadius.circular(11),
          borderSide:
              const BorderSide(color: dojoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide:
              const BorderSide(color: dojoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide:
              const BorderSide(color: dojoOrange),
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
        _filterButton('Active'),
        _filterButton('Inactive'),
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
            color: selected
                ? dojoOrange
                : dojoBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : dojoDark,
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
  // OWNER LIST
  // ==========================================================

  Widget _ownerList() {
    final list = filteredOwners;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((owner) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 12),
          child: _ownerCard(owner),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // OWNER CARD
  // ==========================================================

  Widget _ownerCard(OwnerData owner) {
    final active = owner.status == 'Active';

    final statusColor =
        active ? dojoGreen : dojoOrange;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(
              owner,
              statusColor,
            );
          }

          return _desktopCard(
            owner,
            statusColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    OwnerData owner,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(),

        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _mainInfo(owner),
        ),

        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            owner.phone,
          ),
        ),

        Expanded(
          child: _info(
            Icons.pets_outlined,
            'Pets',
            '${owner.pets}',
          ),
        ),

        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${owner.walks}',
          ),
        ),

        _statusChip(
          owner.status,
          statusColor,
        ),

        const SizedBox(width: 12),

        _viewButton(owner),
      ],
    );
  }

  Widget _mobileCard(
    OwnerData owner,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),

            const SizedBox(width: 12),

            Expanded(
              child: _mainInfo(owner),
            ),

            _statusChip(
              owner.status,
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
                owner.phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.pets_outlined,
                'Pets',
                '${owner.pets}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${owner.walks}',
              ),
            ),
            Expanded(
              child: _info(
                Icons.email_outlined,
                'Email',
                owner.email,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _viewButton(owner),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.person_outline,
        color: dojoBlue,
        size: 26,
      ),
    );
  }

  Widget _mainInfo(OwnerData owner) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          owner.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          owner.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          owner.email,
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

  Widget _viewButton(OwnerData owner) {
    return OutlinedButton.icon(
      onPressed: () {
        _showOwnerDetails(owner);
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
  // OWNER DETAILS
  // ==========================================================

  void _showOwnerDetails(OwnerData owner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: dojoBlue,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  owner.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow('Owner ID', owner.id),
              _detailRow('Phone', owner.phone),
              _detailRow('Email', owner.email),
              _detailRow('Pets', '${owner.pets}'),
              _detailRow('Walks', '${owner.walks}'),
              _detailRow('Status', owner.status),
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
            width: 70,
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
              Icons.people_outline,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No owners found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Owners will appear here.',
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

class OwnerData {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int pets;
  final int walks;
  final String status;

  const OwnerData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.pets,
    required this.walks,
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
